module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.PackingHeat exposing
    ( componentById
    , default
    , init
    , update
    )

import MassiveDecks.Components.Form.Message as Message
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Pages.Lobby.Configure.Component as Component exposing (Component)
import MassiveDecks.Pages.Lobby.Configure.Component.Validator as Validator
import MassiveDecks.Pages.Lobby.Configure.ConfigOption as ConfigOption exposing (ConfigOption)
import MassiveDecks.Pages.Lobby.Configure.ConfigOption.Toggleable as Toggleable
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.PackingHeat.Model exposing (..)
import MassiveDecks.Strings as Strings
import MassiveDecks.Util.Maybe as Maybe


init : Model
init =
    {}


default : Rules.PackingHeat
default =
    {}


update : Msg -> Config -> Model -> ( Config, Model, Cmd msg )
update msg _ model =
    case msg of
        SetEnabled value ->
            ( default |> Maybe.justIf value, model, Cmd.none )


componentById : Id -> Component Config Model Id Msg msg
componentById id =
    case id of
        All ->
            all

        Enabled ->
            enabled |> Component.liftConfig Maybe.isJust (\v -> \_ -> default |> Maybe.justIf v)



{- Private -}


all : Component Config Model Id Msg msg
all =
    Component.group All
        Nothing
        [ componentById Enabled
        ]


enabled : Component Bool Model Id Msg msg
enabled =
    Component.value
        Enabled
        (ConfigOption.view enabledOption)
        (always False)
        Validator.none


enabledOption : ConfigOption Model Bool Msg msg
enabledOption =
    { id = "packing-heat-enabled"
    , toggleable = Toggleable.bool
    , primaryEditor = \_ -> ConfigOption.Label { text = Strings.HouseRulePackingHeat }
    , extraEditor = ConfigOption.noExtraEditor
    , set = ConfigOption.wrappedSetter SetEnabled
    , messages = \_ -> [ Strings.HouseRulePackingHeatDescription |> Message.info ]
    }
