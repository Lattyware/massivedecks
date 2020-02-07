module MassiveDecks.Error.Model exposing
    ( ConfigError(..)
    , Error(..)
    , HttpError(..)
    , Overlay
    , TokenDecodingError(..)
    )

import Json.Decode as Json


{-| A generic error for the application as a whole.
-}
type Error
    = Http HttpError
    | Json Json.Error
    | Token TokenDecodingError
    | Config ConfigError


{-| Errors in configuration.
-}
type ConfigError
    = PatchError String
    | VersionMismatch


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


{-| An error while trying to decode a token.
-}
type TokenDecodingError
    = InvalidTokenStructure String
    | TokenJsonError Json.Error
    | TokenBase64Error String
