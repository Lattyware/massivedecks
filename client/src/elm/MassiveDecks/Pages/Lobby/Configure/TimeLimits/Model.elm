module MassiveDecks.Pages.Lobby.Configure.TimeLimits.Model exposing
    ( Config
    , Id(..)
    , Model
    , Msg(..)
    )

import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Rules as Rules exposing (TimeLimits)


type Id
    = All
    | Mode
    | TimeLimit Round.Stage


type alias Config =
    TimeLimits


type alias Model =
    {}


type Msg
    = TimeLimitChangeMode Rules.TimeLimitMode
    | TimeLimitChange Round.Stage (Maybe Int)
