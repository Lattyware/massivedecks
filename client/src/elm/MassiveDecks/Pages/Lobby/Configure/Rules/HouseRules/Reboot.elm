module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Reboot exposing
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
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Reboot.Model exposing (..)
import MassiveDecks.Strings as Strings
import MassiveDecks.Util.Maybe as Maybe
import Weightless.Attributes as WlA


init : Model
init =
    {}


default : Rules.Reboot
default =
    { cost = 1
    }


update : Msg -> Config -> Model -> ( Config, Model, Cmd msg )
update msg local model =
    case msg of
        SetEnabled value ->
            ( local |> Maybe.withDefault default |> Maybe.justIf value, model, Cmd.none )

        SetCost value ->
            ( setCost value local, model, Cmd.none )

        NoOp ->
            ( local, model, Cmd.none )


componentById : Id -> Component Config Model Id Msg msg
componentById id =
    case id of
        All ->
            all

        Enabled ->
            enabled |> Component.liftConfig Maybe.isJust (\e -> \old -> old |> Maybe.withDefault default |> Maybe.justIf e)

        Children ->
            children

        Cost ->
            cost |> Component.liftConfig (Maybe.map .cost) setCost



{- Private -}


setCost : Maybe Int -> Config -> Config
setCost value local =
    value |> Maybe.map (\v -> local |> Maybe.withDefault default |> (\c -> { c | cost = v }))


all : Component Config Model Id Msg msg
all =
    Component.group All
        Nothing
        [ componentById Enabled
        , children
        ]


children : Component Config Model Id Msg msg
children =
    Component.indentedGroup Children [ componentById Cost ]


enabled : Component Bool Model Id Msg msg
enabled =
    Component.value
        Enabled
        (ConfigOption.view enabledOption)
        (always False)
        Validator.none


enabledOption : ConfigOption Model Bool Msg msg
enabledOption =
    { id = "reboot-enabled"
    , toggleable = Toggleable.bool
    , primaryEditor = \_ -> ConfigOption.Label { text = Strings.HouseRuleReboot }
    , extraEditor = ConfigOption.noExtraEditor
    , set = ConfigOption.wrappedSetter SetEnabled
    , messages = \_ -> [ Strings.HouseRuleRebootDescription { cost = Nothing } |> Message.info ]
    }


costMin : Int
costMin =
    1


costMax : Int
costMax =
    50


cost : Component (Maybe Int) Model Id Msg msg
cost =
    Component.value
        Cost
        (ConfigOption.view costOption)
        Maybe.isNothing
        (Validator.optional (Validator.between costMin costMax (Just >> SetCost)))


costOption : ConfigOption Model (Maybe Int) Msg msg
costOption =
    { id = "reboot-cost"
    , toggleable = Toggleable.none
    , primaryEditor =
        \_ ->
            ConfigOption.intEditor Strings.HouseRuleRebootCost [ WlA.min costMin, WlA.max costMax ]
                |> ConfigOption.maybeEditor
    , extraEditor = ConfigOption.noExtraEditor
    , set = ConfigOption.wrappedSetter SetCost
    , messages = \_ -> [ Strings.HouseRuleRebootCostDescription |> Message.info ]
    }
