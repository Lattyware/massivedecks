module MassiveDecks.Card exposing
    ( view
    , viewUnknown
    )

import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Card.Model exposing (..)
import MassiveDecks.Card.Source as Source
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Pages.Lobby.Configure.Model as Configure
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Maybe as Maybe


{-| Render a card to HTML, with the given side face-up.
-}
view : String -> List Configure.Deck -> Side -> List (Html.Attribute msg) -> ViewBody msg -> ViewInstructions msg -> Source -> Html msg
view cardTypeClass decks visibleSide attributes viewBody viewInstructions source =
    Html.div
        (HtmlA.classList
            [ ( "game-card", True )
            , ( cardTypeClass, True )
            , ( "face-down", visibleSide == Back )
            ]
            :: attributes
        )
        [ Html.div [ HtmlA.class "aspect" ] [ front decks viewBody viewInstructions source, back ] ]


{-| Render an unknown card to HTML, face-down.
-}
viewUnknown : String -> List (Html.Attribute msg) -> Html msg
viewUnknown cardTypeClass attributes =
    Html.div (HtmlA.class "game-card face-down" :: (HtmlA.class cardTypeClass :: attributes))
        [ Html.div [ HtmlA.class "aspect" ] [ back ] ]



{- Private -}


cardSide : Side -> List (Html msg) -> Html msg
cardSide side content =
    Html.div [ HtmlA.classList [ ( "side", True ), ( "front", side == Front ), ( "back", side == Back ) ] ] content


back : Html msg
back =
    cardSide Back
        [ Html.div [ HtmlA.class "content" ]
            [ Html.p [] [ Html.span [] [ Html.text "Massive" ] ], Html.p [] [ Html.span [] [ Html.text "Decks" ] ] ]
        ]


front : List Configure.Deck -> ViewBody msg -> ViewInstructions msg -> Source -> Html msg
front decks (ViewBody viewBody) viewInstructions source =
    cardSide Front
        [ Html.div [ HtmlA.class "content" ] (viewBody ())
        , info decks viewInstructions source
        ]


info : List Configure.Deck -> ViewInstructions msg -> Source -> Html msg
info decks (ViewInstructions viewInstructions) source =
    Html.div [ HtmlA.class "info" ] ((source |> viewSource decks) :: viewInstructions ())


viewSource : List Configure.Deck -> Source -> Html msg
viewSource decks s =
    let
        sourceDetails =
            decks
                |> List.filter (\d -> Source.equals (Source.Ex d.source) s)
                |> List.head
                |> Maybe.andThen .summary
                |> Maybe.map .details
                |> Maybe.withDefault (Source.details s)
    in
    Html.div
        [ HtmlA.class "source" ]
        [ Maybe.transformWith (Html.text sourceDetails.name) makeLink sourceDetails.url ]


makeLink : Html msg -> String -> Html msg
makeLink text url =
    Html.blankA [ HtmlA.href url ] [ text ]
