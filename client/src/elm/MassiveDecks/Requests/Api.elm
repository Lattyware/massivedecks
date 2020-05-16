module MassiveDecks.Requests.Api exposing
    ( checkAlive
    , joinLobby
    , lobbySummaries
    , newLobby
    , sourceInfo
    )

import Http
import Json.Decode as Json
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Error.Model as Error
import MassiveDecks.Models.Decoders as Decoders
import MassiveDecks.Models.Encoders as Encoders
import MassiveDecks.Models.MdError exposing (MdError)
import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Pages.Lobby.Token as Token
import MassiveDecks.Pages.Start.LobbyBrowser.Model as LobbyBrowser
import MassiveDecks.Pages.Start.Model as Start
import MassiveDecks.Requests.Request as Request exposing (Request)
import MassiveDecks.User as User
import MassiveDecks.Util.Result as Result
import Url.Builder


{-| List the public lobbies.
-}
lobbySummaries : (Request.Response Never (List LobbyBrowser.Summary) -> msg) -> Request msg
lobbySummaries msg =
    { method = "GET"
    , headers = []
    , url = url [ "games" ]
    , body = Http.emptyBody
    , expect = Request.expectResponse msg noError (Json.list Decoders.lobbySummary)
    , timeout = Nothing
    , tracker = Nothing
    }


{-| Create a new lobby.
-}
newLobby : (Request.Response Never Lobby.Auth -> msg) -> Start.LobbyCreation -> Request msg
newLobby msg creation =
    { method = "POST"
    , headers = []
    , url = url [ "games" ]
    , body = creation |> Encoders.lobbyCreation |> Http.jsonBody
    , expect = Request.expectResponse (decodeToken >> msg) noError Decoders.lobbyToken
    , timeout = Nothing
    , tracker = Nothing
    }


{-| Join a lobby.
-}
joinLobby : (Request.Response MdError Lobby.Auth -> msg) -> GameCode -> User.Registration -> Request msg
joinLobby msg gameCode registration =
    { method = "POST"
    , headers = []
    , url = url [ "games", gameCode |> GameCode.toString ]
    , body = registration |> Encoders.userRegistration |> Http.jsonBody
    , expect = Request.expectResponse (decodeToken >> msg) Decoders.mdError Decoders.lobbyToken
    , timeout = Nothing
    , tracker = Nothing
    }


{-| Check if previously joined lobbies are still going.
-}
checkAlive : (Request.Response Never (List Lobby.Token) -> msg) -> List Lobby.Token -> Request msg
checkAlive msg tokens =
    { method = "POST"
    , headers = []
    , url = url [ "alive" ]
    , body = tokens |> Encoders.checkAlive |> Http.jsonBody
    , expect = Request.expectResponse msg noError Decoders.tokenValidity
    , timeout = Nothing
    , tracker = Nothing
    }


{-| Find out what sources the server offers.
-}
sourceInfo : (Request.Response Never Source.Info -> msg) -> Request msg
sourceInfo msg =
    { method = "GET"
    , headers = []
    , url = url [ "sources" ]
    , body = Http.emptyBody
    , expect = Request.expectResponse msg noError Decoders.sourceInfo
    , timeout = Nothing
    , tracker = Nothing
    }



{- Private -}


decodeToken : Request.Response error Lobby.Token -> Request.Response error Lobby.Auth
decodeToken =
    Request.map
        Request.GeneralError
        Request.SpecificError
        (Token.decode >> Result.unifiedMap (Error.Token >> Request.GeneralError) Request.Value)


url : List String -> String
url path =
    Url.Builder.absolute ([ "api" ] ++ path) []


noError : Json.Decoder Never
noError =
    Json.fail "No specific errors are expected for this request."
