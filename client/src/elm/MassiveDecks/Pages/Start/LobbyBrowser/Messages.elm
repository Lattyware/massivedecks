module MassiveDecks.Pages.Start.LobbyBrowser.Messages exposing (Msg(..))

import MassiveDecks.Pages.Start.LobbyBrowser.Model exposing (..)
import MassiveDecks.Requests.HttpData.Messages as HttpData


type Msg
    = SummaryUpdate (HttpData.Msg Never (List Summary))
