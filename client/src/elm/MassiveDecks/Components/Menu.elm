module MassiveDecks.Components.Menu exposing
    ( button
    , link
    , open
    , toggle
    , view
    )

import FontAwesome.Icon exposing (Icon)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Attributes.Aria as HtmlA
import MassiveDecks.Components.Menu.Model exposing (..)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Html.Attributes as HtmlA
import Material.ListView as ListView
import Material.Menu as Menu


{-| Toggle the state of a menu.
-}
toggle : State -> State
toggle state =
    case state of
        Open ->
            Closed

        Closed ->
            Open


{-| Get an open state from a boolean indicating if the menu is open.
-}
open : Bool -> State
open isOpen =
    if isOpen then
        Open

    else
        Closed


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
view : Shared -> msg -> State -> Corner -> Html msg -> Menu msg -> Html msg
view shared onClose state corner anchor menu =
    Menu.view onClose state corner anchor (menu |> List.map (menuItem shared))



{- Private -}


menuItem : Shared -> Part msg -> Html msg
menuItem shared mi =
    case mi of
        Button { icon, text, description } action ->
            ListView.viewItem (ListView.action action)
                (Just icon)
                Nothing
                Nothing
                [ text |> Lang.string shared |> Html.text ]

        Link { icon, text, description } href ->
            -- TODO: Deal with being disabled in a decent way.
            Html.blankA [ href |> Maybe.map HtmlA.href |> Maybe.withDefault HtmlA.nothing ]
                [ ListView.viewItem
                    ListView.Link
                    (Just icon)
                    Nothing
                    Nothing
                    [ text |> Lang.string shared |> Html.text ]
                ]

        Separator ->
            Html.li [ HtmlA.attribute "divider" "divider", HtmlA.role "separator" ] []

        Ignore ->
            Html.nothing
