module MassiveDecks.Models.Player where


type alias Id = Int


type alias Player =
  { id : Id
  , name : String
  , status : Status
  , score : Int
  }


type Status
  = NotPlayed
  | Played
  | Czar
  | Disconnected
  | Left
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


nameToStatus : String -> Maybe Status
nameToStatus name = case name of
  "not-played" -> Just NotPlayed
  "played" -> Just Played
  "czar" -> Just Czar
  "disconnected" -> Just Disconnected
  "left" -> Just Left
  "neutral" -> Just Neutral
  _ -> Nothing
