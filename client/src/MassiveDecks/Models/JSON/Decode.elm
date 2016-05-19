module MassiveDecks.Models.JSON.Decode exposing (..)

import Json.Decode exposing (..)

import MassiveDecks.Models.Game exposing (..)
import MassiveDecks.Models.Player exposing (..)
import MassiveDecks.Models.Card exposing (..)


lobbyAndHandDecoder : Decoder LobbyAndHand
lobbyAndHandDecoder = object2 LobbyAndHand
  ("lobby" := lobbyDecoder)
  ("hand" := handDecoder)


lobbyDecoder : Decoder Lobby
lobbyDecoder = object4 Lobby
  ("gameCode" := string)
  ("config" := configDecoder)
  ("players" := (list playerDecoder))
  (maybe ("round" := roundDecoder))


deckInfoDecoder : Decoder DeckInfo
deckInfoDecoder = object4 DeckInfo
  ("id" := string)
  ("name" := string)
  ("calls" := int)
  ("responses" := int)


configDecoder : Decoder Config
configDecoder = object1 Config
  ("decks" := (list deckInfoDecoder))


handDecoder : Decoder Hand
handDecoder = object1 Hand
  ("hand" := (list responseDecoder))


playerDecoder : Decoder Player
playerDecoder = object6 Player
  ("id" := playerIdDecoder)
  ("name" := string)
  ("status" := playerStatusDecoder)
  ("score" := int)
  ("disconnected" := bool)
  ("left" := bool)


playerStatusDecoder : Decoder Status
playerStatusDecoder = customDecoder (string) (\name -> Result.Ok (Maybe.withDefault NotPlayed (nameToStatus name)))


roundDecoder : Decoder Round
roundDecoder = object3 Round
  ("czar" := playerIdDecoder)
  ("call" := callDecoder)
  ("responses" := responsesDecoder)


responsesDecoder : Decoder Responses
responsesDecoder = customDecoder responsesTransportDecoder (\transport -> case transport.hidden of
    Just val -> case transport.revealed of
      Just _ -> Result.Err "Got both count and cards."
      Nothing -> Result.Ok (Hidden val)
    Nothing -> case transport.revealed of
      Just val -> Result.Ok (Revealed val)
      Nothing -> Result.Err "Got neither count nor cards."
  )

revealedResponsesDecoder : Decoder RevealedResponses
revealedResponsesDecoder = object2 RevealedResponses
  ("cards" := list (list responseDecoder))
  (maybe ("playedByAndWinner" := playedByAndWinnerDecoder))


playedByAndWinnerDecoder : Decoder PlayedByAndWinner
playedByAndWinnerDecoder = object2 PlayedByAndWinner
  ("playedBy" := list (playerIdDecoder))
  ("winner" := playerIdDecoder)


callDecoder : Decoder Call
callDecoder = object2 Call
  ("id" := string)
  ("parts" := list string)


responseDecoder : Decoder Response
responseDecoder = object2 Response
  ("id" := string)
  ("text" := string)


playerIdDecoder : Decoder Id
playerIdDecoder = int


playerSecretDecoder : Decoder Secret
playerSecretDecoder = object2 Secret
    ("id" := playerIdDecoder)
    ("secret" := string)


responsesTransportDecoder : Decoder ResponsesTransport
responsesTransportDecoder = object2 ResponsesTransport
  (maybe ("hidden" := int))
  (maybe ("revealed" := revealedResponsesDecoder))

type alias ResponsesTransport =
  { hidden : Maybe Int
  , revealed : Maybe RevealedResponses
  }
