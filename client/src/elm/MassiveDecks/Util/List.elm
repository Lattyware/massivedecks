module MassiveDecks.Util.List exposing
    ( any
    , find
    , map2Long
    , mappedIntersperse
    , merge
    )

{-| Utility functions for lists.
-}

import MassiveDecks.Util.Maybe as Maybe


{-| Returns `True` if any value in the list matches the given predicate.
-}
any : (a -> Bool) -> List a -> Bool
any predicate list =
    find predicate list /= Nothing


{-| Find the first element of the given list that fulfils the given predicate.
-}
find : (a -> Bool) -> List a -> Maybe a
find predicate list =
    case list of
        head :: tail ->
            Maybe.first [ Maybe.validate predicate head, find predicate tail ]

        [] ->
            Nothing


{-| Map two items together, getting `Nothing`s when the shorter ends.
Note that if longer is shorter, shorter will be cut off to match.
-}
map2Long : (Maybe a -> b -> c) -> List a -> List b -> List c
map2Long f shorter longer =
    let
        diff =
            List.length longer - List.length shorter

        shorterJust =
            shorter |> List.map Just

        shorterExtended =
            shorterJust ++ List.repeat diff Nothing
    in
    List.map2 f shorterExtended longer


{-| Intersperse an item into a list, building the item from it's surrounding items.
-}
mappedIntersperse : (a -> a -> a) -> List a -> List a
mappedIntersperse f items =
    case items of
        a :: b :: rest ->
            a :: f a b :: b :: mappedIntersperse f rest

        otherwise ->
            otherwise


{-| Combine two lists, zipping them together until one runs out, then finishing the other.
-}
merge : List a -> List a -> List a
merge xs ys =
    case xs of
        x :: xRest ->
            case ys of
                y :: yRest ->
                    x :: y :: merge xRest yRest

                [] ->
                    xs

        [] ->
            ys
