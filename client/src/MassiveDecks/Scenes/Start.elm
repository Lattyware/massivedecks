module MassiveDecks.Scenes.Start exposing (update, urlUpdate, view, init, subscriptions)

import String
import Html exposing (..)
import Navigation
import MassiveDecks.Models exposing (Init, Path, pathFromLocation)
import MassiveDecks.Models.Game as Game
import MassiveDecks.Components.Tabs as Tabs
import MassiveDecks.Components.Storage as Storage
import MassiveDecks.Components.Input as Input
import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Components.Overlay as Overlay exposing (Overlay)
import MassiveDecks.Components.Title as Title
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
init : Init -> Navigation.Location -> ( Model, Cmd Message )
init init location =
    let
        path =
            pathFromLocation location

        tab =
            if path.gameCode |> Maybe.withDefault "" |> String.isEmpty then
                Create
            else
                Join
    in
        ( { lobby = Nothing
          , init = init
          , path = path
          , nameInput = Input.init Name "name-input" [ text "Your name in the game." ] "" "Nickname" (Util.cmd SubmitCurrentTab) InputMessage
          , gameCodeInput = Input.init GameCode "game-code-input" [ text "The code for the game to join." ] (path.gameCode |> Maybe.withDefault "") "" (Util.cmd JoinLobbyAsNewPlayer) InputMessage
          , passwordInput = Input.init Password "password-input" [ text "The password for the game to join." ] "" "Password" (Util.cmd JoinLobbyAsNewPlayer) InputMessage
          , passwordRequired = Nothing
          , errors = Errors.init
          , overlay = Overlay.init OverlayMessage
          , buttonsEnabled = True
          , tabs = Tabs.init [ Tabs.Tab Create [ text "Create" ], Tabs.Tab Join [ text "Join" ] ] tab TabsMessage
          , storage = init.existingGames
          }
        , Maybe.map (TryExistingGame >> Util.cmd) path.gameCode |> Maybe.withDefault Cmd.none
        )


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
        contents =
            case model.lobby of
                Nothing ->
                    UI.view model

                Just lobby ->
                    Html.map LobbyMessage (Lobby.view lobby)
    in
        div []
            ([ contents
             , Errors.view { url = model.init.url, version = model.init.version } model.errors |> Html.map ErrorMessage
             ]
                ++ Overlay.view model.overlay
            )


{-| Handles changes to the url.
-}
urlUpdate : Path -> Model -> ( Model, Cmd Message )
urlUpdate path model =
    let
        noGameCode =
            case path.gameCode of
                Just _ ->
                    False

                Nothing ->
                    True

        setInput =
            path.gameCode |> Maybe.map (\gameCode -> ( GameCode, Input.SetDefaultValue gameCode ) |> InputMessage |> Util.cmd)
    in
        { model
            | path = path
            , lobby =
                if noGameCode then
                    Nothing
                else
                    model.lobby
            , buttonsEnabled = True
        }
            ! [ (if noGameCode then
                    Cmd.none
                 else
                    Tabs.SetTab Join |> TabsMessage |> Util.cmd
                )
              , setInput
                    |> Maybe.withDefault Cmd.none
              , path.gameCode
                    |> Maybe.map (\gc -> Title.set ("Game " ++ gc ++ " - " ++ title))
                    |> Maybe.withDefault (Title.set title)
              , path.gameCode
                    |> Maybe.map (TryExistingGame >> Util.cmd)
                    |> Maybe.withDefault Cmd.none
              ]


