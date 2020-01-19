module MassiveDecks.Cast.Model exposing
    ( RemoteControlCommand(..)
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


{-| Commands when controlling the instance remotely.
-}
type RemoteControlCommand
    = Spectate { token : Lobby.Token, language : Language }
