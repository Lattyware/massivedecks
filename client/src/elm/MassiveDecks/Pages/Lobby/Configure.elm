module MassiveDecks.Pages.Lobby.Configure exposing
    ( applyChange
    , init
    , update
    , updateFromConfig
    , view
    )

import Dict exposing (Dict)
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Card.Source.Cardcast.Model as Cardcast
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Components as Components
import MassiveDecks.Components.Form as Form
import MassiveDecks.Components.Form.Message as Message exposing (Message)
import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Actions as Actions
import MassiveDecks.Pages.Lobby.Configure.Decks as Decks
import MassiveDecks.Pages.Lobby.Configure.Decks.Model as Decks exposing (Deck)
import MassiveDecks.Pages.Lobby.Configure.Messages exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Model exposing (..)
import MassiveDecks.Pages.Lobby.Events as Events
import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Invite as Invite
import MassiveDecks.Pages.Lobby.Messages as Lobby
import MassiveDecks.Pages.Lobby.Model as Lobby exposing (Lobby)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Html.Attributes as HtmlA
import MassiveDecks.Util.Maybe as Maybe
import Weightless as Wl
import Weightless.Attributes as WlA


init : Model
init =
    { decks = Decks.init
    , handSize = 10
    , scoreLimit = Just 25
    , tab = Decks
    , password = Nothing
    , passwordVisible = False
    , houseRules =
        { rando = Nothing
        , packingHeat = Nothing
        , reboot = Nothing
        , comedyWriter = Nothing
        }
    , public = False
    , timeLimits = Rules.defaultTimeLimits
    }


updateFromConfig : Config -> Model -> Model
updateFromConfig config model =
    { tab = model.tab
    , decks = Decks.updateFromConfig config.decks model.decks
    , handSize = config.rules.handSize
    , scoreLimit = config.rules.scoreLimit
    , password = config.password
    , passwordVisible = model.passwordVisible
    , houseRules = config.rules.houseRules
    , public = config.public
    , timeLimits = config.rules.timeLimits
    }


update : Msg -> Model -> Config -> ( Model, Cmd msg )
update msg model config =
    case msg of
        DeckMsg deckMsg ->
            let
                ( decks, cmd ) =
                    Decks.update config.version deckMsg model.decks
            in
            ( { model | decks = decks }, cmd )

        ChangeTab t ->
            ( { model | tab = t }, Cmd.none )

        StartGame ->
            ( model, Actions.startGame )

        HandSizeChange target value ->
            ( { model | handSize = value }, ifRemote (Actions.setHandSize value config.version) target )

        ScoreLimitChange target value ->
            ( { model | scoreLimit = value }, ifRemote (Actions.setScoreLimit value config.version) target )

        PasswordChange target value ->
            let
                send =
                    ifRemote (Actions.setPassword value config.version) target

                cmd =
                    case value of
                        Just pw ->
                            Maybe.justIf (String.length pw >= 1) send |> Maybe.withDefault Cmd.none

                        Nothing ->
                            send
            in
            ( { model | password = value }, cmd )

        TogglePasswordVisibility ->
            ( { model | passwordVisible = not model.passwordVisible }, Cmd.none )

        HouseRuleChange target value ->
            let
                send =
                    ifRemote (Actions.changeHouseRule value config.version) target
            in
            ( { model | houseRules = model.houseRules |> Rules.apply value }, send )

        PublicChange target value ->
            let
                send =
                    ifRemote (Actions.setPublic value config.version) target
            in
            ( { model | public = value }, send )

        TimeLimitChangeMode target value ->
            let
                timeLimits =
                    model.timeLimits

                send =
                    ifRemote (Actions.changeTimeLimitMode value config.version) target
            in
            ( { model | timeLimits = { timeLimits | mode = value } }, send )

        TimeLimitChange target stage value ->
            let
                timeLimits =
                    model.timeLimits

                send =
                    ifRemote (Actions.changeTimeLimitForStage stage value config.version) target
            in
            ( { model | timeLimits = Rules.setTimeLimitByStage stage value timeLimits }, send )

        RevertChanges ->
            ( updateFromConfig config model, Cmd.none )

        SaveChanges ->
            ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


