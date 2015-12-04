module MassiveDecks.Main where

import Task
import Effects
import Html exposing (Html)
import StartApp
import Json.Decode exposing (decodeString)

import MassiveDecks.Models.State exposing (Model, State(..), LobbyIdAndSecret)
import MassiveDecks.Actions.Action exposing (Action(..))
import MassiveDecks.Start as Start
import MassiveDecks.Config as Config
import MassiveDecks.Playing as Playing
import MassiveDecks.Models.Json.Decode exposing (lobbyDecoder)


game : StartApp.App Model
game = StartApp.start
  { init = (model, Effects.none)
  , update = update
  , view = view
  , inputs = [ notificationDecoded ]
  }


port tasks : Signal (Task.Task Effects.Never ())
port tasks = game.tasks


port notifications : Signal String


port jsAction : Signal (Maybe LobbyIdAndSecret)
port jsAction = Signal.filterMap (.jsAction >> Just) Nothing game.model


notificationDecoded : Signal Action
notificationDecoded =
  notifications
  |> Signal.map (decodeString lobbyDecoder)
  |> Signal.filterMap (Result.toMaybe >> Just) Nothing
  |> Signal.map (\result -> case result of
      Just lobby -> Notification lobby
      Nothing -> NoAction)


main : Signal Html
main = game.html


model : Model
model = Start.model Maybe.Nothing Start.initialData


debug : Bool
debug = False


update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  let
    model = if (debug) then { model | error = Just (toString action) } else model
  in
    case action of
      NoAction ->
        (model, Effects.none)

      DisplayError message ->
        ({ model | error = Just message }, Effects.none)

      _ ->
        case model.state of
          SStart data ->
            Start.update action model.error data

          SConfig data ->
            Config.update action model.error data

          SPlaying data ->
            Playing.update action model.error data


view : Signal.Address Action -> Model -> Html
view address model = case model.state of
  SStart data ->
    Start.view address model.error data

  SConfig data ->
    Config.view address model.error data

  SPlaying data ->
    Playing.view address model.error data
