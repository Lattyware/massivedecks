module MassiveDecks.Models.State where

import MassiveDecks.Models.Card exposing (Hand)
import MassiveDecks.Models.Game exposing (Config, Lobby, Round)
import MassiveDecks.Models.Player exposing (Player, Secret)


type alias Model =
  { state : State
  , jsAction : Maybe LobbyIdAndSecret
  , global: Global
  }


type alias Global =
  { errors : List Error
  , initialState : InitialState
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
  }


type alias PlayingData =
  { lobby : Lobby
  , hand : Hand
  , secret : Secret
  , picked : List Int
  , lastFinishedRound : Maybe Round
  }


type alias LobbyIdAndSecret =
  { lobbyId : String
  , secret : Secret
  }


type alias InitialState =
  { url : String
  , gameCode : Maybe String
  , existingGame : Maybe LobbyIdAndSecret
  }


type alias Error =
  { message : String }
