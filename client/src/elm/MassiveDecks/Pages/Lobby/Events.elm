module MassiveDecks.Pages.Lobby.Events exposing
    ( ConfigChanged(..)
    , DeckChange(..)
    , Event(..)
    , GameEvent(..)
    , PresenceState(..)
    , TimedGameEvent(..)
    , TimedState(..)
    )

import Dict exposing (Dict)
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Play as Play
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Game.Time as Time exposing (Time)
import MassiveDecks.Pages.Lobby.Model exposing (Lobby)
import MassiveDecks.User as User
import Set exposing (Set)


{-| An event from the server.
-}
type Event
    = Sync
        { state : Lobby
        , hand : Maybe (List Card.PotentiallyBlankResponse)
        , play : Maybe (List Card.Played)
        , partialTimeAnchor : Time.PartialAnchor
        }
    | Connection { user : User.Id, state : User.Connection }
    | Presence { user : User.Id, state : PresenceState }
    | Configured { change : ConfigChanged, version : String }
      -- Not a game event because we don't need to be in a game
    | GameStarted { round : Round.Playing, hand : List Card.PotentiallyBlankResponse }
    | Game GameEvent
    | PrivilegeChanged { user : User.Id, privilege : User.Privilege }


{-| The user's intentional presence in the lobby.
-}
type PresenceState
    = UserJoined { name : String, privilege : User.Privilege, control : User.Control }
    | UserLeft { reason : User.LeaveReason }


type ConfigChanged
    = DecksChanged { change : DeckChange, deck : Source.External }
    | HandSizeSet { size : Int }
    | ScoreLimitSet { limit : Maybe Int }
    | PasswordSet { password : Maybe String }
    | HouseRuleChanged { change : Rules.HouseRuleChange }
    | PublicSet { public : Bool }
    | ChangeTimeLimitForStage { stage : Round.Stage, timeLimit : Maybe Float }
    | ChangeTimeLimitMode { mode : Rules.TimeLimitMode }


type DeckChange
    = Add
    | Remove
    | Load { summary : Source.Summary }
    | Fail { reason : Source.LoadFailureReason }


type GameEvent
    = HandRedrawn { player : User.Id, hand : Maybe (List Card.PotentiallyBlankResponse) }
    | PlaySubmitted { by : User.Id }
    | PlayTakenBack { by : User.Id }
    | PlayerAway { player : User.Id }
    | PlayerBack { player : User.Id }
    | Timed TimedState
    | StageTimerDone { round : Round.Id, stage : Round.Stage }
    | Paused
    | Continued
    | GameEnded { winner : Set User.Id }


type TimedState
    = NoTime { event : TimedGameEvent }
    | WithTime { event : TimedGameEvent, time : Time }


type TimedGameEvent
    = RoundStarted
        { id : Round.Id
        , czar : User.Id
        , players : Set User.Id
        , call : Card.Call
        , drawn : Maybe (List Card.PotentiallyBlankResponse)
        }
    | StartRevealing { plays : List Play.Id, drawn : Maybe (List Card.PotentiallyBlankResponse) }
    | RoundFinished { winner : User.Id, playedBy : Dict Play.Id Play.Details }
    | PlayRevealed { id : Play.Id, play : List Card.Response }