view : (Msg -> msg) -> (Lobby.Msg -> msg) -> Shared -> Bool -> Model -> GameCode -> Lobby -> Html msg
view wrap wrapLobby shared canEdit model gameCode lobby =
    Html.div [ HtmlA.class "configure" ]
        [ Wl.card []
            [ Html.div [ HtmlA.class "title" ]
                [ Html.h2 [] [ lobby.name |> Html.text ]
                , Html.div []
                    [ Invite.button wrapLobby shared
                    , Strings.GameCode { code = GameCode.toString gameCode } |> Lang.html shared
                    ]
                ]
            , Wl.tabGroup [ WlA.align WlA.Center ] (tabs |> List.map (tab wrap shared model.tab))
            , tabContent wrap shared canEdit model lobby.config
            ]
        , Wl.card []
            [ startGameSegment wrap wrapLobby shared canEdit model lobby
            ]
        ]


applyChange : Events.ConfigChanged -> Config -> Model -> ( Config, Model )
applyChange configChange oldConfig oldConfigure =
    let
        oldRules =
            oldConfig.rules

        oldTimeLimits =
            oldRules.timeLimits

        oldConfigureTimeLimits =
            oldConfigure.timeLimits
    in
    case configChange of
        Events.DecksChanged decksChanged ->
            let
                ( c, m ) =
                    Decks.handleEvent decksChanged oldConfig.decks oldConfigure.decks
            in
            ( { oldConfig | decks = c }, { oldConfigure | decks = m } )

        Events.HandSizeSet { size } ->
            ( { oldConfig | rules = { oldRules | handSize = size } }, { oldConfigure | handSize = size } )

        Events.ScoreLimitSet { limit } ->
            ( { oldConfig | rules = { oldRules | scoreLimit = limit } }, { oldConfigure | scoreLimit = limit } )

        Events.PasswordSet { password } ->
            ( { oldConfig | password = password }
            , { oldConfigure | password = password }
            )

        Events.HouseRuleChanged { change } ->
            ( { oldConfig | rules = { oldRules | houseRules = oldRules.houseRules |> Rules.apply change } }
            , { oldConfigure | houseRules = oldConfigure.houseRules |> Rules.apply change }
            )

        Events.PublicSet { public } ->
            ( { oldConfig | public = public }
            , { oldConfigure | public = public }
            )

        Events.ChangeTimeLimitForStage { stage, timeLimit } ->
            ( { oldConfig | rules = { oldRules | timeLimits = Rules.setTimeLimitByStage stage timeLimit oldTimeLimits } }
            , { oldConfigure | timeLimits = Rules.setTimeLimitByStage stage timeLimit oldConfigureTimeLimits }
            )

        Events.ChangeTimeLimitMode { mode } ->
            ( { oldConfig | rules = { oldRules | timeLimits = { oldTimeLimits | mode = mode } } }
            , { oldConfigure | timeLimits = { oldConfigureTimeLimits | mode = mode } }
            )



{- Private -}


startGameSegment : (Msg -> msg) -> (Lobby.Msg -> msg) -> Shared -> Bool -> Model -> Lobby -> Html msg
startGameSegment wrap wrapLobby shared canEdit model lobby =
    let
        config =
            lobby.config

        startErrors =
            startGameProblems wrap wrapLobby lobby.users model config

        startGameAttrs =
            if List.isEmpty startErrors && canEdit then
                [ StartGame |> wrap |> HtmlE.onClick ]

            else
                [ WlA.disabled ]
    in
    Form.section shared
        "start-game"
        (Wl.button startGameAttrs [ Strings.StartGame |> Lang.html shared ])
        (startErrors |> Maybe.justIf canEdit |> Maybe.withDefault [])


