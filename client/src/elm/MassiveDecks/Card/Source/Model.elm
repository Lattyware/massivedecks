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
import MassiveDecks.Card.Source.Generated.Model as Generated
import MassiveDecks.Card.Source.JsonAgainstHumanity.Model as JsonAgainstHumanity
import MassiveDecks.Card.Source.ManyDecks.Model as ManyDecks


{-| A representation of a source in general terms, not a specific deck.
-}
type General
    = GBuiltIn
    | GManyDecks
    | GJsonAgainstHumanity


{-| Details on where game data came from.

    - `Ex`: External sources are the main sources of cards users can add.
    - `Custom`: These are cards written by the given player.
    - `Generated`: These are cards generated during a game for reasons such as house rules.
    - `Fake`: These are cards used for presentation outside of a game environment.

-}
type Source
    = Ex External
    | Custom
    | Generated Generated.Generator
    | Fake (Maybe String)


{-| An external source.

"External" might be a bit of a poor name here. What this mostly means is that the user can add these as decks. Other
sources are more limited and specific.

-}
type External
    = BuiltIn BuiltIn.Id
    | ManyDecks ManyDecks.DeckCode
    | JsonAgainstHumanity JsonAgainstHumanity.Id


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
    , language : Maybe String
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
    , manyDecks : Maybe ManyDecks.Info
    , jsonAgainstHumanity : Maybe JsonAgainstHumanity.Info
    }


{-| Get a string name from a general source.
-}
generalToString : General -> String
generalToString source =
    case source of
        GBuiltIn ->
            "BuiltIn"

        GManyDecks ->
            "ManyDecks"

        GJsonAgainstHumanity ->
            "JAH"


{-| Get a general source by a string name.
-}
generalFromString : String -> Maybe General
generalFromString sourceName =
    case sourceName of
        "BuiltIn" ->
            Just GBuiltIn

        "ManyDecks" ->
            Just GManyDecks

        "JAH" ->
            Just GJsonAgainstHumanity

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
