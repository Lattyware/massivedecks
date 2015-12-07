module MassiveDecks.Start where

import Task
import Maybe
import Effects
import Html exposing (Html)

import MassiveDecks.Models.State exposing (Model, State(..))
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.Models.State exposing (State(..), StartData, PlayingData, Error)
import MassiveDecks.UI.Start as UI
import MassiveDecks.Config as Config
import MassiveDecks.API as API
import MassiveDecks.Playing as Playing


update : Action -> List Error -> StartData -> (Model, Effects.Effects Action)
update action errors data = case action of
  UpdateInputValue input value ->
    case input of
      "name" -> (model errors { data | name = value }, Effects.none)
      "lobbyId" -> (model errors { data | lobbyId = value }, Effects.none)
      _ -> (model ((Error "Got an update for an unknown input.") :: errors) data, Effects.none)

  NewLobby Request ->
    (model errors data, API.createLobby |> Task.map (NewLobby << Result) |> API.toEffect)

  NewLobby (Result lobby) ->
    (model errors data,
      (API.newPlayer lobby.id data.name)
      |> Task.map (\secret -> JoinLobby lobby.id secret Request)
      |> API.toEffect)

  JoinExistingLobby ->
    (model errors data,
      (API.newPlayer data.lobbyId data.name)
      |> Task.map (\secret -> JoinLobby data.lobbyId secret Request)
      |> API.toEffect)

  JoinLobby lobbyId secret Request ->
    (model errors data,
      (API.getLobbyAndHand lobbyId secret)
      |> Task.map (\lobbyAndHand -> JoinLobby lobbyId secret (Result lobbyAndHand))
      |> API.toEffect)

  JoinLobby lobbyId secret (Result lobbyAndHand) ->
    case lobbyAndHand.lobby.round of
      Just _ -> (Playing.modelSub errors lobbyId secret (PlayingData lobbyAndHand.lobby lobbyAndHand.hand secret [] Nothing), Effects.none)
      Nothing -> (Config.modelSub errors lobbyId secret (Config.initialData lobbyAndHand.lobby secret), Effects.none)

  other ->
    (model (Error ("Got an action (" ++ (toString other) ++ ") that can't be handled in the current state (Start).") :: errors)
      data, Effects.none)


model : List Error -> StartData -> Model
model errors data =
  { state = SStart data
  , jsAction = Nothing
  , errors = errors
  }


initialData : StartData
initialData =
  { name = ""
  , lobbyId = ""
  }


view : Signal.Address Action -> List Error -> StartData -> Html
view address errors data = UI.view address errors data
