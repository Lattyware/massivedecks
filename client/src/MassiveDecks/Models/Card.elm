module MassiveDecks.Models.Card where

import String

import MassiveDecks.Models.Player as Player
import MassiveDecks.Util as Util


type alias Call = List String


slots : Call -> Int
slots call = (List.length call) - 1


filled : Call -> PlayedCards -> String
filled call playedCards = String.concat (Util.interleave playedCards call)


type alias Response = String


type Responses
  = Hidden Int
  | Revealed RevealedResponses


type alias RevealedResponses =
  { cards : List PlayedCards
  , playedByAndWinner : Maybe Player.PlayedByAndWinner
  }


playedCardsByPlayer : List Player.Id -> List PlayedCards -> List (Player.Id, PlayedCards)
playedCardsByPlayer players cards = List.map2 (,) players cards


winningCards : List PlayedCards -> Player.PlayedByAndWinner -> Maybe PlayedCards
winningCards cards playedByAndWinner =
  let
    cardsByPlayer = playedCardsByPlayer playedByAndWinner.playedBy cards
    winner = playedByAndWinner.winner
  in
    List.filter (\cards -> (fst cards) == winner) cardsByPlayer |> List.head |> Maybe.map snd


type alias Hand =
  { hand : List Response
  }


type alias PlayedCards = List Response
