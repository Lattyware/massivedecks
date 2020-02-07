module MassiveDecks.Pages.Lobby.Configure.Rules exposing
    ( componentById
    , init
    , update
    )

import MassiveDecks.Components.Form.Message as Message
import MassiveDecks.Pages.Lobby.Configure.Component as Component exposing (Component)
import MassiveDecks.Pages.Lobby.Configure.Component.Validator as Validator
import MassiveDecks.Pages.Lobby.Configure.ConfigOption as ConfigOption exposing (ConfigOption)
import MassiveDecks.Pages.Lobby.Configure.ConfigOption.Toggleable as Toggleable
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules as HouseRules
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Model as HouseRules
import MassiveDecks.Pages.Lobby.Configure.Rules.Model exposing (..)
import MassiveDecks.Strings as Strings
import Weightless.Attributes as WlA


init : Model
init =
    { houseRules = HouseRules.init
    }


update : String -> Msg -> Config -> Config -> Model -> ( Config, Model, Cmd msg )
update version msg remote local model =
    case msg of
        HandSizeChange value ->
            ( { local | handSize = value }, model, Cmd.none )

        ScoreLimitChange value ->
            ( { local | scoreLimit = value }, model, Cmd.none )

        HouseRulesMsg houseRulesMsg ->
            let
                ( hrConfig, hrModel, cmd ) =
                    HouseRules.update version houseRulesMsg remote.houseRules local.houseRules model.houseRules
            in
            ( { local | houseRules = hrConfig }, { model | houseRules = hrModel }, cmd )


componentById : Id -> Component Config Model Id Msg msg
componentById id =
    case id of
        All ->
            all

        GameRules ->
            gameRules

        HandSize ->
            handSize |> Component.liftConfig .handSize (\hs -> \c -> { c | handSize = hs })

        ScoreLimit ->
            scoreLimit |> Component.liftConfig .scoreLimit (\sl -> \c -> { c | scoreLimit = sl })

        HouseRulesId houseRule ->
            HouseRules.componentById houseRule
                |> Component.lift HouseRulesId HouseRulesMsg .houseRules (\hr -> \c -> { c | houseRules = hr }) .houseRules



{- Private -}


all : Component Config Model Id Msg msg
all =
    Component.group All
        Nothing
        [ componentById GameRules
        , componentById (HouseRulesId HouseRules.All)
        ]


gameRules : Component Config Model Id Msg msg
gameRules =
    Component.group GameRules
        (Just Strings.ConfigureRules)
        [ componentById HandSize
        , componentById ScoreLimit
        ]


handSize : Component Int Model Id Msg msg
handSize =
    Component.value
        HandSize
        (ConfigOption.view handSizeOption)
        (always False)
        (Validator.between 3 50 HandSizeChange)


handSizeOption : ConfigOption Model Int Msg msg
handSizeOption =
    { id = "hand-size-option"
    , toggleable = Nothing
    , primaryEditor =
        \_ -> ConfigOption.intEditor Strings.HandSize [ 3 |> WlA.min, 50 |> WlA.max ]
    , extraEditor = ConfigOption.noExtraEditor
    , set = ConfigOption.wrappedSetter HandSizeChange
    , messages = \_ -> [ Message.info Strings.HandSizeDescription ]
    }


scoreLimit : Component (Maybe Int) Model Id Msg msg
scoreLimit =
    Component.value
        ScoreLimit
        (ConfigOption.view scoreLimitOption)
        (always False)
        (Validator.optional (Validator.between 3 10000 (Just >> ScoreLimitChange)))


scoreLimitOption : ConfigOption Model (Maybe Int) Msg msg
scoreLimitOption =
    { id = "score-limit-option"
    , toggleable = Toggleable.maybe 25
    , primaryEditor =
        \_ -> ConfigOption.maybeEditor (ConfigOption.intEditor Strings.ScoreLimit [ 3 |> WlA.min, 10000 |> WlA.max ])
    , extraEditor = ConfigOption.noExtraEditor
    , set = ConfigOption.wrappedSetter ScoreLimitChange
    , messages = \_ -> [ Message.info Strings.ScoreLimitDescription ]
    }
