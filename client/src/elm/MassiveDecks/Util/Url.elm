module MassiveDecks.Util.Url exposing (origin)

{-| Utility methods for urls.
-}

import Url exposing (Url)


{-| Get an origin from a URL (combination of protocol, host and port).
-}
origin : Url -> String
origin url =
    let
        protocol =
            case url.protocol of
                Url.Http ->
                    "http"

                Url.Https ->
                    "https"
    in
    protocol
        ++ "://"
        ++ url.host
        ++ (url.port_ |> Maybe.map (\p -> ":" ++ String.fromInt p) |> Maybe.withDefault "")
