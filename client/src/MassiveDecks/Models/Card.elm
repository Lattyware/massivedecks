module MassiveDecks.Models.Card

  ( Call
  , Response

  , Responses(..)
  , RevealedResponses

  , Hand

  , PlayedCards

  , slots
  , filled

  , playedCardsByPlayer
  , winningCards

  ) where

import String
import Dict exposing (Dict)

import MassiveDecks.Models.Player as Player
import MassiveDecks.Util as Util


{-| A call (black card) is composed of a list of strings making up the text of the card, with a blank space ('slot') for
a response implicitly existing inbetween each string.
-}
type alias Call =
  { id: String
  , parts: List String
  }


{-| A response (white card).
-}
type alias Response =
  { id: String
  , text: String
  }


{-| Responses as they exist in a round. Either those responses are:
* Hidden - The round is still being played into, so the only information is the number of cards played in so far.
* Revealed - Every player has played in, and the responses are revealed.
-}
type Responses
  = Hidden Int
  | Revealed RevealedResponses


{-| The responses that have been played into a round. If the round has ended, also who played what and who won.
-}
type alias RevealedResponses =
  { cards : List PlayedCards
  , playedByAndWinner : Maybe Player.PlayedByAndWinner
  }


{-| A hand of a player.
-}
type alias Hand =
  { hand : List Response
  }


{-| Cards that have been played into a round for a call.
-}
type alias PlayedCards = List Response


{-| The number of slots on a given call.
-}
slots : Call -> Int
slots call = (List.length call.parts) - 1


{-| Produce a string of the given call with the given played cards injected into it.
-}
filled : Call -> PlayedCards -> String
filled call playedCards = String.concat (Util.interleave (List.map .text playedCards) call.parts)


{-| Join the player ids to the cards played into a round.
-}
playedCardsByPlayer : List Player.Id -> List PlayedCards -> Dict Player.Id PlayedCards
playedCardsByPlayer players cards = List.map2 (,) players cards |> Dict.fromList


{-| The cards played by the winner of the game.
-}
winningCards : List PlayedCards -> Player.PlayedByAndWinner -> Maybe PlayedCards
winningCards cards playedByAndWinner =
  let
    cardsByPlayer = playedCardsByPlayer playedByAndWinner.playedBy cards
    winner = playedByAndWinner.winner
  in
    Dict.get winner cardsByPlayer
