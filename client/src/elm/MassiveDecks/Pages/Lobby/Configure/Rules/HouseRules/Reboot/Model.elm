module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Reboot.Model exposing
    ( Config
    , Id(..)
    , Model
    , Msg(..)
    )

import MassiveDecks.Game.Rules as Rules


type Id
    = All
    | Enabled
    | Children
    | Cost


type alias Model =
    {}


type alias Config =
    Maybe Rules.Reboot


type Msg
    = SetEnabled Bool
    | SetCost (Maybe Int)
    | NoOp
