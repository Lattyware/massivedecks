module MassiveDecks.Playing where

import Task
import Effects
import Html exposing (Html)

import MassiveDecks.Models.Player exposing (Secret)
import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.Game exposing (Lobby)
import MassiveDecks.Models.State exposing (State(..), Model, ConfigData, PlayingData, Error)
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.UI.Playing as UI
import MassiveDecks.API as API


update : Action -> List Error -> PlayingData -> (Model, Effects.Effects Action)
update action errors data = case action of
  Pick card ->
    let
      canPlay = (List.length data.picked) < Maybe.withDefault 0 (Maybe.map (\round -> Card.slots round.call) data.lobby.round)
      playing = Maybe.withDefault False (Maybe.map (\round -> case round.responses of
        Card.Revealed _ -> False
        Card.Hidden _ -> True
      ) data.lobby.round)
    in
      if playing && canPlay then
        (model errors { data | picked = List.append data.picked [card] }, Effects.none)
      else
        (model errors data, Effects.none)

  Withdraw card ->
    (model errors { data | picked = List.filter ((/=) card) data.picked }, Effects.none)

  Play Request ->
    (model errors data, (API.play data.lobby.id data.secret data.picked) |> Task.map (Play << Result) |> API.toEffect)

  Play (Result lobbyAndHand) ->
    let
      data = (updateLobby data lobbyAndHand.lobby)
    in
      (model errors
        { data | hand = lobbyAndHand.hand
               , picked = []
               }, Effects.none)

  Notification lobby ->
    case lobby.round of
      Just _ -> (model errors (updateLobby data lobby), Effects.none)
      Nothing -> (configModel errors (ConfigData lobby data.secret ""), Effects.none)

  JoinLobby lobbyId secret (Result lobbyAndHand) ->
    case lobbyAndHand.lobby.round of
      Just _ -> (model errors (updateLobby data lobbyAndHand.lobby), Effects.none)
      Nothing -> (configModel errors (ConfigData lobbyAndHand.lobby data.secret ""), Effects.none)

  Choose winner Request ->
    (model errors data, (API.choose data.lobby.id data.secret winner) |> Task.map (Choose winner << Result) |> API.toEffect)

  Choose winner (Result lobbyAndHand) ->
    let
      data = (updateLobby data lobbyAndHand.lobby)
    in
      (model errors
        { data | hand = lobbyAndHand.hand
               , picked = []
               }, Effects.none)

  NextRound ->
    (model errors { data | lastFinishedRound = Nothing }, Effects.none)

  other ->
    (model (Error ("Got an action (" ++ (toString other) ++ ") that can't be handled in the current state (Playing).") :: errors)
      data, Effects.none)


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


model : List Error -> PlayingData -> Model
model errors data =
  { state = SPlaying data
  , jsAction = Nothing
  , errors = errors
  }


modelSub : List Error -> String -> Secret -> PlayingData -> Model
modelSub errors lobbyId secret data =
  { state = SPlaying data
  , jsAction = Just { lobbyId = lobbyId, secret = secret }
  , errors = errors
  }


configModel : List Error -> ConfigData -> Model
configModel errors data =
  { state = SConfig data
  , jsAction = Nothing
  , errors = errors
  }


view : Signal.Address Action -> List Error -> PlayingData -> Html
view address errors playingData = UI.view address errors playingData
