module MassiveDecks.Pages.Lobby.Configure exposing
    ( applyChange
    , init
    , update
    , updateFromConfig
    , view
    )

import Dict exposing (Dict)
import FontAwesome.Attributes as Icon
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Card.Source as Source
import MassiveDecks.Card.Source.Cardcast.Model as Cardcast
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Components as Components
import MassiveDecks.Components.Form as Form
import MassiveDecks.Components.Form.Message as Message exposing (Message)
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Messages as Global
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Actions as Actions
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
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Html.Attributes as HtmlA
import MassiveDecks.Util.Maybe as Maybe
import MassiveDecks.Util.Result as Result
import Weightless as Wl
import Weightless.Attributes as WlA


init : Model
init =
    { deckToAdd = Source.default
    , deckErrors = []
    , handSize = 10
    , scoreLimit = Just 25
    , tab = Decks
    , password = Nothing
    , passwordVisible = False
    , houseRules =
        { rando = Nothing
        , packingHeat = Nothing
        , reboot = Nothing
        }
    , public = False
    }


updateFromConfig : Config -> Model -> Model
updateFromConfig config model =
    { deckToAdd = model.deckToAdd
    , deckErrors = model.deckErrors
    , tab = model.tab
    , handSize = config.rules.handSize
    , scoreLimit = config.rules.scoreLimit
    , password = config.password
    , passwordVisible = model.passwordVisible
    , houseRules = config.rules.houseRules
    , public = config.public
    }


update : Msg -> Model -> Config -> ( Model, Cmd msg )
update msg model config =
    case msg of
        AddDeck source ->
            ( { model | deckToAdd = Source.emptyMatching source }, Actions.addDeck config.version source )

        RemoveDeck source ->
            ( model, Actions.removeDeck config.version source )

        UpdateSource source ->
            ( { model | deckToAdd = source }, Cmd.none )

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


view : Shared -> Bool -> Model -> GameCode -> Lobby -> Config -> Html Global.Msg
view shared canEdit model gameCode lobby config =
    Html.div [ HtmlA.class "configure" ]
        [ Wl.card []
            [ Html.div [ HtmlA.class "title" ]
                [ Html.h2 [] [ lobby.name |> Html.text ]
                , Html.div []
                    [ Invite.button shared
                    , Strings.GameCode { code = GameCode.toString gameCode } |> Lang.html shared
                    ]
                ]
            , Wl.tabGroup [ WlA.align WlA.Center ] (tabs |> List.map (tab shared model.tab))
            , tabContent shared canEdit model config
            ]
        , Wl.card []
            [ startGameSegment shared canEdit lobby config
            ]
        ]


applyChange : Events.ConfigChanged -> Config -> Model -> ( Config, Model )
applyChange configChange oldConfig oldConfigure =
    let
        oldRules =
            oldConfig.rules
    in
    case configChange of
        Events.DecksChanged decksChanged ->
            applyDeckChange decksChanged oldConfig oldConfigure

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



{- Private -}


startGameSegment : Shared -> Bool -> Lobby -> Config -> Html Global.Msg
startGameSegment shared canEdit lobby config =
    let
        startErrors =
            startGameProblems lobby.users config

        startGameAttrs =
            if List.isEmpty startErrors && canEdit then
                [ StartGame |> lift |> HtmlE.onClick ]

            else
                [ WlA.disabled ]
    in
    Form.section shared
        "start-game"
        (Wl.button startGameAttrs [ Strings.StartGame |> Lang.html shared ])
        (startErrors |> Maybe.justIf canEdit |> Maybe.withDefault [])


addSummary : Source.External -> Source.Summary -> Deck -> Deck
addSummary target summary deckSource =
    if deckSource.source == target then
        Deck target (Just summary)

    else
        deckSource


