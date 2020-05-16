module MassiveDecks.Util.List exposing
    ( map2Long
    , mappedIntersperse
    , merge
    )

{-| Utility functions for lists.
-}


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
