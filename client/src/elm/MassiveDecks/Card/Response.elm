module MassiveDecks.Card.Response exposing
    ( view
    , viewCustom
    , viewPotentiallyCustom
    , viewUnknown
    )

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Card as Card
import MassiveDecks.Card.Model exposing (..)
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Decks as Decks
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Util.String as String
import Regex exposing (Regex)


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
viewPotentiallyCustom : Shared -> Config -> Side -> (String -> msg) -> (String -> msg) -> List (Html.Attribute msg) -> Dict Id String -> Response -> Html msg
viewPotentiallyCustom shared config side update canonicalize attributes fills response =
    case response.details.source of
        Source.Custom ->
            viewCustom shared config side update canonicalize attributes response (fills |> Dict.get response.details.id)

        _ ->
            view shared config side attributes response


{-| Render a blank card to HTML.
-}
viewCustom : Shared -> Config -> Side -> (String -> msg) -> (String -> msg) -> List (Html.Attribute msg) -> Response -> Maybe String -> Html msg
viewCustom shared config side update canonicalize attributes response fill =
    Card.view
        "response"
        shared
        (config.decks |> Decks.getSummary)
        side
        attributes
        (viewCustomBody response.details.id update canonicalize response.body fill)
        viewInstructions
        response.details.source



{- Private -}


punctuation : Regex
punctuation =
    -- TODO: This should probably get localized.
    Regex.fromString "[.?!]$" |> Maybe.withDefault Regex.never


viewBody : Response -> ViewBody msg
viewBody response =
    let
        end =
            if response.body |> Regex.contains punctuation then
                []

            else
                [ Html.text "." ]
    in
    ViewBody (\() -> [ Html.p [] [ Html.span [] ((response.body |> String.capitalise |> Html.text) :: end) ] ])


viewCustomBody : String -> (String -> msg) -> (String -> msg) -> String -> Maybe String -> ViewBody msg
viewCustomBody id update canonicalize canonicalValue value =
    let
        mostRecentValue =
            value |> Maybe.withDefault canonicalValue
    in
    ViewBody
        (\() ->
            [ Html.textarea
                [ HtmlA.id id
                , mostRecentValue |> HtmlA.value
                , (String.replace "\n" "" >> update) |> HtmlE.onInput
                , mostRecentValue |> canonicalize |> HtmlE.onBlur
                ]
                []
            ]
        )


viewInstructions : ViewInstructions msg
viewInstructions =
    ViewInstructions (\() -> [])
