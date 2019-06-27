module MassiveDecks.Util.Result exposing
    ( byDefinition
    , error
    , isError
    , isOk
    , unifiedMap
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


{-| A result with a never error can be simplified to just a value.
-}
byDefinition : Result Never a -> a
byDefinition result =
    case result of
        Ok value ->
            value

        Err n ->
            never n


{-| Turn a result that gives the same type in both cases into that result.
-}
unify : Result a a -> a
unify result =
    case result of
        Ok value ->
            value

        Err value ->
            value


{-| Map both sides of a result at the same time to the same type, and give the unified result.
-}
unifiedMap : (err -> a) -> (ok -> a) -> Result err ok -> a
unifiedMap errMap okMap =
    Result.mapError errMap >> Result.map okMap >> unify
