module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.ComedyWriter exposing
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
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.ComedyWriter.Model exposing (..)
import MassiveDecks.Strings as Strings
import MassiveDecks.Util.Maybe as Maybe


init : Model
init =
    {}


default : Rules.ComedyWriter
default =
    { exclusive = False
    , number = 3
    }


update : Msg -> Config -> Model -> ( Config, Model, Cmd msg )
update msg local model =
    case msg of
        SetEnabled value ->
            ( local |> Maybe.withDefault default |> Maybe.justIf value, model, Cmd.none )

        SetNumber value ->
            ( setNumber value local, model, Cmd.none )

        SetExclusive value ->
            ( setExclusive value local, model, Cmd.none )

        NoOp ->
            ( local, model, Cmd.none )


componentById : Id -> Component Config Model Id Msg msg
componentById id =
    case id of
        All ->
            all

        Children ->
            children

        Enabled ->
            enabled |> Component.liftConfig Maybe.isJust (\e -> \old -> old |> Maybe.withDefault default |> Maybe.justIf e)

        Number ->
            number |> Component.liftConfig (Maybe.map .number) setNumber

        Exclusive ->
            exclusive |> Component.liftConfig (Maybe.map .exclusive) setExclusive



{- Private -}


setNumber : Maybe Int -> Config -> Config
setNumber value local =
    value |> Maybe.map (\n -> local |> Maybe.withDefault default |> (\c -> { c | number = n }))


setExclusive : Maybe Bool -> Config -> Config
setExclusive value local =
    value |> Maybe.map (\e -> local |> Maybe.withDefault default |> (\c -> { c | exclusive = e }))


all : Component Config Model Id Msg msg
all =
    Component.group All
        Nothing
        [ componentById Enabled
        , children
        ]


children : Component Config Model Id Msg msg
children =
    Component.indentedGroup Children
        [ componentById Exclusive
        , componentById Number
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
    { id = "comedy-writer-enabled"
    , toggleable = Toggleable.bool
    , primaryEditor = \_ -> ConfigOption.Label { text = Strings.HouseRuleComedyWriter }
    , extraEditor = ConfigOption.noExtraEditor
    , set = ConfigOption.wrappedSetter SetEnabled
    , messages = \_ -> [ Strings.HouseRuleComedyWriterDescription |> Message.info ]
    }


numberBounds : ConfigOption.IntBounds
numberBounds =
    ConfigOption.IntBounds 1 99999


number : Component (Maybe Int) Model Id Msg msg
number =
    Component.value
        Number
        (ConfigOption.view numberOption)
        Maybe.isNothing
        (Validator.optional (ConfigOption.toValidator numberBounds (Just >> SetNumber)))


numberOption : ConfigOption Model (Maybe Int) Msg msg
numberOption =
    { id = "comedy-writer-number"
    , toggleable = Nothing
    , primaryEditor =
        \_ ->
            ConfigOption.intEditor Strings.HouseRuleComedyWriterNumber (ConfigOption.toMinMaxAttrs numberBounds)
                |> ConfigOption.maybeEditor
    , extraEditor = ConfigOption.noExtraEditor
    , set = ConfigOption.wrappedSetter SetNumber
    , messages = \_ -> [ Strings.HouseRuleComedyWriterNumberDescription |> Message.info ]
    }


exclusive : Component (Maybe Bool) Model Id Msg msg
exclusive =
    Component.value
        Exclusive
        (ConfigOption.view exclusiveOption)
        Maybe.isNothing
        Validator.none


exclusiveOption : ConfigOption Model (Maybe Bool) Msg msg
exclusiveOption =
    { id = "comedy-writer-exclusive"
    , toggleable = Toggleable.bool |> Toggleable.map Just
    , primaryEditor = \_ -> ConfigOption.Label { text = Strings.HouseRuleComedyWriterExclusive }
    , extraEditor = ConfigOption.noExtraEditor
    , set = ConfigOption.wrappedSetter SetExclusive
    , messages = \_ -> [ Strings.HouseRuleComedyWriterExclusiveDescription |> Message.info ]
    }
