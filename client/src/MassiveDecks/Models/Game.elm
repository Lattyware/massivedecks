module MassiveDecks.Models.Game exposing (..)

import MassiveDecks.Models.Game.Round as Round exposing (Round)
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
type alias GameCode =
    String


{-| Configuration for a game.
-}
type alias Config =
    { decks : List DeckInfo
    , houseRules : List HouseRule.Id
    , password : Maybe String
    }


{-| Information about a deck of cards.
-}
type alias DeckInfo =
    { id : String
    , name : String
    , calls : Int
    , responses : Int
    }


type State
    = Configuring
    | Playing Round
    | Finished


{-| A lobby.
-}
type alias Lobby =
    { gameCode : String
    , owner : Player.Id
    , config : Config
    , players : List Player
    , game : State
    }


{-| A lobby and a player's hand.
-}
type alias LobbyAndHand =
    { lobby : Lobby
    , hand : Card.Hand
    }
