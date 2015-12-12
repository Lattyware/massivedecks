module MassiveDecks.Actions.Action where

import Task
import Effects

import MassiveDecks.Models.State exposing (InitialState)
import MassiveDecks.Models.Game exposing (Lobby, LobbyAndHand)
import MassiveDecks.Models.Player as Player
import MassiveDecks.Actions.Event exposing (Event, events, catchUpEvents)


type APICall a
  = Request
  | Result a


type Action
  = NoAction
  | DisplayError String
  | UpdateInputValue String String
  | NewLobby (APICall Lobby)
  | JoinExistingLobby
  | JoinLobby String Player.Secret (APICall LobbyAndHand)
  | AddDeck (APICall LobbyAndHand)
  | StartGame (APICall LobbyAndHand)
  | Pick Int
  | Play (APICall LobbyAndHand)
  | Withdraw Int
  | Notification Lobby
  | Consider Int
  | Choose Int (APICall LobbyAndHand)
  | RemoveErrorPanel Int
  | NextRound
  | SetInitialState InitialState
  | AnimatePlayedCards (List Int)
  | GameEvent Event


eventEffects : Lobby -> Lobby -> Effects.Effects Action
eventEffects oldLobby newLobby =
  events oldLobby newLobby |> eventsToEffects


catchUpEffects : Lobby -> Effects.Effects Action
catchUpEffects lobby =
  catchUpEvents lobby |> eventsToEffects


eventsToEffects : List Event -> Effects.Effects Action
eventsToEffects events
  = events
  |> List.map GameEvent
  |> List.map Task.succeed
  |> List.map Effects.task
  |> Effects.batch
