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


playerDisconnect : Player.Id -> List Player.Player -> Maybe Player
playerDisconnect id players =
  let
    name = Player.byId id players |> Maybe.map .name
  in
    Maybe.map (\name -> player "minus-circle" name (name ++ " has disconnected from the game.")) name


playerLeft : Player.Id -> List Player.Player -> Maybe Player
playerLeft id players =
  let
    name = Player.byId id players |> Maybe.map .name
  in
    Maybe.map (\name -> player "sign-out" name (name ++ " has left the game.")) name
