module MassiveDecks.Card exposing
    ( fillFromDict
    , view
    , viewUnknown
    )

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Card.Model exposing (..)
import MassiveDecks.Card.Source as Source
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Decks.Model as Configure
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Maybe as Maybe


{-| Render a card to HTML, with the given side face-up.
-}
view :
    String
    -> Shared
    -> Configure.GetSummary
    -> Side
    -> List (Html.Attribute msg)
    -> ViewBody msg
    -> ViewInstructions msg
    -> Source
    -> Html msg
view cardTypeClass shared getSummary visibleSide attributes viewBody viewInstructions source =
    Html.div
        (HtmlA.classList
            [ ( "game-card", True )
            , ( cardTypeClass, True )
            , ( "face-down", visibleSide == Back )
            ]
            :: attributes
        )
        [ Html.div [ HtmlA.class "aspect" ] [ front shared getSummary viewBody viewInstructions source, back shared ] ]


{-| Render an unknown card to HTML, face-down.
-}
viewUnknown : Shared -> String -> List (Html.Attribute msg) -> Html msg
viewUnknown shared cardTypeClass attributes =
    Html.div (HtmlA.class "game-card face-down" :: (HtmlA.class cardTypeClass :: attributes))
        [ Html.div [ HtmlA.class "aspect" ] [ back shared ] ]


{-| Fill a blank response into a normal one from a dictionary, falling back to nothing if the card id isn't in it.
-}
fillFromDict : Dict Id String -> Response -> Response
fillFromDict values response =
    case response.details.source of
        Source.Custom ->
            { response | body = values |> Dict.get response.details.id |> Maybe.withDefault response.body }

        _ ->
            response



{- Private -}


cardSide : Side -> List (Html msg) -> Html msg
cardSide side content =
    Html.div [ HtmlA.classList [ ( "side", True ), ( "front", side == Front ), ( "back", side == Back ) ] ] content


back : Shared -> Html msg
back shared =
    let
        renderWord word =
            Html.p [] [ Html.span [] [ Html.text word ] ]
    in
    cardSide Back
        [ Html.div [ HtmlA.class "content" ]
            (Strings.MassiveDecks |> Lang.string shared |> String.words |> List.map renderWord)
        ]


front : Shared -> Configure.GetSummary -> ViewBody msg -> ViewInstructions msg -> Source -> Html msg
front shared getSummary (ViewBody viewBody) viewInstructions source =
    cardSide Front
        [ Html.div [ HtmlA.class "content" ] (viewBody ())
        , info shared getSummary viewInstructions source
        ]


info : Shared -> Configure.GetSummary -> ViewInstructions msg -> Source -> Html msg
info shared getSummary (ViewInstructions viewInstructions) source =
    Html.div [ HtmlA.class "card-info" ] ((source |> viewSource shared getSummary) :: viewInstructions ())


viewSource : Shared -> Configure.GetSummary -> Source -> Html msg
viewSource shared getSummary s =
    let
        sourceDetails =
            s
                |> getSummary
                |> Maybe.map .details
                |> Maybe.withDefault (Source.defaultDetails shared s)
    in
    Html.div
        [ HtmlA.class "source", HtmlA.title sourceDetails.name ]
        [ Maybe.transformWith (Html.text sourceDetails.name) makeLink sourceDetails.url ]


makeLink : Html msg -> String -> Html msg
makeLink text url =
    Html.blankA [ HtmlA.href url ] [ text ]
