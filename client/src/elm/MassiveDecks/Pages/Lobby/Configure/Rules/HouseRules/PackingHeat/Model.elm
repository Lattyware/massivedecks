module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.PackingHeat.Model exposing
    ( Config
    , Id(..)
    , Model
    , Msg(..)
    )

import MassiveDecks.Game.Rules as Rules


type Id
    = All
    | Enabled


type alias Model =
    {}


type alias Config =
    Maybe Rules.PackingHeat


type Msg
    = SetEnabled Bool
