module MassiveDecks.Pages.Lobby.Token exposing (decode)

import Base64
import Json.Decode as Json
import MassiveDecks.Error.Model exposing (TokenDecodingError(..))
import MassiveDecks.Models.Decoders as Decoders
import MassiveDecks.Pages.Lobby.Model exposing (..)


{-| Decode a token to some claims.
-}
decode : Token -> Result TokenDecodingError Auth
decode token =
    case token |> String.split "." of
        _ :: body :: _ :: [] ->
            body
                |> Base64.decode
                |> Result.mapError TokenBase64Error
                |> Result.andThen (decodeJson token)

        _ ->
            Err (InvalidTokenStructure token)



{- Private -}


decodeJson : Token -> String -> Result TokenDecodingError Auth
decodeJson token json =
    json
        |> Json.decodeString decodeClaims
        |> Result.mapError TokenJsonError
        |> Result.map (\claims -> Auth token claims)


decodeClaims : Json.Decoder Claims
decodeClaims =
    Json.map2 Claims
        (Json.field "gc" Decoders.gameCode)
        (Json.field "uid" Decoders.userId)
