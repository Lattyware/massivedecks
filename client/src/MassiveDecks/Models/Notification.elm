module MassiveDecks.Models.Notification where

import MassiveDecks.Models.Player as Player


type alias Player =
  { icon : String
  , name : String
  , description : String
  , visible : Bool
  }


player : String -> String -> String -> Player
player icon name description = Player icon name description True


hide : Player -> Player
hide notification = { notification | visible = False }


playerStatus : Player.Id -> Player.Status -> List Player.Player -> Maybe Player
playerStatus id status players =
  let
    name = Player.byId id players |> Maybe.map .name
    icon = statusIcon status
    description = name `Maybe.andThen` (statusDescription status)
  in
    Maybe.map3 player icon name description


playerJoin : Player.Id -> List Player.Player -> Maybe Player
playerJoin id players =
  let
    name = Player.byId id players |> Maybe.map .name
  in
    Maybe.map (\name -> player "sign-in" name (name ++ " has joined the game.")) name


playerReconnect : Player.Id -> List Player.Player -> Maybe Player
playerReconnect id players =
  let
    name = Player.byId id players |> Maybe.map .name
  in
    Maybe.map (\name -> player "sign-in" name (name ++ " has reconnected to the game.")) name


statusDescription : Player.Status -> String -> Maybe String
statusDescription status name = case status of
  Player.NotPlayed -> Nothing
  Player.Played -> Nothing
  Player.Czar -> Nothing
  Player.Disconnected -> Just (name ++ " has disconnected from the game.")
  Player.Left -> Just (name ++ " has left the game.")
  Player.Ai -> Nothing
  Player.Neutral -> Nothing


statusIcon : Player.Status -> Maybe String
statusIcon status = case status of
  Player.NotPlayed -> Nothing
  Player.Played -> Nothing
  Player.Czar -> Nothing
  Player.Disconnected -> Just ("minus-circle")
  Player.Left -> Just ("sign-out")
  Player.Ai -> Nothing
  Player.Neutral -> Nothing