applyDeckChange : { change : Events.DeckChange, deck : Source.External } -> Config -> Model -> ( Config, Model )
applyDeckChange event config configure =
    let
        change =
            event.change

        deckSource =
            event.deck

        newConfig =
            case change of
                Events.Add ->
                    { config | decks = config.decks ++ [ Deck deckSource Nothing ] }

                Events.Remove ->
                    { config | decks = config.decks |> List.filter (.source >> (/=) deckSource) }

                Events.Load { summary } ->
                    { config | decks = config.decks |> List.map (addSummary deckSource summary) }

                Events.Fail _ ->
                    { config | decks = config.decks |> List.filter (.source >> (/=) deckSource) }

        newConfigure =
            case change of
                Events.Fail { reason } ->
                    { configure | deckErrors = { deck = deckSource, reason = reason } :: configure.deckErrors }

                _ ->
                    configure
    in
    ( newConfig, newConfigure )


startGameProblems : Dict User.Id User -> Config -> List (Message Global.Msg)
startGameProblems users config =
    let
        -- We assume decks will have calls/responses.
        summaries =
            \getTypeAmount -> config.decks |> List.map (.summary >> Maybe.map getTypeAmount >> Maybe.withDefault 1)

        noDecks =
            List.length config.decks == 0

        loadingDecks =
            config.decks |> List.any (.summary >> Maybe.isNothing)

        deckIssues =
            if noDecks then
                [ Message.errorWithFix
                    Strings.NeedAtLeastOneDeck
                    [ { description = Strings.NoDecksHint
                      , icon = Icon.plus
                      , action = "CAHBS" |> Cardcast.playCode |> Source.Cardcast |> AddDeck |> lift
                      }
                    ]
                    |> Just
                ]

            else if loadingDecks then
                [ Strings.WaitForDecks |> Message.info |> Just ]

            else
                [ Strings.MissingCardType { cardType = Strings.Call }
                    |> Message.error
                    |> Maybe.justIf ((summaries .calls |> List.sum) < 1)
                , Strings.MissingCardType { cardType = Strings.Response }
                    |> Message.error
                    |> Maybe.justIf ((summaries .responses |> List.sum) < 1)
                ]

        playerCount =
            users
                |> Dict.values
                |> List.filter (\user -> user.role == User.Player && user.presence == User.Joined)
                |> List.length

        aiPlayers =
            config.rules.houseRules.rando |> Maybe.map .number |> Maybe.withDefault 0

        playerIssues =
            [ Message.errorWithFix
                Strings.NeedAtLeastThreePlayers
                [ { description = Strings.Invite
                  , icon = Icon.bullhorn
                  , action = Lobby.ToggleInviteDialog |> Global.LobbyMsg
                  }
                , { description = Strings.AddAnAiPlayer
                  , icon = Icon.robot
                  , action =
                        { number = 3 - playerCount + aiPlayers }
                            |> Just
                            |> Rules.RandoChange
                            |> HouseRuleChange Remote
                            |> Lobby.ConfigureMsg
                            |> Global.LobbyMsg
                  }
                ]
                |> Maybe.justIf (playerCount < 3)
            ]
    in
    [ deckIssues, playerIssues ] |> List.concat |> List.filterMap identity


ifRemote : Cmd msg -> Target -> Cmd msg
ifRemote cmd target =
    case target of
        Local ->
            Cmd.none

        Remote ->
            cmd


tabs : List Tab
tabs =
    [ Decks, Rules, Privacy ]


