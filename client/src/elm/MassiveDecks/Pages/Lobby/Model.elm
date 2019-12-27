module MassiveDecks.Pages.Lobby.Model exposing
    ( Auth
    , Claims
    , Lobby
    , Model
    , Notification
    , NotificationId
    , NotificationMessage(..)
    , State(..)
    , Token
    , TokenDecodingError(..)
    )

import Dict exposing (Dict)
import Json.Decode as Json
import MassiveDecks.Animated exposing (Animated)
import MassiveDecks.Game.Model as Game exposing (Game)
import MassiveDecks.Pages.Lobby.Configure.Model as Configure
import MassiveDecks.Pages.Lobby.GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Route exposing (..)
import MassiveDecks.User as User exposing (User)


{-| Data for the lobby page.
-}
type alias Model =
    { route : Route
    , auth : Auth
    , lobby : Maybe Lobby
    , configure : Configure.Model
    , notificationId : NotificationId
    , notifications : List (Animated Notification)
    , inviteDialogOpen : Bool
    }


{-| A lobby.
-}
type alias Lobby =
    { name : String
    , public : Bool
    , users : Dict User.Id User
    , owner : User.Id
    , config : Configure.Config
    , game : Maybe Game.Model
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
    , pvg : User.Privilege
    }


{-| An error while trying to decode a token.
-}
type TokenDecodingError
    = InvalidTokenStructure Token
    | TokenJsonError Json.Error
    | TokenBase64Error String


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
    | UserLeft User.Id
