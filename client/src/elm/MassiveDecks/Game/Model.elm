module MassiveDecks.Game.Model exposing
    ( CardStyle
    , Game
    , Model
    , PlayStyle
    , PlayStyles
    , RoundView
    , emptyModel
    )

import Dict exposing (Dict)
import Html exposing (Html)
import MassiveDecks.Card.Model as Card
import MassiveDecks.Game.Action.Model exposing (Action)
import MassiveDecks.Game.Player exposing (Player)
import MassiveDecks.Game.Round as Round exposing (Round)
import MassiveDecks.Game.Rules exposing (Rules)
import MassiveDecks.Game.Time exposing (Time)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.User as User


{-| A model for the game scene.
-}
type alias Model =
    { game : Game
    , hand : List Card.Response
    , playStyles : PlayStyles
    , completeRound : Maybe Round.Complete
    , viewingHistory : Bool
    , time : Maybe Time
    }


{-| A model not yet configured with player-specific data.
-}
emptyModel : Game -> Model
emptyModel game =
    { game = game
    , hand = []
    , playStyles = Dict.empty
    , completeRound = Nothing
    , viewingHistory = False
    , time = Nothing
    }


{-| A game.
-}
type alias Game =
    { round : Round
    , history : List Round.Complete
    , playerOrder : List User.Id
    , players : Dict User.Id Player
    , rules : Rules
    , winner : Maybe User.Id
    , paused : Bool
    }


{-| A view of a round in the game.
-}
type alias RoundView msg =
    { instruction : Maybe MdString
    , action : Maybe Action
    , content : Html msg
    , fillCallWith : List Card.Response
    }


{-| Data to render all the plays in a round.
-}
type alias PlayStyles =
    Dict User.Id PlayStyle


{-| Data to render a play.
-}
type alias PlayStyle =
    List CardStyle


{-| Data to render a card in a play.
-}
type alias CardStyle =
    { rotation : Float
    }