tab : Shared -> Tab -> Tab -> Html Global.Msg
tab shared currently target =
    Wl.tab
        ((target |> ChangeTab |> lift |> always |> HtmlE.onCheck)
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

        Privacy ->
            Strings.ConfigurePrivacy


tabContent : Shared -> Bool -> Model -> Config -> Html Global.Msg
tabContent shared canEdit model config =
    let
        viewTab =
            case model.tab of
                Decks ->
                    configureDecks

                Rules ->
                    configureRules

                Privacy ->
                    configureGameSettings
    in
    viewTab shared canEdit model config


configureRules : Shared -> Bool -> Model -> Config -> Html Global.Msg
configureRules shared canEdit model config =
    Html.div [ HtmlA.class "rules" ]
        [ Html.div [ HtmlA.class "core-rules" ]
            [ Html.h3 [] [ Strings.GameRulesTitle |> Lang.html shared ]
            , handSize shared canEdit model config
            , scoreLimit shared canEdit model config
            ]
        , houseRules shared canEdit model config
        ]


handSize : Shared -> Bool -> Model -> Config -> Html Global.Msg
handSize shared canEdit model config =
    let
        change =
            \t -> \s -> s |> String.toInt |> Maybe.withDefault 10 |> HandSizeChange t |> lift

        value =
            model.handSize
    in
    Form.section shared
        "hand-size"
        (Html.div
            [ HtmlA.class "multipart" ]
            [ Wl.textField
                [ WlA.type_ WlA.Number
                , value |> String.fromInt |> WlA.value
                , Strings.HandSize |> Lang.string shared |> WlA.label
                , 3 |> WlA.min
                , 50 |> WlA.max
                , change Local |> HtmlE.onInput
                , HandSizeChange Remote value |> lift |> HtmlE.onBlur
                , HtmlA.class "primary"
                , WlA.disabled |> Maybe.justIf (not canEdit) |> Maybe.withDefault HtmlA.nothing
                , WlA.outlined
                ]
                []
            , Components.iconButton
                [ WlA.disabled
                    |> Maybe.justIf (not canEdit || config.rules.handSize == value)
                    |> Maybe.withDefault (value |> HandSizeChange Remote |> lift |> HtmlE.onClick)
                ]
                (Icon.save |> Maybe.justIf (config.rules.handSize /= value) |> Maybe.withDefault Icon.check)
            ]
        )
        [ Message.info Strings.HandSizeDescription ]


scoreLimit : Shared -> Bool -> Model -> Config -> Html Global.Msg
scoreLimit shared canEdit model config =
    let
        change =
            \t -> \s -> s |> String.toInt |> ScoreLimitChange t |> lift

        value =
            model.scoreLimit
    in
    Form.section shared
        "score-limit"
        (Html.div
            [ HtmlA.class "multipart" ]
            [ Wl.switch
                [ (\on -> 25 |> Maybe.justIf on |> ScoreLimitChange Remote |> lift) |> HtmlE.onCheck
                , WlA.checked |> Maybe.justIf (value /= Nothing) |> Maybe.withDefault HtmlA.nothing
                , WlA.disabled |> Maybe.justIf (not canEdit) |> Maybe.withDefault HtmlA.nothing
                ]
            , Wl.textField
                [ HtmlA.class "primary"
                , WlA.type_ WlA.Number
                , value |> Maybe.map String.fromInt |> Maybe.withDefault "" |> WlA.value
                , Strings.ScoreLimit |> Lang.string shared |> WlA.label
                , 1 |> WlA.min
                , 10000 |> WlA.max
                , change Local |> HtmlE.onInput
                , ScoreLimitChange Remote value |> lift |> HtmlE.onBlur
                , WlA.disabled |> Maybe.justIf (not canEdit || value == Nothing) |> Maybe.withDefault HtmlA.nothing
                , WlA.outlined
                ]
                []
            , Components.iconButton
                [ WlA.disabled
                    |> Maybe.justIf (not canEdit || config.rules.scoreLimit == value)
                    |> Maybe.withDefault (value |> ScoreLimitChange Remote |> lift |> HtmlE.onClick)
                ]
                (Icon.save |> Maybe.justIf (config.rules.scoreLimit /= value) |> Maybe.withDefault Icon.check)
            ]
        )
        [ Message.info Strings.ScoreLimitDescription ]


houseRules : Shared -> Bool -> Model -> Config -> Html Global.Msg
houseRules shared canEdit model config =
    Html.div [ HtmlA.class "house-rules" ]
        [ Html.h3 [] [ Strings.HouseRulesTitle |> Lang.html shared ]
        , rando shared canEdit model config
        , packingHeat shared canEdit model config
        , reboot shared canEdit model config
        ]


type alias ViewHouseRuleSettings houseRule =
    Shared -> Bool -> houseRule -> (houseRule -> Global.Msg) -> List (Html Global.Msg)


houseRule : Shared -> String -> Rules.HouseRule a -> Bool -> Model -> Config -> ViewHouseRuleSettings a -> Html Global.Msg
houseRule shared id { default, change, title, description, extract, insert } canEdit model config viewSettings =
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
                    |> lift

        save =
            localValue |> change |> HouseRuleChange Remote |> lift |> HtmlE.onClick

        saved =
            localValue == (config.rules.houseRules |> extract)

        settings =
            localValue
                |> Maybe.map (\v -> viewSettings shared canEdit v (Just >> change >> HouseRuleChange Local >> lift))
                |> Maybe.withDefault []
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
                , Components.iconButton [ save, WlA.disabled |> Maybe.justIf saved |> Maybe.withDefault HtmlA.nothing ]
                    (Icon.check |> Maybe.justIf saved |> Maybe.withDefault Icon.save)
                ]
            )
            [ Message.info (localValue |> description) ]
        , Html.div [ HtmlA.class "house-rule-settings" ] settings
        ]


