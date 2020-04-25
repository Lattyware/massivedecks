module MassiveDecks.Settings.Model exposing
    ( CardSize(..)
    , Model
    , Settings
    , cardSizeFromValue
    , cardSizeToValue
    )

import Dict exposing (Dict)
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Notifications.Model as Notifications
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Speech as Speech
import MassiveDecks.Strings.Languages.Model exposing (Language)


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
    , cardSize : CardSize
    , speech : Speech.Settings
    , notifications : Notifications.Settings
    , autoAdvance : Maybe Bool
    }


type CardSize
    = Minimal
    | Square
    | Full


cardSizeToValue : CardSize -> Int
cardSizeToValue size =
    case size of
        Minimal ->
            1

        Square ->
            2

        Full ->
            3


cardSizeFromValue : Int -> Maybe CardSize
cardSizeFromValue size =
    case size of
        1 ->
            Just Minimal

        2 ->
            Just Square

        3 ->
            Just Full

        _ ->
            Nothing
