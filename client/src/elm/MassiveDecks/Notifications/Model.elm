module MassiveDecks.Notifications.Model exposing
    ( Message
    , Model
    , Msg
    , Permission(..)
    , Settings
    , Visibility(..)
    , default
    )

import MassiveDecks.Strings exposing (MdString)


{-| Permissions from the browser to send notifications.
-}
type Permission
    = Default
    | Denied
    | Granted
    | NotificationsUnsupported


{-| If the page is visible.
-}
type Visibility
    = Visible
    | Hidden
    | VisibilityUnsupported


{-| A message to display as a notification.
-}
type alias Message =
    { title : MdString
    , body : MdString
    }


{-| The current transient state of the notification system.
-}
type alias Model =
    { permission : Permission
    , visibility : Visibility
    }


{-| The permanent state of the notification system.
-}
type alias Settings =
    { enabled : Bool
    , requireNotVisible : Bool
    }


{-| The default settings for the notification system.
-}
default : Settings
default =
    { enabled = False
    , requireNotVisible = True
    }


{-| A change to the state from the notification manager.
-}
type alias Msg =
    { permission : Maybe Permission
    , visibility : Maybe Visibility
    }
