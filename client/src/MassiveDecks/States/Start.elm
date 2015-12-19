module MassiveDecks.States.Start where

import Task
import Maybe
import Effects
import Html exposing (Html)

import MassiveDecks.API as API
import MassiveDecks.API.Request as Request
import MassiveDecks.Models.State exposing (Model, State(..))
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..), catchUpEffects)
import MassiveDecks.Models.State exposing (State(..), StartData, playingData, Error, Global)
import MassiveDecks.States.Start.UI as UI
import MassiveDecks.States.Config as Config
import MassiveDecks.States.Playing as Playing


update : Action -> Global -> StartData -> (Model, Effects.Effects Action)
update action global data = case action of
  UpdateInputValue input value ->
    case input of
      "name" -> (model global { data | name = value }, Effects.none)
      "lobbyId" -> (model global { data | lobbyId = value }, Effects.none)
      _ -> (model global data, DisplayError "Got an update for an unknown input." |> Task.succeed |> Effects.task)

  NewLobby Request ->
    (model global data, API.createLobby
      |> Request.toEffect (\error -> DisplayError (toString error)) (NewLobby << Result))

  NewLobby (Result lobby) ->
    (model global data,
      (API.newPlayer lobby.id data.name)
        |> Request.toEffect (\error -> DisplayError (toString error)) (\secret -> JoinLobby lobby.id secret Request))

  JoinExistingLobby ->
    (model global data,
      (API.newPlayer data.lobbyId data.name)
        |> Request.toEffect (\error -> DisplayError (toString error)) (\secret -> JoinLobby data.lobbyId secret Request))

  JoinLobby lobbyId secret Request ->
    (model global data,
      (API.getLobbyAndHand lobbyId secret)
        |> Request.toEffect (\error -> DisplayError (toString error)) (\lobbyAndHand -> JoinLobby lobbyId secret (Result lobbyAndHand)))

  JoinLobby lobbyId secret (Result lobbyAndHand) ->
    case lobbyAndHand.lobby.round of
      Just _ ->
        ( Playing.modelSub global lobbyId secret (playingData lobbyAndHand.lobby lobbyAndHand.hand secret)
        , catchUpEffects lobbyAndHand.lobby
        )

      Nothing ->
        (Config.modelSub global lobbyId secret
          (Config.initialData lobbyAndHand.lobby secret), Effects.none)

  Notification _ ->
    (model global data, Effects.none)

  DismissPlayerNotification _ ->
    (model global data, Effects.none)

  other ->
    (model global data,
      DisplayError ("Got an action (" ++ (toString other) ++ ") that can't be handled in the current state (Start).")
      |> Task.succeed
      |> Effects.task)


model : Global -> StartData -> Model
model global data =
  { state = SStart data
  , subscription = Nothing
  , global = global
  }


initialData : String -> StartData
initialData lobbyId =
  { name = ""
  , lobbyId = lobbyId
  }


view : Signal.Address Action -> Global -> StartData -> Html
view address global data = UI.view address global data
