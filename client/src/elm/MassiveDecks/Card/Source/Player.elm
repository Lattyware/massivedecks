module MassiveDecks.Card.Source.Player exposing (..)

import MassiveDecks.Card.Source.Methods as Source
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang


methods : Source.Methods msg
methods =
    { name = \shared -> Lang.string shared Strings.APlayer
    , logo = \() -> Nothing
    , defaultDetails =
        \shared ->
            { name = name shared
            , url = Nothing
            }
    , tooltip = \() -> Nothing
    }



{- Private -}


name : Shared -> String
name shared =
    Strings.APlayer |> Lang.string shared
