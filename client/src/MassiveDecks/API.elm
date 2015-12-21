module MassiveDecks.API where

import Json.Encode as Json
import Json.Decode exposing (succeed)

import Http exposing (send, defaultSettings)

import MassiveDecks.API.Request exposing (Request, SpecificErrorDecoder, toRequest, jsonBody, specificErrorDecoder, oneArgument, twoArguments)
import MassiveDecks.Models.Player exposing (Secret, Id)
import MassiveDecks.Models.Game exposing (Lobby, LobbyAndHand)
import MassiveDecks.Models.Json.Encode exposing (..)
import MassiveDecks.Models.Json.Decode exposing (..)


headers : List (String, String)
headers = [("Content-Type", "application/json")]


commandBody : String -> Secret -> List (String, Json.Value) -> Http.Body
commandBody command secret data =
  jsonBody (Json.object (List.append
    [ ("command", Json.string command)
    , ("secret", playerSecretEncoder secret)
    ] data))


createLobby : Request () Lobby
createLobby =
  send defaultSettings
    { verb = "POST"
    , headers = []
    , url = "/lobbies"
    , body = Http.empty
    }
  |> toRequest lobbyDecoder (\_ -> Nothing)


noArguments : a -> List Json.Value -> Maybe a
noArguments value _ = Just value


type NewPlayerError
  = NameInUse
  | LobbyNotFound

newPlayerErrorDecoder : SpecificErrorDecoder NewPlayerError
newPlayerErrorDecoder = specificErrorDecoder (List.concat
  [ [ (400, "name-in-use", [], noArguments NameInUse)
    , (404, "lobby-not-found", [], noArguments LobbyNotFound)
    ]
  ])

newPlayer : String -> String -> Request NewPlayerError Secret
newPlayer lobbyId name =
  send defaultSettings
    { verb = "POST"
    , headers = headers
    , url = "/lobbies/" ++ lobbyId ++ "/players"
    , body = jsonBody (Json.object [ ("name", Json.string name) ])
    }
  |> toRequest playerSecretDecoder newPlayerErrorDecoder


leave : String -> Secret -> Request () LobbyAndHand
leave lobbyId secret =
  send defaultSettings
    { verb = "POST"
    , headers = headers
    , url = "/lobbies/" ++ lobbyId ++ "/players/" ++ (toString secret.id) ++ "/leave"
    , body = jsonBody (Json.object [ ("secret", Json.string secret.secret) ])
    }
  |> toRequest lobbyAndHandDecoder (\_ -> Nothing)


type AddDeckError
  = CardcastTimeout
  | DeckNotFound

addDeckErrorDecoder : SpecificErrorDecoder AddDeckError
addDeckErrorDecoder = specificErrorDecoder (List.concat
  [ [ (502, "cardcast-timeout", [], noArguments CardcastTimeout)
    , (400, "deck-not-found", [], noArguments DeckNotFound)
    ]
  ])

addDeck : String -> Secret -> String -> Request AddDeckError LobbyAndHand
addDeck lobbyId secret deckId =
  send defaultSettings
    { verb = "POST"
    , headers = headers
    , url = "/lobbies/" ++ lobbyId
    , body = commandBody "addDeck" secret [ ("deckId", Json.string deckId) ]
    }
  |> toRequest lobbyAndHandDecoder addDeckErrorDecoder


newAi : String -> Request () ()
newAi lobbyId =
  send defaultSettings
    { verb = "POST"
    , headers = []
    , url = "/lobbies/" ++ lobbyId ++ "/players/newAi"
    , body = Http.empty
    }
  |> toRequest (succeed ()) (\_ -> Nothing)


type NewGameError
  = NotEnoughPlayers Int
  | GameInProgress

newGameErrorDecoder : SpecificErrorDecoder NewGameError
newGameErrorDecoder = specificErrorDecoder (List.concat
  [ [ (400, "game-in-progress", [], noArguments GameInProgress)
    , (400, "not-enough-players", [ "required" ], oneArgument Json.Decode.int NotEnoughPlayers)
    ]
  ])

newGame : String -> Secret -> Request NewGameError LobbyAndHand
newGame lobbyId secret =
  send defaultSettings
    { verb = "POST"
    , headers = headers
    , url = "/lobbies/" ++ lobbyId
    , body = commandBody "newGame" secret []
    }
  |> toRequest lobbyAndHandDecoder newGameErrorDecoder


type PlayError
  = NotInRound
  | AlreadyPlayed
  | AlreadyJudging
  | WrongNumberOfCards Int Int

playErrorDecoder : SpecificErrorDecoder PlayError
playErrorDecoder = specificErrorDecoder (List.concat
  [ [ (400, "not-in-round", [], noArguments NotInRound)
    , (400, "already-played", [], noArguments AlreadyPlayed)
    , (400, "already-judging", [], noArguments AlreadyJudging)
    , (400, "wrong-number-of-cards-played", [ "got", "expected" ]
      , twoArguments (Json.Decode.int, Json.Decode.int) WrongNumberOfCards)
    ]
  ])

play : String -> Secret -> List Int -> Request PlayError LobbyAndHand
play lobbyId secret ids =
  send defaultSettings
    { verb = "POST"
    , headers = headers
    , url = "/lobbies/" ++ lobbyId
    , body = commandBody "play" secret [ ("ids", Json.list (List.map Json.int ids)) ]
    }
  |> toRequest lobbyAndHandDecoder playErrorDecoder


type ChooseError
  = NotCzar

chooseErrorDecoder : SpecificErrorDecoder ChooseError
chooseErrorDecoder = specificErrorDecoder (List.concat
  [ [ (400, "not-czar", [], noArguments NotCzar)
    ]
  ])

choose : String -> Secret -> Int -> Request ChooseError LobbyAndHand
choose lobbyId secret winner =
  send defaultSettings
    { verb = "POST"
    , headers = headers
    , url = "/lobbies/" ++ lobbyId
    , body = commandBody "choose" secret [ ("winner", Json.int winner) ]
    }
  |> toRequest lobbyAndHandDecoder chooseErrorDecoder


type SkipError
  = NotEnoughPlayersToSkip
  | PlayersNotSkippable

skipErrorDecoder : SpecificErrorDecoder SkipError
skipErrorDecoder = specificErrorDecoder (List.concat
  [ [ (400, "not-enough-players-to-skip", [], noArguments NotEnoughPlayersToSkip)
    , (400, "players-must-be-skippable", [], noArguments PlayersNotSkippable)
    ]
  ])

skip : String -> Secret -> List Id -> Request SkipError LobbyAndHand
skip lobbyId secret players =
  send defaultSettings
    { verb = "POST"
    , headers = headers
    , url = "/lobbies/" ++ lobbyId
    , body = commandBody "skip" secret [ ("players", Json.list (List.map Json.int players)) ]
    }
  |> toRequest lobbyAndHandDecoder skipErrorDecoder


getLobbyAndHand : String -> Secret -> Request () LobbyAndHand
getLobbyAndHand lobbyId secret =
  send defaultSettings
    { verb = "POST"
    , headers = headers
    , url = "/lobbies/" ++ lobbyId
    , body = commandBody "getLobbyAndHand" secret []
    }
  |> toRequest lobbyAndHandDecoder (\_ -> Nothing)
