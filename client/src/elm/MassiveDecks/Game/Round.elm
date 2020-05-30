module MassiveDecks.Game.Round exposing
    ( Complete
    , Data
    , Id
    , Judging
    , LikeDetail
    , Pick
    , PickState(..)
    , Playing
    , Revealing
    , Round(..)
    , Stage(..)
    , complete
    , data
    , idDecoder
    , idString
    , judging
    , noPick
    , playing
    , revealing
    , stage
    , stageDescription
    , stageToName
    )

import Dict exposing (Dict)
import Json.Decode as Json
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
    = SPlaying
    | SRevealing
    | SJudging
    | SComplete


{-| Get the stage of the given round.
-}
stage : Round -> Stage
stage round =
    case round of
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
stageToName : Stage -> String
stageToName s =
    case s of
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
type Round
    = P Playing
    | R Revealing
    | J Judging
    | C Complete


{-| A round while users are playing a round.
-}
type alias Playing =
    Data { played : Set User.Id, pick : Pick, timedOut : Bool }


playing : Id -> User.Id -> Set User.Id -> Card.Call -> Set User.Id -> Time -> Bool -> Playing
playing id czar players call played startedAt timedOut =
    { id = id
    , czar = czar
    , players = players
    , call = call
    , played = played
    , pick = { state = Selected, cards = Dict.empty }
    , startedAt = startedAt
    , timedOut = timedOut
    }


type alias LikeDetail =
    { played : Maybe Play.Id
    , liked : Set Play.Id
    }


defaultLikeDetail : LikeDetail
defaultLikeDetail =
    { played = Nothing
    , liked = Set.empty
    }


type alias Revealing =
    Data
        { plays : List Play
        , lastRevealed : Maybe Play.Id
        , pick : Maybe Play.Id
        , likeDetail : LikeDetail
        , timedOut : Bool
        }


revealing : Maybe LikeDetail -> Id -> User.Id -> Set User.Id -> Card.Call -> List Play -> Time -> Bool -> Revealing
revealing likeDetail id czar players call plays startedAt timedOut =
    { id = id
    , czar = czar
    , players = players
    , call = call
    , plays = plays
    , lastRevealed = Nothing
    , startedAt = startedAt
    , pick = Nothing
    , likeDetail = likeDetail |> Maybe.withDefault defaultLikeDetail
    , timedOut = timedOut
    }


{-| A round while the czar is judging a round.
-}
type alias Judging =
    Data
        { plays : List Play.Known
        , pick : Maybe Play.Id
        , likeDetail : LikeDetail
        , timedOut : Bool
        }


judging :
    Maybe Play.Id
    -> Maybe LikeDetail
    -> Id
    -> User.Id
    -> Set User.Id
    -> Card.Call
    -> List Play.Known
    -> Time
    -> Bool
    -> Judging
judging pick likeDetail id czar players call plays startedAt timedOut =
    { id = id
    , czar = czar
    , players = players
    , call = call
    , plays = plays
    , pick = pick
    , likeDetail = likeDetail |> Maybe.withDefault defaultLikeDetail
    , startedAt = startedAt
    , timedOut = timedOut
    }


{-| A round that has been finished.
-}
type alias Complete =
    Data { plays : Dict User.Id Play.WithLikes, playOrder : List User.Id, winner : User.Id }


complete : Id -> User.Id -> Set User.Id -> Card.Call -> Dict User.Id Play.WithLikes -> List User.Id -> User.Id -> Time -> Complete
complete id czar players call plays playOrder winner startedAt =
    { id = id
    , czar = czar
    , players = players
    , call = call
    , plays = plays
    , playOrder = playOrder
    , winner = winner
    , startedAt = startedAt
    }


{-| Data common to all rounds.
-}
type alias Data specific =
    { specific
        | id : Id
        , czar : User.Id
        , players : Set User.Id
        , call : Card.Call
        , startedAt : Time
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


data : Round -> Data {}
data round =
    case round of
        P rd ->
            extract rd

        J rd ->
            extract rd

        C rd ->
            extract rd

        R rd ->
            extract rd


extract : Data a -> Data {}
extract rd =
    { id = rd.id, call = rd.call, czar = rd.czar, players = rd.players, startedAt = rd.startedAt }
