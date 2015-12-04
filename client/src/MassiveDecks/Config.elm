module MassiveDecks.Config where

import Task
import Effects
import Html exposing (Html)

import MassiveDecks.Models.Player exposing (Secret)
import MassiveDecks.Models.Game exposing (Lobby)
import MassiveDecks.Models.State exposing (Model, State(..), ConfigData, PlayingData)
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.UI.Config as UI
import MassiveDecks.API as API
import MassiveDecks.Playing as Playing


update : Action -> Maybe String -> ConfigData -> (Model, Effects.Effects Action)
update action error data = case action of
  UpdateInputValue input value ->
    case input of
      "deckId" -> (model error { data | deckId = value }, Effects.none)
      _ -> (model (Just "Got an update for an unknown input.") data, Effects.none)

  AddDeck Request ->
    (model error data,
      (API.addDeck data.lobby.id data.secret data.deckId)
      |> Task.map (AddDeck << Result)
      |> API.toEffect)

  AddDeck (Result lobbyAndHand) ->
    (model error { data | lobby = lobbyAndHand.lobby }, Effects.none)

  StartGame Request ->
    (model error data, (API.newGame data.lobby.id data.secret) |> Task.map (StartGame << Result) |> API.toEffect)

  StartGame (Result lobbyAndHand) ->
    (Playing.model error (PlayingData lobbyAndHand.lobby lobbyAndHand.hand data.secret []), Effects.none)

  Notification lobby ->
    case lobby.round of
      Just _ -> (model error data,
        (API.getLobbyAndHand lobby.id data.secret)
        |> Task.map (\lobbyAndHand -> JoinLobby lobby.id data.secret (Result lobbyAndHand))
        |> API.toEffect)
      Nothing -> (model error { data | lobby = lobby }, Effects.none)

  JoinLobby lobbyId secret (Result lobbyAndHand) ->
    case lobbyAndHand.lobby.round of
      Just _ -> (Playing.model error (PlayingData lobbyAndHand.lobby lobbyAndHand.hand secret []), Effects.none)
      Nothing -> (model error { data | lobby = lobbyAndHand.lobby }, Effects.none)

  other ->
    (model (Just ("Got an action (" ++ (toString other) ++ ") that can't be handled in the current state (Config)."))
      data, Effects.none)


model : Maybe String -> ConfigData -> Model
model error data =
  { state = SConfig data
  , jsAction = Nothing
  , error = error
  }


modelSub : Maybe String -> String -> Secret -> ConfigData -> Model
modelSub error lobbyId secret data =
  { state = SConfig data
  , jsAction = Just { lobbyId = lobbyId, secret = secret }
  , error = error
  }


initialData : Lobby -> Secret -> ConfigData
initialData lobby secret =
  { lobby = lobby
  , secret = secret
  , deckId = ""
  }


view : Signal.Address Action -> Maybe String -> ConfigData -> Html
view address error data = UI.view address data error
