module MassiveDecks.Actions.Action where

import MassiveDecks.Models.Game exposing (Lobby, LobbyAndHand)
import MassiveDecks.Models.Player exposing (Secret)


type APICall a
  = Request
  | Result a


type Action
  = NoAction
  | DisplayError String
  | UpdateInputValue String String
  | NewLobby (APICall Lobby)
  | JoinExistingLobby
  | JoinLobby String Secret (APICall LobbyAndHand)
  | AddDeck (APICall LobbyAndHand)
  | StartGame (APICall LobbyAndHand)
  | Pick Int
  | Play (APICall LobbyAndHand)
  | Withdraw Int
  | Notification Lobby
  | Choose Int (APICall LobbyAndHand)
  | RemoveErrorPanel Int
  | NextRound
