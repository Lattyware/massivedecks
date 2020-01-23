module MassiveDecks.Pages.Spectate.Messages exposing (Msg(..))

import MassiveDecks.Pages.Lobby.Messages as Lobby


type Msg
    = LobbyMsg Lobby.Msg
    | ToggleAdvert
