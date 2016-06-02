module MassiveDecks.Scenes.Lobby.Messages exposing (..)

import MassiveDecks.Models.Game as Game
import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.Notification as Notification exposing (Notification)
import MassiveDecks.Scenes.Lobby.Event as Event exposing (Event)
import MassiveDecks.Scenes.Config.Messages as Config
import MassiveDecks.Scenes.Playing.Messages as Playing
import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Components.Overlay as Overlay
import MassiveDecks.Components.BrowserNotifications as BrowserNotifications


{-| This type is used for all sending of messages, allowing us to send messages handled outside this scene.
-}
type ConsumerMessage
  = ErrorMessage Errors.Message
  | OverlayMessage (Overlay.Message Message)
  | Leave
  | LocalMessage Message


{-| The messages used in the start screen.
-}
type Message
  = DismissNotification Notification
  | UpdateLobby Game.Lobby
  | UpdateHand Card.Hand
  | Identify
  | DisplayInviteOverlay
  | RenderQr
  | NoOp
  | GameEvent Event
  | BrowserNotificationsMessage BrowserNotifications.Message
  | ConfigMessage Config.ConsumerMessage
  | PlayingMessage Playing.ConsumerMessage