{-| Handles messages and alters the model as appropriate.
-}
update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        ErrorMessage message ->
            let
                ( newErrors, cmd ) =
                    Errors.update message model.errors
            in
                ( { model | errors = newErrors }, Cmd.map ErrorMessage cmd )

        PathChange path ->
            urlUpdate path model

        TabsMessage tabsMessage ->
            ( { model | tabs = (Tabs.update tabsMessage model.tabs) }, Cmd.none )

        ClearExistingGame existingGame ->
            { model | storage = Storage.leave existingGame model.storage }
                ! [ Overlay "info-circle" "Game over." [ text ("The game " ++ existingGame.gameCode ++ " has ended.") ]
                        |> Overlay.Show
                        |> OverlayMessage
                        |> Util.cmd
                  , Storage.Store |> StorageMessage |> Util.cmd
                  , Navigation.newUrl model.init.url
                  ]

        TryExistingGame gameCode ->
            let
                existing =
                    List.filter (.gameCode >> ((==) gameCode)) model.storage |> List.head

                cmd =
                    Maybe.map (\existing -> JoinLobbyAsExistingPlayer existing.secret existing.gameCode |> Util.cmd) existing
                        |> Maybe.withDefault (Navigation.modifyUrl model.init.url)
            in
                ( model, cmd )

        CreateLobby ->
            ( { model | buttonsEnabled = False }
            , Request.send_
                (API.createLobby model.nameInput.value)
                ErrorMessage
                (\gameCodeAndSecret -> StoreCredentialsAndMoveToLobby gameCodeAndSecret.gameCode gameCodeAndSecret.secret)
            )

        SubmitCurrentTab ->
            case model.tabs.current of
                Create ->
                    ( model, Util.cmd CreateLobby )

                Join ->
                    ( model, Util.cmd JoinLobbyAsNewPlayer )

        SetButtonsEnabled enabled ->
            ( { model | buttonsEnabled = enabled }, Cmd.none )

        SetPasswordRequired ->
            ( { model | passwordRequired = Just model.gameCodeInput.value }, Cmd.none )

        JoinLobbyAsNewPlayer ->
            ( { model | buttonsEnabled = False }, Util.cmd (JoinGivenLobbyAsNewPlayer model.gameCodeInput.value) )

        JoinGivenLobbyAsNewPlayer gameCode ->
            case List.filter (.gameCode >> ((==) gameCode)) model.storage |> List.head of
                Nothing ->
                    model
                        ! [ Request.send (API.newPlayer gameCode model.nameInput.value model.passwordInput.value)
                                newPlayerErrorHandler
                                ErrorMessage
                                (StoreCredentialsAndMoveToLobby gameCode)
                          ]

                Just _ ->
                    model
                        ! [ MoveToLobby gameCode |> Util.cmd
                          , UI.alreadyInGameOverlay
                                |> Overlay.Show
                                |> OverlayMessage
                                |> Util.cmd
                          ]

        StoreCredentialsAndMoveToLobby gameCode secret ->
            { model | storage = Storage.join (Game.GameCodeAndSecret gameCode secret) model.storage }
                ! [ Storage.Store |> StorageMessage |> Util.cmd
                  , MoveToLobby gameCode |> Util.cmd
                  ]

        MoveToLobby gameCode ->
            model ! [ Navigation.newUrl (model.init.url ++ "#" ++ gameCode) ]

        JoinLobbyAsExistingPlayer secret gameCode ->
            model
                ! [ Request.send (API.getLobbyAndHand gameCode secret)
                        (getLobbyAndHandErrorHandler (Game.GameCodeAndSecret gameCode secret))
                        ErrorMessage
                        (JoinLobby secret)
                  ]

        JoinLobby secret lobbyAndHand ->
            let
                ( lobby, cmd ) =
                    Lobby.init model.init lobbyAndHand secret
            in
                { model | lobby = Just lobby }
                    ! [ cmd |> Cmd.map LobbyMessage
                      ]

        InputMessage message ->
            let
                ( nameInput, nameCmd ) =
                    Input.update message model.nameInput

                ( gameCodeInput, gameCodeCmd ) =
                    Input.update message model.gameCodeInput

                ( passwordInput, passwordCmd ) =
                    Input.update message model.passwordInput
            in
                ( { model
                    | nameInput = nameInput
                    , gameCodeInput = gameCodeInput
                    , passwordInput = passwordInput
                  }
                , Cmd.batch [ nameCmd, gameCodeCmd, passwordCmd ]
                )

        OverlayMessage overlayMessage ->
            ( { model | overlay = Overlay.update overlayMessage model.overlay }, Cmd.none )

        StorageMessage storageMessage ->
            let
                ( storageModel, cmd ) =
                    Storage.update storageMessage model.storage
            in
                ( { model | storage = storageModel }, cmd |> Cmd.map StorageMessage )

        LobbyMessage message ->
            case message of
                Lobby.ErrorMessage message ->
                    ( model, Util.cmd (ErrorMessage message) )

                Lobby.OverlayMessage message ->
                    ( model, Util.cmd (OverlayMessage (Overlay.map (Lobby.LocalMessage >> LobbyMessage) message)) )

                Lobby.Leave ->
                    let
                        ( leave, storage ) =
                            case model.lobby of
                                Nothing ->
                                    ( [], model.storage )

                                Just lobby ->
                                    ( [ Request.send_ (API.leave lobby.lobby.gameCode lobby.secret) ErrorMessage (\_ -> NoOp)
                                      , Storage.Store |> StorageMessage |> Util.cmd
                                      ]
                                    , Storage.leave (Game.GameCodeAndSecret lobby.lobby.gameCode lobby.secret) model.storage
                                    )
                    in
                        { model
                            | lobby = Nothing
                            , buttonsEnabled = True
                            , storage = storage
                        }
                            ! ([ Navigation.newUrl model.init.url
                               ]
                                ++ leave
                              )

                Lobby.LocalMessage message ->
                    case model.lobby of
                        Nothing ->
                            ( model, Cmd.none )

                        Just lobby ->
                            let
                                ( newLobby, cmd ) =
                                    Lobby.update message lobby
                            in
                                ( { model | lobby = Just newLobby }, Cmd.map LobbyMessage cmd )

        Batch messages ->
            ( model, messages |> List.map Util.cmd |> Cmd.batch )

        NoOp ->
            ( model, Cmd.none )


title : String
title =
    "Massive Decks"


newPlayerErrorHandler : API.NewPlayerError -> Message
newPlayerErrorHandler error =
    let
        errorMessage =
            case error of
                API.NameInUse ->
                    ( Name, Just "This name is already in use in this game, try something else." |> Input.Error ) |> InputMessage

                API.PasswordWrong ->
                    Batch
                        [ SetPasswordRequired
                        , ( Password, Just "This game requires a password, please check you have the right one." |> Input.Error ) |> InputMessage
                        ]

                API.NewPlayerLobbyNotFound ->
                    ( GameCode, Just "This game doesn't exist - check you have the right code." |> Input.Error ) |> InputMessage
    in
        Batch [ SetButtonsEnabled True, errorMessage ]


getLobbyAndHandErrorHandler : Game.GameCodeAndSecret -> API.GetLobbyAndHandError -> Message
getLobbyAndHandErrorHandler gameCodeAndSecret error =
    let
        errorMessage =
            case error of
                API.LobbyNotFound ->
                    ClearExistingGame gameCodeAndSecret

                API.SecretWrongOrNotAPlayer ->
                    ClearExistingGame gameCodeAndSecret
    in
        Batch [ SetButtonsEnabled True, errorMessage ]