startGameProblems : (Msg -> msg) -> (Lobby.Msg -> msg) -> Dict User.Id User -> Model -> Config -> List (Message msg)
startGameProblems wrap wrapLobby users model config =
    let
        -- We assume decks will have calls/responses.
        summaries =
            \getTypeAmount ->
                config.decks
                    |> List.map (.summary >> Maybe.map getTypeAmount >> Maybe.withDefault 1)
                    |> List.sum

        noDecks =
            List.length config.decks == 0

        loadingDecks =
            config.decks |> List.any (.summary >> Maybe.isNothing)

        hr =
            config.rules.houseRules

        numberOfResponses =
            case hr.comedyWriter of
                Just { exclusive, number } ->
                    if exclusive then
                        number

                    else
                        number + summaries .responses

                Nothing ->
                    summaries .responses

        requiredResponses =
            (users |> Dict.values |> List.filter (\u -> u.role == User.Player) |> List.length) * 3

        deckIssues =
            if noDecks then
                [ Message.errorWithFix
                    Strings.NeedAtLeastOneDeck
                    [ { description = Strings.NoDecksHint
                      , icon = Icon.plus
                      , action = "CAHBS" |> Cardcast.playCode |> Source.Cardcast |> Decks.Add |> DeckMsg |> wrap
                      }
                    ]
                    |> Just
                ]

            else if loadingDecks then
                [ Strings.WaitForDecks |> Message.info |> Just ]

            else
                [ Strings.MissingCardType { cardType = Strings.Call }
                    |> Message.error
                    |> Maybe.justIf (summaries .calls < 1)
                , Strings.MissingCardType { cardType = Strings.Response }
                    |> Message.error
                    |> Maybe.justIf (numberOfResponses < 1)
                , Strings.NotEnoughCardsOfType { cardType = Strings.Response, needed = requiredResponses, have = numberOfResponses }
                    |> Message.error
                    |> Maybe.justIf (numberOfResponses < requiredResponses)
                ]

        playerCount =
            users
                |> Dict.values
                |> List.filter (\user -> user.role == User.Player && user.presence == User.Joined)
                |> List.length

        aiPlayers =
            hr.rando |> Maybe.map .number |> Maybe.withDefault 0

        playerIssues =
            [ Message.errorWithFix
                Strings.NeedAtLeastThreePlayers
                [ { description = Strings.Invite
                  , icon = Icon.bullhorn
                  , action = wrapLobby Lobby.ToggleInviteDialog
                  }
                , { description = Strings.AddAnAiPlayer
                  , icon = Icon.robot
                  , action =
                        { number = 3 - playerCount + aiPlayers }
                            |> Just
                            |> Rules.RandoChange
                            |> HouseRuleChange Remote
                            |> wrap
                  }
                ]
                |> Maybe.justIf (playerCount < 3)
            ]

        aisNoWriteGoodIssues =
            [ Message.errorWithFix
                Strings.RandoCantWrite
                [ { description = Strings.DisableRando
                  , icon = Icon.powerOff
                  , action = Nothing |> Rules.RandoChange |> HouseRuleChange Remote |> wrap
                  }
                , { description = Strings.DisableComedyWriter
                  , icon = Icon.eraser
                  , action = Nothing |> Rules.ComedyWriterChange |> HouseRuleChange Remote |> wrap
                  }
                ]
                |> Maybe.justIf (hr.rando /= Nothing && hr.comedyWriter /= Nothing)
            ]

        configurationIssues =
            [ Message.errorWithFix Strings.UnsavedChangesWarning
                [ { description = Strings.DiscardChanges
                  , icon = Icon.undo
                  , action = RevertChanges |> wrap
                  }
                ]
                |> Maybe.justIf (updateFromConfig config model /= model)
            ]
    in
    [ deckIssues, playerIssues, aisNoWriteGoodIssues, configurationIssues ] |> List.concat |> List.filterMap identity


ifRemote : Cmd msg -> Target -> Cmd msg
ifRemote cmd target =
    case target of
        Local ->
            Cmd.none

        Remote ->
            cmd


tabs : List Tab
tabs =
    [ Decks, Rules, TimeLimits, Privacy ]


