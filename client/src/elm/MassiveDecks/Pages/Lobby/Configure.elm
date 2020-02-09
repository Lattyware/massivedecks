module MassiveDecks.Pages.Lobby.Configure exposing
    ( applyChange
    , init
    , update
    , view
    )

import Dict exposing (Dict)
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Json.Decode as Json
import Json.Diff as Json
import Json.Encode
import Json.Patch as Json
import MassiveDecks.Card.Source.Cardcast.Model as Cardcast
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Components as Components
import MassiveDecks.Components.Form as Form
import MassiveDecks.Components.Form.Message as Message exposing (Message)
import MassiveDecks.Error.Model as Error exposing (Error)
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Model exposing (..)
import MassiveDecks.Models.Decoders as Decoders
import MassiveDecks.Models.Encoders as Encoders
import MassiveDecks.Pages.Lobby.Actions as Actions
import MassiveDecks.Pages.Lobby.Configure.Component as Component exposing (Component)
import MassiveDecks.Pages.Lobby.Configure.ConfigOption as ConfigOption
import MassiveDecks.Pages.Lobby.Configure.Decks as Decks
import MassiveDecks.Pages.Lobby.Configure.Decks.Model as Decks exposing (Deck)
import MassiveDecks.Pages.Lobby.Configure.Diff as Diff
import MassiveDecks.Pages.Lobby.Configure.Messages exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Model as Config exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Privacy as Privacy
import MassiveDecks.Pages.Lobby.Configure.Privacy.Model as Privacy
import MassiveDecks.Pages.Lobby.Configure.Rules as Rules
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.ComedyWriter.Model as ComedyWriter
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Model as HouseRule
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Rando.Model as Rando
import MassiveDecks.Pages.Lobby.Configure.Rules.Model as Rules
import MassiveDecks.Pages.Lobby.Configure.TimeLimits as TimeLimits
import MassiveDecks.Pages.Lobby.Configure.TimeLimits.Model as TimeLimits
import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Invite as Invite
import MassiveDecks.Pages.Lobby.Messages as Lobby
import MassiveDecks.Pages.Lobby.Model as Lobby exposing (Lobby)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Maybe as Maybe
import Weightless as Wl
import Weightless.Attributes as WlA


init : Model
init =
    { localConfig = default
    , tab = Decks
    , decks = Decks.init
    , privacy = Privacy.init
    , timeLimits = TimeLimits.init
    , rules = Rules.init
    , conflicts = []
    }


update : Shared -> Msg -> Model -> Config -> ( Model, Shared, Cmd msg )
update shared msg model config =
    case msg of
        PrivacyMsg privacyMsg ->
            let
                localConfig =
                    model.localConfig

                ( local, privacy, cmd ) =
                    Privacy.update privacyMsg localConfig.privacy model.privacy
            in
            ( { model | privacy = privacy, localConfig = { localConfig | privacy = local } }, shared, cmd )

        DecksMsg decksMsg ->
            let
                ( decks, newShared, cmd ) =
                    Decks.update shared decksMsg model.decks
            in
            ( { model | decks = decks }, newShared, cmd )

        TimeLimitsMsg timeLimitsMsg ->
            let
                localConfig =
                    model.localConfig

                ( local, timeLimits, cmd ) =
                    TimeLimits.update timeLimitsMsg localConfig.rules.timeLimits model.timeLimits

                rules =
                    localConfig.rules
            in
            ( { model
                | timeLimits = timeLimits
                , localConfig = { localConfig | rules = { rules | timeLimits = local } }
              }
            , shared
            , cmd
            )

        RulesMsg rulesMsg ->
            let
                localConfig =
                    model.localConfig

                ( local, newRules, cmd ) =
                    Rules.update config.version rulesMsg config.rules localConfig.rules model.rules
            in
            ( { model
                | rules = newRules
                , localConfig = { localConfig | rules = local }
              }
            , shared
            , cmd
            )

        StartGame ->
            ( model, shared, Actions.startGame )

        ChangeTab t ->
            ( { model | tab = t }, shared, Cmd.none )

        ResolveConflict source id ->
            let
                conflictComponent =
                    componentById id

                local =
                    model.localConfig

                ( newLocal, cmd ) =
                    case source of
                        Remote ->
                            ( Component.update conflictComponent config local, Cmd.none )

                        Local ->
                            ( local
                            , patchFor (Component.update conflictComponent local config) config
                                |> Maybe.map Actions.configure
                                |> Maybe.withDefault Cmd.none
                            )
            in
            ( { model | localConfig = newLocal, conflicts = model.conflicts |> List.filter ((/=) id) }, shared, cmd )

        SaveChanges ->
            if Component.isValid all model.localConfig then
                ( model
                , shared
                , patchFor config model.localConfig
                    |> Maybe.map Actions.configure
                    |> Maybe.withDefault Cmd.none
                )

            else
                ( model, shared, Cmd.none )

        RevertChanges ->
            ( { model | localConfig = config }, shared, Cmd.none )

        NoOp ->
            ( model, shared, Cmd.none )


