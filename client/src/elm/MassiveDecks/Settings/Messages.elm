module MassiveDecks.Settings.Messages exposing (Msg(..))

import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Settings.Model exposing (..)
import MassiveDecks.Strings.Languages.Model exposing (Language)


type Msg
    = ChangeLang (Maybe Language)
    | ChangeCardSize CardSize
    | ChangeOpenUserList Bool
    | ToggleOpen
    | RemoveInvalid (List Lobby.Token)
    | ToggleSpeech Bool
    | ToggleAutoAdvance Bool
    | ChangeSpeech (Maybe String)
    | ToggleNotifications Bool
    | ToggleOnlyWhenHidden Bool
    | NoOp
