module MassiveDecks.Game.Messages exposing (Msg(..))

import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Play as Play
import MassiveDecks.Game.Model exposing (..)
import MassiveDecks.Game.Player as Player
import MassiveDecks.Game.Time exposing (Time)
import MassiveDecks.User as User


type Msg
    = Pick Card.Id
    | EditBlank Card.Id String
    | Fill Card.Id String
    | Submit
    | TakeBack
    | PickPlay Play.Id
    | Reveal Play.Id
    | Judge
    | Like
    | ScrollToTop
    | SetPlayStyles PlayStyles
    | AdvanceRound
    | Discard
    | DismissDiscard
    | Redraw
    | ToggleHistoryView
    | SetPresence Player.Presence
    | SetPlayerAway User.Id
    | UpdateTimer Time
    | ToggleHelp
    | EnforceTimeLimit
    | Confetti
    | NoOp
