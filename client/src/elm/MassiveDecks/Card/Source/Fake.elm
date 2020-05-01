module MassiveDecks.Card.Source.Fake exposing (methods)

import MassiveDecks.Card.Source.Methods as Source
import MassiveDecks.Strings as Strings


methods : Source.Methods msg
methods =
    { name = \_ -> Strings.MassiveDecks
    , logo = \() -> Nothing
    , defaultDetails =
        \_ ->
            { name = ""
            , url = Nothing
            }
    , tooltip = \_ -> Nothing
    }
