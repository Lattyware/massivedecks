module MassiveDecks.Pages.Lobby.Configure.Model exposing
    ( Config
    , Model
    , Tab(..)
    , fake
    )

import MassiveDecks.Game.Rules as Rules exposing (Rules)
import MassiveDecks.Pages.Lobby.Configure.Decks.Model as Decks


type Tab
    = Decks
    | Rules
    | TimeLimits
    | Privacy


type alias Model =
    { decks : Decks.Model
    , handSize : Int
    , scoreLimit : Maybe Int
    , password : Maybe String
    , passwordVisible : Bool
    , tab : Tab
    , houseRules : Rules.HouseRules
    , public : Bool
    , timeLimits : Rules.TimeLimits
    }


{-| Configuration for a lobby.
-}
type alias Config =
    { rules : Rules
    , decks : Decks.Config
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