rando : Shared -> Bool -> Model -> Config -> Html Global.Msg
rando shared canEdit model config =
    houseRule shared "rando" Rules.rando canEdit model config randoSettings


randoSettings : Shared -> Bool -> Rules.Rando -> (Rules.Rando -> Global.Msg) -> List (Html Global.Msg)
randoSettings shared canEdit value localChange =
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
                >> Maybe.map (\n -> { value | number = n } |> localChange)
                >> Maybe.withDefault Global.NoOp
                |> HtmlE.onInput
            ]
            []
        )
        [ Strings.HouseRuleRandoCardrissianNumberDescription |> Message.info ]
    ]


packingHeat : Shared -> Bool -> Model -> Config -> Html Global.Msg
packingHeat shared canEdit model config =
    houseRule shared "packing-heat" Rules.packingHeat canEdit model config packingHeatSettings


packingHeatSettings : Shared -> Bool -> Rules.PackingHeat -> (Rules.PackingHeat -> Global.Msg) -> List (Html Global.Msg)
packingHeatSettings shared canEdit value localChange =
    []


reboot : Shared -> Bool -> Model -> Config -> Html Global.Msg
reboot shared canEdit model config =
    houseRule shared "reboot" Rules.reboot canEdit model config rebootSettings


rebootSettings : Shared -> Bool -> Rules.Reboot -> (Rules.Reboot -> Global.Msg) -> List (Html Global.Msg)
rebootSettings shared canEdit value localChange =
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
                >> Maybe.map (\c -> { value | cost = c } |> localChange)
                >> Maybe.withDefault Global.NoOp
                |> HtmlE.onInput
            ]
            []
        )
        [ Strings.HouseRuleRebootCostDescription |> Message.info ]
    ]


configureDecks : Shared -> Bool -> Model -> Config -> Html Global.Msg
configureDecks shared canEdit model config =
    let
        hint =
            if canEdit then
                Components.linkButton
                    [ "CAHBS" |> Cardcast.playCode |> Source.Cardcast |> AddDeck |> lift |> HtmlE.onClick
                    ]
                    [ Strings.NoDecksHint |> Lang.html shared ]

            else
                Html.nothing

        tableContent =
            if List.isEmpty config.decks then
                [ Html.tr [ HtmlA.class "empty-info" ]
                    [ Html.td [ HtmlA.colspan 3 ]
                        [ Html.p []
                            [ Icon.view Icon.ghost
                            , Html.text " "
                            , Strings.NoDecks |> Lang.html shared
                            ]
                        , hint
                        ]
                    ]
                ]

            else
                config.decks |> List.map (deck shared canEdit)

        editor =
            if canEdit then
                [ addDeckWidget shared config.decks model.deckToAdd
                ]

            else
                []
    in
    Html.div [ HtmlA.class "decks", HtmlA.class "compressed-terms" ]
        (List.concat
            [ [ Html.table []
                    [ Html.colgroup []
                        [ Html.col [ HtmlA.class "deck-name" ] []
                        , Html.col [ HtmlA.class "count" ] []
                        , Html.col [ HtmlA.class "count" ] []
                        ]
                    , Html.thead []
                        [ Html.tr []
                            [ Html.th [ HtmlA.class "deck-name", HtmlA.scope "col" ] [ Strings.Deck |> Lang.html shared ]
                            , Html.th [ HtmlA.scope "col" ] [ Strings.Call |> Lang.html shared ]
                            , Html.th [ HtmlA.scope "col" ] [ Strings.Response |> Lang.html shared ]
                            ]
                        ]
                    , Html.tbody [] tableContent
                    ]
              ]
            , editor
            ]
        )


