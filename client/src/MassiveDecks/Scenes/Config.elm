module MassiveDecks.Scenes.Config exposing (update, view, init, subscriptions)

import String

import Html exposing (Html)
import Html.App as Html

import MassiveDecks.API as API
import MassiveDecks.API.Request as Request
import MassiveDecks.Components.Input as Input
import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Models.Game as Game
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
  , deckIdInput = Input.initWithExtra DeckId "deck-id-input" UI.deckIdInputLabel "" "Play Code" UI.addDeckButton InputMessage
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
update : Message -> Lobby.Model -> (Lobby.Model, Cmd ConsumerMessage)
update message lobbyModel =
  let
    gameCode = lobbyModel.lobbyAndHand.lobby.gameCode
    secret = lobbyModel.secret
  in
    case message of
      ConfigureDecks (Request rawDeckId) ->
        let
          deckId = String.toUpper rawDeckId
        in
          lobbyModel
            |> updateConfig (\model -> ({ model | loadingDecks = model.loadingDecks ++ [ deckId ] }, Cmd.none))
            :> cmd (Request.send (API.addDeck gameCode secret deckId)
                                  (addDeckErrorHandler deckId)
                                  ErrorMessage
                                  ((Add deckId) >> ConfigureDecks >> LocalMessage))
            :> clearDeckIdError

      ConfigureDecks (Add deckId lobbyAndHand) ->
        lobbyModel
          |> updateLobbyAndHand lobbyAndHand
          :> removeDeckLoadingSpinner deckId

      ConfigureDecks (Fail deckId errorMessage) ->
        lobbyModel
          |> deckIdError errorMessage
          :> removeDeckLoadingSpinner deckId

      InputMessage message ->
        lobbyModel
          |> updateDeckIdInput (Input.update message lobbyModel.config.deckIdInput)

      AddAi ->
        lobbyModel
          |> cmd (Request.send' (API.newAi gameCode) ErrorMessage (\_ -> LocalMessage NoOp))

      StartGame ->
        lobbyModel
          |> cmd (Request.send (API.newGame gameCode secret) newGameErrorHandler ErrorMessage (GameStarted >> LocalMessage))

      GameStarted lobbyAndHand ->
        lobbyModel
          |> updateLobbyAndHand lobbyAndHand

      NoOp ->
        (lobbyModel, Cmd.none)


type alias Update = Lobby.Model -> (Lobby.Model, Cmd ConsumerMessage)


clearDeckIdError : Update
clearDeckIdError lobbyModel = (lobbyModel, (DeckId, Nothing |> Input.Error) |> InputMessage |> LocalMessage |> Util.cmd)


deckIdError : String -> Update
deckIdError error lobbyModel = (lobbyModel, (DeckId, Just error |> Input.Error) |> InputMessage |> LocalMessage |> Util.cmd)


cmd : Cmd ConsumerMessage -> Update
cmd command lobbyModel = (lobbyModel, command)


updateLobbyAndHand : Game.LobbyAndHand -> Update
updateLobbyAndHand lobbyAndHand lobbyModel = ({ lobbyModel | lobbyAndHand = lobbyAndHand }, Cmd.none)


updateConfig : (Model -> (Model, Cmd ConsumerMessage)) -> Update
updateConfig update lobbyModel =
  let
    result = update lobbyModel.config
  in
    ({ lobbyModel | config = fst result }, snd result)


removeDeckLoadingSpinner : String -> Update
removeDeckLoadingSpinner deckId =
  updateConfig (\model -> ({ model | loadingDecks = List.filter ((/=) deckId) model.loadingDecks }, Cmd.none))


updateDeckIdInput : (Input.Model InputId Message, Cmd Message) -> Update
updateDeckIdInput update lobbyModel =
  updateConfig (\model -> ({ model | deckIdInput = fst update }, snd update |> Cmd.map LocalMessage)) lobbyModel


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
