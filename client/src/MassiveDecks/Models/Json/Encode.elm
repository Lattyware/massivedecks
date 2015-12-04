module MassiveDecks.Models.Json.Encode where

import Json.Encode exposing (..)

import MassiveDecks.Models.Player exposing (..)


commandEncoder : String -> Secret -> List (String, Value) -> String
commandEncoder action playerSecret rest = object
  (List.concat [ [ ("command", string action)
                 , ("secret", playerSecretEncoder playerSecret)
                 ], rest ]) |> encode 0


deckIdEncoder : String -> (String, Value)
deckIdEncoder id = ("deckId", string id)


playerSecretEncoder : Secret -> Value
playerSecretEncoder playerSecret = object
  [ ("id", playerIdEncoder playerSecret.id)
  , ("secret", string playerSecret.secret)
  ]


playerIdEncoder : Id -> Value
playerIdEncoder playerId = int playerId
