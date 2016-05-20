module MassiveDecks.Scenes.Start.Messages exposing (..)

import MassiveDecks.Components.Input as Input
import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Scenes.Lobby.Messages as Lobby
import MassiveDecks.Models.Game as Game
import MassiveDecks.Models.Player as Player


{-| The messages used in the start screen.
-}
type Message
  = CreateLobby
  | ShowInfoMessage String
  | JoinLobbyAsNewPlayer String
  | JoinLobbyAsExistingPlayer Player.Secret String
  | JoinLobby Player.Secret Game.LobbyAndHand
  | InputMessage (Input.Message InputId)
  | LobbyMessage Lobby.ConsumerMessage
  | ErrorMessage Errors.Message


{-| IDs for the inputs to differentiate between them in messages.
-}
type InputId
  = Name
  | GameCode
