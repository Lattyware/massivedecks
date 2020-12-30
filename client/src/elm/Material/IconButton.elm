module Material.IconButton exposing
    ( view
    , viewCustomIcon
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
    viewRenderedIcon [ actionAttrFromMaybe HtmlE.onClick action ] shared title (renderIcon icon)


{-| View a button that displays as a simple icon, and blocks clicks propagating to other elements.
-}
viewNoPropagation : Shared -> MdString -> NeList (Icon.Presentation id msg) -> Maybe msg -> Html msg
viewNoPropagation shared title icon action =
    viewRenderedIcon [ actionAttrFromMaybe HtmlE.onClickNoPropagation action ] shared title (renderIcon icon)


{-| View a button that displays as a custom rendered icon.
-}
viewCustomIcon : Shared -> MdString -> Html msg -> Maybe msg -> Html msg
viewCustomIcon shared title icon action =
    viewRenderedIcon [ actionAttrFromMaybe HtmlE.onClick action ] shared title icon



{- Private -}


actionAttrFromMaybe : (a -> Html.Attribute msg) -> Maybe a -> Html.Attribute msg
actionAttrFromMaybe onClick action =
    case action of
        Just msg ->
            msg |> onClick

        Nothing ->
            HtmlA.disabled True


renderIcon : NeList (Icon.Presentation id msg) -> Html msg
renderIcon (NeList first rest) =
    case rest of
        [] ->
            first |> Icon.view

        _ ->
            (first :: rest) |> List.map Icon.view |> Icon.layers []


viewRenderedIcon : List (Html.Attribute msg) -> Shared -> MdString -> Html msg -> Html msg
viewRenderedIcon actionAttr shared title renderedIcon =
    Html.node "mwc-icon-button"
        ((title |> Lang.title shared) :: actionAttr)
        [ renderedIcon ]
