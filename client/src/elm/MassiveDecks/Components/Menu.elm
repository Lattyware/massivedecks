module MassiveDecks.Components.Menu exposing
    ( Item
    , Menu
    , Part(..)
    , item
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
import Weightless as Wl
import Weightless.Attributes as WlA


{-| A menu.
-}
type alias Menu msg =
    List (Part msg)


{-| A part of a menu.
-}
type Part msg
    = Part (Item msg)
    | Separator
    | Nothing


{-| A menu item
-}
type alias Item msg =
    { icon : Icon
    , text : MdString
    , description : MdString
    , action : Maybe msg
    }


{-| Convenience function for an item part.
-}
item : Icon -> MdString -> MdString -> Maybe msg -> Part msg
item icon text description action =
    Item icon text description action |> Part


{-| Render a menu to Html.
-}
view : Shared -> String -> WlA.XOrigin -> WlA.YOrigin -> Menu msg -> Html msg
view shared anchorId xOrigin yOrigin menu =
    Wl.popover
        (List.concat
            [ [ WlA.anchor anchorId
              , WlA.fixed
              , WlA.anchorOpenEvents [ "click" ]
              , HtmlA.id "game-menu"
              , HtmlA.class "menu"
              , WlA.disableFocusTrap
              ]
            , WlA.anchorOrigin xOrigin yOrigin
            ]
        )
        [ Wl.popoverCard [] [ Html.ul [] (menu |> List.map (menuItem shared)) ] ]



{- Private -}


menuItem : Shared -> Part msg -> Html msg
menuItem shared mi =
    case mi of
        Part { icon, text, description, action } ->
            let
                actionAttrs =
                    action
                        |> Maybe.map (\m -> [ m |> HtmlE.onClick, WlA.clickable ])
                        |> Maybe.withDefault [ WlA.disabled ]

                attrs =
                    (description |> Lang.title shared) :: actionAttrs
            in
            Html.li []
                [ Wl.listItem attrs
                    [ Icon.viewStyled [ WlA.listItemSlot WlA.BeforeItem, Icon.fw ] icon

                    -- We have an icon already, so we don't want to enhance this.
                    , text |> Lang.string shared |> Html.text
                    ]
                ]

        Separator ->
            Html.li [] [ Html.hr [] [] ]

        Nothing ->
            Html.nothing
