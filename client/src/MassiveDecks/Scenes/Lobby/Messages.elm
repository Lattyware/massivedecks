module MassiveDecks.Scenes.Lobby.Messages exposing (..)

import MassiveDecks.Models.Game as Game
import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.Notification as Notification exposing (Notification)
import MassiveDecks.Scenes.Lobby.Event as Event exposing (Event)
import MassiveDecks.Scenes.Config.Messages as Config
import MassiveDecks.Scenes.Playing.Messages as Playing
import MassiveDecks.Components.Errors as Errors


{-| This type is used for all sending of messages, allowing us to send messages handled outside this scene.
-}
type ConsumerMessage
  = ErrorMessage Errors.Message
  | Leave
  | LocalMessage Message


{-| The messages used in the start screen.
-}
type Message
  = DismissNotification Notification
  | LobbyUpdated Game.Lobby
  | HandUpdated Card.Hand
  | Identify
  | NoOp
  | GameEvent Event
  | ConfigMessage Config.ConsumerMessage
  | PlayingMessage Playing.ConsumerMessage
