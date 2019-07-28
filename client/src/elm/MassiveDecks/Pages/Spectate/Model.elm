module MassiveDecks.Pages.Spectate.Model exposing
    ( FinishedPlays
    , JudgingPlay
    , Model
    , OwnedPlay
    , PlayingPlay
    , Plays(..)
    , Rotations
    , playingPlay
    )

import MassiveDecks.Card.Model as Card exposing (Call, Response)
import MassiveDecks.Card.Play as Play
import MassiveDecks.Pages.Spectate.Route exposing (..)
import MassiveDecks.User as User


{-| Data for the lobby page.
-}
type alias Model =
    { route : Route
    , call : Card.Call
    , plays : Plays
    }


{-| The various states of plays depending on round state.
-}
type Plays
    = Playing (List PlayingPlay)
    | Judging (List JudgingPlay)
    | Finished FinishedPlays


type alias Rotations =
    List Float


{-| A convenience constructor for `PlayingPlay`.
-}
playingPlay : Maybe Play.Id -> PlayingPlay
playingPlay play =
    Maybe.map (\p -> { play = p, animation = Nothing }) play


{-| A play while people are playing cards. If `Nothing`, then the user hasn't played yet.
-}
type alias PlayingPlay =
    Maybe { play : Play.Id, animation : Maybe Rotations }


{-| A play that is actively being judged.
-}
type alias JudgingPlay =
    { play : Play.Known, rotation : Rotations, revealed : Bool }


{-| Plays for a finished round.
-}
type alias FinishedPlays =
    { plays : List OwnedPlay, winner : User.Id }


{-| A play with a revealed user it was played by.
-}
type alias OwnedPlay =
    { playedBy : User.Id, play : Play.Known, rotation : Rotations }
