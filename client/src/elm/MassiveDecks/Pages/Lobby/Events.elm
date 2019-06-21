module MassiveDecks.Pages.Lobby.Events exposing
    ( ConfigChanged(..)
    , DeckChange(..)
    , Event(..)
    , GameEvent(..)
    , PresenceState(..)
    , Redraw(..)
    )

import Dict exposing (Dict)
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Play as Play
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Pages.Lobby.Model as Lobby exposing (Lobby)
import MassiveDecks.User as User
import Set exposing (Set)


{-| An event from the server.
-}
type Event
    = Sync { state : Lobby, hand : Maybe (List Card.Response), play : Maybe (List Card.Id) }
    | Connection { user : User.Id, state : User.Connection }
    | Presence { user : User.Id, state : PresenceState }
    | Configured { change : ConfigChanged, version : String }
      -- Not a game event because we don't need to be in a game
    | GameStarted { round : Round.Playing, hand : List Card.Response }
    | Game GameEvent


{-| The user's intentional presence in the lobby.
-}
type PresenceState
    = UserJoined { name : String }
    | UserLeft


type ConfigChanged
    = DecksChanged { change : DeckChange, deck : Source.External }
    | HandSizeSet { size : Int }
    | ScoreLimitSet { limit : Maybe Int }
    | PasswordSet { password : Maybe String }
    | HouseRuleChanged { change : Rules.HouseRuleChange }


type DeckChange
    = Add
    | Remove
    | Load { summary : Source.Summary }
    | Fail { reason : Source.LoadFailureReason }


type Redraw
    = Player { hand : List Card.Response }
    | Other { player : User.Id }


type GameEvent
    = HandRedrawn Redraw
    | PlayRevealed { id : Play.Id, play : List Card.Response }
    | PlaySubmitted { by : User.Id }
    | PlayTakenBack { by : User.Id }
    | RoundFinished { winner : User.Id, playedBy : Dict Play.Id User.Id }
    | RoundStarted
        { id : Round.Id
        , czar : User.Id
        , players : Set User.Id
        , call : Card.Call
        , drawn : Maybe (List Card.Response)
        }
    | StartRevealing { plays : List Play.Id }
