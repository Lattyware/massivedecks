module MassiveDecks.Scenes.Start exposing (update, view, init, subscriptions)

import Html exposing (..)
import Html.App as Html

import MassiveDecks.Models exposing (Init)
import MassiveDecks.Models.Game as Game
import MassiveDecks.Components.Tabs as Tabs
import MassiveDecks.Components.Storage as Storage
import MassiveDecks.Components.Input as Input
import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Components.Overlay as Overlay
import MassiveDecks.Scenes.Start.Messages exposing (InputId(..), Message(..), Tab(..))
import MassiveDecks.Scenes.Start.Models exposing (Model)
import MassiveDecks.Scenes.Start.UI as UI
import MassiveDecks.Scenes.Lobby as Lobby
import MassiveDecks.Scenes.Lobby.Messages as Lobby
import MassiveDecks.API as API
import MassiveDecks.API.Request as Request
import MassiveDecks.Util as Util


{-| Create the initial model for the start screen.
-}
init : Init -> (Model, Cmd Message)
init init =
  let
    command = case init.existingGame of
      Just existingGame ->
        Util.cmd (JoinLobbyAsExistingPlayer existingGame.secret existingGame.gameCode)

      Nothing ->
        Cmd.none
  in
    ( { lobby = Nothing
      , init = init
      , nameInput = Input.init Name "name-input" [ text "Your name in the game." ] "" "Nickname" (Util.cmd SubmitCurrentTab) InputMessage
      , gameCodeInput = Input.init GameCode "game-code-input" [ text "The code for the game to join." ] (init.gameCode |> Maybe.withDefault "") "" (Util.cmd JoinLobbyAsNewPlayer) InputMessage
      , info = Nothing
      , errors = Errors.init
      , overlay = Overlay.init OverlayMessage
      , buttonsEnabled = True
      , tabs = Tabs.init [ Tabs.Tab Create [ text "Create" ], Tabs.Tab Join [ text "Join" ] ] Create TabsMessage
      }
    , command)


{-| Subscriptions for the start screen.
-}
subscriptions : Model -> Sub Message
subscriptions model =
  case model.lobby of
    Nothing ->
      Sub.none

    Just lobby ->
      Lobby.subscriptions lobby |> Sub.map LobbyMessage


{-| Render the start scene.
-}
view : Model -> Html Message
view model =
  let
    contents = case model.lobby of
      Nothing ->
        UI.view model

      Just lobby ->
        Html.map LobbyMessage (Lobby.view lobby)
  in
    div []
        ([ contents
         , Errors.view { url = model.init.url, version = model.init.version } model.errors |> Html.map ErrorMessage
         ] ++ Overlay.view model.overlay)


{-| Handles messages and alters the model as appropriate.
-}
update : Message -> Model -> (Model, Cmd Message)
update message model =
  case message of
    ErrorMessage message ->
      let
        (newErrors, cmd) = Errors.update message model.errors
      in
        ({ model | errors = newErrors }, Cmd.map ErrorMessage cmd)

    TabsMessage tabsMessage ->
      ({ model | tabs = (Tabs.update tabsMessage model.tabs) }, Cmd.none)

    ShowInfoMessage message ->
      ({ model | info = Just message }, Cmd.none)

    ClearExistingGame ->
      model ! [ "The game you were in has ended." |> ShowInfoMessage |> Util.cmd, Storage.storeLeftGame ]

    CreateLobby ->
      ({ model | buttonsEnabled = False }, Request.send' API.createLobby ErrorMessage (\lobby -> JoinGivenLobbyAsNewPlayer lobby.gameCode))

    SubmitCurrentTab ->
      case model.tabs.current of
        Create ->
          (model, Util.cmd CreateLobby)

        Join ->
          (model, Util.cmd JoinLobbyAsNewPlayer)

    SetButtonsEnabled enabled ->
      ({ model | buttonsEnabled = enabled }, Cmd.none)

    JoinLobbyAsNewPlayer ->
      ({ model | buttonsEnabled = False }, Util.cmd (JoinGivenLobbyAsNewPlayer model.gameCodeInput.value))

    JoinGivenLobbyAsNewPlayer gameCode ->
      (model, Request.send (API.newPlayer gameCode model.nameInput.value) newPlayerErrorHandler ErrorMessage (\secret -> JoinLobbyAsExistingPlayer secret gameCode))

    JoinLobbyAsExistingPlayer secret gameCode ->
      model !
        [ Request.send (API.getLobbyAndHand gameCode secret) getLobbyAndHandErrorHandler ErrorMessage (JoinLobby secret)
        , Storage.storeInGame (Game.GameCodeAndSecret gameCode secret)
        ]

    JoinLobby secret lobbyAndHand ->
      let
        (lobby, cmd) = Lobby.init model.init lobbyAndHand secret
      in
        ({ model | lobby = Just lobby }, cmd |> Cmd.map LobbyMessage)

    InputMessage message ->
      let
        (nameInput, nameCmd) = Input.update message model.nameInput
        (gameCodeInput, gameCodeCmd) = Input.update message model.gameCodeInput
      in
        ({ model | nameInput = nameInput
                 , gameCodeInput = gameCodeInput
         }, Cmd.batch [ nameCmd, gameCodeCmd ])

    OverlayMessage overlayMessage ->
      ({ model | overlay = Overlay.update overlayMessage model.overlay }, Cmd.none)

    LobbyMessage message ->
      case message of
        Lobby.ErrorMessage message ->
          (model, Util.cmd (ErrorMessage message))

        Lobby.OverlayMessage message ->
          (model, Util.cmd (OverlayMessage (Overlay.map (Lobby.LocalMessage >> LobbyMessage) message)))

        Lobby.Leave ->
          let
            leave = case model.lobby of
              Nothing -> []
              Just lobby -> [ Request.send' (API.leave lobby.lobby.gameCode lobby.secret) ErrorMessage (\_ -> NoOp) ]
          in
            { model | lobby = Nothing
                    , buttonsEnabled = True } ! ([ Storage.storeLeftGame ] ++ leave)

        Lobby.LocalMessage message ->
          case model.lobby of
            Nothing ->
              (model, Cmd.none)

            Just lobby ->
              let
                (newLobby, cmd) = Lobby.update message lobby
              in
                ({ model | lobby = Just newLobby }, Cmd.map LobbyMessage cmd)

    Batch messages ->
      (model, messages |> List.map Util.cmd |> Cmd.batch)

    NoOp ->
      (model, Cmd.none)


newPlayerErrorHandler : API.NewPlayerError -> Message
newPlayerErrorHandler error =
  let
    errorMessage = case error of
      API.NameInUse -> (Name, Just "This name is already in use in this game, try something else." |> Input.Error) |> InputMessage
      API.NewPlayerLobbyNotFound -> (GameCode, Just "This game doesn't exist - check you have the right code." |> Input.Error) |> InputMessage
  in
    Batch [ SetButtonsEnabled True, errorMessage ]


getLobbyAndHandErrorHandler : API.GetLobbyAndHandError -> Message
getLobbyAndHandErrorHandler error =
  let
    errorMessage = case error of
      API.LobbyNotFound -> ClearExistingGame
  in
    Batch [ SetButtonsEnabled True, errorMessage ]
