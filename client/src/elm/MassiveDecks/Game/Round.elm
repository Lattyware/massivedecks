module MassiveDecks.Game.Round exposing
    ( Complete
    , Id
    , Judging
    , LikeDetail
    , Pick
    , PickState(..)
    , Playing
    , Revealing
    , Round
    , Specific
    , Stage(..)
    , StageDetails(..)
    , Starting
    , Timed
    , WithCall
    , defaultLikeDetail
    , idDecoder
    , idString
    , noPick
    , stage
    , stageDescription
    , stageToString
    , withStage
    )

import Dict exposing (Dict)
import Json.Decode as Json
import MassiveDecks.Card.Call.Editor.Model as CallEditor
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Play as Play exposing (Play)
import MassiveDecks.Game.Time exposing (Time)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.User as User
import Set exposing (Set)


{-| A unique id for a round.
-}
type Id
    = Id String


idDecoder : Json.Decoder Id
idDecoder =
    Json.string |> Json.map Id


idString : Id -> String
idString (Id id) =
    id


{-| The stage of the round.
-}
type Stage
    = SStarting
    | SPlaying
    | SRevealing
    | SJudging
    | SComplete


{-| Get the stage of the given round.
-}
stage : StageDetails -> Stage
stage specific =
    case specific of
        S _ ->
            SStarting

        P _ ->
            SPlaying

        R _ ->
            SRevealing

        J _ ->
            SJudging

        C _ ->
            SComplete


{-| Get the serializing name for the stage.
-}
stageToString : Stage -> String
stageToString s =
    case s of
        SStarting ->
            "Starting"

        SPlaying ->
            "Playing"

        SRevealing ->
            "Revealing"

        SJudging ->
            "Judging"

        SComplete ->
            "Complete"


{-| A description of the given stage.
-}
stageDescription : Stage -> MdString
stageDescription toDescribe =
    case toDescribe of
        SStarting ->
            Strings.Starting

        SPlaying ->
            Strings.Playing

        SRevealing ->
            Strings.Revealing

        SJudging ->
            Strings.Judging

        SComplete ->
            Strings.Complete


{-| A round during a game.
-}
type alias Round =
    Specific StageDetails


type alias Specific stageDetails =
    { id : Id
    , czar : User.Id
    , players : Set User.Id
    , startedAt : Time
    , stage : stageDetails
    }


type alias WithCall stageDetails =
    Specific { stageDetails | call : Card.Call }


type alias Timed stageDetails =
    Specific { stageDetails | timedOut : Bool }


withStage : stageDetails -> Specific oldDetails -> Specific stageDetails
withStage newStage round =
    { id = round.id
    , czar = round.czar
    , players = round.players
    , startedAt = round.startedAt
    , stage = newStage
    }


type StageDetails
    = S Starting
    | P Playing
    | R Revealing
    | J Judging
    | C Complete


type alias LikeDetail =
    { played : Maybe Play.Id
    , liked : Set Play.Id
    }


defaultLikeDetail : LikeDetail
defaultLikeDetail =
    { played = Nothing
    , liked = Set.empty
    }


{-| The user's pick for the round.
-}
type alias Pick =
    { state : PickState, cards : Dict Int Card.Id }


noPick : Pick
noPick =
    { state = Selected, cards = Dict.empty }


{-| Whether the pick has been committed to the server yet.
-}
type PickState
    = Selected
    | Submitted


{-| A round while the czar is picking a call.
-}
type alias Starting =
    { pick : Maybe Card.Id
    , editor : Maybe CallEditor.Model
    , calls : Maybe (List Card.Call)
    , timedOut : Bool
    }


{-| A round while users are playing a round.
-}
type alias Playing =
    { pick : Pick
    , call : Card.Call
    , played : Set User.Id
    , timedOut : Bool
    }


type alias Revealing =
    { likeDetail : LikeDetail
    , lastRevealed : Maybe Play.Id
    , pick : Maybe Play.Id
    , call : Card.Call
    , plays : List Play
    , timedOut : Bool
    }


{-| A round while the czar is judging a round.
-}
type alias Judging =
    { likeDetail : LikeDetail
    , pick : Maybe Play.Id
    , call : Card.Call
    , plays : List Play.Known
    , timedOut : Bool
    }


{-| A round that has been finished.
-}
type alias Complete =
    { likeDetail : LikeDetail
    , pick : Maybe Play.Id
    , call : Card.Call
    , plays : Dict Play.Id Play.WithDetails
    , playOrder : List Play.Id
    , winner : User.Id
    }
