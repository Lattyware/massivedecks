module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Rando exposing
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
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Rando.Model exposing (..)
import MassiveDecks.Strings as Strings
import MassiveDecks.Util.Maybe as Maybe


init : Model
init =
    {}


default : Rules.Rando
default =
    { number = 1 }


update : Msg -> Config -> Model -> ( Config, Model, Cmd msg )
update msg local model =
    case msg of
        SetEnabled value ->
            ( local |> Maybe.withDefault default |> Maybe.justIf value, model, Cmd.none )

        SetNumber value ->
            ( setNumber value local, model, Cmd.none )

        Set value ->
            ( Just value, model, Cmd.none )

        NoOp ->
            ( local, model, Cmd.none )


componentById : Id -> Component Config Model Id Msg msg
componentById id =
    case id of
        All ->
            all

        Enabled ->
            enabled |> Component.liftConfig Maybe.isJust (\v -> \_ -> default |> Maybe.justIf v)

        Children ->
            children

        Number ->
            number |> Component.liftConfig (Maybe.map .number) setNumber



{- Private -}


setNumber : Maybe Int -> Config -> Config
setNumber value local =
    value |> Maybe.map (\n -> local |> Maybe.withDefault default |> (\c -> { c | number = n }))


all : Component Config Model Id Msg msg
all =
    Component.group All
        Nothing
        [ componentById Enabled
        , children
        ]


children : Component Config Model Id Msg msg
children =
    Component.indentedGroup Children [ componentById Number ]


enabled : Component Bool Model Id Msg msg
enabled =
    Component.value
        Enabled
        (ConfigOption.view enabledOption)
        (always False)
        Validator.none


enabledOption : ConfigOption Model Bool Msg msg
enabledOption =
    { id = "rando-enabled"
    , toggleable = Toggleable.bool
    , primaryEditor = \_ -> ConfigOption.Label { text = Strings.HouseRuleRandoCardrissian }
    , extraEditor = ConfigOption.noExtraEditor
    , set = ConfigOption.wrappedSetter SetEnabled
    , messages = \_ -> [ Strings.HouseRuleRandoCardrissianDescription |> Message.info ]
    }


numberBounds : ConfigOption.IntBounds
numberBounds =
    ConfigOption.IntBounds 1 10


number : Component (Maybe Int) Model Id Msg msg
number =
    Component.value
        Number
        (ConfigOption.view numberOption)
        Maybe.isNothing
        (Validator.optional (ConfigOption.toValidator numberBounds (Just >> SetNumber)))


numberOption : ConfigOption Model (Maybe Int) Msg msg
numberOption =
    { id = "rando-number"
    , toggleable = Toggleable.none
    , primaryEditor =
        \_ ->
            ConfigOption.intEditor Strings.HouseRuleRandoCardrissianNumber (ConfigOption.toMinMaxAttrs numberBounds)
                |> ConfigOption.maybeEditor
    , extraEditor = ConfigOption.noExtraEditor
    , set = ConfigOption.wrappedSetter SetNumber
    , messages = \_ -> [ Strings.HouseRuleRandoCardrissianNumberDescription |> Message.info ]
    }
