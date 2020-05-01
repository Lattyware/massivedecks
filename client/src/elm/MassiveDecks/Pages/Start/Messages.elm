module MassiveDecks.Pages.Start.Messages exposing (Msg(..))

import MassiveDecks.Models.MdError exposing (MdError)
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Pages.Start.LobbyBrowser.Messages as LobbyBrowser
import MassiveDecks.Requests.HttpData.Messages as HttpData


type Msg
    = GameCodeChanged String
    | NameChanged String
    | StartGame (HttpData.Msg Never Lobby.Auth)
    | JoinGame (HttpData.Msg MdError Lobby.Auth)
    | LobbyBrowserMsg LobbyBrowser.Msg
    | PasswordChanged String
    | JoinFailure MdError
    | HideOverlay
