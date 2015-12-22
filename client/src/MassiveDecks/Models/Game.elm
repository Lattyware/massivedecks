module MassiveDecks.Models.Game where

import MassiveDecks.Models.Player exposing (..)
import MassiveDecks.Models.Card exposing (..)


{-| Configuration for a game.
-}
type alias Config =
  { decks : List DeckInfo
  }


{-| Information about a deck of cards.
-}
type alias DeckInfo =
  { id : String
  , name : String
  , calls : Int
  , responses : Int
  }


{-| A round in the game.
-}
type alias Round =
  { czar : Id
  , call : Call
  , responses : Responses
  }


{-| A round that has been completed.
-}
type alias FinishedRound =
  { call : Call
  , czar : Id
  , responses : (List PlayedCards)
  , playedByAndWinner : PlayedByAndWinner
  }


{-| A lobby.
-}
type alias Lobby =
  { id : String
  , config : Config
  , players : List Player
  , round : Maybe Round
  }


{-| A lobby and a player's hand.
-}
type alias LobbyAndHand =
  { lobby: Lobby
  , hand: Hand
  }
