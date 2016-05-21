module MassiveDecks.Scenes.Playing.Models exposing (Model, ShownPlayedCards)

import Random

import Html exposing (Attribute)

import MassiveDecks.Scenes.Playing.Messages exposing (Message)
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
  { animated : List (Attribute Message)
  , toAnimate : List (Attribute Message)
  }
