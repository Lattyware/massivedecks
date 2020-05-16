module MassiveDecks.Card.Source.Model exposing
    ( Details
    , External(..)
    , General(..)
    , Info
    , LoadFailureReason(..)
    , Source(..)
    , Summary
    , generalDecoder
    , generalFromString
    , generalToString
    )

import Json.Decode as Json
import MassiveDecks.Card.Source.BuiltIn.Model as BuiltIn
import MassiveDecks.Strings.Languages.Model exposing (Language)
import Url exposing (Url)


{-| A representation of a source in general terms, not a specific deck.
-}
type General
    = GBuiltIn
    | GJsonUrl


{-| Details on where game data came from.

    - `Ex`: External sources are the main sources of cards users can add.
    - `Player`: These are cards written by the given player.
    - `Fake`: These are cards used for presentation outside of a game environment.

-}
type Source
    = Ex External
    | Custom
    | Fake (Maybe String)


{-| An external source.

"External" might be a bit of a poor name here. What this mostly means is that the user can add these as decks. Other
sources are more limited and specific.

-}
type External
    = BuiltIn BuiltIn.Id
    | JsonUrl String


{-| A summary of the contents of the source deck.
-}
type alias Summary =
    { details : Details
    , calls : Int
    , responses : Int
    }


{-| Details about the source deck.
-}
type alias Details =
    { name : String
    , url : Maybe String
    , author : Maybe String
    , language : Maybe Language
    , translator : Maybe String
    }


{-| The reason a source failed to load.
-}
type LoadFailureReason
    = SourceFailure
    | NotFound


{-| Information about what sources are available from the server.
-}
type alias Info =
    { builtIn : Maybe BuiltIn.Info
    , jsonUrl : Bool
    }


{-| Get a string name from a general source.
-}
generalToString : General -> String
generalToString source =
    case source of
        GBuiltIn ->
            "BuiltIn"

        GJsonUrl ->
            "JsonUrl"


{-| Get a general source by a string name.
-}
generalFromString : String -> Maybe General
generalFromString sourceName =
    case sourceName of
        "BuiltIn" ->
            Just GBuiltIn

        "JsonUrl" ->
            Just GJsonUrl

        _ ->
            Nothing


{-| A Json decoder for general sources.
-}
generalDecoder : Json.Decoder General
generalDecoder =
    let
        internal name =
            case generalFromString name of
                Just general ->
                    Json.succeed general

                Nothing ->
                    Json.fail ("Unknown source '" ++ name ++ "'.")
    in
    Json.string |> Json.andThen internal
