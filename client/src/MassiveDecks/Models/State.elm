module MassiveDecks.Models.State where

import MassiveDecks.Models.Card exposing (Hand)
import MassiveDecks.Models.Game exposing (Config, Lobby)
import MassiveDecks.Models.Player exposing (Player, Secret)


type alias Model =
  { state : State
  , jsAction : Maybe LobbyIdAndSecret
  , errors : List Error
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
  }


type alias LobbyIdAndSecret =
  { lobbyId : String
  , secret : Secret
  }


type alias Error =
  { message : String }
