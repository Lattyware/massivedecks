module MassiveDecks.Pages.Start.Model exposing
    ( LobbyCreation
    , Model
    )

import MassiveDecks.Models.MdError exposing (LobbyNotFoundError, MdError)
import MassiveDecks.Pages.Lobby.GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Pages.Start.LobbyBrowser.Model as LobbyBrowser
import MassiveDecks.Pages.Start.Route exposing (Route)
import MassiveDecks.Requests.HttpData.Model exposing (HttpData)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.User as User


{-| Data for the start page.
-}
type alias Model =
    { route : Route
    , lobbies : LobbyBrowser.Model
    , name : String
    , gameCode : Maybe GameCode
    , newLobbyRequest : HttpData Never Lobby.Auth
    , joinLobbyRequest : HttpData MdError Lobby.Auth
    , password : Maybe String
    , overlay : Maybe MdString
    }


{-| A request to create a new lobby.
-}
type alias LobbyCreation =
    { name : String
    , owner : User.Registration
    }
