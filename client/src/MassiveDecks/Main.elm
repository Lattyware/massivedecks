module MassiveDecks.Main

  ( main

  ) where

import Task
import Effects
import Html exposing (Html)
import StartApp
import Json.Decode exposing (decodeString)
import Random

import MassiveDecks.Models.State exposing (Model, State(..), LobbyIdAndSecret, Error, Global, InitialState)
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.Models.Json.Decode exposing (lobbyDecoder)
import MassiveDecks.Util exposing (remove)
import MassiveDecks.States.Start as Start
import MassiveDecks.States.Config as Config
import MassiveDecks.States.Playing as Playing
import MassiveDecks.States.SharedUI.General as UI


{-| A wrapper for the model to wait for initial data before doing anything.
-}
type SetupModel
  = Waiting
  | Started Model


{-| The core game configuration.
-}
game : StartApp.App SetupModel
game = StartApp.start
  { init = (Waiting, Effects.none)
  , update = update
  , view = view
  , inputs = [ notificationDecoded, initialStateAction ]
  }


{-| A port to run tasks (e.g: http requests).
-}
port tasks : Signal (Task.Task Effects.Never ())
port tasks = game.tasks


{-| A port to get notifications about game changes from the websocket.
-}
port notifications : Signal String


{-| A port to allow the creation of and subscription to a websocket.
-}
port subscription : Signal (Maybe LobbyIdAndSecret)
port subscription
  = game.model
  |> Signal.map (\setupModel -> case setupModel of
      Waiting -> Nothing
      Started model -> Just model.subscription
    )
  |>  Signal.filterMap (Maybe.withDefault Nothing) Nothing


{-| A port to take in the initial state before the game starts.
Should only get one value, and should get it as soon as the game loads.
-}
port initialState : Signal InitialState


{-| Turn the data from the initial state port into an action to set the initial state.
-}
initialStateAction : Signal Action
initialStateAction = initialState |> Signal.map SetInitialState


{-| Decode inbound notifications ready to be fed into the game state as actions.
-}
notificationDecoded : Signal Action
notificationDecoded =
  notifications
  |> Signal.map (decodeString lobbyDecoder)
  |> Signal.filterMap (Result.toMaybe >> Just) Nothing
  |> Signal.map (\result -> case result of
      Just lobby -> Notification lobby
      Nothing -> NoAction)


{-| Run the game.
-}
main : Signal Html
main = game.html


{-| Produce a start state for the game based on the initial data.
-}
start : InitialState -> (Model, Effects.Effects Action)
start initialState =
  (Start.model (Global [] initialState (Random.initialSeed initialState.seed)) (Start.initialData (Maybe.withDefault "" initialState.gameCode)),
    case initialState.existingGame of
      Just existingGame ->
        if (Just existingGame.lobbyId == initialState.gameCode) then
          Task.succeed (JoinLobby existingGame.lobbyId existingGame.secret Request) |> Effects.task
        else
          Effects.none

      Nothing -> Effects.none
  )


{-| Change the state of the game as needed given the action.
-}
update : Action -> SetupModel -> (SetupModel, Effects.Effects Action)
update action setupModel =
  case setupModel of
    Waiting ->
      case action of
        SetInitialState initialState ->
          let
            (model, effects) = start initialState
          in
            (Started model, effects)

        _ ->
          (Waiting, Effects.none)

    Started model ->
      let
        result =
          case action of
            NoAction ->
              (model, Effects.none)

            Batch actions ->
              (model, List.map Task.succeed actions |> List.map Effects.task |> Effects.batch)

            DisplayError message ->
              let
                global = model.global
              in
                ({ model | global = { global | errors = Error message :: model.global.errors } }, Effects.none)

            RemoveErrorPanel index ->
              let
                global = model.global
              in
                ({ model | global = { global | errors = (remove model.global.errors index) } }, Effects.none)

            _ ->
              case model.state of
                SStart data ->
                  Start.update action model.global data

                SConfig data ->
                  Config.update action model.global data

                SPlaying data ->
                  Playing.update action model.global data
      in
        (Started (fst result), (snd result))


{-| Render the game.
-}
view : Signal.Address Action -> SetupModel -> Html
view address setupModel =
  case setupModel of
    Waiting -> UI.spinner

    Started model ->
      case model.state of
        SStart data ->
          Start.view address model.global data

        SConfig data ->
          Config.view address model.global data

        SPlaying data ->
          Playing.view address model.global data
