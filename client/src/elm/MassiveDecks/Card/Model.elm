module MassiveDecks.Card.Model exposing
    ( Call
    , Card(..)
    , Details
    , Id
    , Response
    , Side(..)
    , Type
    , UnknownResponse
    , call
    , frontSide
    , response
    )

import MassiveDecks.Card.Parts exposing (..)
import MassiveDecks.Card.Source.Model exposing (..)


{-| A unique ID for a card.
-}
type alias Id =
    String


{-| The side of a card.
-}
type Side
    = Front
    | Back


{-| Get a side from a boolean test.
-}
frontSide : Bool -> Side
frontSide isFront =
    if isFront then
        Front

    else
        Back


{-| A general card.
-}
type Card
    = C Call
    | R Response


{-| A call card.
-}
type alias Call =
    Type Parts


{-| A simple constructor for a call card.
-}
call : Parts -> Id -> Source -> Call
call parts id source =
    { details = { source = source, id = id }
    , body = parts
    }


{-| A response card.
-}
type alias Response =
    Type String


{-| A simple constructor for a response card.
-}
response : String -> Id -> Source -> Response
response text id source =
    { details = { source = source, id = id }
    , body = text
    }


{-| A response that isn't known to the user. Only the back can be displayed.
-}
type alias UnknownResponse =
    Id


{-| The data for a type of card.
-}
type alias Type body =
    { details : Details
    , body : body
    }


{-| The general details for a card.
-}
type alias Details =
    { source : Source
    , id : Id
    }
