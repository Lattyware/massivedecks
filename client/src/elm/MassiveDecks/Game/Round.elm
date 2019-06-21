module MassiveDecks.Game.Round exposing
    ( Complete
    , Data
    , Id
    , Judging
    , Pick
    , PickState(..)
    , Playing
    , Revealing
    , Round(..)
    , complete
    , data
    , idDecoder
    , judging
    , noPick
    , playing
    , revealing
    )

import Dict exposing (Dict)
import Json.Decode as Json
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Play as Play exposing (Play)
import MassiveDecks.User as User
import Set exposing (Set)


{-| A unique id for a round.
-}
type Id
    = Id String


idDecoder : Json.Decoder Id
idDecoder =
    Json.string |> Json.map Id


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
    Data { played : Set User.Id, pick : Pick }


playing : Id -> User.Id -> Set User.Id -> Card.Call -> Set User.Id -> Playing
playing id czar players call played =
    { id = id
    , czar = czar
    , players = players
    , call = call
    , played = played
    , pick = { state = Selected, cards = [] }
    }


type alias Revealing =
    Data { plays : List Play }


revealing : Id -> User.Id -> Set User.Id -> Card.Call -> List Play -> Revealing
revealing id czar players call plays =
    { id = id
    , czar = czar
    , players = players
    , call = call
    , plays = plays
    }


{-| A round while the czar is judging a round.
-}
type alias Judging =
    Data { plays : List Play.Known, pick : Maybe Play.Id, liked : Set Play.Id }


judging : Id -> User.Id -> Set User.Id -> Card.Call -> List Play.Known -> Judging
judging id czar players call plays =
    { id = id
    , czar = czar
    , players = players
    , call = call
    , plays = plays
    , pick = Nothing
    , liked = Set.empty
    }


{-| A round that has been finished.
-}
type alias Complete =
    Data { plays : Dict User.Id (List Card.Response), winner : User.Id }


complete : Id -> User.Id -> Set User.Id -> Card.Call -> Dict User.Id (List Card.Response) -> User.Id -> Complete
complete id czar players call plays winner =
    { id = id
    , czar = czar
    , players = players
    , call = call
    , plays = plays
    , winner = winner
    }


{-| Data common to all rounds.
-}
type alias Data specific =
    { specific
        | id : Id
        , czar : User.Id
        , players : Set User.Id
        , call : Card.Call
    }


{-| The user's pick for the round.
-}
type alias Pick =
    { state : PickState, cards : List Card.Id }


noPick =
    { state = Selected, cards = [] }


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
    { id = rd.id, call = rd.call, czar = rd.czar, players = rd.players }
