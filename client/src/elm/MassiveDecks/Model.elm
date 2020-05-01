module MassiveDecks.Model exposing
    ( Flags
    , Shared
    )

import Browser.Navigation as Navigation
import MassiveDecks.Card.Source.Model as Sources
import MassiveDecks.Cast.Model as Cast
import MassiveDecks.Notifications.Model as Notifications
import MassiveDecks.Settings.Model as Settings exposing (Settings)
import MassiveDecks.Speech as Speech
import MassiveDecks.Strings.Languages.Model exposing (Language)


{-| Model shared by all pages.
-}
type alias Shared =
    { language : Language
    , origin : String
    , key : Navigation.Key
    , settings : Settings.Model
    , browserLanguage : Maybe Language
    , castStatus : Cast.Status
    , speech : Speech.Model
    , notifications : Notifications.Model
    , remoteMode : Bool
    , sources : Sources.Info
    }


{-| Flags passed to the application from init code.
-}
type alias Flags =
    { settings : Maybe Settings
    , browserLanguages : List String
    , remoteMode : Bool
    }