tab : (Msg -> msg) -> Shared -> Tab -> Tab -> Html msg
tab wrap shared currently target =
    Wl.tab
        ((target |> ChangeTab |> wrap |> always |> HtmlE.onCheck)
            :: ([ WlA.checked ] |> Maybe.justIf (currently == target) |> Maybe.withDefault [])
        )
        [ target |> tabName |> Lang.html shared ]


tabName : Tab -> MdString
tabName target =
    case target of
        Decks ->
            Strings.ConfigureDecks

        Rules ->
            Strings.ConfigureRules

        TimeLimits ->
            Strings.ConfigureTimeLimits

        Privacy ->
            Strings.ConfigurePrivacy


tabContent : (Msg -> msg) -> Shared -> Bool -> Model -> Config -> Html msg
tabContent wrap shared canEdit model config =
    let
        viewTab =
            case model.tab of
                Decks ->
                    configureDecks

                Rules ->
                    configureRules

                TimeLimits ->
                    configureTimeLimits

                Privacy ->
                    configurePrivacy
    in
    viewTab wrap shared canEdit model config


configureDecks : (Msg -> msg) -> Shared -> Bool -> Model -> Config -> Html msg
configureDecks wrap shared canEdit model config =
    Decks.view (DeckMsg >> wrap) shared canEdit model.decks config.decks


configureRules : (Msg -> msg) -> Shared -> Bool -> Model -> Config -> Html msg
configureRules wrap shared canEdit model config =
    let
        viewOpt =
            viewOption shared model config (wrap NoOp) canEdit
    in
    Html.div [ HtmlA.id "rules-tab" ]
        [ Html.div [ HtmlA.class "core-rules" ]
            [ Html.h3 [] [ Strings.GameRulesTitle |> Lang.html shared ]
            , handSizeOption wrap |> viewOpt
            , scoreLimitOption wrap |> viewOpt
            ]
        , houseRules wrap shared canEdit model config
        ]


handSizeOption : (Msg -> msg) -> ConfigOption Int msg
handSizeOption wrap =
    { id = "hand-size-option"
    , toggleable = Nothing
    , primaryEditor =
        TextField
            { placeholder = Strings.HandSize
            , inputType = Nothing
            , toString = String.fromInt >> Just
            , fromString = String.toInt
            , attrs = [ 3 |> WlA.min, 50 |> WlA.max ]
            }
    , extraEditor = Nothing
    , getRemoteValue = .rules >> .handSize
    , getLocalValue = .handSize
    , set = \t -> \v -> HandSizeChange t v |> wrap
    , validate = \v -> v >= 3 && v <= 50
    , messages = [ Message.info Strings.HandSizeDescription ]
    }


scoreLimitOption : (Msg -> msg) -> ConfigOption (Maybe Int) msg
scoreLimitOption wrap =
    { id = "score-limit-option"
    , toggleable = Just { off = Nothing, on = Just 25 }
    , primaryEditor =
        TextField
            { placeholder = Strings.ScoreLimit
            , inputType = Nothing
            , toString = Maybe.map String.fromInt
            , fromString = String.toInt >> Maybe.map Just
            , attrs = [ 1 |> WlA.min, 10000 |> WlA.max ]
            }
    , extraEditor = Nothing
    , getRemoteValue = .rules >> .scoreLimit
    , getLocalValue = .scoreLimit
    , set = \t -> \v -> ScoreLimitChange t v |> wrap
    , validate = Maybe.map (\v -> v >= 1 && v <= 10000) >> Maybe.withDefault True
    , messages = [ Message.info Strings.ScoreLimitDescription ]
    }


houseRules : (Msg -> msg) -> Shared -> Bool -> Model -> Config -> Html msg
houseRules wrap shared canEdit model config =
    Html.div [ HtmlA.class "house-rules" ]
        [ Html.h3 [] [ Strings.HouseRulesTitle |> Lang.html shared ]
        , rando wrap shared canEdit model config
        , packingHeat wrap shared canEdit model config
        , reboot wrap shared canEdit model config
        , comedyWriter wrap shared canEdit model config
        ]


