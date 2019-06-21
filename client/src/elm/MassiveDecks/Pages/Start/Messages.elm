module MassiveDecks.Pages.Start.Messages exposing (Msg(..))

import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Pages.Start.LobbyBrowser.Messages as LobbyBrowser
import MassiveDecks.Requests.HttpData.Messages as HttpData


type Msg
    = GameCodeChanged String
    | NameChanged String
    | StartGame (HttpData.Msg Lobby.Auth)
    | JoinGame (HttpData.Msg Lobby.Auth)
    | LobbyBrowserMsg LobbyBrowser.Msg