configureGameSettings : Shared -> Bool -> Model -> Config -> Html Global.Msg
configureGameSettings shared canEdit model config =
    let
        passwordAttrs =
            List.concat
                [ case model.password of
                    Just value ->
                        [ value |> WlA.value ]

                    Nothing ->
                        [ "" |> WlA.value, WlA.disabled ]
                , [ Strings.LobbyPassword |> Lang.string shared |> WlA.label
                  , WlA.minLength 1
                  , WlA.outlined
                  , HtmlA.class "primary"
                  ]
                , [ WlA.readonly ]
                    |> Maybe.justIf (not canEdit)
                    |> Maybe.withDefault
                        [ HtmlE.onInput (Just >> PasswordChange Local >> lift)
                        , HtmlE.onBlur (model.password |> PasswordChange Remote |> lift)
                        ]
                , [ WlA.Password |> WlA.type_ ] |> Maybe.justIf (not model.passwordVisible) |> Maybe.withDefault []
                ]

        passwordSwitchAttrs =
            List.concat
                [ [ WlA.disabled ]
                    |> Maybe.justIf (not canEdit)
                    |> Maybe.withDefault [ HtmlE.onCheck (defaultPassword >> PasswordChange Remote >> lift) ]
                , case model.password of
                    Just _ ->
                        [ WlA.checked ]

                    Nothing ->
                        []
                ]

        password =
            Form.section
                shared
                "password"
                (Html.div [ HtmlA.class "multipart" ]
                    [ Wl.switch passwordSwitchAttrs
                    , Wl.textField passwordAttrs []
                    , Components.iconButton
                        [ TogglePasswordVisibility |> lift |> HtmlE.onClick
                        , WlA.disabled |> Maybe.justIf (Maybe.isNothing model.password) |> Maybe.withDefault HtmlA.nothing
                        ]
                        (Icon.eyeSlash |> Maybe.justIf model.passwordVisible |> Maybe.withDefault Icon.eye)
                    , Components.iconButton
                        [ WlA.disabled
                            |> Maybe.justIf (not canEdit || config.password == model.password)
                            |> Maybe.withDefault (model.password |> PasswordChange Remote |> lift |> HtmlE.onClick)
                        ]
                        (Icon.save |> Maybe.justIf (config.password /= model.password) |> Maybe.withDefault Icon.check)
                    ]
                )
                [ Message.info Strings.LobbyPasswordDescription
                , Message.warning Strings.PasswordShared
                , Message.warning Strings.PasswordNotSecured
                ]

        public =
            Form.section shared
                "public"
                (Html.div [ HtmlA.class "multipart" ]
                    [ Wl.switch
                        [ WlA.disabled |> Maybe.justIf (not canEdit) |> Maybe.withDefault (PublicChange Remote >> lift |> HtmlE.onCheck)
                        , WlA.checked |> Maybe.justIf model.public |> Maybe.withDefault HtmlA.nothing
                        ]
                    , Html.span [ HtmlA.class "primary" ] [ Strings.Public |> Lang.html shared ]
                    ]
                )
                [ Message.info Strings.PublicDescription ]
    in
    Html.div [ HtmlA.class "game-settings" ]
        [ public
        , password
        ]


defaultPassword : Bool -> Maybe String
defaultPassword enabled =
    "" |> Maybe.justIf enabled


