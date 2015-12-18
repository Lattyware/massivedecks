module MassiveDecks.Models.Player where

import MassiveDecks.Util as Util


type alias Id = Int


type alias Player =
  { id : Id
  , name : String
  , status : Status
  , score : Int
  , disconnected : Bool
  , left : Bool
  }


type alias PlayedByAndWinner =
  { playedBy : List Id
  , winner : Id
  }


type Status
  = NotPlayed
  | Played
  | Czar
  | Ai
  | Neutral
  | Skipping


type alias Secret =
  { id : Id
  , secret : String
  }


statusName : Status -> String
statusName status = case status of
  NotPlayed -> "not-played"
  Played -> "played"
  Czar -> "czar"
  Ai -> "ai"
  Neutral -> "neutral"
  Skipping -> "skipping"


nameToStatus : String -> Maybe Status
nameToStatus name = case name of
  "not-played" -> Just NotPlayed
  "played" -> Just Played
  "czar" -> Just Czar
  "ai" -> Just Ai
  "neutral" -> Just Neutral
  "skipping" -> Just Skipping
  _ -> Nothing


byId : Id -> List Player -> Maybe Player
byId id players = Util.find (\player -> player.id == id) players
