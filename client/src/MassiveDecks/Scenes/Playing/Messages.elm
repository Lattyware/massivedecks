module MassiveDecks.Scenes.Playing.Messages exposing (..)

import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Models.Player as Player
import MassiveDecks.Models.Game as Game


{-| This type is used for all sending of messages, allowing us to send messages handled outside this scene.
-}
type ConsumerMessage
  = LobbyUpdate Game.LobbyAndHand
  | ErrorMessage Errors.Message
  | LocalMessage Message


{-| The messages used in the start screen.
-}
type Message
  = LobbyAndHandUpdated
  | Pick String
  | Withdraw String
  | Play
  | Consider Int
  | Choose Int
  | NextRound
  | AnimatePlayedCards
  | Skip (List Player.Id)
  | Back
  | Redraw
  | NoOp
