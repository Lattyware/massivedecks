module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.ComedyWriter.Model exposing
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
    | Exclusive


type alias Model =
    {}


type alias Config =
    Maybe Rules.ComedyWriter


type Msg
    = SetEnabled Bool
    | SetNumber (Maybe Int)
    | SetExclusive (Maybe Bool)
    | NoOp
