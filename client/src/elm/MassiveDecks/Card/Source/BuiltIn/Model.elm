module MassiveDecks.Card.Source.BuiltIn.Model exposing (Id(..))

{-| Models for the built-in source.
-}


{-| The id for a built-in deck.
-}
type Id
    = Id String


{-| Create an id from a string.
-}
playCode : String -> Id
playCode string =
    string |> Id
