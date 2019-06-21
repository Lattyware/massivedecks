module MassiveDecks.Util.Result exposing
    ( error
    , isError
    , isOk
    , unify
    )

{-| Utility functions for results.
-}


{-| Get the error of a result as a maybe.
-}
error : Result err ok -> Maybe err
error result =
    case result of
        Ok _ ->
            Nothing

        Err err ->
            Just err


{-| If a result is an error.
-}
isError : Result a b -> Bool
isError result =
    error result /= Nothing


{-| If a result is an error.
-}
isOk : Result a b -> Bool
isOk result =
    Result.toMaybe result /= Nothing


{-| Turn a result that gives the same type in both cases into that result.
-}
unify : Result a a -> a
unify result =
    case result of
        Ok value ->
            value

        Err value ->
            value
