module MassiveDecks.Models.Event exposing (Event(..), fromJson)

import Json.Decode as Json exposing ((:=))

import MassiveDecks.Models.JSON.Decode exposing (..)
import MassiveDecks.Models.Game as Game
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
  | RoundEnd Game.FinishedRound

  | GameStart
  | GameEnd

  | ConfigChange Game.Config

  | RoundTimeLimitHit


fromJson : String -> Result String Event
fromJson json = Json.decodeString eventDecoder json


eventDecoder : Json.Decoder Event
eventDecoder =
  ("event" := Json.string) `Json.andThen` specificEventDecoder


specificEventDecoder : String  -> Json.Decoder Event
specificEventDecoder name =
  case name of
    "Sync" -> Json.object1 Sync ("lobbyAndHand" := lobbyAndHandDecoder)

    "PlayerJoin" -> Json.object1 PlayerJoin ("player" := playerDecoder)
    "PlayerStatus" -> Json.object2 PlayerStatus ("player" := playerIdDecoder) ("status" := playerStatusDecoder)
    "PlayerLeft" -> Json.object1 PlayerLeft ("player" := playerIdDecoder)
    "PlayerDisconnect" -> Json.object1 PlayerDisconnect ("player" := playerIdDecoder)
    "PlayerReconnect" -> Json.object1 PlayerReconnect ("player" := playerIdDecoder)
    "PlayerScoreChange" -> Json.object2 PlayerScoreChange ("player" := playerIdDecoder) ("score" := Json.int)

    "HandChange" -> Json.object1 HandChange ("hand" := handDecoder)

    "RoundStart" -> Json.object2 RoundStart ("czar" := playerIdDecoder) ("call" := callDecoder)
    "RoundPlayed" -> Json.object1 RoundPlayed ("playedCards" := Json.int)
    "RoundJudging" -> Json.object1 RoundJudging ("playedCards" := Json.list (Json.list responseDecoder))
    "RoundEnd" -> Json.object1 RoundEnd ("finishedRound" := finishedRoundDecoder)

    "GameStart" -> Json.succeed GameStart
    "GameEnd" -> Json.succeed GameEnd

    "ConfigChange" -> Json.object1 ConfigChange ("config" := configDecoder)

    "RoundTimeLimitHit" -> Json.succeed RoundTimeLimitHit

    unknown -> Json.fail (unknown ++ " is not a recognised event.")