view : (Msg -> msg) -> (Lobby.Msg -> msg) -> Shared -> Maybe msg -> Bool -> Model -> GameCode -> Lobby -> Html msg
view wrap wrapLobby shared return canEdit model gameCode lobby =
    let
        conflicts =
            if List.isEmpty model.conflicts then
                Html.nothing

            else
                Html.div [ HtmlA.id "merge-overlay" ]
                    [ Wl.card []
                        [ model.conflicts |> viewMerge wrap shared model model.localConfig lobby.config (wrap NoOp) canEdit
                        ]
                    ]

        tabComponent =
            case model.tab of
                Decks ->
                    Decks.All |> DecksId

                Rules ->
                    Rules.All |> RulesId

                TimeLimits ->
                    TimeLimits.All |> TimeLimitsId

                Privacy ->
                    Privacy.All |> PrivacyId

        returnButton msg =
            Wl.card []
                [ Wl.button [ HtmlA.class "game-in-progress", HtmlE.onClick msg, Strings.ReturnViewToGameDescription |> Lang.title shared ]
                    [ Icon.play |> Icon.viewIcon
                    , Strings.ReturnViewToGame |> Lang.html shared
                    ]
                ]
    in
    Html.div [ HtmlA.class "configure" ]
        [ return |> Maybe.map returnButton |> Maybe.withDefault Html.nothing
        , Wl.card []
            [ Html.div [ HtmlA.class "title" ]
                [ Html.h2 [] [ lobby.name |> Html.text ]
                , Html.div []
                    [ Invite.button wrapLobby shared
                    , Strings.GameCode { code = GameCode.toString gameCode } |> Lang.html shared
                    ]
                ]
            ]
        , Wl.card []
            [ Wl.tabGroup [ WlA.align WlA.Center ] (tabs |> List.map (tab wrap shared model.tab))
            , Component.view (componentById tabComponent)
                wrap
                shared
                model
                model.localConfig
                lobby.config
                (wrap NoOp)
                canEdit
                ConfigOption.Local
                |> Maybe.withDefault Html.nothing
            ]
        , Wl.card []
            [ startGameSegment wrap wrapLobby shared canEdit model lobby
            ]
        , actions wrap shared (model.localConfig /= lobby.config)
        , conflicts
        ]


applyChange : Json.Patch -> Config -> Model -> Result Error ( Config, Model )
applyChange change config model =
    let
        handleError error =
            case error of
                "test failed" ->
                    Error.VersionMismatch

                other ->
                    other |> Error.PatchError
    in
    config
        |> Encoders.config
        |> Json.apply change
        |> Result.mapError (handleError >> Error.Config)
        |> Result.andThen (Json.decodeValue Decoders.config >> Result.mapError Error.Json)
        |> Result.map (\c -> ( c, mergeChange config model.localConfig c model ))



