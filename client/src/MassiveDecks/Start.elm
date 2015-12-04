module MassiveDecks.Start where

import Task
import Maybe
import Effects
import Html exposing (Html)

import MassiveDecks.Models.State exposing (Model, State(..))
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.Models.State exposing (State(..), StartData, PlayingData)
import MassiveDecks.UI.Start as UI
import MassiveDecks.Config as Config
import MassiveDecks.API as API
import MassiveDecks.Playing as Playing


update : Action -> Maybe String -> StartData -> (Model, Effects.Effects Action)
update action error data = case action of
  UpdateInputValue input value ->
    case input of
      "name" -> (model error { data | name = value }, Effects.none)
      "lobbyId" -> (model error { data | lobbyId = value }, Effects.none)
      _ -> (model (Just "Got an update for an unknown input.") data, Effects.none)

  NewLobby Request ->
    (model error data, API.createLobby |> Task.map (NewLobby << Result) |> API.toEffect)

  NewLobby (Result lobby) ->
    (model error data,
      (API.newPlayer lobby.id data.name)
      |> Task.map (\secret -> JoinLobby lobby.id secret Request)
      |> API.toEffect)

  JoinExistingLobby ->
    (model error data,
      (API.newPlayer data.lobbyId data.name)
      |> Task.map (\secret -> JoinLobby data.lobbyId secret Request)
      |> API.toEffect)

  JoinLobby lobbyId secret Request ->
    (model error data,
      (API.getLobbyAndHand lobbyId secret)
      |> Task.map (\lobbyAndHand -> JoinLobby lobbyId secret (Result lobbyAndHand))
      |> API.toEffect)

  JoinLobby lobbyId secret (Result lobbyAndHand) ->
    case lobbyAndHand.lobby.round of
      Just _ -> (Playing.modelSub error lobbyId secret (PlayingData lobbyAndHand.lobby lobbyAndHand.hand secret []), Effects.none)
      Nothing -> (Config.modelSub error lobbyId secret (Config.initialData lobbyAndHand.lobby secret), Effects.none)

  other ->
    (model (Just ("Got an action (" ++ (toString other) ++ ") that can't be handled in the current state (Start)."))
      data, Effects.none)


model : Maybe String -> StartData -> Model
model error data =
  { state = SStart data
  , jsAction = Nothing
  , error = error
  }


initialData : StartData
initialData =
  { name = ""
  , lobbyId = ""
  }


view : Signal.Address Action -> Maybe String -> StartData -> Html
view address error data = UI.view address error
