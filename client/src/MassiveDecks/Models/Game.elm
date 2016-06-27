module MassiveDecks.Models.Game exposing (..)

import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.Player as Player exposing (Player)
import MassiveDecks.Scenes.Playing.HouseRule.Id as HouseRule


{-| The required information to rejoin a lobby - the ID and the secret.
-}
type alias GameCodeAndSecret =
  { gameCode : GameCode
  , secret : Player.Secret
  }


{-| A lobby ID is a string used to identify a given lobby.
-}
type alias GameCode = String



{-| Configuration for a game.
-}
type alias Config =
  { decks : List DeckInfo
  , houseRules : List HouseRule.Id
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
  { czar : Player.Id
  , call : Card.Call
  , responses : Card.Responses
  , afterTimeLimit : Bool
  }


{-| A round that has been completed.
-}
type alias FinishedRound =
  { czar : Player.Id
  , call : Card.Call
  , responses : (List Card.PlayedCards)
  , playedByAndWinner : Player.PlayedByAndWinner
  }


{-| A lobby.
-}
type alias Lobby =
  { gameCode : String
  , config : Config
  , players : List Player
  , round : Maybe Round
  }


{-| A lobby and a player's hand.
-}
type alias LobbyAndHand =
  { lobby: Lobby
  , hand: Card.Hand
  }
