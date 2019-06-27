module MassiveDecks.Error.Model exposing
    ( Error(..)
    , HttpError(..)
    , Overlay
    )

import Json.Decode as Json
import MassiveDecks.Pages.Lobby.Model as Lobby


{-| A generic error for the application as a whole.
-}
type Error
    = Http HttpError
    | Json Json.Error
    | Token Lobby.TokenDecodingError


{-| An error from an HTTP request.
-}
type HttpError
    = BadUrl String
    | Timeout
    | NetworkError
    | BadStatus Int


{-| An overlay displaying a number of errors.
-}
type alias Overlay =
    { errors : List Error }
