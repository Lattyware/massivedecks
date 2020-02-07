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
import MassiveDecks.Pages.Lobby.Configure.TimeLimits.Model as TimeLimits


{-| Where a config has come from.
-}
type Source
    = Local
    | Remote


type Tab
    = Decks
    | Rules
    | TimeLimits
    | Privacy


type Id
    = All
    | DecksId Decks.Id
    | PrivacyId Privacy.Id
    | TimeLimitsId TimeLimits.Id
    | RulesId Rules.Id


type alias Model =
    { localConfig : Config
    , tab : Tab
    , decks : Decks.Model
    , privacy : Privacy.Model
    , timeLimits : TimeLimits.Model
    , rules : Rules.Model
    , conflicts : List Id
    }


{-| Configuration for a lobby.
-}
type alias Config =
    { rules : Rules
    , decks : Decks.Config
    , privacy : Privacy.Config
    , version : String
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
    , privacy =
        { password = Nothing
        , public = False
        }
    , version = ""
    }
