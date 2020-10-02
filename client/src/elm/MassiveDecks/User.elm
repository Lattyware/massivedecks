module MassiveDecks.User exposing
    ( Connection(..)
    , Control(..)
    , Id
    , LeaveReason(..)
    , Presence(..)
    , Privilege(..)
    , Registration
    , Role(..)
    , User
    , roleDescription
    )

{-| Operations and models for a user in the game.
-}

import MassiveDecks.Strings as Strings exposing (MdString)


{-| A unique Id for a user.
-}
type alias Id =
    String


{-| The level of privilege a user has.
-}
type Privilege
    = Privileged
    | Unprivileged


{-| The role the user has in games in the lobby.
-}
type Role
    = Player
    | Spectator


roleDescription : Role -> MdString
roleDescription toDescribe =
    case toDescribe of
        Player ->
            Strings.noun Strings.Player 1

        Spectator ->
            Strings.noun Strings.Spectator 1


{-| If the user is actively a part of the lobby.
-}
type Presence
    = Joined
    | Left


{-| The reason a user left the lobby.
-}
type LeaveReason
    = LeftNormally
    | Kicked


{-| The state of connection to the lobby.
-}
type Connection
    = Connected
    | Disconnected


{-| How the user is being controlled.
-}
type Control
    = Human
    | Computer


{-| A request to register a new user in a lobby.
-}
type alias Registration =
    { name : String
    , password : Maybe String
    }


{-| A user in the lobby.
-}
type alias User =
    { name : String
    , presence : Presence
    , connection : Connection
    , privilege : Privilege
    , role : Role
    , control : Control
    }
