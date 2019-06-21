module MassiveDecks.Card.Source.Fake exposing (methods)

import MassiveDecks.Card.Source.Methods as Source
import MassiveDecks.Util.Html as Html


methods : Source.Methods msg
methods =
    { problem = \() -> Nothing
    , details =
        \() ->
            { name = ""
            , url = Nothing
            }
    , tooltip = \() -> Nothing
    , logo = \() -> Nothing
    , name = \() -> ""
    , editor = \_ -> \_ -> Html.nothing
    , equals = \_ -> False
    }
