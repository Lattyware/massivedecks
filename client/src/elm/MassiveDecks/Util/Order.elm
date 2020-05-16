module MassiveDecks.Util.Order exposing (..)

{-| Utilities for dealing with ordering.
-}


{-| Map an ordering.
-}
map : (a -> b) -> (b -> b -> Order) -> a -> a -> Order
map f order a b =
    order (f a) (f b)


{-| Map an ordering where the value might not exist.
-}
filterMap : (b -> Order) -> (a -> Maybe b) -> (b -> b -> Order) -> a -> a -> Order
filterMap againstNothing f order a b =
    case f a of
        Just x ->
            case f b of
                Just y ->
                    order x y

                Nothing ->
                    againstNothing x

        Nothing ->
            case f b of
                Just y ->
                    againstNothing y |> reverse

                Nothing ->
                    EQ


{-| Get the reversed order.
-}
reverse : Order -> Order
reverse o =
    case o of
        LT ->
            GT

        EQ ->
            EQ

        GT ->
            LT