addDeckWidget : Shared -> List Deck -> Source.External -> Html Global.Msg
addDeckWidget shared existing deckToAdd =
    let
        submit =
            deckToAdd |> submitDeckAction existing
    in
    Html.form
        [ submit |> Result.map (lift >> HtmlE.onSubmit) |> Result.withDefault HtmlA.nothing ]
        [ Form.section
            shared
            "add-deck"
            (Html.div [ HtmlA.class "multipart" ]
                [ Wl.select
                    [ HtmlA.id "source-selector"
                    , WlA.outlined
                    , HtmlE.onInput (Source.empty >> Maybe.withDefault Source.default >> UpdateSource >> lift)
                    ]
                    [ Html.option [ HtmlA.value "Cardcast" ]
                        [ Html.text "Cardcast"
                        ]
                    ]
                , Source.editor shared (deckToAdd |> Source.Ex) (UpdateSource >> lift)
                , Components.floatingActionButton
                    [ HtmlA.type_ "submit"
                    , Result.isError submit |> HtmlA.disabled
                    , Strings.AddDeck |> Lang.title shared
                    ]
                    Icon.plus
                ]
            )
            [ submit |> Result.error |> Maybe.withDefault Nothing ]
        ]


submitDeckAction : List Deck -> Source.External -> Result (Message Global.Msg) Msg
submitDeckAction existing deckToAdd =
    let
        potentialProblem =
            if List.any (.source >> Source.Ex >> Source.equals (Source.Ex deckToAdd)) existing then
                Strings.DeckAlreadyAdded |> Message.error |> Just

            else
                Source.validate (Source.Ex deckToAdd)
    in
    case potentialProblem of
        Just problem ->
            problem |> Result.Err

        Nothing ->
            deckToAdd |> AddDeck |> Result.Ok


lift : Msg -> Global.Msg
lift =
    Lobby.ConfigureMsg >> Global.LobbyMsg


deck : Shared -> Bool -> Deck -> Html Global.Msg
deck shared canEdit givenDeck =
    let
        source =
            givenDeck.source

        row =
            case givenDeck.summary of
                Just summary ->
                    [ Html.td [] [ name shared canEdit source False summary.details ]
                    , Html.td [] [ summary.calls |> String.fromInt |> Html.text ]
                    , Html.td [] [ summary.responses |> String.fromInt |> Html.text ]
                    ]

                Nothing ->
                    [ Html.td [ HtmlA.colspan 3 ] [ source |> Source.Ex |> Source.details |> name shared canEdit source True ]
                    ]
    in
    Html.tr [ HtmlA.class "deck-row" ] row


name : Shared -> Bool -> Source.External -> Bool -> Source.Details -> Html Global.Msg
name shared canEdit source loading details =
    let
        removeButton =
            if canEdit then
                [ Components.iconButton
                    [ source |> RemoveDeck |> lift |> HtmlE.onClick
                    , Strings.RemoveDeck |> Lang.title shared
                    , HtmlA.class "remove-button"
                    ]
                    Icon.minus
                ]

            else
                []

        ( maybeId, maybeTooltip ) =
            source |> Source.Ex |> Source.tooltip |> Maybe.decompose

        attrs =
            maybeId |> Maybe.map (\id -> [ HtmlA.id id ]) |> Maybe.withDefault []

        nameText =
            Html.text details.name

        tooltip =
            maybeTooltip |> Maybe.map (\t -> [ t ]) |> Maybe.withDefault []

        linkOrText =
            [ Html.span attrs [ Maybe.transformWith nameText makeLink details.url ] ]

        spinner =
            if loading then
                [ Icon.viewStyled [ Icon.spin ] Icon.circleNotch ]

            else
                []
    in
    Html.td [ HtmlA.class "name" ] (List.concat [ linkOrText, removeButton, spinner, tooltip ])


makeLink : Html msg -> String -> Html msg
makeLink text url =
    Html.blankA [ HtmlA.href url ] [ text ]
