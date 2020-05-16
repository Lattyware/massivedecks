module Material.Fab exposing
    ( Type(..)
    , view
    )

import FontAwesome.Icon as Icon exposing (Icon)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html.Attributes as HtmlA


type Type
    = Normal
    | Extended
    | Mini


view : Shared -> Type -> MdString -> Icon.Presentation id msg -> Maybe msg -> List (Html.Attribute msg) -> Html msg
view shared type_ title icon action attrs =
    let
        content =
            case type_ of
                Extended ->
                    [ title |> Lang.html shared ]

                _ ->
                    []

        style =
            case type_ of
                Mini ->
                    [ HtmlA.attribute "mini" "" ]

                _ ->
                    []

        onClick =
            case action of
                Just msg ->
                    msg |> HtmlE.onClick

                Nothing ->
                    HtmlA.attribute "disabled" ""
    in
    Html.node "mwc-fab"
        (List.concat [ [ title |> Lang.title shared, onClick ], style, attrs ])
        ((icon |> Icon.styled [ HtmlA.slot "icon" ] |> Icon.view) :: content)
