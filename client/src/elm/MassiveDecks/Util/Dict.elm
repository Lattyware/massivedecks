module MassiveDecks.Util.Dict exposing (getFrom)

import Dict exposing (..)


{-| It is very common to have the key as the thing you are chaining, so this is a convenience function to swap the
argument order.
-}
getFrom : Dict.Dict comparable value -> comparable -> Maybe value
getFrom dict key =
    get key dict
