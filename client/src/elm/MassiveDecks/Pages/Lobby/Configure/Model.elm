module MassiveDecks.Pages.Lobby.Configure.Model exposing
    ( Config
    , Id(..)
    , Model
    , Source(..)
    , Tab(..)
    , fake
    )

import MassiveDecks.Game.Rules as Rules exposing (Rules)
import MassiveDecks.Pages.Lobby.Configure.Decks.Model as Decks
import MassiveDecks.Pages.Lobby.Configure.Privacy.Model as Privacy
import MassiveDecks.Pages.Lobby.Configure.Rules.Model as Rules
import MassiveDecks.Pages.Lobby.Configure.Stages.Model as Stages


{-| Where a config has come from.
-}
type Source
    = Local
    | Remote


type Tab
    = Decks
    | Rules
    | Stages
    | Privacy


type Id
    = All
    | NameId
    | PrivacyId Privacy.Id
    | StagesId Stages.Id
    | RulesId Rules.Id
    | DecksId Decks.Id


type alias Model =
    { localConfig : Config
    , tab : Tab
    , decks : Decks.Model
    , passwordVisible : Bool
    , conflicts : List Id
    }


{-| Configuration for a lobby.
-}
type alias Config =
    { name : String
    , rules : Rules
    , decks : Decks.Config
    , privacy : Privacy.Config
    , version : String
    }


{-| A fake configuration.
-}
fake : Config
fake =
    { name = "A Game"
    , rules =
        { handSize = 0
        , scoreLimit = Nothing
        , houseRules =
            { rando = Nothing
            , packingHeat = Nothing
            , reboot = Nothing
            , comedyWriter = Nothing
            , neverHaveIEver = Nothing
            , happyEnding = Nothing
            }
        , stages =
            { mode = Rules.Soft
            , playing = { duration = Nothing, after = 0 }
            , revealing = Nothing
            , judging = { duration = Nothing, after = 0 }
            }
        }
    , decks = []
    , privacy =
        { password = Nothing
        , public = False
        , audienceMode = False
        }
    , version = ""
    }
