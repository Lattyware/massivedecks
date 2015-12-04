module MassiveDecks.Models.Card where

type alias Call = List String


slots : Call -> Int
slots call = (List.length call) - 1


type alias Response = String


type Responses
  = Hidden Int
  | Revealed (List PlayedCards)


type alias Hand =
  { hand : List Response
  }


type alias PlayedCards = List Response
