module MassiveDecks.Card exposing
    ( id
    , slotCount
    , source
    , view
    , viewFilled
    , viewUnknownCall
    , viewUnknownResponse
    )

import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Card.Model exposing (..)
import MassiveDecks.Card.Parts as Parts exposing (Parts)
import MassiveDecks.Card.Source as Source
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Model as Configure
import MassiveDecks.Strings exposing (MdString(..))
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Maybe as Maybe
import MassiveDecks.Util.String as String


{-| Render a card to HTML, with the given side face-up.
-}
view : Shared -> List Configure.Deck -> Side -> List (Html.Attribute msg) -> Card -> Html msg
view shared decks visibleSide extraAttributes card =
    viewInternal shared decks visibleSide extraAttributes [] card


{-| View a call rendered with the given play filling the slots.
-}
viewFilled : Shared -> List Configure.Deck -> Side -> List (Html.Attribute msg) -> List String -> Call -> Html msg
viewFilled shared decks visibleSide extraAttributes play card =
    viewInternal shared decks visibleSide extraAttributes play (C card)


{-| Render an unknown response to HTML, face-down.
-}
viewUnknownResponse : List (Html.Attribute msg) -> Html msg
viewUnknownResponse extraAttributes =
    viewUnknown (HtmlA.class "response" :: extraAttributes)


{-| Render an unknown response to HTML, face-down.
-}
viewUnknownCall : List (Html.Attribute msg) -> Html msg
viewUnknownCall extraAttributes =
    viewUnknown (HtmlA.class "call" :: extraAttributes)


{-| Get the source of a card.
-}
source : Card -> Source
source card =
    card |> details |> .source


{-| Get the id of a card.
-}
id : Card -> Id
id card =
    card |> details |> .id


{-| How many slots there are on a call.
-}
slotCount : Call -> Int
slotCount call =
    call.body |> Parts.slotCount



{- Private -}


viewInternal : Shared -> List Configure.Deck -> Side -> List (Html.Attribute msg) -> List String -> Card -> Html msg
viewInternal shared decks visibleSide extraAttributes play card =
    Html.div
        ([ HtmlA.classList
            [ ( "game-card", True )
            , ( cardTypeClass card, True )
            , ( "face-down", visibleSide == Back )
            ]
         ]
            ++ extraAttributes
        )
        [ Html.div [ HtmlA.class "aspect" ]
            [ front shared decks play card
            , back
            ]
        ]


viewUnknown : List (Html.Attribute msg) -> Html msg
viewUnknown extraAttributes =
    Html.div
        ([ HtmlA.class "game-card face-down" ] ++ extraAttributes)
        [ Html.div [ HtmlA.class "aspect" ]
            [ back ]
        ]


instructions : Shared -> Parts -> List (Html msg)
instructions shared parts =
    let
        slots =
            Parts.slotCount parts

        instructionViews =
            List.concat [ extraCardsInstruction shared slots, pickInstruction shared slots ]
    in
    if List.length instructionViews > 0 then
        [ Html.ol
            [ HtmlA.class "instructions" ]
            instructionViews
        ]

    else
        []


extraCardsInstruction : Shared -> Int -> List (Html msg)
extraCardsInstruction shared slots =
    let
        extraCards =
            slots - 1
    in
    if extraCards > 0 then
        [ Html.li [] [ Draw { numberOfCards = extraCards } |> Lang.html shared ]
        ]

    else
        []


pickInstruction : Shared -> Int -> List (Html msg)
pickInstruction shared slots =
    if slots > 1 then
        [ Html.li [] [ Pick { numberOfCards = slots } |> Lang.html shared ]
        ]

    else
        []


cardSide : Side -> List (Html msg) -> Html msg
cardSide side content =
    Html.div [ HtmlA.classList [ ( "side", True ), ( "front", side == Front ), ( "back", side == Back ) ] ] content


back : Html msg
back =
    cardSide Back
        [ Html.div [ HtmlA.class "content" ]
            [ Html.p [] [ Html.span [] [ Html.text "Massive" ] ], Html.p [] [ Html.span [] [ Html.text "Decks" ] ] ]
        ]


front : Shared -> List Configure.Deck -> List String -> Card -> Html msg
front shared decks play card =
    cardSide Front
        [ Html.div [ HtmlA.class "content" ]
            (case card of
                C call ->
                    Parts.viewFilled play call.body

                R response ->
                    [ Html.p [] [ Html.span [] [ response.body |> String.capitalise |> Html.text ] ] ]
            )
        , info shared decks card
        ]


info : Shared -> List Configure.Deck -> Card -> Html msg
info shared decks card =
    let
        instructionsInfo =
            case card of
                C call ->
                    instructions shared call.body

                R _ ->
                    []
    in
    Html.div [ HtmlA.class "info" ]
        ([ card |> source |> viewSource decks
         ]
            ++ instructionsInfo
        )


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


cardTypeClass : Card -> String
cardTypeClass card =
    case card of
        C _ ->
            "call"

        R _ ->
            "response"


details : Card -> Details
details card =
    case card of
        C call ->
            call.details

        R response ->
            response.details
