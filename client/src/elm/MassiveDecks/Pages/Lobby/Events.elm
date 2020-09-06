module MassiveDecks.Pages.Lobby.Events exposing
    ( AfterPlaying
    , Event(..)
    , GameEvent(..)
    , PresenceState(..)
    , TimedGameEvent(..)
    , TimedState(..)
    )

import Dict exposing (Dict)
import Json.Patch as Json
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Play as Play
import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Time as Time exposing (Time)
import MassiveDecks.Models.MdError as MdError
import MassiveDecks.Pages.Lobby.Model exposing (Lobby)
import MassiveDecks.User as User
import Set exposing (Set)


{-| An event from the server.
-}
type Event
    = Sync
        { state : Lobby
        , hand : Maybe (List Card.Response)
        , play : Maybe (List Card.Id)
        , partialTimeAnchor : Time.PartialAnchor
        }
    | Connection { user : User.Id, state : User.Connection }
    | Presence { user : User.Id, state : PresenceState }
    | Configured { change : Json.Patch }
      -- Not a game event because we don't need to be in a game
    | GameStarted { round : Round.Specific Round.Playing, hand : Maybe (List Card.Response) }
    | Game GameEvent
    | PrivilegeChanged { user : User.Id, privilege : User.Privilege }
    | UserRoleChanged { user : User.Id, role : User.Role, hand : Maybe (List Card.Response) }
    | ErrorEncountered { error : MdError.GameStateError }


{-| The user's intentional presence in the lobby.
-}
type PresenceState
    = UserJoined { name : String, privilege : User.Privilege, control : User.Control }
    | UserLeft { reason : User.LeaveReason }


type GameEvent
    = HandRedrawn { player : User.Id, hand : Maybe (List Card.Response) }
    | CardDiscarded { player : User.Id, card : Card.Response, replacement : Maybe Card.Response }
    | PlaySubmitted { by : User.Id }
    | PlayTakenBack { by : User.Id }
    | PlayLiked { play : Play.Id }
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


type alias AfterPlaying =
    { played : Maybe Play.Id
    , drawn : Maybe (List Card.Response)
    }


type TimedGameEvent
    = RoundStarted
        { id : Round.Id
        , czar : User.Id
        , players : Set User.Id
        , call : Card.Call
        , drawn : Maybe (List Card.Response)
        }
    | StartRevealing { plays : List Play.Id, afterPlaying : AfterPlaying }
    | StartJudging { plays : Maybe (List Play.Known), afterPlaying : AfterPlaying }
    | RoundFinished { winner : User.Id, playedBy : Dict Play.Id Play.Details }
    | PlayRevealed { id : Play.Id, play : List Card.Response }
