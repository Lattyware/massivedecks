module MassiveDecks.Card.Source.Fake exposing (methods)

import MassiveDecks.Card.Source.Methods as Source


methods : Source.Methods msg
methods =
    { name = \_ -> ""
    , logo = \() -> Nothing
    , defaultDetails =
        \_ ->
            { name = ""
            , url = Nothing
            }
    , tooltip = \() -> Nothing
    }
