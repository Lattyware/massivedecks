module MassiveDecks.Models.State

  ( Model
  , Global
  , State(..)

  , StartData
  , ConfigData
  , configData
  , PlayingData
  , playingData

  , LobbyIdAndSecret
  , InitialState
  , Error

  ) where

import Random
import Html exposing (Attribute)

import MassiveDecks.Models.Card exposing (Hand, Call, PlayedCards)
import MassiveDecks.Models.Game exposing (Config, Lobby, Round, FinishedRound)
import MassiveDecks.Models.Player exposing (Player, Secret, Status(..), Id, PlayedByAndWinner, byId)
import MassiveDecks.Models.Notification as Notification


{-| The state of the game.
-}
type alias Model =
  { state : State
  , subscription : Maybe (Maybe LobbyIdAndSecret)
  , global: Global
  }


{-| Things that exist globally, regardless of game state.
-}
type alias Global =
  { errors : List Error
  , initialState : InitialState
  , seed : Random.Seed
  }


{-| The state of the game. These are the core 'stages' of the game where the interface is very different, and each is
essentially a little application in it's own right, with transitions between them.

* `SStart` - The start screen where players choose to join games.
* `SConfig` - The configuration state where the game is set up.
* `SPlaying` - The playing state where the game is actually played.
-}
type State
  = SStart StartData
  | SConfig ConfigData
  | SPlaying PlayingData


{-| Data for the start state of the game.
-}
type alias StartData =
  { name : String
  , nameError : Maybe String
  , lobbyId : String
  , lobbyIdError : Maybe String
  }


{-| Data for the configuration state of the game.
-}
type alias ConfigData =
  { lobby : Lobby
  , secret : Secret
  , deckId : String
  , deckIdError : Maybe String
  , loadingDecks : List String
  , playerNotification : Maybe Notification.Player
  }


{-| Create a `ConfigData` in it's initial state.
-}
configData : Lobby -> Secret -> ConfigData
configData lobby secret = ConfigData lobby secret "" Nothing [] Nothing


{-| Data for the playing state of the game.
-}
type alias PlayingData =
  { lobby : Lobby
  , hand : Hand
  , secret : Secret
  , picked : List Int
  , considering : Maybe Int
  , lastFinishedRound : Maybe FinishedRound
  , shownPlayed : List Attribute
  , playerNotification : Maybe Notification.Player
  }


{-| Create a `PlayingData` in it's initial state.
-}
playingData : Lobby -> Hand -> Secret -> PlayingData
playingData lobby hand secret = PlayingData lobby hand secret [] Nothing Nothing [] Nothing


{-| A lobby id and secret of
-}
type alias LobbyIdAndSecret =
  { lobbyId : String
  , secret : Secret
  }


{-| A set of data that is obtained before anything else is done. This is used to get initial data from outside of Elm.
-}
type alias InitialState =
  { url : String
  , gameCode : Maybe String
  , existingGame : Maybe LobbyIdAndSecret
  , seed : Int
  }


{-| A generic error message to be displayed when something goes wrong. Should only be used where there isn't a good way
to avoid the error altogether or display the error closer to it's source.
-}
type alias Error =
  { message : String
  }
