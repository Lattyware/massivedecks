module MassiveDecks.Card.Source.Generated exposing (..)

import MassiveDecks.Card.Source.Generated.Model exposing (Generator(..))
import MassiveDecks.Card.Source.Methods as Source
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang


methods : Generator -> Source.Methods msg
methods generator =
    { name = \() -> Strings.Generated { by = generatorName generator }
    , logo = \() -> Nothing
    , defaultDetails =
        \shared ->
            { name = name shared generator
            , url = Nothing
            , translator = Nothing
            , author = Nothing
            , language = Nothing
            }
    , tooltip = \_ -> Nothing
    , messages = \() -> []
    }



{- Private -}


name : Shared -> Generator -> String
name shared generator =
    Strings.Generated { by = generatorName generator } |> Lang.string shared


generatorName : Generator -> MdString
generatorName generator =
    case generator of
        HappyEndingRule ->
            Strings.HouseRuleHappyEnding
