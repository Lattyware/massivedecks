module MassiveDecks.API

  ( createLobby

  , NewPlayerError(..)
  , newPlayer

  , leave

  , AddDeckError(..)
  , addDeck

  , newAi

  , NewGameError(..)
  , newGame

  , PlayError(..)
  , play

  , ChooseError(..)
  , choose

  , SkipError(..)
  , skip

  , getLobbyAndHand

  ) where

import Json.Encode as Json
import Json.Decode exposing (succeed)

import Http exposing (send, defaultSettings)

import MassiveDecks.API.Request exposing (Request, SpecificErrorDecoder, toRequest, jsonBody, specificErrorDecoder, noArguments, oneArgument, twoArguments)
import MassiveDecks.Models.Player exposing (Secret, Id)
import MassiveDecks.Models.Game exposing (Lobby, LobbyAndHand)
import MassiveDecks.Models.Json.Encode exposing (..)
import MassiveDecks.Models.Json.Decode exposing (..)


{-| Makes a request to create a new game lobby to the server. On success, returns that lobby.
-}
createLobby : Request () Lobby
createLobby =
  send defaultSettings
    { verb = "POST"
    , headers = []
    , url = "/lobbies"
    , body = Http.empty
    }
  |> toRequest lobbyDecoder (\_ -> Nothing)


{-| Errors specific to new player requests.
* `NameInUse` - The request was to create a new player with a name already being uses in that lobby.
* `LobbyNotFound` - The given lobby does not exist.
-}
type NewPlayerError
  = NameInUse
  | LobbyNotFound

{-| Makes a request to add a new player to the given lobby. On success, returns a `Secret` for that player.
-}
newPlayer : String -> String -> Request NewPlayerError Secret
newPlayer lobbyId name =
  let
    newPlayerErrorDecoder = specificErrorDecoder
      [ (400, "name-in-use", [], noArguments NameInUse)
      , (404, "lobby-not-found", [], noArguments LobbyNotFound)
      ]
  in
    send defaultSettings
      { verb = "POST"
      , headers = headers
      , url = "/lobbies/" ++ lobbyId ++ "/players"
      , body = jsonBody (Json.object [ ("name", Json.string name) ])
      }
    |> toRequest playerSecretDecoder newPlayerErrorDecoder


{-| Makes a request to the server to permanently leave the given lobby, using the given secret to authenticate.
-}
leave : String -> Secret -> Request () LobbyAndHand
leave lobbyId secret =
  send defaultSettings
    { verb = "POST"
    , headers = headers
    , url = "/lobbies/" ++ lobbyId ++ "/players/" ++ (toString secret.id) ++ "/leave"
    , body = jsonBody (Json.object [ ("secret", Json.string secret.secret) ])
    }
  |> toRequest lobbyAndHandDecoder (\_ -> Nothing)


{-| Errors specific to add deck requests.
* `CardcastTimeout` - The server timed out trying to retrieve the deck from Cardcast.
* `DeckNotFound` - The given play code does not resolve to a Cardcast deck.
-}
type AddDeckError
  = CardcastTimeout
  | DeckNotFound

{-| Makes a request to add the deck for the given play code to the game configuration, using the given secret to
authenticate.
-}
addDeck : String -> Secret -> String -> Request AddDeckError LobbyAndHand
addDeck lobbyId secret deckId =
  let
    addDeckErrorDecoder = specificErrorDecoder
      [ (502, "cardcast-timeout", [], noArguments CardcastTimeout)
      , (400, "deck-not-found", [], noArguments DeckNotFound)
      ]
  in
    send defaultSettings
      { verb = "POST"
      , headers = headers
      , url = "/lobbies/" ++ lobbyId
      , body = commandBody "addDeck" secret [ ("deckId", Json.string deckId) ]
      }
    |> toRequest lobbyAndHandDecoder addDeckErrorDecoder


{-| Makes a request to the server to add a new AI player to the game.
-}
newAi : String -> Request () ()
newAi lobbyId =
  send defaultSettings
    { verb = "POST"
    , headers = []
    , url = "/lobbies/" ++ lobbyId ++ "/players/newAi"
    , body = Http.empty
    }
  |> toRequest (succeed ()) (\_ -> Nothing)


{-| Errors specific to starting a new game.
* `NotEnoughPlayers` - There are not enough players in the lobby to start the game. The required number is given.
* `GameInProgress` - There is already a game in progress.
-}
type NewGameError
  = NotEnoughPlayers Int
  | GameInProgress

