module MassiveDecks.API where

import Json.Encode exposing (..)
import Json.Decode

import Task
import Effects
import Http exposing (post, url, empty, send, defaultSettings, fromJson)

import MassiveDecks.Actions.Action exposing (Action(..))
import MassiveDecks.Models.Player exposing (Secret)
import MassiveDecks.Models.Game exposing (Lobby, LobbyAndHand)
import MassiveDecks.Models.Json.Encode exposing (..)
import MassiveDecks.Models.Json.Decode exposing (..)


createLobby : Task.Task Http.Error Lobby
createLobby = post lobbyDecoder (url "/lobbies" []) empty


newPlayer : String -> String -> Task.Task Http.Error Secret
newPlayer lobbyId name = send defaultSettings
  { verb = "POST"
  , headers = [("Content-Type", "application/json")]
  , url = url ("/lobbies/" ++ lobbyId ++ "/players") []
  , body = Http.string ("{ \"name\": \"" ++ name ++ "\"}")
  } |> fromJson playerSecretDecoder


addDeck : String -> Secret -> String -> Task.Task Http.Error LobbyAndHand
addDeck lobbyId secret deckId = lobbyAction lobbyId (commandEncoder "addDeck" secret [ ("deckId", string deckId) ])


newAi : String -> Task.Task Http.Error ()
newAi lobbyId = send defaultSettings
  { verb = "POST"
  , headers = []
  , url = url ("/lobbies/" ++ lobbyId ++ "/players/newAi") []
  , body = empty
  } |> fromJson (Json.Decode.succeed ())


newGame : String -> Secret -> Task.Task Http.Error LobbyAndHand
newGame lobbyId secret = lobbyAction lobbyId (commandEncoder "newGame" secret [])


play : String -> Secret -> List Int -> Task.Task Http.Error LobbyAndHand
play lobbyId secret ids = lobbyAction lobbyId (commandEncoder "play" secret [ ("ids", list (List.map int ids)) ])


choose : String -> Secret -> Int -> Task.Task Http.Error LobbyAndHand
choose lobbyId secret winner = lobbyAction lobbyId (commandEncoder "choose" secret [ ("winner", int winner) ])


getLobbyAndHand : String -> Secret -> Task.Task Http.Error LobbyAndHand
getLobbyAndHand lobbyId secret =
  lobbyAction lobbyId (commandEncoder "getLobbyAndHand" secret [])


lobbyAction : String -> String -> Task.Task Http.Error LobbyAndHand
lobbyAction lobbyId content = send defaultSettings
  { verb = "POST"
  , headers = [("Content-Type", "application/json")]
  , url = url ("/lobbies/" ++ lobbyId) []
  , body = Http.string (content)
  } |> fromJson lobbyAndHandDecoder


toEffect : Task.Task Http.Error Action -> Effects.Effects Action
toEffect task =  task `Task.onError` handleError |> Effects.task


handleError : Http.Error -> Task.Task b Action
handleError error = toString error |> DisplayError |> Task.succeed
