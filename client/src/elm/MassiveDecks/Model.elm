module MassiveDecks.Model exposing
    ( Flags
    , Shared
    )

import Browser.Navigation as Navigation
import MassiveDecks.Cast.Model as Cast
import MassiveDecks.Settings.Model as Settings exposing (Settings)
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
    }


{-| Flags passed to the application from init code.
-}
type alias Flags =
    { settings : Settings
    , browserLanguages : List String
    }
