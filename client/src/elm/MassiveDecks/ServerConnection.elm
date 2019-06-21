module MassiveDecks.ServerConnection exposing
    ( connect
    , disconnect
    , message
    , notifications
    )

import Json.Decode as JsonDecode
import Json.Encode as Json
import MassiveDecks.Models.Decoders as Decoders
import MassiveDecks.Models.MdError exposing (MdError)
import MassiveDecks.Pages.Lobby.Events exposing (Event)
import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Ports as Ports


connect : GameCode -> Lobby.Token -> Cmd msg
connect gameCode token =
    Json.object
        [ ( "gameCode", gameCode |> GameCode.toString |> Json.string )
        , ( "token", Json.string token )
        ]
        |> Ports.serverSend


message : Json.Value -> Cmd msg
message value =
    Json.object [ ( "message", value |> Json.encode 0 |> Json.string ) ] |> Ports.serverSend


disconnect : Cmd msg
disconnect =
    Json.object [] |> Ports.serverSend


notifications : (Event -> msg) -> (MdError -> msg) -> (JsonDecode.Error -> msg) -> Sub msg
notifications handle handleError handleJsonError =
    Ports.serverRecv
        (JsonDecode.decodeString Decoders.eventOrMdError >> eventOrError handle handleError handleJsonError)


eventOrError :
    (Event -> msg)
    -> (MdError -> msg)
    -> (JsonDecode.Error -> msg)
    -> Result JsonDecode.Error (Result MdError Event)
    -> msg
eventOrError handle handleError handleJsonError result =
    case result of
        Ok (Ok event) ->
            handle event

        Ok (Err error) ->
            handleError error

        Err error ->
            handleJsonError error
