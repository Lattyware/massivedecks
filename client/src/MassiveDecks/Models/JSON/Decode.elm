module MassiveDecks.Models.JSON.Decode exposing (..)

import Json.Decode exposing (..)

import MassiveDecks.Models.Game as Game
import MassiveDecks.Models.Game.Round as Round exposing (Round)
import MassiveDecks.Models.Player as Player exposing (Player)
import MassiveDecks.Models.Card as Card
import MassiveDecks.Scenes.Playing.HouseRule.Id as HouseRule


lobbyAndHandDecoder : Decoder Game.LobbyAndHand
lobbyAndHandDecoder = object2 Game.LobbyAndHand
  ("lobby" := lobbyDecoder)
  ("hand" := handDecoder)


lobbyDecoder : Decoder Game.Lobby
lobbyDecoder = object4 Game.Lobby
  ("gameCode" := string)
  ("config" := configDecoder)
  ("players" := (list playerDecoder))
  ("state" := gameStateDecoder)


deckInfoDecoder : Decoder Game.DeckInfo
deckInfoDecoder = object4 Game.DeckInfo
  ("id" := string)
  ("name" := string)
  ("calls" := int)
  ("responses" := int)


configDecoder : Decoder Game.Config
configDecoder = object2 Game.Config
  ("decks" := (list deckInfoDecoder))
  ("houseRules" := (list houseRuleDecoder))


handDecoder : Decoder Card.Hand
handDecoder = object1 Card.Hand
  ("hand" := (list responseDecoder))


playerDecoder : Decoder Player
playerDecoder = object6 Player
  ("id" := playerIdDecoder)
  ("name" := string)
  ("status" := playerStatusDecoder)
  ("score" := int)
  ("disconnected" := bool)
  ("left" := bool)


playerStatusDecoder : Decoder Player.Status
playerStatusDecoder = customDecoder (string) (\name -> Player.nameToStatus name |> Result.fromMaybe ("Unknown player status '" ++ name ++ "'."))


gameStateDecoder : Decoder Game.State
gameStateDecoder =
  ("gameState" := string) `andThen` (\gameState ->
    case gameState of
      "configuring" ->
        succeed Game.Configuring

      "playing" ->
        map Game.Playing roundDecoder

      "finished" ->
        succeed Game.Finished

      _ ->
        fail ("Unknown game state '" ++ gameState ++ "'."))


roundDecoder : Decoder Round
roundDecoder = object3 Round
  ("czar" := playerIdDecoder)
  ("call" := callDecoder)
  ("state" := roundStateDecoder)


roundStateDecoder : Decoder Round.State
roundStateDecoder =
  ("roundState" := string) `andThen` (\roundState ->
    case roundState of
      "playing" ->
        object2 Round.playing
          ("numberPlayed" := int)
          ("afterTimeLimit" := bool)

      "judging" ->
        object2 Round.judging
          ("cards" := list (list responseDecoder))
          ("afterTimeLimit" := bool)

      "finished" ->
        map Round.F finishedStateDecoder

      _ ->
        fail ("Unknown round state '" ++ roundState ++ "'."))

finishedStateDecoder : Decoder Round.Finished
finishedStateDecoder = object2 Round.Finished
  ("cards" := list (list responseDecoder))
  ("playedByAndWinner" := playedByAndWinnerDecoder)


finishedRoundDecoder : Decoder Round.FinishedRound
finishedRoundDecoder = object3 Round.FinishedRound
  ("czar" := playerIdDecoder)
  ("call" := callDecoder)
  ("state" := finishedStateDecoder)


playedByAndWinnerDecoder : Decoder Player.PlayedByAndWinner
playedByAndWinnerDecoder = object2 Player.PlayedByAndWinner
  ("playedBy" := list (playerIdDecoder))
  ("winner" := playerIdDecoder)


callDecoder : Decoder Card.Call
callDecoder = object2 Card.Call
  ("id" := string)
  ("parts" := list string)


responseDecoder : Decoder Card.Response
responseDecoder = object2 Card.Response
  ("id" := string)
  ("text" := string)


playerIdDecoder : Decoder Player.Id
playerIdDecoder = int


playerSecretDecoder : Decoder Player.Secret
playerSecretDecoder = object2 Player.Secret
    ("id" := playerIdDecoder)
    ("secret" := string)


houseRuleDecoder : Decoder HouseRule.Id
houseRuleDecoder = customDecoder (string) (\name -> ruleNameToId name |> Result.fromMaybe ("Unknown house rule '" ++ name ++ "'."))

ruleNameToId : String -> Maybe HouseRule.Id
ruleNameToId name =
  case name of
    "reboot" -> Just HouseRule.Reboot
    _ -> Nothing
