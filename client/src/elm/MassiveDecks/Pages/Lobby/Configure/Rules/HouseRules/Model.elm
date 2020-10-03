module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Model exposing (Id(..))

import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.ComedyWriter.Model as ComedyWriter
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.NeverHaveIEver.Model as NeverHaveIEver
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.HappyEnding.Model as HappyEnding
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.PackingHeat.Model as PackingHeat
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Rando.Model as Rando
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Reboot.Model as Reboot


type Id
    = All
    | RandoId Rando.Id
    | PackingHeatId PackingHeat.Id
    | ComedyWriterId ComedyWriter.Id
    | RebootId Reboot.Id
    | NeverHaveIEverId NeverHaveIEver.Id
    | HappyEndingId HappyEnding.Id
