module MassiveDecks.Models.Notification

  ( Player
  , hide
  , playerJoin
  , playerReconnect
  , playerDisconnect
  , playerLeft

  ) where

import MassiveDecks.Models.Player as Player


{-| A notification about a player.
-}
type alias Player =
  { icon : String
  , name : String
  , description : String
  , visible : Bool
  }


{-| Hide the given notificaiton.
-}
hide : Player -> Player
hide notification = { notification | visible = False }


{-| Create a notification for a player joining the game.
-}
playerJoin : Player.Id -> List Player.Player -> Maybe Player
playerJoin id players = playerFromIdAndPlayers id players "sign-in" " has joined the game."


{-| Create a notification for a player reconnecting to the game.
-}
playerReconnect : Player.Id -> List Player.Player -> Maybe Player
playerReconnect id players = playerFromIdAndPlayers id players "sign-in" " has reconnected to the game."


{-| Create a notification for a player disconnecting from the game.
-}
playerDisconnect : Player.Id -> List Player.Player -> Maybe Player
playerDisconnect id players = playerFromIdAndPlayers id players "minus-circle" " has disconnected from the game."


{-| Create a notification for a player leaving the game.
-}
playerLeft : Player.Id -> List Player.Player -> Maybe Player
playerLeft id players = playerFromIdAndPlayers id players "sign-out" " has left the game."


{- Private -}


playerFromIdAndPlayers : Player.Id -> List Player.Player -> String -> String -> Maybe Player
playerFromIdAndPlayers id players icon suffix
    = Player.byId id players
    |> Maybe.map .name
    |> Maybe.map (\name -> Player icon name (name ++ suffix) True)
