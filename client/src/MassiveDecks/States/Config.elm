module MassiveDecks.States.Config where

import Task
import Effects
import Html exposing (Html)

import MassiveDecks.States.Config.UI as UI
import MassiveDecks.Models.Player exposing (Secret)
import MassiveDecks.Models.Game exposing (Lobby)
import MassiveDecks.Models.State exposing (Model, State(..), ConfigData, PlayingData, Error, Global)
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..), eventEffects)
import MassiveDecks.API as API
import MassiveDecks.States.Playing as Playing


update : Action -> Global -> ConfigData -> (Model, Effects.Effects Action)
update action global data = case action of
  UpdateInputValue input value ->
    case input of
      "deckId" -> (model global { data | deckId = value }, Effects.none)
      _ -> (model global data, DisplayError "Got an update for an unknown input." |> Task.succeed |> Effects.task)

  AddDeck Request ->
    (model global data,
      (API.addDeck data.lobby.id data.secret data.deckId)
      |> Task.map (AddDeck << Result)
      |> API.toEffect)

  AddDeck (Result lobbyAndHand) ->
    let
      (data, effects) = updateLobby data lobbyAndHand.lobby
    in
      (model global data, effects)

  StartGame Request ->
    (model global data, (API.newGame data.lobby.id data.secret) |> Task.map (StartGame << Result) |> API.toEffect)

  StartGame (Result lobbyAndHand) ->
    (Playing.model global (PlayingData lobbyAndHand.lobby lobbyAndHand.hand data.secret [] Nothing Nothing []),
      eventEffects data.lobby lobbyAndHand.lobby)

  Notification lobby ->
    case lobby.round of
      Just _ -> (model global data,
        (API.getLobbyAndHand lobby.id data.secret)
        |> Task.map (\lobbyAndHand -> JoinLobby lobby.id data.secret (Result lobbyAndHand))
        |> API.toEffect)
      Nothing ->
        let
          (data, effects) = updateLobby data lobby
        in
          (model global data, effects)

  JoinLobby lobbyId secret (Result lobbyAndHand) ->
    case lobbyAndHand.lobby.round of
      Just _ ->
        (Playing.model global (PlayingData lobbyAndHand.lobby lobbyAndHand.hand secret [] Nothing Nothing []),
          eventEffects data.lobby lobbyAndHand.lobby)
      Nothing ->
        let
          (data, effects) = updateLobby data lobbyAndHand.lobby
        in
          (model global data, effects)

  GameEvent _ ->
    (model global data, Effects.none)

  other ->
    (model global data,
      DisplayError ("Got an action (" ++ (toString other) ++ ") that can't be handled in the current state (Config).")
      |> Task.succeed
      |> Effects.task)


updateLobby : ConfigData -> Lobby -> (ConfigData, Effects.Effects Action)
updateLobby data lobby =
  let
    events = eventEffects data.lobby lobby
  in
    ({ data | lobby = lobby }, events)


model : Global -> ConfigData -> Model
model global data =
  { state = SConfig data
  , jsAction = Nothing
  , global = global
  }


modelSub : Global -> String -> Secret -> ConfigData -> Model
modelSub global lobbyId secret data =
  { state = SConfig data
  , jsAction = Just { lobbyId = lobbyId, secret = secret }
  , global = global
  }


initialData : Lobby -> Secret -> ConfigData
initialData lobby secret =
  { lobby = lobby
  , secret = secret
  , deckId = ""
  }


view : Signal.Address Action -> Global -> ConfigData -> Html
view address global data = UI.view address data global
