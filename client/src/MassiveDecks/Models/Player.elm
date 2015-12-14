module MassiveDecks.Models.Player where

import MassiveDecks.Util as Util


type alias Id = Int


type alias Player =
  { id : Id
  , name : String
  , status : Status
  , score : Int
  }


type alias PlayedByAndWinner =
  { playedBy : List Id
  , winner : Id
  }


type Status
  = NotPlayed
  | Played
  | Czar
  | Disconnected
  | Left
  | Ai
  | Neutral


type alias Secret =
  { id : Id
  , secret : String
  }


statusName : Status -> String
statusName status = case status of
  NotPlayed -> "not-played"
  Played -> "played"
  Czar -> "czar"
  Disconnected -> "disconnected"
  Left -> "left"
  Neutral -> "neutral"
  Ai -> "ai"


nameToStatus : String -> Maybe Status
nameToStatus name = case name of
  "not-played" -> Just NotPlayed
  "played" -> Just Played
  "czar" -> Just Czar
  "disconnected" -> Just Disconnected
  "left" -> Just Left
  "neutral" -> Just Neutral
  "ai" -> Just Ai
  _ -> Nothing


byId : Id -> List Player -> Maybe Player
byId id players = Util.find (\player -> player.id == id) players