{- Private -}


actions wrap shared hasChanges =
    Html.div [ HtmlA.class "actions" ]
        [ Components.floatingActionButton
            [ Strings.SaveChanges |> Lang.title shared
            , SaveChanges |> wrap |> HtmlE.onClick
            , HtmlA.classList [ ( "action", True ), ( "important", True ), ( "exited", not hasChanges ) ]
            ]
            Icon.save
        , Components.floatingActionButton
            [ Strings.RevertChanges |> Lang.title shared
            , RevertChanges |> wrap |> HtmlE.onClick
            , HtmlA.classList [ ( "action", True ), ( "exited", not hasChanges ) ]
            , WlA.inverted
            ]
            Icon.undo
        ]


patchFor : Config -> Config -> Maybe Json.Patch
patchFor old new =
    let
        diff =
            Json.diff (old |> Encoders.config) (new |> Encoders.config)
    in
    if diff |> List.isEmpty then
        Nothing

    else
        Json.Test [ "version" ] (old.version |> Json.Encode.string) :: diff |> Just


{-| Show merge conflicts to a user to resolve.
-}
viewMerge : (Msg -> msg) -> Shared -> Model -> Config -> Config -> msg -> Bool -> List Id -> Html msg
viewMerge wrap shared model local config noOp canEdit conflicts =
    Html.div [ HtmlA.class "merge" ]
        [ Html.div []
            [ Html.h2 [] [ Strings.Conflict |> Lang.html shared ]
            , Html.p [] [ Strings.ConflictDescription |> Lang.html shared ]
            ]
        , Html.div
            [ HtmlA.class "conflicts" ]
            (conflicts |> List.map (viewConflict wrap shared model local config noOp canEdit))
        ]


viewConflict : (Msg -> msg) -> Shared -> Model -> Config -> Config -> msg -> Bool -> Id -> Html msg
viewConflict wrap shared model local config noOp canEdit conflict =
    let
        conflictComponent =
            componentById conflict
    in
    Html.div [ HtmlA.class "conflict" ]
        [ Component.view conflictComponent wrap shared model local config noOp canEdit ConfigOption.Diff |> Maybe.withDefault Html.nothing
        , Html.div [ HtmlA.class "resolution" ]
            [ resolveButton wrap shared conflict Config.Local Strings.YourChanges
            , resolveButton wrap shared conflict Config.Remote Strings.TheirChanges
            ]
        ]


resolveButton wrap shared conflict source description =
    Wl.button [ HtmlA.class "resolve", ResolveConflict source conflict |> wrap |> HtmlE.onClick ] [ description |> Lang.html shared ]


default : Config
default =
    { decks = Decks.default
    , privacy = Privacy.default
    , rules = Rules.default
    , version = ""
    }


all : Component Config Model Id Msg msg
all =
    Component.group All
        Nothing
        [ Decks.All |> DecksId |> componentById
        , Privacy.All |> PrivacyId |> componentById
        , TimeLimits.All |> TimeLimitsId |> componentById
        , Rules.All |> RulesId |> componentById
        ]


componentById : Id -> Component Config Model Id Msg msg
componentById id =
    case id of
        All ->
            all

        DecksId decksId ->
            decksId
                |> Decks.componentById
                |> Component.lift DecksId DecksMsg .decks (\d -> \c -> { c | decks = d }) .decks

        PrivacyId privacyId ->
            privacyId
                |> Privacy.componentById
                |> Component.lift PrivacyId PrivacyMsg .privacy (\p -> \c -> { c | privacy = p }) .privacy

        TimeLimitsId timeLimitsId ->
            timeLimitsId
                |> TimeLimits.componentById
                |> Component.lift
                    TimeLimitsId
                    TimeLimitsMsg
                    .timeLimits
                    (\tl -> \r -> { r | timeLimits = tl })
                    .timeLimits
                |> Component.liftConfig .rules (\r -> \c -> { c | rules = r })

        RulesId rulesId ->
            rulesId
                |> Rules.componentById
                |> Component.lift RulesId RulesMsg .rules (\r -> \c -> { c | rules = r }) .rules


