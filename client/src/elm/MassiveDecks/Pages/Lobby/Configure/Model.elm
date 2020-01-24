module MassiveDecks.Pages.Lobby.Configure.Model exposing
    ( Config
    , Deck
    , DeckError
    , Model
    , Tab(..)
    , fake
    )

import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Game.Rules as Rules exposing (Rules)


type Tab
    = Decks
    | Rules
    | TimeLimits
    | Privacy


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
    , passwordVisible : Bool
    , tab : Tab
    , houseRules : Rules.HouseRules
    , public : Bool
    , timeLimits : Rules.TimeLimits
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
    , public : Bool
    }


{-| A fake configuration.
-}
fake : Config
fake =
    { rules =
        { handSize = 0
        , scoreLimit = Nothing
        , houseRules =
            { rando = Nothing
            , packingHeat = Nothing
            , reboot = Nothing
            , comedyWriter = Nothing
            }
        , timeLimits =
            { mode = Rules.Soft
            , playing = Nothing
            , revealing = Nothing
            , judging = Nothing
            , complete = 0
            }
        }
    , decks = []
    , password = Nothing
    , version = ""
    , public = False
    }
