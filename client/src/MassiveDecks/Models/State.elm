module MassiveDecks.Models.State where

import Random
import Html exposing (Attribute)

import MassiveDecks.Models.Card exposing (Hand, Call, PlayedCards)
import MassiveDecks.Models.Game exposing (Config, Lobby, Round, FinishedRound)
import MassiveDecks.Models.Player exposing (Player, Secret, Status(..), Id, PlayedByAndWinner, byId)
import MassiveDecks.Models.Notification as Notification


type alias Model =
  { state : State
  , jsAction : Maybe LobbyIdAndSecret
  , global: Global
  }


type alias Global =
  { errors : List Error
  , initialState : InitialState
  , seed : Random.Seed
  }


type State
  = SStart StartData
  | SConfig ConfigData
  | SPlaying PlayingData


type alias StartData =
  { name : String
  , lobbyId : String
  }


type alias ConfigData =
  { lobby : Lobby
  , secret : Secret
  , deckId : String
  , loadingDecks : List String
  , playerNotification : Maybe Notification.Player
  }


configData : Lobby -> Secret -> ConfigData
configData lobby secret = ConfigData lobby secret "" [] Nothing


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


playingData : Lobby -> Hand -> Secret -> PlayingData
playingData lobby hand secret = PlayingData lobby hand secret [] Nothing Nothing [] Nothing


type alias LobbyIdAndSecret =
  { lobbyId : String
  , secret : Secret
  }


type alias InitialState =
  { url : String
  , gameCode : Maybe String
  , existingGame : Maybe LobbyIdAndSecret
  , seed : Int
  }


type alias Error =
  { message : String }
