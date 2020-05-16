module MassiveDecks.Components.Menu.Model exposing
    ( Corner(..)
    , Item
    , Menu
    , Part(..)
    , State(..)
    )

import FontAwesome.Icon exposing (Icon)
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
    { icon : Icon
    , text : MdString
    , description : MdString
    }


{-| The corner of the anchor element the menu should position itself at.
-}
type Corner
    = TopLeft
    | TopRight
    | BottomLeft
    | BottomRight
    | TopStart
    | TopEnd
    | BottomStart
    | BottomEnd


{-| If the menu is visible or not.
-}
type State
    = Open
    | Closed
