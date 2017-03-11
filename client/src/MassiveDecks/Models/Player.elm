module MassiveDecks.Models.Player exposing (..)

import MassiveDecks.Util as Util


{-| A game-unique identifier for a player.
-}
type alias Id =
    Int


{-| A player.
-}
type alias Player =
    { id : Id
    , name : String
    , status : Status
    , score : Int
    , disconnected : Bool
    , left : Bool
    }


{-| A list of ids to identify who played what responses into a round and the id of the winner of the round.
-}
type alias PlayedByAndWinner =
    { playedBy : List Id
    , winner : Id
    }


{-| A secret that a player uses to authenticate themselves to the server.
-}
type alias Secret =
    { id : Id
    , secret : String
    }


{-| The status of a player.
-}
type Status
    = NotPlayed
    | Played
    | Czar
    | Ai
    | Neutral
    | Skipping


{-| The name of the status.
-}
statusName : Status -> String
statusName status =
    case status of
        NotPlayed ->
            "not-played"

        Played ->
            "played"

        Czar ->
            "czar"

        Ai ->
            "ai"

        Neutral ->
            "neutral"

        Skipping ->
            "skipping"


{-| Get a status from a name.
-}
nameToStatus : String -> Maybe Status
nameToStatus name =
    case name of
        "not-played" ->
            Just NotPlayed

        "played" ->
            Just Played

        "czar" ->
            Just Czar

        "ai" ->
            Just Ai

        "neutral" ->
            Just Neutral

        "skipping" ->
            Just Skipping

        _ ->
            Nothing


{-| Get a player from a list of players by their id.
-}
byId : Id -> List Player -> Maybe Player
byId id players =
    Util.find (\player -> player.id == id) players
