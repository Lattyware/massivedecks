module MassiveDecks.Pages.Lobby.Configure.TimeLimits exposing
    ( componentById
    , default
    , init
    , update
    )

import MassiveDecks.Components.Form.Message as Message
import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Pages.Lobby.Configure.Component as Component exposing (Component)
import MassiveDecks.Pages.Lobby.Configure.Component.Validator as Validator
import MassiveDecks.Pages.Lobby.Configure.ConfigOption as ConfigOption exposing (ConfigOption)
import MassiveDecks.Pages.Lobby.Configure.TimeLimits.Model exposing (..)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Util.Maybe as Maybe


init : Model
init =
    {}


default : Config
default =
    Rules.defaultTimeLimits


update : Msg -> Config -> Model -> ( Config, Model, Cmd msg )
update msg config model =
    case msg of
        TimeLimitChangeMode value ->
            ( { config | mode = value }, model, Cmd.none )

        TimeLimitChange stage value ->
            ( Rules.setTimeLimitByStage stage value config, model, Cmd.none )


componentById : Id -> Component Config Model Id Msg msg
componentById id =
    case id of
        All ->
            all

        Mode ->
            mode |> Component.liftConfig .mode (\m -> \c -> { c | mode = m })

        TimeLimit round ->
            case round of
                Round.SPlaying ->
                    timeLimit Round.SPlaying Strings.PlayingTimeLimitDescription True
                        |> Component.liftConfig .playing (\t -> \c -> { c | playing = t })

                Round.SRevealing ->
                    timeLimit Round.SRevealing Strings.RevealingTimeLimitDescription True
                        |> Component.liftConfig .revealing (\t -> \c -> { c | revealing = t })

                Round.SJudging ->
                    timeLimit Round.SJudging Strings.JudgingTimeLimitDescription True
                        |> Component.liftConfig .judging (\t -> \c -> { c | judging = t })

                Round.SComplete ->
                    timeLimit Round.SComplete Strings.CompleteTimeLimitDescription False
                        |> Component.liftConfig (.complete >> Just) (\t -> \c -> { c | complete = t |> Maybe.withDefault c.complete })



{- Private -}


all : Component Config Model Id Msg msg
all =
    Component.group All
        (Just Strings.ConfigureTimeLimits)
        [ componentById Mode
        , componentById (TimeLimit Round.SPlaying)
        , componentById (TimeLimit Round.SRevealing)
        , componentById (TimeLimit Round.SJudging)
        , componentById (TimeLimit Round.SComplete)
        ]


mode : Component Rules.TimeLimitMode Model Id Msg msg
mode =
    Component.value
        Mode
        (ConfigOption.view modeOption)
        (always False)
        Validator.none


modeOption : ConfigOption Model Rules.TimeLimitMode Msg msg
modeOption =
    { id = "time-limit-mode"
    , toggleable = Just { off = Rules.Soft, on = Rules.Hard }
    , primaryEditor = \_ -> ConfigOption.Label { text = Strings.Automatic }
    , extraEditor = ConfigOption.noExtraEditor
    , set = ConfigOption.wrappedSetter TimeLimitChangeMode
    , messages = \_ -> [ Message.info Strings.AutomaticDescription ]
    }


timeLimitBounds : ConfigOption.IntBounds
timeLimitBounds =
    ConfigOption.IntBounds 0 900


timeLimit : Round.Stage -> MdString -> Bool -> Component (Maybe Int) Model Id Msg msg
timeLimit stage description toggleable =
    Component.value
        (TimeLimit stage)
        (ConfigOption.view (timeLimitOption stage description toggleable))
        (always False)
        (Validator.optional (ConfigOption.toValidator timeLimitBounds (\v -> TimeLimitChange stage (Just v))))


stageId : Round.Stage -> String
stageId stage =
    case stage of
        Round.SPlaying ->
            "playing"

        Round.SRevealing ->
            "revealing"

        Round.SJudging ->
            "judging"

        Round.SComplete ->
            "complete"


timeLimitOption : Round.Stage -> MdString -> Bool -> ConfigOption Model (Maybe Int) Msg msg
timeLimitOption stage description toggleable =
    { id = "stage-limit-" ++ (stage |> stageId)
    , toggleable =
        { off = Nothing
        , on = Rules.defaultTimeLimits |> Rules.getTimeLimitByStage stage
        }
            |> Maybe.justIf toggleable
    , primaryEditor =
        \_ -> ConfigOption.maybeEditor (ConfigOption.intEditor (Strings.TimeLimit { stage = stage |> Round.stageDescription }) (ConfigOption.toMinMaxAttrs timeLimitBounds))
    , extraEditor = ConfigOption.noExtraEditor
    , set = ConfigOption.wrappedSetter (TimeLimitChange stage)
    , messages = \_ -> [ Message.info description ]
    }
