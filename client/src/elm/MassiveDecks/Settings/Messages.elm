module MassiveDecks.Settings.Messages exposing (Msg(..))

import Dict exposing (Dict)
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Settings.Model exposing (..)
import MassiveDecks.Strings.Languages.Model exposing (Language)


type Msg
    = ChangeLang (Maybe Language)
    | ChangeCardSize CardSize
    | ChangeOpenUserList Bool
    | ToggleOpen
    | RemoveInvalid (Dict Lobby.Token Bool)
    | ToggleSpeech Bool
    | ToggleAutoAdvance Bool
    | ChangeSpeech String
    | ToggleNotifications Bool
    | ToggleOnlyWhenHidden Bool
    | NoOp
