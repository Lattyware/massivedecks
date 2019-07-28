module MassiveDecks.Card.Response exposing (view, viewUnknown)

import Html exposing (Html)
import MassiveDecks.Card as Card
import MassiveDecks.Card.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Util.String as String


{-| Render the response to HTML.
-}
view : Config -> Side -> List (Html.Attribute msg) -> Response -> Html msg
view config side attributes response =
    Card.view
        "response"
        config.decks
        side
        attributes
        (viewBody response)
        viewInstructions
        response.details.source


{-| Render an unknown response to HTML, face-down.
-}
viewUnknown : List (Html.Attribute msg) -> Html msg
viewUnknown attributes =
    Card.viewUnknown "response" attributes



{- Private -}


viewBody : Response -> ViewBody msg
viewBody response =
    ViewBody (\() -> [ Html.p [] [ Html.span [] [ response.body |> String.capitalise |> Html.text ] ] ])


viewInstructions : ViewInstructions msg
viewInstructions =
    ViewInstructions (\() -> [])
