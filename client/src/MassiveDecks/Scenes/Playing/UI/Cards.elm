module MassiveDecks.Scenes.Playing.UI.Cards exposing (call, callText, response)

import String
import Html exposing (..)
import Html.Attributes exposing (..)
import MassiveDecks.Models.Card as Card
import MassiveDecks.Util as Util


call : Card.Call -> List Card.Response -> Html msg
call call picked =
    let
        responseFirst =
            call.parts |> List.head |> Maybe.map ((==) "") |> Maybe.withDefault False

        pickedText =
            List.map .text picked

        ( parts, responses ) =
            if responseFirst then
                ( call.parts, Util.mapFirst Util.firstLetterToUpper pickedText )
            else
                ( Util.mapFirst Util.firstLetterToUpper call.parts, pickedText )

        spanned =
            List.map (\part -> span [] [ text part ]) call.parts

        withSlots =
            Util.interleave (slots (Card.slots call) "" responses) spanned

        callContents =
            if responseFirst then
                List.tail withSlots |> Maybe.withDefault withSlots
            else
                withSlots
    in
        div [ class "card call mui-panel" ] [ div [ class "call-text" ] callContents ]


callText : Card.Call -> List Card.Response -> String
callText call picked =
    let
        responseFirst =
            call.parts |> List.head |> Maybe.map ((==) "") |> Maybe.withDefault False

        pickedText =
            List.map .text picked

        ( parts, responses ) =
            if responseFirst then
                ( call.parts, Util.mapFirst Util.firstLetterToUpper pickedText )
            else
                ( Util.mapFirst Util.firstLetterToUpper call.parts, pickedText )

        extra =
            (Card.slots call) - List.length picked

        withSlots =
            Util.interleave (List.concat [ pickedText, List.repeat extra "blank" ]) call.parts
    in
        String.join " " withSlots


slot : String -> Html msg
slot value =
    (span [ class "slot" ] [ text value ])


slots : Int -> String -> List String -> List (Html msg)
slots count placeholder picked =
    let
        extra =
            count - List.length picked
    in
        List.concat [ picked, List.repeat extra placeholder ] |> List.map slot


response : Bool -> List (Attribute msg) -> Card.Response -> Html msg
response picked attributes response =
    let
        classes =
            [ classList [ ( "card", True ), ( "response", True ), ( "mui-panel", True ), ( "picked", picked ) ] ]
    in
        div (List.concat [ classes, attributes ])
            [ div [ class "response-text" ] [ text (Util.firstLetterToUpper response.text), text "." ] ]
