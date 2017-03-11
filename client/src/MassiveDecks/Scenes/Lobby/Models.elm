module MassiveDecks.Scenes.Lobby.Models exposing (Model)

import MassiveDecks.Models exposing (Init)
import MassiveDecks.Models.Game as Game
import MassiveDecks.Models.Player as Player
import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.Notification as Notification exposing (Notification)
import MassiveDecks.Scenes.Lobby.Sidebar as Sidebar
import MassiveDecks.Scenes.Config.Models as Config
import MassiveDecks.Scenes.Playing.Models as Playing
import MassiveDecks.Components.BrowserNotifications as BrowserNotifications
import MassiveDecks.Components.TTS as TTS


{-| The state of the lobby.
-}
type alias Model =
    { lobby : Game.Lobby
    , hand : Card.Hand
    , config : Config.Model
    , playing : Playing.Model
    , browserNotifications : BrowserNotifications.Model
    , secret : Player.Secret
    , init : Init
    , notification : Maybe Notification
    , qrNeedsRendering : Bool
    , sidebar : Sidebar.Model
    , tts : TTS.Model
    }
