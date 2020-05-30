module MassiveDecks.Card.Source.JsonAgainstHumanity.Model exposing
    ( Deck
    , Id
    , Info
    , fromString
    , hardcoded
    , idDecoder
    , toString
    )

{-| The id for a built-in deck.
-}

import Json.Decode as Json
import List.Extra as List


type Id
    = Id String


{-| Information about the source from the server.
-}
type alias Info =
    { aboutUrl : String
    , decks : List Deck
    }


{-| Information about a deck.
-}
type alias Deck =
    { id : Id
    , name : String
    }


{-| Get an id from a string.
-}
fromString : Maybe Info -> String -> Maybe Id
fromString builtInInfo stringId =
    let
        matching got deck =
            case deck.id of
                Id str ->
                    str == got

        internal { decks } =
            decks |> List.find (matching stringId) |> Maybe.map .id
    in
    builtInInfo |> Maybe.andThen internal


{-| Allows you to hard-code an Id for a deck. This means that the client and server could end up out of sync if the id
doesn't actually exist.
-}
hardcoded : String -> Id
hardcoded =
    Id


{-| A decoder for ids.
-}
idDecoder : Json.Decoder Id
idDecoder =
    Json.string |> Json.map Id


{-| Convert an Id to it's string representation.
-}
toString : Id -> String
toString (Id str) =
    str
