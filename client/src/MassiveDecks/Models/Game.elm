module MassiveDecks.Models.Game where

import MassiveDecks.Models.Player exposing (..)
import MassiveDecks.Models.Card exposing (..)


type alias Config =
  { deckIds : List String
  }


type alias Round =
  { czar : Id
  , call : Call
  , responses : Responses
  }


type alias Lobby =
  { id : String
  , config : Config
  , players : List Player
  , round : Maybe Round
  }


type alias LobbyAndHand =
  { lobby: Lobby
  , hand: Hand
  }
