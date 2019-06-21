module MassiveDecks.User exposing
    ( Connection(..)
    , Id
    , Presence(..)
    , Privilege(..)
    , Registration
    , Role(..)
    , User
    )

{-| Operations and models for a user in the game.
-}


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


{-| If the user is actively a part of the lobby.
-}
type Presence
    = Joined
    | Left


{-| The state of connection to the lobby.
-}
type Connection
    = Connected
    | Disconnected


{-| A request to register a new user in a lobby.
-}
type alias Registration =
    { name : String
    }


{-| A user in the lobby.
-}
type alias User =
    { name : String
    , presence : Presence
    , connection : Connection
    , privilege : Privilege
    , role : Role
    }
