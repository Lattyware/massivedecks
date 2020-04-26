module MassiveDecks.Card.Response exposing
    ( view
    , viewBlank
    , viewPotentiallyBlank
    , viewUnknown
    )

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Card as Card
import MassiveDecks.Card.Model exposing (..)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Decks as Decks
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Util.String as String


{-| Render the response to HTML.
-}
view : Shared -> Config -> Side -> List (Html.Attribute msg) -> Response -> Html msg
view shared config side attributes response =
    Card.view
        "response"
        shared
        (config.decks |> Decks.getSummary)
        side
        attributes
        (viewBody response)
        viewInstructions
        response.details.source


{-| Render an unknown response to HTML, face-down.
-}
viewUnknown : Shared -> List (Html.Attribute msg) -> Html msg
viewUnknown shared attributes =
    Card.viewUnknown shared "response" attributes


{-| Render a potentially blank card to HTML.
-}
viewPotentiallyBlank : Shared -> Config -> Side -> (String -> msg) -> List (Html.Attribute msg) -> Dict Id String -> PotentiallyBlankResponse -> Html msg
viewPotentiallyBlank shared config side update attributes fills response =
    case response of
        Normal r ->
            view shared config side attributes r

        Blank b ->
            viewBlank shared config side update attributes b (fills |> Dict.get b.details.id)


{-| Render a blank card to HTML.
-}
viewBlank : Shared -> Config -> Side -> (String -> msg) -> List (Html.Attribute msg) -> BlankResponse -> Maybe String -> Html msg
viewBlank shared config side update attributes response fill =
    Card.view
        "response"
        shared
        (config.decks |> Decks.getSummary)
        side
        attributes
        (viewBlankBody response.details.id update fill)
        viewInstructions
        response.details.source



{- Private -}


viewBody : Response -> ViewBody msg
viewBody response =
    ViewBody (\() -> [ Html.p [] [ Html.span [] [ response.body |> String.capitalise |> Html.text ] ] ])


viewBlankBody : String -> (String -> msg) -> Maybe String -> ViewBody msg
viewBlankBody id update value =
    ViewBody
        (\() ->
            [ Html.textarea
                [ HtmlA.id id
                , value |> Maybe.withDefault "" |> HtmlA.value
                , update |> HtmlE.onInput
                ]
                []
            ]
        )


viewInstructions : ViewInstructions msg
viewInstructions =
    ViewInstructions (\() -> [])
