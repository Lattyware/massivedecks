module Material.Menu exposing (view)

import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Json.Decode
import Json.Encode as Json
import MassiveDecks.Components.Menu.Model exposing (..)


{-| View a pop-up menu.
-}
view : msg -> State -> Corner -> Html msg -> List (Html msg) -> Html msg
view onClose state corner anchor menuItems =
    let
        open =
            case state of
                Open ->
                    True

                Closed ->
                    False

        stringCorner =
            case corner of
                TopLeft ->
                    "TOP_LEFT"

                TopRight ->
                    "TOP_RIGHT"

                BottomLeft ->
                    "BOTTOM_LEFT"

                BottomRight ->
                    "BOTTOM_RIGHT"

                TopStart ->
                    "TOP_START"

                TopEnd ->
                    "TOP_END"

                BottomStart ->
                    "BOTTOM_START"

                BottomEnd ->
                    "BOTTOM_END"
    in
    Html.div [ HtmlA.class "menu-anchor" ]
        [ anchor
        , Html.node "mwc-menu"
            [ True |> Json.bool |> HtmlA.property "activatable"
            , open |> Json.bool |> HtmlA.property "open"
            , stringCorner |> HtmlA.attribute "corner"
            , HtmlA.class "menu"
            , onClose |> Json.Decode.succeed |> HtmlE.on "closed"
            ]
            menuItems
        ]