type alias ViewHouseRuleSettings houseRule msg =
    (Msg -> msg) -> Shared -> Bool -> houseRule -> (Target -> houseRule -> msg) -> List (Html msg)


houseRule : (Msg -> msg) -> Shared -> String -> Rules.HouseRule a -> Bool -> Model -> Config -> ViewHouseRuleSettings a msg -> Html msg
houseRule wrap shared id { default, change, title, description, extract, validate } canEdit model config viewSettings =
    let
        localValue =
            model.houseRules |> extract

        enabled =
            localValue |> Maybe.isJust

        toggle =
            \checked ->
                default
                    |> Maybe.justIf checked
                    |> change
                    |> HouseRuleChange Remote
                    |> wrap

        save =
            localValue |> change |> HouseRuleChange Remote |> wrap |> HtmlE.onClick

        saved =
            localValue == (config.rules.houseRules |> extract)

        validated =
            localValue |> Maybe.map validate |> Maybe.withDefault True

        settings =
            localValue
                |> Maybe.map (\v -> viewSettings wrap shared canEdit v (\t -> \nv -> Just nv |> change |> HouseRuleChange t |> wrap))
                |> Maybe.withDefault []

        ( saveIcon, message ) =
            if saved then
                ( Icon.check, Strings.AppliedConfiguration )

            else if validated then
                ( Icon.save, Strings.ApplyConfiguration )

            else
                ( Icon.times, Strings.InvalidConfiguration )
    in
    Html.div [ HtmlA.classList [ ( "house-rule", True ), ( "enabled", enabled ) ] ]
        [ Form.section
            shared
            id
            (Html.div [ HtmlA.class "multipart" ]
                [ Wl.switch
                    [ WlA.disabled |> Maybe.justIf (not canEdit) |> Maybe.withDefault (toggle |> HtmlE.onCheck)
                    , WlA.checked |> Maybe.justIf enabled |> Maybe.withDefault HtmlA.nothing
                    ]
                , Html.h4 [ HtmlA.class "primary" ] [ Lang.html shared title ]
                , Components.iconButton
                    [ save
                    , WlA.disabled |> Maybe.justIf (saved || not validated) |> Maybe.withDefault HtmlA.nothing
                    , Lang.title shared message
                    ]
                    saveIcon
                ]
            )
            [ Message.info (localValue |> description) ]
        , Html.div [ HtmlA.class "house-rule-settings" ] settings
        ]


rando : (Msg -> msg) -> Shared -> Bool -> Model -> Config -> Html msg
rando wrap shared canEdit model config =
    houseRule wrap shared "rando" Rules.rando canEdit model config randoSettings


randoSettings : (Msg -> msg) -> Shared -> Bool -> Rules.Rando -> (Target -> Rules.Rando -> msg) -> List (Html msg)
randoSettings wrap shared canEdit value change =
    [ Form.section
        shared
        "rando-number"
        (Wl.textField
            [ Strings.HouseRuleRandoCardrissianNumber |> Lang.label shared
            , HtmlA.class "primary"
            , WlA.type_ WlA.Number
            , WlA.min 1
            , WlA.max 10
            , Maybe.justIf (not canEdit) WlA.disabled |> Maybe.withDefault HtmlA.nothing
            , value.number |> String.fromInt |> WlA.value
            , String.toInt
                >> Maybe.map (\n -> { value | number = n } |> change Local)
                >> Maybe.withDefault (wrap NoOp)
                |> HtmlE.onInput
            ]
            []
        )
        [ Strings.HouseRuleRandoCardrissianNumberDescription |> Message.info ]
    ]


packingHeat : (Msg -> msg) -> Shared -> Bool -> Model -> Config -> Html msg
packingHeat wrap shared canEdit model config =
    houseRule wrap shared "packing-heat" Rules.packingHeat canEdit model config packingHeatSettings


packingHeatSettings : ViewHouseRuleSettings Rules.PackingHeat msg
packingHeatSettings wrap shared canEdit value localChange =
    []