mergeChange : Config -> Config -> Config -> Model -> Model
mergeChange base local remote model =
    let
        { updated, conflicts } =
            Diff.merge all base local remote { base | version = remote.version }

        -- If someone else changed the configuration to match yours, the conflict is resolved.
        oldConflicts =
            model.conflicts |> List.filter (\c -> not (Component.equal (componentById c) local remote))

        -- We can't have duplicate conflicts.
        newConflicts =
            conflicts |> List.filter (\c -> List.all ((/=) c) model.conflicts)
    in
    { model | localConfig = updated, conflicts = oldConflicts ++ newConflicts }


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
startGameProblems wrap wrapLobby users model remote =
    let
        config =
            model.localConfig

        deckSummaries =
            Decks.getDecks config.decks |> List.map .summary

        -- We assume decks will have calls/responses.
        summaries =
            \getTypeAmount ->
                deckSummaries
                    |> List.map (Maybe.map getTypeAmount >> Maybe.withDefault 1)
                    |> List.sum

        noDecks =
            List.length config.decks == 0

        loadingDecks =
            deckSummaries |> List.any Maybe.isNothing

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
                      , action = "CAHBS" |> Cardcast.playCode |> Source.Cardcast |> Decks.Add |> DecksMsg |> wrap
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

        humanPlayerCount =
            users
                |> Dict.values
                |> List.filter (\user -> user.role == User.Player && user.presence == User.Joined && user.control == User.Human)
                |> List.length

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
                        { number = max (3 - humanPlayerCount) 1 }
                            |> Rando.Set
                            |> HouseRule.RandoMsg
                            |> Rules.HouseRulesMsg
                            |> RulesMsg
                            |> wrap
                  }
                ]
                |> Maybe.justIf (playerCount < 3)
            , Message.errorWithFix
                Strings.NeedAtLeastOneHuman
                [ { description = Strings.Invite
                  , icon = Icon.bullhorn
                  , action = wrapLobby Lobby.ToggleInviteDialog
                  }
                ]
                |> Maybe.justIf (humanPlayerCount < 1)
            ]

        aisNoWriteGoodIssues =
            [ Message.errorWithFix
                Strings.RandoCantWrite
                [ { description = Strings.DisableRando
                  , icon = Icon.powerOff
                  , action =
                        False
                            |> Rando.SetEnabled
                            |> HouseRule.RandoMsg
                            |> Rules.HouseRulesMsg
                            |> RulesMsg
                            |> wrap
                  }
                , { description = Strings.DisableComedyWriter
                  , icon = Icon.eraser
                  , action =
                        False
                            |> ComedyWriter.SetEnabled
                            |> HouseRule.ComedyWriterMsg
                            |> Rules.HouseRulesMsg
                            |> RulesMsg
                            |> wrap
                  }
                ]
                |> Maybe.justIf (hr.rando /= Nothing && hr.comedyWriter /= Nothing)
            ]

        configurationIssues =
            [ Message.errorWithFix Strings.UnsavedChangesWarning
                (List.filterMap identity
                    [ { description = Strings.SaveChanges
                      , icon = Icon.save
                      , action = SaveChanges |> wrap
                      }
                        |> Maybe.justIf (Component.isValid all config)
                    , { description = Strings.RevertChanges
                      , icon = Icon.undo
                      , action = RevertChanges |> wrap
                      }
                        |> Just
                    ]
                )
                |> Maybe.justIf (config /= remote)
            ]
    in
    [ deckIssues, playerIssues, aisNoWriteGoodIssues, configurationIssues ] |> List.concat |> List.filterMap identity


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
