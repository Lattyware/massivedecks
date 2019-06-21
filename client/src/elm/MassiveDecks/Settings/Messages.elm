module MassiveDecks.Settings.Messages exposing (Msg(..))

import Dict exposing (Dict)
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Strings.Languages.Model exposing (Language)


type Msg
    = ChangeLang (Maybe Language)
    | ChangeCompactCards Bool
    | ChangeOpenUserList Bool
    | ToggleOpen
    | RemoveInvalid (Dict Lobby.Token Bool)
