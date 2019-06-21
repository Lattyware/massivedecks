module MassiveDecks.Settings.Model exposing (Model, Settings)

import Dict exposing (Dict)
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Strings.Languages.Model as Lang exposing (Language)


{-| The model for the settings panel.
-}
type alias Model =
    { settings : Settings
    , open : Bool
    }


{-| Persisted data.
This is really more than just user settings, it's any persistent data we store in the user's local storage.
-}
type alias Settings =
    { tokens : Dict String Lobby.Token
    , openUserList : Bool
    , lastUsedName : Maybe String
    , recentDecks : List Source.External
    , chosenLanguage : Maybe Language
    , compactCards : Bool
    }
