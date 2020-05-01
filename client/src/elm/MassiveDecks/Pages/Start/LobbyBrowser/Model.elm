module MassiveDecks.Pages.Start.LobbyBrowser.Model exposing
    ( Model
    , Summary
    , UserSummary
    )

import MassiveDecks.Pages.Lobby.GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Requests.HttpData.Model exposing (HttpData)


{-| The model for the lobby browser.
-}
type alias Model =
    HttpData Never (List Summary)


{-| An external summary of a lobby.
-}
type alias Summary =
    { name : String
    , gameCode : GameCode
    , state : Lobby.State
    , users : UserSummary
    , password : Bool
    }


{-| A summary of the users in a lobby.
-}
type alias UserSummary =
    { players : Int
    , spectators : Int
    }
