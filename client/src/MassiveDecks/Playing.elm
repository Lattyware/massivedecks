module MassiveDecks.Playing where

import Task
import Effects
import Html exposing (Html)

import MassiveDecks.Models.Player exposing (Secret)
import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.Game exposing (Lobby)
import MassiveDecks.Models.State exposing (State(..), Model, ConfigData, PlayingData, Error, Global)
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.UI.Playing as UI
import MassiveDecks.API as API


update : Action -> Global -> PlayingData -> (Model, Effects.Effects Action)
update action global data = case action of
  Pick card ->
    let
      canPlay = (List.length data.picked) < Maybe.withDefault 0 (Maybe.map (\round -> Card.slots round.call) data.lobby.round)
      playing = Maybe.withDefault False (Maybe.map (\round -> case round.responses of
        Card.Revealed _ -> False
        Card.Hidden _ -> True
      ) data.lobby.round)
    in
      if playing && canPlay then
        (model global { data | picked = List.append data.picked [card] }, Effects.none)
      else
        (model global data, Effects.none)

  Withdraw card ->
    (model global { data | picked = List.filter ((/=) card) data.picked }, Effects.none)

  Play Request ->
    (model global data, (API.play data.lobby.id data.secret data.picked) |> Task.map (Play << Result) |> API.toEffect)

  Play (Result lobbyAndHand) ->
    let
      data = (updateLobby data lobbyAndHand.lobby)
    in
      (model global
        { data | hand = lobbyAndHand.hand
               , picked = []
               }, Effects.none)

  Notification lobby ->
    case lobby.round of
      Just _ -> (model global (updateLobby data lobby), Effects.none)
      Nothing -> (configModel global (ConfigData lobby data.secret ""), Effects.none)

  JoinLobby lobbyId secret (Result lobbyAndHand) ->
    case lobbyAndHand.lobby.round of
      Just _ -> (model global (updateLobby data lobbyAndHand.lobby), Effects.none)
      Nothing -> (configModel global (ConfigData lobbyAndHand.lobby data.secret ""), Effects.none)

  Choose winner Request ->
    (model global data, (API.choose data.lobby.id data.secret winner) |> Task.map (Choose winner << Result) |> API.toEffect)

  Choose winner (Result lobbyAndHand) ->
    let
      data = (updateLobby data lobbyAndHand.lobby)
    in
      (model global
        { data | hand = lobbyAndHand.hand
               , picked = []
               }, Effects.none)

  NextRound ->
    (model global { data | lastFinishedRound = Nothing }, Effects.none)

  other ->
    (model global data,
      DisplayError ("Got an action (" ++ (toString other) ++ ") that can't be handled in the current state (Playing).")
      |> Task.succeed
      |> Effects.task)


updateLobby : PlayingData -> Lobby -> PlayingData
updateLobby data lobby =
  let
    lastFinishedRound = if (Maybe.map .call data.lobby.round) == (Maybe.map .call lobby.round) then
      data.lastFinishedRound
    else
      data.lobby.round
  in
    { data | lobby = lobby
           , lastFinishedRound = lastFinishedRound
           }


model : Global -> PlayingData -> Model
model global data =
  { state = SPlaying data
  , jsAction = Nothing
  , global = global
  }


modelSub : Global -> String -> Secret -> PlayingData -> Model
modelSub global lobbyId secret data =
  { state = SPlaying data
  , jsAction = Just { lobbyId = lobbyId, secret = secret }
  , global = global
  }


configModel : Global -> ConfigData -> Model
configModel global data =
  { state = SConfig data
  , jsAction = Nothing
  , global = global
  }


view : Signal.Address Action -> Global -> PlayingData -> Html
view address global playingData = UI.view address global playingData
