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
import Html5.DragDrop as DragDrop
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Parts as Parts
import MassiveDecks.Game.Action.Model exposing (Action)
import MassiveDecks.Game.Player exposing (Player)
import MassiveDecks.Game.Round as Round exposing (Round)
import MassiveDecks.Game.Rules exposing (Rules)
import MassiveDecks.Game.Time exposing (Time)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.User as User
import Set exposing (Set)


{-| A model for the game scene.
-}
type alias Model =
    { game : Game
    , hand : List Card.Response
    , filledCards : Dict Card.Id String
    , playStyles : PlayStyles
    , completeRound : Maybe (Round.Specific Round.Complete)
    , viewingHistory : Bool
    , time : Maybe Time
    , helpVisible : Bool
    , confetti : Bool
    , discarded : List ( User.Id, Card.Response )
    , dragDrop : DragDrop.Model Card.Id Int
    }


{-| A model not yet configured with player-specific data.
-}
emptyModel : Game -> Model
emptyModel game =
    { game = game
    , hand = []
    , filledCards = Dict.empty
    , playStyles = Dict.empty
    , completeRound = Nothing
    , viewingHistory = False
    , time = Nothing
    , helpVisible = False
    , confetti = False
    , discarded = []
    , dragDrop = DragDrop.init
    }


{-| A game.
-}
type alias Game =
    { round : Round
    , history : List (Round.Specific Round.Complete)
    , playerOrder : List User.Id
    , players : Dict User.Id Player
    , rules : Rules
    , winner : Maybe (Set User.Id)
    , paused : Bool
    }


{-| A view of a round in the game.
-}
type alias RoundView msg =
    { instruction : Maybe MdString
    , action : Maybe Action
    , content : Html msg
    , slotAttrs : Parts.SlotAttrs msg
    , fillCallWith : Dict Int String
    , roundAttrs : List (Html.Attribute msg)
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
