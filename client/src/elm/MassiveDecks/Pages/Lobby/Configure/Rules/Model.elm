module MassiveDecks.Pages.Lobby.Configure.Rules.Model exposing
    ( Config
    , Id(..)
    , Model
    , Msg(..)
    )

import MassiveDecks.Game.Rules exposing (Rules)
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Model as HouseRules


type Id
    = All
    | GameRules
    | HandSize
    | ScoreLimit
    | HouseRulesId HouseRules.Id


type alias Model =
    { houseRules : HouseRules.Model
    }


type alias Config =
    Rules


type Msg
    = HandSizeChange Int
    | ScoreLimitChange (Maybe Int)
    | HouseRulesMsg HouseRules.Msg
