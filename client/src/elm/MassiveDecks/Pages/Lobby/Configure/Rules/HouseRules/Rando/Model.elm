module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Rando.Model exposing
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
    | Number


type alias Model =
    {}


type alias Config =
    Maybe Rules.Rando


type Msg
    = SetEnabled Bool
    | SetNumber (Maybe Int)
    | Set Rules.Rando
    | NoOp
