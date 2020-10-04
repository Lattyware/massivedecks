module MassiveDecks.Card.Source.Generated exposing (..)

import MassiveDecks.Card.Source.Methods as Source
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang


methods : Source.Methods msg
methods =
    { name = \() -> Strings.Generated
    , logo = \() -> Nothing
    , defaultDetails =
        \shared ->
            { name = name shared
            , url = Nothing
            , translator = Nothing
            , author = Nothing
            , language = Nothing
            }
    , tooltip = \_ -> Nothing
    , messages = \() -> []
    }



{- Private -}


name : Shared -> String
name shared =
    Strings.Generated |> Lang.string shared
