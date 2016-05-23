module MassiveDecks.Scenes.Playing.Models exposing (Model, ShownPlayedCards, ShownCard)

import Random

import MassiveDecks.Models.Game as Game


{-| The state of the lobby.
-}
type alias Model =
  { picked : List String
  , considering : Maybe Int
  , finishedRound : Maybe Game.FinishedRound
  , shownPlayed : ShownPlayedCards
  , seed : Random.Seed
  }


type alias ShownPlayedCards =
  { animated : List (ShownCard)
  , toAnimate : List (ShownCard)
  }


type alias ShownCard =
  { rotation : Int
  , horizontalPos : Int
  , isLeft : Bool
  , verticalPos : Int
  }
