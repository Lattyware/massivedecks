module MassiveDecks.Pages.Lobby.Configure.Model exposing
    ( Config
    , Deck
    , DeckError
    , Model
    , Tab(..)
    )

import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Game.Rules as Rules exposing (Rules)


type Tab
    = Decks
    | Rules
    | Game


type alias DeckError =
    { reason : Source.LoadFailureReason
    , deck : Source.External
    }


type alias Model =
    { deckToAdd : Source.External
    , deckErrors : List DeckError
    , handSize : Int
    , scoreLimit : Maybe Int
    , password : Maybe String
    , tab : Tab
    , houseRules : Rules.HouseRules
    }


{-| A deck in the configuration, either loaded or not.
-}
type alias Deck =
    { source : Source.External, summary : Maybe Source.Summary }


{-| Configuration for a lobby.
-}
type alias Config =
    { rules : Rules
    , decks : List Deck
    , password : Maybe String
    , version : String
    }
