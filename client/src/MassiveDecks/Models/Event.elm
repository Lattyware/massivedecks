module MassiveDecks.Models.Event exposing (Event(..), fromJson)

import Json.Decode as Json
import MassiveDecks.Models.JSON.Decode exposing (..)
import MassiveDecks.Models.Game as Game
import MassiveDecks.Models.Game.Round as Round
import MassiveDecks.Models.Player as Player exposing (Player)
import MassiveDecks.Models.Card as Card


{-| An event represents a change in the game state from the server. These are recieved by websocket.
-}
type Event
    = Sync Game.LobbyAndHand
    | PlayerJoin Player
    | PlayerStatus Player.Id Player.Status
    | PlayerLeft Player.Id
    | PlayerDisconnect Player.Id
    | PlayerReconnect Player.Id
    | PlayerScoreChange Player.Id Int
    | HandChange Card.Hand
    | RoundStart Player.Id Card.Call
    | RoundPlayed Int
    | RoundJudging (List Card.PlayedCards)
    | RoundEnd Round.FinishedRound
    | GameStart Player.Id Card.Call
    | GameEnd
    | ConfigChange Game.Config
    | RoundTimeLimitHit


fromJson : String -> Result String Event
fromJson json =
    Json.decodeString eventDecoder json


eventDecoder : Json.Decoder Event
eventDecoder =
    (Json.field "event" Json.string) |> Json.andThen specificEventDecoder


specificEventDecoder : String -> Json.Decoder Event
specificEventDecoder name =
    case name of
        "Sync" ->
            Json.map Sync (Json.field "lobbyAndHand" lobbyAndHandDecoder)

        "PlayerJoin" ->
            Json.map PlayerJoin (Json.field "player" playerDecoder)

        "PlayerStatus" ->
            Json.map2 PlayerStatus (Json.field "player" playerIdDecoder) (Json.field "status" playerStatusDecoder)

        "PlayerLeft" ->
            Json.map PlayerLeft (Json.field "player" playerIdDecoder)

        "PlayerDisconnect" ->
            Json.map PlayerDisconnect (Json.field "player" playerIdDecoder)

        "PlayerReconnect" ->
            Json.map PlayerReconnect (Json.field "player" playerIdDecoder)

        "PlayerScoreChange" ->
            Json.map2 PlayerScoreChange (Json.field "player" playerIdDecoder) (Json.field "score" Json.int)

        "HandChange" ->
            Json.map HandChange (Json.field "hand" handDecoder)

        "RoundStart" ->
            Json.map2 RoundStart (Json.field "czar" playerIdDecoder) (Json.field "call" callDecoder)

        "RoundPlayed" ->
            Json.map RoundPlayed (Json.field "playedCards" Json.int)

        "RoundJudging" ->
            Json.map RoundJudging (Json.field "playedCards" (Json.list (Json.list responseDecoder)))

        "RoundEnd" ->
            Json.map RoundEnd (Json.field "finishedRound" finishedRoundDecoder)

        "GameStart" ->
            Json.map2 GameStart (Json.field "czar" playerIdDecoder) (Json.field "call" callDecoder)

        "GameEnd" ->
            Json.succeed GameEnd

        "ConfigChange" ->
            Json.map ConfigChange (Json.field "config" configDecoder)

        "RoundTimeLimitHit" ->
            Json.succeed RoundTimeLimitHit

        unknown ->
            Json.fail (unknown ++ " is not a recognised event.")
