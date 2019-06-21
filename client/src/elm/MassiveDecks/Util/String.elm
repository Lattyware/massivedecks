module MassiveDecks.Util.String exposing (capitalise)

{-| Utility methods for strings.
-}


{-| Make the first letter of a word a capital if it isn't.
-}
capitalise : String -> String
capitalise str =
    case String.uncons str of
        Just ( firstChar, rest ) ->
            String.cons (Char.toLocaleUpper firstChar) rest

        Nothing ->
            ""
