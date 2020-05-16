module Material.Button exposing
    ( Type(..)
    , view
    )

import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html.Attributes as HtmlA


type Type
    = Standard
    | Outlined
    | Raised
    | Unelevated


view : Shared -> Type -> MdString -> MdString -> Html msg -> List (Html.Attribute msg) -> Html msg
view shared type_ label title icon attributes =
    let
        typeAttr =
            case type_ of
                Standard ->
                    []

                Outlined ->
                    [ HtmlA.attribute "outlined" "" ]

                Raised ->
                    [ HtmlA.attribute "raised" "" ]

                Unelevated ->
                    [ HtmlA.attribute "unelevated" "" ]

        allAttrs =
            List.concat
                [ [ label |> Lang.label shared
                  , title |> Lang.title shared
                  ]
                , typeAttr
                , attributes
                ]
    in
    Html.node "mwc-button" allAttrs [ Html.span [ HtmlA.slot "icon" ] [ icon ] ]
