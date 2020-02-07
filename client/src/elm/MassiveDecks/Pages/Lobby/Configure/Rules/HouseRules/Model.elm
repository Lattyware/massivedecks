module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Model exposing
    ( Config
    , Id(..)
    , Model
    , Msg(..)
    )

import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.ComedyWriter.Model as ComedyWriter
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.PackingHeat.Model as PackingHeat
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Rando.Model as Rando
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Reboot.Model as Reboot


type Id
    = All
    | RandoId Rando.Id
    | PackingHeatId PackingHeat.Id
    | ComedyWriterId ComedyWriter.Id
    | RebootId Reboot.Id


type alias Model =
    { rando : Rando.Model
    , packingHeat : PackingHeat.Model
    , comedyWriter : ComedyWriter.Model
    , reboot : Reboot.Model
    }


type alias Config =
    Rules.HouseRules


type Msg
    = RandoMsg Rando.Msg
    | PackingHeatMsg PackingHeat.Msg
    | ComedyWriterMsg ComedyWriter.Msg
    | RebootMsg Reboot.Msg
