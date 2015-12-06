module MassiveDecks.Models.Game where

import MassiveDecks.Models.Player exposing (..)
import MassiveDecks.Models.Card exposing (..)


type alias Config =
  { decks : List DeckInfo
  }


type alias DeckInfo =
  { id : String
  , name : String
  , calls : Int
  , responses : Int
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
