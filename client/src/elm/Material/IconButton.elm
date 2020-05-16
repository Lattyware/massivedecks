module Material.IconButton exposing
    ( view
    , viewNoPropagation
    )

import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Layering as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html.Events as HtmlE
import MassiveDecks.Util.NeList exposing (NeList(..))


{-| View a button that displays as a simple icon.
-}
view : Shared -> MdString -> NeList (Icon.Presentation id msg) -> Maybe msg -> Html msg
view shared title icon action =
    let
        actionAttr =
            case action of
                Just msg ->
                    msg |> HtmlE.onClick

                Nothing ->
                    HtmlA.disabled True
    in
    viewInternal [ actionAttr ] shared title icon


{-| View a button that displays as a simple icon, and blocks clicks propagating to other elements.
-}
viewNoPropagation : Shared -> MdString -> NeList (Icon.Presentation id msg) -> Maybe msg -> Html msg
viewNoPropagation shared title icon action =
    let
        actionAttr =
            case action of
                Just msg ->
                    msg |> HtmlE.onClickNoPropagation

                Nothing ->
                    HtmlA.disabled True
    in
    viewInternal [ actionAttr ] shared title icon



{- Private -}


viewInternal : List (Html.Attribute msg) -> Shared -> MdString -> NeList (Icon.Presentation id msg) -> Html msg
viewInternal actionAttr shared title (NeList first rest) =
    let
        renderedIcon =
            case rest of
                [] ->
                    first |> Icon.view

                _ ->
                    (first :: rest) |> List.map Icon.view |> Icon.layers []
    in
    Html.node "mwc-icon-button"
        ((title |> Lang.title shared) :: actionAttr)
        [ renderedIcon ]
