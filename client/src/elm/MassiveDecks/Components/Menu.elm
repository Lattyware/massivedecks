module MassiveDecks.Components.Menu exposing
    ( Item
    , Menu
    , Part(..)
    , button
    , link
    , view
    )

import FontAwesome.Attributes as Icon
import FontAwesome.Icon as Icon exposing (Icon)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Model exposing (..)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Html.Attributes as HtmlA
import MassiveDecks.Util.Maybe as Maybe
import Weightless as Wl
import Weightless.Attributes as WlA


{-| A menu.
-}
type alias Menu msg =
    List (Part msg)


{-| A part of a menu.
-}
type Part msg
    = Button Item (Maybe msg)
    | Link Item (Maybe String)
    | Separator
    | Nothing


{-| A menu item
-}
type alias Item =
    { icon : Icon
    , text : MdString
    , description : MdString
    }


{-| Convenience function for a menu button.
-}
button : Icon -> MdString -> MdString -> Maybe msg -> Part msg
button icon text description action =
    Button (Item icon text description) action


{-| Convenience function for a menu link.
-}
link : Icon -> MdString -> MdString -> Maybe String -> Part msg
link icon text description href =
    Link (Item icon text description) href


{-| Render a menu to Html.
-}
view :
    Shared
    -> String
    -> ( WlA.XOrigin, WlA.YOrigin )
    -> ( WlA.XOrigin, WlA.YOrigin )
    -> Menu msg
    -> Html msg
view shared anchorId ( xAnchor, yAnchor ) ( xTransform, yTransform ) menu =
    Wl.popover
        (List.concat
            [ [ WlA.anchor anchorId
              , WlA.fixed
              , WlA.anchorOpenEvents [ "click" ]
              , HtmlA.id "game-menu"
              , HtmlA.class "menu"
              , WlA.disableFocusTrap
              ]
            , WlA.anchorOrigin xAnchor yAnchor
            , WlA.transformOrigin xTransform yTransform
            ]
        )
        [ Wl.popoverCard [] [ Html.ul [] (menu |> List.map (menuItem shared)) ] ]



{- Private -}


menuItem : Shared -> Part msg -> Html msg
menuItem shared mi =
    case mi of
        Button item action ->
            Html.li []
                [ listItem shared item (Maybe.isJust action) (action |> Maybe.map HtmlE.onClick |> Maybe.withDefault HtmlA.nothing)
                ]

        Link item href ->
            Html.li []
                [ Html.blankA [ href |> Maybe.map HtmlA.href |> Maybe.withDefault HtmlA.nothing ]
                    [ listItem shared item (Maybe.isJust href) HtmlA.nothing ]
                ]

        Separator ->
            Html.li [] [ Html.hr [] [] ]

        Nothing ->
            Html.nothing


listItem : Shared -> Item -> Bool -> Html.Attribute msg -> Html msg
listItem shared { icon, text, description } enabled attr =
    Wl.listItem
        [ description |> Lang.title shared
        , WlA.clickable |> Maybe.justIf enabled |> Maybe.withDefault WlA.disabled
        , attr
        ]
        [ Icon.viewStyled [ WlA.listItemSlot WlA.BeforeItem, Icon.fw ] icon

        -- We have an icon already, so we don't want to enhance this.
        , text |> Lang.string shared |> Html.text
        ]