reboot : (Msg -> msg) -> Shared -> Bool -> Model -> Config -> Html msg
reboot wrap shared canEdit model config =
    houseRule wrap shared "reboot" Rules.reboot canEdit model config rebootSettings


rebootSettings : (Msg -> msg) -> Shared -> Bool -> Rules.Reboot -> (Target -> Rules.Reboot -> msg) -> List (Html msg)
rebootSettings wrap shared canEdit value change =
    [ Form.section
        shared
        "reboot-cost"
        (Wl.textField
            [ Strings.HouseRuleRebootCost |> Lang.label shared
            , HtmlA.class "primary"
            , WlA.type_ WlA.Number
            , WlA.min 1
            , WlA.max 50
            , Maybe.justIf (not canEdit) WlA.disabled |> Maybe.withDefault HtmlA.nothing
            , value.cost |> String.fromInt |> WlA.value
            , String.toInt
                >> Maybe.map (\c -> { value | cost = c } |> change Local)
                >> Maybe.withDefault (wrap NoOp)
                |> HtmlE.onInput
            ]
            []
        )
        [ Strings.HouseRuleRebootCostDescription |> Message.info ]
    ]


comedyWriter : (Msg -> msg) -> Shared -> Bool -> Model -> Config -> Html msg
comedyWriter wrap shared canEdit model config =
    houseRule wrap shared "comedy-writer" Rules.comedyWriter canEdit model config comedyWriterSettings


comedyWriterSettings : (Msg -> msg) -> Shared -> Bool -> Rules.ComedyWriter -> (Target -> Rules.ComedyWriter -> msg) -> List (Html msg)
comedyWriterSettings wrap shared canEdit value change =
    [ Form.section
        shared
        "comedy-writer-number"
        (Wl.textField
            [ Strings.HouseRuleComedyWriterNumber |> Lang.label shared
            , HtmlA.class "primary"
            , WlA.type_ WlA.Number
            , WlA.min 1
            , WlA.max 99999
            , Maybe.justIf (not canEdit) WlA.disabled |> Maybe.withDefault HtmlA.nothing
            , value.number |> String.fromInt |> WlA.value
            , String.toInt
                >> Maybe.map (\n -> { value | number = n } |> change Local)
                >> Maybe.withDefault (wrap NoOp)
                |> HtmlE.onInput
            ]
            []
        )
        [ Strings.HouseRuleComedyWriterNumberDescription |> Message.info ]
    , Form.section
        shared
        "comedy-writer-exclusive"
        (Html.div [ HtmlA.class "multipart" ]
            [ Wl.switch
                [ HtmlA.id "comedy-writer-exclusive-switch"
                , Maybe.justIf (not canEdit) WlA.disabled |> Maybe.withDefault HtmlA.nothing
                , WlA.checked |> Maybe.justIf value.exclusive |> Maybe.withDefault HtmlA.nothing
                , (\e -> { value | exclusive = e } |> change Remote)
                    |> HtmlE.onCheck
                ]
            , Html.label [ HtmlA.for "#comedy-writer-exclusive-switch", HtmlA.class "primary" ]
                [ Strings.HouseRuleComedyWriterExclusive |> Lang.html shared
                ]
            ]
        )
        [ Strings.HouseRuleComedyWriterExclusiveDescription |> Message.info ]
    ]


configurePrivacy : (Msg -> msg) -> Shared -> Bool -> Model -> Config -> Html msg
configurePrivacy wrap shared canEdit model config =
    let
        viewOpt =
            viewOption shared model config (wrap NoOp) canEdit
    in
    Html.div [ HtmlA.id "privacy-tab" ]
        [ Html.h3 [] [ Strings.ConfigurePrivacy |> Lang.html shared ]
        , viewOpt (publicGameOption wrap)
        , viewOpt (gamePasswordOption wrap model)
        ]


