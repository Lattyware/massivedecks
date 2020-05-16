module MassiveDecks.Pages.Lobby.Configure.Rules.Model exposing (Id(..))

import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Model as HouseRules


type Id
    = All
    | GameRules
    | HandSize
    | ScoreLimit
    | HouseRulesId HouseRules.Id
