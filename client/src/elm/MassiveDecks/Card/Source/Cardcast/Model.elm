module MassiveDecks.Card.Source.Cardcast.Model exposing (PlayCode(..), playCode)

{-| -}


{-| A code for a Cardcast deck.
-}
type PlayCode
    = PlayCode String


{-| Create a cardcast PlayCode from a string.
-}
playCode : String -> PlayCode
playCode string =
    string |> String.toUpper |> PlayCode