configureTimeLimits : (Msg -> msg) -> Shared -> Bool -> Model -> Config -> Html msg
configureTimeLimits wrap shared canEdit model config =
    let
        viewOpt =
            viewOption shared model config (wrap NoOp) canEdit

        stageLimit =
            \s -> \d -> \t -> stageLimitOption wrap s d t |> viewOpt
    in
    Html.div [ HtmlA.id "time-limits-tab" ]
        [ Html.h3 [] [ Strings.ConfigureTimeLimits |> Lang.html shared ]
        , viewOpt (timeLimitModeOption wrap)
        , stageLimit Round.SPlaying Strings.PlayingTimeLimitDescription True
        , stageLimit Round.SRevealing Strings.RevealingTimeLimitDescription True
        , stageLimit Round.SJudging Strings.JudgingTimeLimitDescription True
        , stageLimit Round.SComplete Strings.CompleteTimeLimitDescription False
        ]


timeLimitModeOption : (Msg -> msg) -> ConfigOption Rules.TimeLimitMode msg
timeLimitModeOption wrap =
    { id = "time-limit-mode"
    , toggleable = Just { off = Rules.Soft, on = Rules.Hard }
    , primaryEditor = Label { text = Strings.Automatic }
    , extraEditor = Nothing
    , getRemoteValue = .rules >> .timeLimits >> .mode
    , getLocalValue = .timeLimits >> .mode
    , set = \t -> \v -> TimeLimitChangeMode t v |> wrap
    , validate = always True
    , messages = [ Message.info Strings.AutomaticDescription ]
    }


stageLimitOption : (Msg -> msg) -> Round.Stage -> MdString -> Bool -> ConfigOption (Maybe Float) msg
stageLimitOption wrap stage description toggleable =
    { id = "stage-limit-" ++ (stage |> Round.stageToName)
    , toggleable =
        { off = Nothing
        , on = Rules.defaultTimeLimits |> Rules.getTimeLimitByStage stage
        }
            |> Maybe.justIf toggleable
    , primaryEditor =
        TextField
            { placeholder = Strings.TimeLimit { stage = stage |> Round.stageDescription }
            , inputType = Just WlA.Number
            , toString = Maybe.map String.fromFloat
            , fromString = String.toFloat >> Maybe.map Just
            , attrs = [ WlA.min 0, WlA.max 900 ]
            }
    , extraEditor = Nothing
    , getRemoteValue = .rules >> .timeLimits >> Rules.getTimeLimitByStage stage
    , getLocalValue = .timeLimits >> Rules.getTimeLimitByStage stage
    , set = \t -> \v -> TimeLimitChange t stage v |> wrap
    , validate = Maybe.map (\v -> v >= 0 && v <= 900) >> Maybe.withDefault True
    , messages =
        [ Message.info description ]
    }


publicGameOption : (Msg -> msg) -> ConfigOption Bool msg
publicGameOption wrap =
    { id = "public-option"
    , toggleable = Just { off = False, on = True }
    , primaryEditor = Label { text = Strings.Public }
    , extraEditor = Nothing
    , getRemoteValue = .public
    , getLocalValue = .public
    , set = \t -> \v -> PublicChange t v |> wrap
    , validate = always True
    , messages = [ Message.info Strings.PublicDescription ]
    }


gamePasswordOption : (Msg -> msg) -> Model -> ConfigOption (Maybe String) msg
gamePasswordOption wrap model =
    { id = "game-password-option"
    , toggleable = Just { off = Nothing, on = Just "" }
    , primaryEditor =
        TextField
            { placeholder = Strings.LobbyPassword
            , inputType = WlA.Password |> Maybe.justIf (not model.passwordVisible)
            , toString = identity
            , fromString = Just >> Just
            , attrs = [ WlA.minLength 1 ]
            }
    , extraEditor =
        Just
            (Components.iconButton
                [ TogglePasswordVisibility |> wrap |> HtmlE.onClick
                , WlA.disabled |> Maybe.justIf (Maybe.isNothing model.password) |> Maybe.withDefault HtmlA.nothing
                ]
                (Icon.eyeSlash |> Maybe.justIf model.passwordVisible |> Maybe.withDefault Icon.eye)
            )
    , getRemoteValue = .password
    , getLocalValue = .password
    , set = \t -> \v -> PasswordChange t v |> wrap
    , validate = Maybe.map (String.isEmpty >> not) >> Maybe.withDefault True
    , messages =
        [ Message.info Strings.LobbyPasswordDescription
        , Message.warning Strings.PasswordShared
        , Message.warning Strings.PasswordNotSecured
        ]
    }


