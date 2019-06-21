module MassiveDecks.Error.Model exposing
    ( Error(..)
    , Overlay
    )

import Http
import Json.Decode as Json
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Strings exposing (MdString)


{-| A generic error for the application as a whole.
-}
type Error
    = Http Http.Error
    | Json Json.Error
    | Token Lobby.TokenDecodingError
    | Generic MdString


{-| An overlay displaying a number of errors.
-}
type alias Overlay =
    { errors : List Error }
