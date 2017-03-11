module MassiveDecks.Models.Notification exposing (..)

import MassiveDecks.Models.Player as Player exposing (Player)


{-| A notification about a player.
-}
type alias Notification =
    { icon : String
    , name : String
    , description : String
    , visible : Bool
    }


{-| Hide the given notificaiton.
-}
hide : Notification -> Notification
hide notification =
    { notification | visible = False }


{-| Create a notification for a player joining the game.
-}
playerJoin : Player.Id -> List Player -> Maybe Notification
playerJoin id players =
    playerFromIdAndPlayers id players "sign-in" " has joined the game."


{-| Create a notification for a player reconnecting to the game.
-}
playerReconnect : Player.Id -> List Player -> Maybe Notification
playerReconnect id players =
    playerFromIdAndPlayers id players "sign-in" " has reconnected to the game."


{-| Create a notification for a player disconnecting from the game.
-}
playerDisconnect : Player.Id -> List Player -> Maybe Notification
playerDisconnect id players =
    playerFromIdAndPlayers id players "minus-circle" " has disconnected from the game."


{-| Create a notification for a player leaving the game.
-}
playerLeft : Player.Id -> List Player -> Maybe Notification
playerLeft id players =
    playerFromIdAndPlayers id players "sign-out" " has left the game."


playerFromIdAndPlayers : Player.Id -> List Player -> String -> String -> Maybe Notification
playerFromIdAndPlayers id players icon suffix =
    Player.byId id players
        |> Maybe.map .name
        |> Maybe.map (\name -> Notification icon name (name ++ suffix) True)
