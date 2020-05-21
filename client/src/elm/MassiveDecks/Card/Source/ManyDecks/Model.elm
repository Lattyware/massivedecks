module MassiveDecks.Card.Source.ManyDecks.Model exposing
    ( DeckCode
    , Info
    , deckCode
    , encode
    , isValidChar
    , toString
    , validChars
    )

import Json.Encode as Json
import Set


type alias Info =
    { baseUrl : String }


validChars : Set.Set Char
validChars =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" |> String.toList |> Set.fromList


isValidChar : Char -> Bool
isValidChar char =
    Set.member char validChars


type DeckCode
    = DeckCode String


deckCode : String -> DeckCode
deckCode string =
    string |> String.toUpper |> String.toList |> List.filter isValidChar |> String.fromList |> DeckCode


encode : DeckCode -> Json.Value
encode =
    toString >> Json.string


toString : DeckCode -> String
toString (DeckCode code) =
    code
