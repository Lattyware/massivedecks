module MassiveDecks.Models.Game.Round exposing (..)

import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.Player as Player


type alias Round =
    { czar : Player.Id
    , call : Card.Call
    , state : State
    }


{-| The possible states of the round.
-}
type State
    = P Playing
    | J Judging
    | F Finished


playing : Int -> Bool -> State
playing numberPlayed afterTimeLimit =
    P (Playing numberPlayed afterTimeLimit)


{-| A round that is being played into.
-}
type alias Playing =
    { numberPlayed : Int
    , afterTimeLimit : Bool
    }


judging : List Card.PlayedCards -> Bool -> State
judging responses afterTimeLimit =
    J (Judging responses afterTimeLimit)


{-| A round that is being judged.
-}
type alias Judging =
    { responses : List Card.PlayedCards
    , afterTimeLimit : Bool
    }


finished : List Card.PlayedCards -> Player.PlayedByAndWinner -> State
finished responses playedByAndWinner =
    F (Finished responses playedByAndWinner)


{-| A round that has been completed.
-}
type alias Finished =
    { responses : List Card.PlayedCards
    , playedByAndWinner : Player.PlayedByAndWinner
    }


{-| A historical round that has been completed.
-}
type alias FinishedRound =
    { czar : Player.Id
    , call : Card.Call
    , state : Finished
    }


afterTimeLimit : State -> Bool
afterTimeLimit state =
    case state of
        P playing ->
            playing.afterTimeLimit

        J judging ->
            judging.afterTimeLimit

        F finished ->
            False


setAfterTimeLimit : Round -> Bool -> Round
setAfterTimeLimit round afterTimeLimit =
    case round.state of
        P playing ->
            { round | state = P { playing | afterTimeLimit = afterTimeLimit } }

        J judging ->
            { round | state = J { judging | afterTimeLimit = afterTimeLimit } }

        F finished ->
            round
