module MassiveDecks.Util.Maybe exposing
    ( decompose
    , first
    , isJust
    , isNothing
    , justIf
    , toList
    , transformWith
    , validate
    )

{-| Utility functions for optional values.
-}


{-| Turn a maybe of a pair into two maybes.
-}
decompose : Maybe ( a, b ) -> ( Maybe a, Maybe b )
decompose pair =
    case pair of
        Just ( a, b ) ->
            ( Just a, Just b )

        Nothing ->
            ( Nothing, Nothing )


{-| Get the first value that isn't Nothing, if any.
-}
first : List (Maybe a) -> Maybe a
first values =
    case values of
        (Just value) :: _ ->
            Just value

        Nothing :: rest ->
            first rest

        [] ->
            Nothing


{-| Give the value if the predicate is true, or nothing if the predicate is false.
-}
justIf : Bool -> a -> Maybe a
justIf predicate value =
    if predicate then
        Just value

    else
        Nothing


{-| Create a singleton list of the value, or an empty list.
-}
toList : Maybe a -> List a
toList value =
    case value of
        Just item ->
            [ item ]

        Nothing ->
            []


{-| Apply a given transformation to the value if the given maybe holds the necessary data
-}
transformWith : b -> (b -> a -> b) -> Maybe a -> b
transformWith value transform maybe =
    case maybe of
        Just op ->
            transform value op

        Nothing ->
            value


{-| Return `Just` the value if it fulfills the predicate, otherwise `Nothing`.
-}
validate : (a -> Bool) -> a -> Maybe a
validate predicate item =
    if predicate item then
        Just item

    else
        Nothing


{-| Return if the given maybe doesn't hold a value.
-}
isNothing : Maybe a -> Bool
isNothing =
    (==) Nothing


{-| Return if the given maybe holds a value.
-}
isJust : Maybe a -> Bool
isJust =
    (/=) Nothing
