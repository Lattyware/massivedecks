module MassiveDecks.Game.Messages exposing (Msg(..))

import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Play as Play
import MassiveDecks.Game.Model exposing (..)


type Msg
    = Pick Card.Id
    | Submit
    | TakeBack
    | PickPlay Play.Id
    | Reveal Play.Id
    | Judge
    | Like
    | ScrollToTop
    | SetPlayStyles PlayStyles
    | AdvanceRound
    | Redraw
