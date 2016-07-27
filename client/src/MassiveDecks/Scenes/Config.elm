module MassiveDecks.Scenes.Config exposing (update, view, init, subscriptions)

import String

import Html exposing (Html)
import Html.App as Html

import MassiveDecks.API as API
import MassiveDecks.API.Request as Request
import MassiveDecks.Components.Input as Input
import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Scenes.Lobby.Models as Lobby
import MassiveDecks.Scenes.Config.Messages exposing (ConsumerMessage(..), Message(..), InputId(..), Deck(..))
import MassiveDecks.Scenes.Config.Models exposing (Model)
import MassiveDecks.Scenes.Config.UI as UI
import MassiveDecks.Util as Util exposing ((:>))


{-| Create the initial model for the config screen.
-}
init : Model
init =
  { decks = []
  , deckIdInput = Input.initWithExtra DeckId "deck-id-input" UI.deckIdInputLabel "" "Play Code" UI.addDeckButton (Util.cmd AddDeck) InputMessage
  , passwordInput = Input.init Password "password-input" UI.passwordInputLabel "" "Password" (Cmd.none) InputMessage
  , loadingDecks = []
  }


{-| Subscriptions for the config screen.
-}
subscriptions : Model -> Sub ConsumerMessage
subscriptions model = Sub.none


{-| Render the config screen.
-}
view : Lobby.Model -> Html ConsumerMessage
view lobbyModel = UI.view lobbyModel |> Html.map LocalMessage


{-| Handles messages and alters the model as appropriate.
-}
update : Message -> Lobby.Model -> (Model, Cmd ConsumerMessage)
update message lobbyModel =
  let
    lobby = lobbyModel.lobby
    gameCode = lobbyModel.lobby.gameCode
    secret = lobbyModel.secret
    model = lobbyModel.config
  in
    case message of
      ConfigureDecks (Request rawDeckId) ->
        let
          deckId = String.toUpper rawDeckId
        in
          { model | loadingDecks = model.loadingDecks ++ [ deckId ] } !
            [ Request.send (API.addDeck gameCode secret deckId) (addDeckErrorHandler deckId) ErrorMessage (\_ -> (Add deckId) |> ConfigureDecks |> LocalMessage)
            , inputClearErrorCmd DeckId
            ]

      AddDeck ->
        (model, Util.cmd (LocalMessage (ConfigureDecks (Request model.deckIdInput.value))))

      ConfigureDecks (Add deckId) ->
        (removeDeckLoadingSpinner deckId model, Cmd.none)

      ConfigureDecks (Fail deckId errorMessage) ->
        (removeDeckLoadingSpinner deckId model, inputSetErrorCmd DeckId errorMessage)

      InputMessage message ->
        let
          (deckIdInput, msg) = Input.update message lobbyModel.config.deckIdInput
        in
          ({ model | deckIdInput = deckIdInput }, Cmd.map LocalMessage msg)

      AddAi ->
        (model, Request.send' (API.newAi gameCode secret) ErrorMessage (\_ -> LocalMessage NoOp))

      StartGame ->
        (model, Request.send (API.newGame gameCode secret) newGameErrorHandler ErrorMessage HandUpdate)

      EnableRule rule ->
        (model, Request.send' (API.enableRule rule gameCode secret) ErrorMessage ignore)

      DisableRule rule ->
        (model, Request.send' (API.disableRule rule gameCode secret) ErrorMessage ignore)

      NoOp ->
        (model, Cmd.none)


ignore : () -> ConsumerMessage
ignore = (\_ -> LocalMessage NoOp)


inputClearErrorCmd : InputId -> Cmd ConsumerMessage
inputClearErrorCmd inputId = (inputId, Nothing |> Input.Error) |> InputMessage |> LocalMessage |> Util.cmd


inputSetErrorCmd : InputId -> String -> Cmd ConsumerMessage
inputSetErrorCmd inputId error = (inputId, Just error |> Input.Error) |> InputMessage |> LocalMessage |> Util.cmd


removeDeckLoadingSpinner : String -> Model -> Model
removeDeckLoadingSpinner deckId model = { model | loadingDecks = List.filter ((/=) deckId) model.loadingDecks }


addDeckErrorHandler : String -> API.AddDeckError -> ConsumerMessage
addDeckErrorHandler deckId error =
  case error of
    API.CardcastTimeout ->
      ConfigureDecks (Fail deckId "There was a problem accessing CardCast, please try again after a short wait.") |> LocalMessage

    API.DeckNotFound ->
      ConfigureDecks (Fail deckId "The given play code doesn't exist, please check you have the correct code.") |> LocalMessage


newGameErrorHandler : API.NewGameError -> ConsumerMessage
newGameErrorHandler error =
  case error of
    API.GameInProgress -> ErrorMessage <| Errors.New "Can't start the game - it is already in progress." False
    API.NotEnoughPlayers required -> ErrorMessage <| Errors.New ("Can't start the game - you need at least " ++ (toString required) ++ " players to start the game.") False