type alias ConfigOption value msg =
    { id : String
    , toggleable : Maybe (Toggleable value)
    , primaryEditor : PrimaryEditor value msg
    , extraEditor : Maybe (Html msg)
    , getRemoteValue : Config -> value
    , getLocalValue : Model -> value
    , set : Target -> value -> msg
    , validate : value -> Bool
    , messages : List (Message msg)
    }


type alias Toggleable value =
    { off : value
    , on : value
    }


type PrimaryEditor value msg
    = TextField
        { placeholder : MdString
        , inputType : Maybe WlA.InputType
        , toString : value -> Maybe String
        , fromString : String -> Maybe value
        , attrs : List (Html.Attribute msg)
        }
    | Label { text : MdString }


viewOption : Shared -> Model -> Config -> msg -> Bool -> ConfigOption value msg -> Html msg
viewOption shared model config noOp canEdit opt =
    let
        localValue =
            opt.getLocalValue model

        remoteValue =
            opt.getRemoteValue config

        saved =
            localValue == remoteValue

        validated =
            localValue |> opt.validate

        ( saveIcon, message ) =
            if saved then
                ( Icon.check, Strings.AppliedConfiguration )

            else if validated then
                ( Icon.save, Strings.ApplyConfiguration )

            else
                ( Icon.times, Strings.InvalidConfiguration )

        saveState =
            Components.iconButton
                [ WlA.disabled
                    |> Maybe.justIf (saved || not validated || not canEdit)
                    |> Maybe.withDefault (HtmlE.onClick (opt.set Remote localValue))
                , Lang.title shared message
                ]
                saveIcon

        primaryEditor =
            case opt.primaryEditor of
                TextField { placeholder, inputType, toString, fromString, attrs } ->
                    Wl.textField
                        ([ placeholder |> Lang.label shared
                         , WlA.outlined
                         , inputType |> Maybe.map WlA.type_ |> Maybe.withDefault HtmlA.nothing
                         , HtmlA.class "primary"
                         , localValue |> toString |> Maybe.map WlA.value |> Maybe.withDefault HtmlA.nothing
                         , fromString
                            >> Maybe.map (opt.set Local)
                            >> Maybe.withDefault noOp
                            |> HtmlE.onInput
                         , opt.set Remote localValue |> HtmlE.onBlur
                         , opt.toggleable
                            |> Maybe.andThen (\t -> Maybe.justIf (t.off == localValue) WlA.disabled)
                            |> Maybe.withDefault HtmlA.nothing
                         , WlA.disabled |> Maybe.justIf (not canEdit) |> Maybe.withDefault HtmlA.nothing
                         ]
                            ++ attrs
                        )
                        []

                Label { text } ->
                    Html.label [ HtmlA.class "primary" ] [ text |> Lang.html shared ]

        switch =
            case opt.toggleable of
                Just { off, on } ->
                    Wl.switch
                        [ WlA.checked |> Maybe.justIf (localValue /= off) |> Maybe.withDefault HtmlA.nothing
                        , HtmlE.onCheck (\c -> Maybe.justIf c on |> Maybe.withDefault off |> opt.set Remote)
                        , WlA.disabled |> Maybe.justIf (not canEdit) |> Maybe.withDefault HtmlA.nothing
                        ]
                        |> Just

                Nothing ->
                    Nothing

        contents =
            [ switch, Just primaryEditor, opt.extraEditor, Just saveState ] |> List.filterMap identity
    in
    Form.section shared opt.id (Html.div [ HtmlA.class "multipart" ] contents) opt.messages
