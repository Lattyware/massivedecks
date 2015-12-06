module MassiveDecks.Models.Json.Decode where

import Json.Decode exposing (..)

import MassiveDecks.Models.Game exposing (..)
import MassiveDecks.Models.Card exposing (..)
import MassiveDecks.Models.Player exposing (..)


lobbyAndHandDecoder : Decoder LobbyAndHand
lobbyAndHandDecoder = object2 LobbyAndHand
  ("lobby" := lobbyDecoder)
  ("hand" := handDecoder)


lobbyDecoder : Decoder Lobby
lobbyDecoder = object4 Lobby
  ("id" := string)
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
playerDecoder = object4 Player
    ("id" := playerIdDecoder)
    ("name" := string)
    ("status" := playerStatusDecoder)
    ("score" := int)


playerStatusDecoder : Decoder Status
playerStatusDecoder = customDecoder (string) (\name -> Result.Ok (Maybe.withDefault NotPlayed (nameToStatus name)))


roundDecoder : Decoder Round
roundDecoder = object3 Round
  ("czar" := playerIdDecoder)
  ("call" := callDecoder)
  ("responses" := responsesDecoder)


responsesDecoder : Decoder Responses
responsesDecoder = customDecoder responsesTransportDecoder (\transport -> case transport.count of
    Just val -> case transport.cards of
      Just _ -> Result.Err "Got both count and cards."
      Nothing -> Result.Ok (Hidden val)
    Nothing -> case transport.cards of
      Just val -> Result.Ok (Revealed val)
      Nothing -> Result.Err "Got neither count nor cards."
  )

responsesTransportDecoder : Decoder ResponsesTransport
responsesTransportDecoder = object2 ResponsesTransport
  (maybe ("count" := int))
  (maybe ("cards" := list (list responseDecoder)))

type alias ResponsesTransport =
  { count : Maybe Int
  , cards : Maybe (List (PlayedCards))
  }


callDecoder : Decoder Call
callDecoder = list string


responseDecoder : Decoder Response
responseDecoder = string


playerIdDecoder : Decoder Id
playerIdDecoder = int


playerSecretDecoder : Decoder Secret
playerSecretDecoder = object2 Secret
    ("id" := playerIdDecoder)
    ("secret" := string)
