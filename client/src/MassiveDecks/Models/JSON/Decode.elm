module MassiveDecks.Models.JSON.Decode exposing (..)

import Json.Decode exposing (..)
import MassiveDecks.Models.Game as Game
import MassiveDecks.Models.Game.Round as Round exposing (Round)
import MassiveDecks.Models.Player as Player exposing (Player)
import MassiveDecks.Models.Card as Card
import MassiveDecks.Scenes.Playing.HouseRule.Id as HouseRule


lobbyAndHandDecoder : Decoder Game.LobbyAndHand
lobbyAndHandDecoder =
    map2 Game.LobbyAndHand
        (field "lobby" lobbyDecoder)
        (field "hand" handDecoder)


lobbyDecoder : Decoder Game.Lobby
lobbyDecoder =
    map5 Game.Lobby
        (field "gameCode" string)
        (field "owner" playerIdDecoder)
        (field "config" configDecoder)
        (field "players" (list playerDecoder))
        (field "state" gameStateDecoder)


gameCodeAndSecretDecoder : Decoder Game.GameCodeAndSecret
gameCodeAndSecretDecoder =
    map2 Game.GameCodeAndSecret
        (field "gameCode" string)
        (field "secret" playerSecretDecoder)


deckInfoDecoder : Decoder Game.DeckInfo
deckInfoDecoder =
    map4 Game.DeckInfo
        (field "id" string)
        (field "name" string)
        (field "calls" int)
        (field "responses" int)


configDecoder : Decoder Game.Config
configDecoder =
    map3 Game.Config
        (field "decks" (list deckInfoDecoder))
        (field "houseRules" (list houseRuleDecoder))
        (maybe (field "password" string))


handDecoder : Decoder Card.Hand
handDecoder =
    map Card.Hand
        (field "hand" (list responseDecoder))


playerDecoder : Decoder Player
playerDecoder =
    map6 Player
        (field "id" playerIdDecoder)
        (field "name" string)
        (field "status" playerStatusDecoder)
        (field "score" int)
        (field "disconnected" bool)
        (field "left" bool)


playerStatusDecoder : Decoder Player.Status
playerStatusDecoder =
    customDecoder (string) (\name -> Player.nameToStatus name |> Result.fromMaybe ("Unknown player status '" ++ name ++ "'."))


gameStateDecoder : Decoder Game.State
gameStateDecoder =
    (field "gameState" string
        |> andThen
            (\gameState ->
                case gameState of
                    "configuring" ->
                        succeed Game.Configuring

                    "playing" ->
                        map Game.Playing (field "round" roundDecoder)

                    "finished" ->
                        succeed Game.Finished

                    _ ->
                        fail ("Unknown game state '" ++ gameState ++ "'.")
            )
    )


roundDecoder : Decoder Round
roundDecoder =
    map3 Round
        (field "czar" playerIdDecoder)
        (field "call" callDecoder)
        (field "state" roundStateDecoder)


roundStateDecoder : Decoder Round.State
roundStateDecoder =
    (field "roundState" string
        |> andThen
            (\roundState ->
                case roundState of
                    "playing" ->
                        map2 Round.playing
                            (field "numberPlayed" int)
                            (field "afterTimeLimit" bool)

                    "judging" ->
                        map2 Round.judging
                            (field "cards" (list (list responseDecoder)))
                            (field "afterTimeLimit" bool)

                    "finished" ->
                        map Round.F finishedStateDecoder

                    _ ->
                        fail ("Unknown round state '" ++ roundState ++ "'.")
            )
    )


finishedStateDecoder : Decoder Round.Finished
finishedStateDecoder =
    map2 Round.Finished
        (field "cards" (list (list responseDecoder)))
        (field "playedByAndWinner" playedByAndWinnerDecoder)


finishedRoundDecoder : Decoder Round.FinishedRound
finishedRoundDecoder =
    map3 Round.FinishedRound
        (field "czar" playerIdDecoder)
        (field "call" callDecoder)
        (field "state" finishedStateDecoder)


playedByAndWinnerDecoder : Decoder Player.PlayedByAndWinner
playedByAndWinnerDecoder =
    map2 Player.PlayedByAndWinner
        (field "playedBy" (list (playerIdDecoder)))
        (field "winner" playerIdDecoder)


callDecoder : Decoder Card.Call
callDecoder =
    map2 Card.Call
        (field "id" string)
        (field "parts" (list string))


responseDecoder : Decoder Card.Response
responseDecoder =
    map2 Card.Response
        (field "id" string)
        (field "text" string)


playerIdDecoder : Decoder Player.Id
playerIdDecoder =
    int


playerSecretDecoder : Decoder Player.Secret
playerSecretDecoder =
    map2 Player.Secret
        (field "id" playerIdDecoder)
        (field "secret" string)


houseRuleDecoder : Decoder HouseRule.Id
houseRuleDecoder =
    customDecoder (string) (\name -> ruleNameToId name |> Result.fromMaybe ("Unknown house rule '" ++ name ++ "'."))


ruleNameToId : String -> Maybe HouseRule.Id
ruleNameToId name =
    case name of
        "reboot" ->
            Just HouseRule.Reboot

        _ ->
            Nothing


customDecoder : Decoder b -> (b -> Result String a) -> Decoder a
customDecoder decoder toResult =
    andThen
        (\a ->
            case toResult a of
                Ok b ->
                    succeed b

                Err err ->
                    fail err
        )
        decoder
