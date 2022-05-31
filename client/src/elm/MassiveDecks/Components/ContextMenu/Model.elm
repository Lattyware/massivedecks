module MassiveDecks.Components.ContextMenu.Model exposing
    ( Item
    , Menu
    , Part(..)
    )

import FontAwesome as Icon exposing (Icon)
import MassiveDecks.Strings exposing (MdString)


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
    | Ignore


{-| A menu item
-}
type alias Item =
    { icon : Icon Icon.WithoutId
    , text : MdString
    , description : MdString
    }
