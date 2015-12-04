module MassiveDecks.Playing where

import Task
import Effects
import Html exposing (Html)

import MassiveDecks.Models.Player exposing (Secret)
import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.State exposing (State(..), Model, ConfigData, PlayingData)
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.UI.Playing as UI
import MassiveDecks.API as API


update : Action -> Maybe String -> PlayingData -> (Model, Effects.Effects Action)
update action error data = case action of
  Pick card ->
    let
      canPlay = (List.length data.picked) < Maybe.withDefault 0 (Maybe.map (\round -> Card.slots round.call) data.lobby.round)
      playing = Maybe.withDefault False (Maybe.map (\round -> case round.responses of
        Card.Revealed _ -> False
        Card.Hidden _ -> True
      ) data.lobby.round)
    in
      if playing && canPlay then
        (model error { data | picked = card :: data.picked }, Effects.none)
      else
        (model error data, Effects.none)

  Withdraw card ->
    (model error { data | picked = List.filter ((/=) card) data.picked }, Effects.none)

  Play Request ->
    (model error data, (API.play data.lobby.id data.secret data.picked) |> Task.map (Play << Result) |> API.toEffect)

  Play (Result lobbyAndHand) ->
    (model error
      { data | lobby = lobbyAndHand.lobby
      , hand = lobbyAndHand.hand
      , picked = []
      }, Effects.none)

  Notification lobby ->
    case lobby.round of
      Just _ -> (model error { data | lobby = lobby }, Effects.none)
      Nothing -> (configModel error (ConfigData lobby data.secret ""), Effects.none)

  JoinLobby lobbyId secret (Result lobbyAndHand) ->
    case lobbyAndHand.lobby.round of
      Just _ -> (model error { data | lobby = lobbyAndHand.lobby }, Effects.none)
      Nothing -> (configModel error (ConfigData lobbyAndHand.lobby data.secret ""), Effects.none)

  Choose winner Request ->
    (model error data, (API.choose data.lobby.id data.secret winner) |> Task.map (Choose winner << Result) |> API.toEffect)

  Choose winner (Result lobbyAndHand) ->
    (model error
      { data | lobby = lobbyAndHand.lobby
      , hand = lobbyAndHand.hand
      , picked = []
      }, Effects.none)

  other ->
    (model (Just ("Got an action (" ++ (toString other) ++ ") that can't be handled in the current state (Playing)."))
      data, Effects.none)


model : Maybe String -> PlayingData -> Model
model error data =
  { state = SPlaying data
  , jsAction = Nothing
  , error = error
  }


modelSub : Maybe String -> String -> Secret -> PlayingData -> Model
modelSub error lobbyId secret data =
  { state = SPlaying data
  , jsAction = Just { lobbyId = lobbyId, secret = secret }
  , error = error
  }


configModel : Maybe String -> ConfigData -> Model
configModel error data =
  { state = SConfig data
  , jsAction = Nothing
  , error = error
  }


view : Signal.Address Action -> Maybe String -> PlayingData -> Html
view address error playingData = UI.view address error playingData
