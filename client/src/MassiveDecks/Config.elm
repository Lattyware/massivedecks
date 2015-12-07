module MassiveDecks.Config where

import Task
import Effects
import Html exposing (Html)

import MassiveDecks.Models.Player exposing (Secret)
import MassiveDecks.Models.Game exposing (Lobby)
import MassiveDecks.Models.State exposing (Model, State(..), ConfigData, PlayingData, Error)
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.UI.Config as UI
import MassiveDecks.API as API
import MassiveDecks.Playing as Playing


update : Action -> List Error -> ConfigData -> (Model, Effects.Effects Action)
update action errors data = case action of
  UpdateInputValue input value ->
    case input of
      "deckId" -> (model errors { data | deckId = value }, Effects.none)
      _ -> (model ((Error "Got an update for an unknown input.") :: errors) data, Effects.none)

  AddDeck Request ->
    (model errors data,
      (API.addDeck data.lobby.id data.secret data.deckId)
      |> Task.map (AddDeck << Result)
      |> API.toEffect)

  AddDeck (Result lobbyAndHand) ->
    (model errors { data | lobby = lobbyAndHand.lobby }, Effects.none)

  StartGame Request ->
    (model errors data, (API.newGame data.lobby.id data.secret) |> Task.map (StartGame << Result) |> API.toEffect)

  StartGame (Result lobbyAndHand) ->
    (Playing.model errors (PlayingData lobbyAndHand.lobby lobbyAndHand.hand data.secret [] Nothing), Effects.none)

  Notification lobby ->
    case lobby.round of
      Just _ -> (model errors data,
        (API.getLobbyAndHand lobby.id data.secret)
        |> Task.map (\lobbyAndHand -> JoinLobby lobby.id data.secret (Result lobbyAndHand))
        |> API.toEffect)
      Nothing -> (model errors { data | lobby = lobby }, Effects.none)

  JoinLobby lobbyId secret (Result lobbyAndHand) ->
    case lobbyAndHand.lobby.round of
      Just _ -> (Playing.model errors (PlayingData lobbyAndHand.lobby lobbyAndHand.hand secret [] Nothing), Effects.none)
      Nothing -> (model errors { data | lobby = lobbyAndHand.lobby }, Effects.none)

  other ->
    (model (Error ("Got an action (" ++ (toString other) ++ ") that can't be handled in the current state (Config).") :: errors)
      data, Effects.none)


model : List Error -> ConfigData -> Model
model errors data =
  { state = SConfig data
  , jsAction = Nothing
  , errors = errors
  }


modelSub : List Error -> String -> Secret -> ConfigData -> Model
modelSub errors lobbyId secret data =
  { state = SConfig data
  , jsAction = Just { lobbyId = lobbyId, secret = secret }
  , errors = errors
  }


initialData : Lobby -> Secret -> ConfigData
initialData lobby secret =
  { lobby = lobby
  , secret = secret
  , deckId = ""
  }


view : Signal.Address Action -> List Error -> ConfigData -> Html
view address errors data = UI.view address data errors
