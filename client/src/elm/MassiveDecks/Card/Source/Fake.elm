module MassiveDecks.Card.Source.Fake exposing (methods)

import MassiveDecks.Card.Source.Methods as Source
import MassiveDecks.Card.Source.Model exposing (Source(..))
import MassiveDecks.Strings as Strings


methods : Maybe String -> Source.Methods msg
methods name =
    { name = \_ -> Strings.MassiveDecks
    , logo = \() -> Nothing
    , defaultDetails =
        \_ ->
            { name = name |> Maybe.withDefault ""
            , url = Nothing
            , author = Nothing
            , translator = Nothing
            , language = Nothing
            }
    , tooltip = \_ -> Nothing
    , messages = \() -> []
    }