{-| Makes a request to the server to start a new game in the given lobby, using the given secret to authenticate.
-}
newGame : String -> Secret -> Request NewGameError LobbyAndHand
newGame lobbyId secret =
  let
    newGameErrorDecoder = specificErrorDecoder
      [ (400, "game-in-progress", [], noArguments GameInProgress)
      , (400, "not-enough-players", [ "required" ], oneArgument Json.Decode.int NotEnoughPlayers)
      ]
  in
    send defaultSettings
      { verb = "POST"
      , headers = headers
      , url = "/lobbies/" ++ lobbyId
      , body = commandBody "newGame" secret []
      }
    |> toRequest lobbyAndHandDecoder newGameErrorDecoder


{-| Errors specific to playing responses into the round.
* `NotInRound` - The player is not in the round, and therefore can't play (i.e.: They are card czar, joined mid-round
*                or were skipped.)
* `AlreadyPlayed` - The player has already played into the round.
* `AlreadyJudging` - The round is in the judging phase, no more cards can be played.
* `WrongNumberOfCards` - The wrong number of cards were played, with the number got, and the number expected.
-}
type PlayError
  = NotInRound
  | AlreadyPlayed
  | AlreadyJudging
  | WrongNumberOfCards Int Int

{-| Make a request to play the given (by index) cards from the player's hand into the round for the given lobby, using
the given secret to authenticate.
-}
play : String -> Secret -> List Int -> Request PlayError LobbyAndHand
play lobbyId secret ids =
  let
    playErrorDecoder = specificErrorDecoder
      [ (400, "not-in-round", [], noArguments NotInRound)
      , (400, "already-played", [], noArguments AlreadyPlayed)
      , (400, "already-judging", [], noArguments AlreadyJudging)
      , (400, "wrong-number-of-cards-played", [ "got", "expected" ]
        , twoArguments (Json.Decode.int, Json.Decode.int) WrongNumberOfCards)
      ]
  in
    send defaultSettings
      { verb = "POST"
      , headers = headers
      , url = "/lobbies/" ++ lobbyId
      , body = commandBody "play" secret [ ("ids", Json.list (List.map Json.int ids)) ]
      }
    |> toRequest lobbyAndHandDecoder playErrorDecoder


{-| Errors specific to choosing a winner for the round.
* `NotCzar` - The player is not the card czar.
-}
type ChooseError
  = NotCzar

{-| Make a request to choose the given (by index) winning response for round for the given lobby, using the given secret
to authenticate.
-}
choose : String -> Secret -> Int -> Request ChooseError LobbyAndHand
choose lobbyId secret winner =
  let
    chooseErrorDecoder = specificErrorDecoder
      [ (400, "not-czar", [], noArguments NotCzar)
      ]
  in
    send defaultSettings
      { verb = "POST"
      , headers = headers
      , url = "/lobbies/" ++ lobbyId
      , body = commandBody "choose" secret [ ("winner", Json.int winner) ]
      }
    |> toRequest lobbyAndHandDecoder chooseErrorDecoder


{-| Errors specific to skipping a player in the lobby.
* `NotEnoughPlayersToSkip` - The number of active players would drop below the minimum if the given players were
*                            skipped.
* `PlayersNotSkippable` - One of the given players was not in a state where they could be skipped (i.e.: not
*                         disconnected or timed out).
-}
type SkipError
  = NotEnoughPlayersToSkip
  | PlayersNotSkippable

{-| Make a request to skip the givne players in the given lobby using the given secret to authenticate.
-}
skip : String -> Secret -> List Id -> Request SkipError LobbyAndHand
skip lobbyId secret players =
  let
    skipErrorDecoder = specificErrorDecoder
      [ (400, "not-enough-players-to-skip", [], noArguments NotEnoughPlayersToSkip)
      , (400, "players-must-be-skippable", [], noArguments PlayersNotSkippable)
      ]
  in
    send defaultSettings
      { verb = "POST"
      , headers = headers
      , url = "/lobbies/" ++ lobbyId
      , body = commandBody "skip" secret [ ("players", Json.list (List.map Json.int players)) ]
      }
    |> toRequest lobbyAndHandDecoder skipErrorDecoder


{-| Get the lobby and the hand for the player with the given secret (using it to authenticate).
-}
getLobbyAndHand : String -> Secret -> Request () LobbyAndHand
getLobbyAndHand lobbyId secret =
  send defaultSettings
    { verb = "POST"
    , headers = headers
    , url = "/lobbies/" ++ lobbyId
    , body = commandBody "getLobbyAndHand" secret []
    }
  |> toRequest lobbyAndHandDecoder (\_ -> Nothing)


{- Private -}


headers : List (String, String)
headers = [("Content-Type", "application/json")]


commandBody : String -> Secret -> List (String, Json.Value) -> Http.Body
commandBody command secret data =
  jsonBody (Json.object (List.append
    [ ("command", Json.string command)
    , ("secret", playerSecretEncoder secret)
    ] data))
