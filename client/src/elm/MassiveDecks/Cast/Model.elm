module MassiveDecks.Cast.Model exposing
    ( Flags
    , Status(..)
    )

import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Strings.Languages.Model exposing (Language)


{-| The cast state.
-}
type Status
    = NoDevicesAvailable
    | NotConnected
    | Connecting
    | Connected String


{-| The initial date required for the cast.
-}
type alias Flags =
    { token : Lobby.Token
    , language : Language
    }
