module MassiveDecks.Util.NeList exposing
    ( NeList(..)
    , decoder
    , extend
    , fromList
    , head
    , just
    , toList
    )

{-| A module for a list that cannot be empty.
-}

import Json.Decode as Json


{-| A list that cannot be empty.
-}
type NeList item
    = NeList item (List item)


{-| A list of one item.
-}
just : item -> NeList item
just item =
    NeList item []


{-| Add all the new elements to the end of the list.
-}
extend : List item -> NeList item -> NeList item
extend new (NeList first rest) =
    NeList first (rest ++ new)


{-| Get the first element of a non-empty list.
-}
head : NeList item -> item
head (NeList first _) =
    first


{-| Convert to a normal list.
-}
toList : NeList item -> List item
toList (NeList first rest) =
    first :: rest


{-| Convert from a normal list.
-}
fromList : List item -> Maybe (NeList item)
fromList items =
    case items of
        first :: rest ->
            NeList first rest |> Just

        [] ->
            Nothing


{-| A JSON decoder that fails if there are no values.
-}
decoder : Json.Decoder item -> Json.Decoder (NeList item)
decoder itemDecoder =
    Json.list itemDecoder
        |> Json.andThen (fromList >> Maybe.map Json.succeed >> Maybe.withDefault (Json.fail "Can't be empty."))
