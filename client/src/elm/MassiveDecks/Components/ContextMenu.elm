module MassiveDecks.Components.ContextMenu exposing
    ( button
    , link
    , open
    , toggle
    , view
    )

import FontAwesome as Icon exposing (Icon)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Attributes.Aria as HtmlA
import MassiveDecks.Components.ContextMenu.Model exposing (..)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Html.Attributes as HtmlA
import Material.ListView as ListView
import Material.Menu as Menu


{-| Toggle the state of a menu.
-}
toggle : Menu.State -> Menu.State
toggle state =
    case state of
        Menu.Open ->
            Menu.Closed

        Menu.Closed ->
            Menu.Open


{-| Get an open state from a boolean indicating if the menu is open.
-}
open : Bool -> Menu.State
open isOpen =
    if isOpen then
        Menu.Open

    else
        Menu.Closed


{-| Convenience function for a menu button.
-}
button : Icon Icon.WithoutId -> MdString -> MdString -> Maybe msg -> Part msg
button icon text description action =
    Button (Item icon text description) action


{-| Convenience function for a menu link.
-}
link : Icon Icon.WithoutId -> MdString -> MdString -> Maybe String -> Part msg
link icon text description href =
    Link (Item icon text description) href


{-| Render a menu to Html.
-}
view : Shared -> msg -> Menu.State -> Menu.Corner -> Html msg -> Menu msg -> Html msg
view shared onClose state corner anchor menu =
    Menu.view onClose state corner anchor (menu |> List.map (menuItem shared))



{- Private -}


menuItem : Shared -> Part msg -> Html msg
menuItem shared mi =
    case mi of
        Button { icon, text, description } action ->
            ListView.viewItem
                (ListView.Button action)
                (icon |> Icon.view |> Just)
                ([ description |> Lang.string shared |> Html.text ] |> Just)
                Nothing
                [ text |> Lang.string shared |> Html.text ]

        Link { icon, text, description } href ->
            let
                linkify =
                    List.singleton
                        >> Html.blankA
                            [ href
                                |> Maybe.map HtmlA.href
                                |> Maybe.withDefault HtmlA.nothing
                            ]
            in
            -- TODO: Deal with being disabled in a decent way.
            ListView.viewItem
                (ListView.Link linkify)
                (icon |> Icon.view |> Just)
                ([ description |> Lang.string shared |> Html.text ] |> Just)
                Nothing
                [ text |> Lang.string shared |> Html.text ]

        Separator ->
            Html.li [ HtmlA.attribute "divider" "divider", HtmlA.role "separator" ] []

        Ignore ->
            Html.nothing
