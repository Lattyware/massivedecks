module MassiveDecks.Scenes.Lobby.Messages exposing (..)

import MassiveDecks.Models.Game as Game
import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.Player as Player exposing (Player)
import MassiveDecks.Models.Notification as Notification exposing (Notification)
import MassiveDecks.Scenes.Lobby.Sidebar as Sidebar
import MassiveDecks.Scenes.Config.Messages as Config
import MassiveDecks.Scenes.Playing.Messages as Playing
import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Components.Overlay as Overlay
import MassiveDecks.Components.BrowserNotifications as BrowserNotifications
import MassiveDecks.Components.TTS as TTS


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
    | SetNotification (List Player -> Maybe Notification)
    | UpdateLobbyAndHand Game.LobbyAndHand
    | UpdateLobby (Game.Lobby -> Game.Lobby)
    | UpdateHand Card.Hand
    | Identify
    | DisplayInviteOverlay
    | BrowserNotificationForUser (Game.Lobby -> Maybe Player.Id) String String
    | RenderQr
    | Batch (List Message)
    | NoOp
    | BrowserNotificationsMessage BrowserNotifications.Message
    | ConfigMessage Config.ConsumerMessage
    | PlayingMessage Playing.ConsumerMessage
    | SidebarMessage Sidebar.Message
    | TTSMessage TTS.Message
