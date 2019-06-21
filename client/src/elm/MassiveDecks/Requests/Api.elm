module MassiveDecks.Requests.Api exposing
    ( checkAlive
    , joinLobby
    , lobbySummaries
    , newLobby
    )

import Dict exposing (Dict)
import Http
import Json.Decode
import MassiveDecks.Models.Decoders as Decoders
import MassiveDecks.Models.Encoders as Encoders
import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Pages.Start.LobbyBrowser.Model as LobbyBrowser
import MassiveDecks.Pages.Start.Model as Start
import MassiveDecks.Requests.Request exposing (Request)
import MassiveDecks.User as User
import Url.Builder


{-| List the public lobbies.
-}
lobbySummaries : Request (List LobbyBrowser.Summary)
lobbySummaries =
    { method = "GET"
    , headers = []
    , url = url [ "games" ]
    , body = Http.emptyBody
    , expect = Http.expectJson identity (Json.Decode.list Decoders.lobbySummary)
    , timeout = Nothing
    , tracker = Nothing
    }


{-| Create a new lobby.
-}
newLobby : Start.LobbyCreation -> Request Lobby.Token
newLobby creation =
    { method = "POST"
    , headers = []
    , url = url [ "games" ]
    , body = creation |> Encoders.lobbyCreation |> Http.jsonBody
    , expect = Http.expectJson identity Decoders.lobbyToken
    , timeout = Nothing
    , tracker = Nothing
    }


joinLobby : GameCode -> User.Registration -> Request Lobby.Token
joinLobby gameCode registration =
    { method = "POST"
    , headers = []
    , url = url [ "games", gameCode |> GameCode.toString ]
    , body = registration |> Encoders.userRegistration |> Http.jsonBody
    , expect = Http.expectJson identity Decoders.lobbyToken
    , timeout = Nothing
    , tracker = Nothing
    }


checkAlive : List Lobby.Token -> Request (Dict Lobby.Token Bool)
checkAlive tokens =
    { method = "POST"
    , headers = []
    , url = url [ "games", "alive" ]
    , body = tokens |> Encoders.checkAlive |> Http.jsonBody
    , expect = Http.expectJson identity Decoders.tokenValidity
    , timeout = Nothing
    , tracker = Nothing
    }



{- Private -}


url : List String -> String
url path =
    Url.Builder.absolute ([ "api" ] ++ path) []
