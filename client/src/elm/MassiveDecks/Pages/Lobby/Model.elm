module MassiveDecks.Pages.Lobby.Model exposing
    ( Auth
    , Change(..)
    , Claims
    , Lobby
    , LobbyAndConfigure
    , Model
    , Notification
    , NotificationId
    , NotificationMessage(..)
    , State(..)
    , Token
    )

import Dict exposing (Dict)
import MassiveDecks.Animated exposing (Animated)
import MassiveDecks.Components.Menu.Model as Menu
import MassiveDecks.Error.Model exposing (Error)
import MassiveDecks.Game.Model as Game exposing (Game)
import MassiveDecks.Game.Time as Time
import MassiveDecks.Models.MdError exposing (GameStateError, MdError)
import MassiveDecks.Pages.Lobby.Configure.Model as Configure
import MassiveDecks.Pages.Lobby.GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Route exposing (..)
import MassiveDecks.Pages.Lobby.Spectate.Model as Spectate
import MassiveDecks.User as User exposing (User)


{-| A change. This is the result of the update function, and implies either an update to the current page or a redirect
to somewhere else with some payload.
-}
type Change
    = Stay Model
    | JoinError GameCode MdError
    | LeftGame GameCode User.LeaveReason
    | ConfigError Error


{-| Data for the lobby page.
-}
type alias Model =
    { route : Route
    , auth : Auth
    , lobbyAndConfigure : Maybe LobbyAndConfigure
    , notificationId : NotificationId
    , notifications : List (Animated Notification)
    , inviteDialogOpen : Bool
    , timeAnchor : Maybe Time.Anchor
    , spectate : Spectate.Model
    , gameMenu : Menu.State
    , userMenu : Maybe User.Id
    }


type alias LobbyAndConfigure =
    { lobby : Lobby
    , configure : Configure.Model
    }


{-| A lobby.
-}
type alias Lobby =
    { users : Dict User.Id User
    , owner : User.Id
    , config : Configure.Config
    , game : Maybe Game.Model
    , errors : List GameStateError
    }


{-| The state of a lobby.
-}
type State
    = Playing
    | SettingUp


{-| A JSON Web Token for authentication with the server.
-}
type alias Token =
    String


{-| Some claims and the token they came from.
-}
type alias Auth =
    { token : Token
    , claims : Claims
    }


{-| The decoded (but not verified) claims of a JWT.
-}
type alias Claims =
    { gc : GameCode
    , uid : User.Id
    }


{-| A transient notification for the user.
-}
type alias Notification =
    { id : NotificationId
    , message : NotificationMessage
    }


{-| A unique id for a notification.
-}
type alias NotificationId =
    Int


{-| Data defining a message for a notification for the user.
-}
type NotificationMessage
    = UserConnected User.Id
    | UserDisconnected User.Id
    | UserJoined User.Id
    | UserLeft User.Id User.LeaveReason
    | Error MdError
