module MassiveDecks.Pages.Lobby.Configure exposing
    ( applyChange
    , init
    , update
    , view
    )

import Dict exposing (Dict)
import FontAwesome as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Json.Decode as Json
import Json.Diff as Json
import Json.Encode
import Json.Patch as Json
import MassiveDecks.Components.Form as Form
import MassiveDecks.Components.Form.Message as Message exposing (Message)
import MassiveDecks.Error.Model as Error exposing (Error)
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Icon as Icon
import MassiveDecks.Model exposing (..)
import MassiveDecks.Models.Decoders as Decoders
import MassiveDecks.Models.Encoders as Encoders
import MassiveDecks.Pages.Lobby.Actions as Actions
import MassiveDecks.Pages.Lobby.Configure.Configurable as Configurable
import MassiveDecks.Pages.Lobby.Configure.Configurable.Editor as Editor
import MassiveDecks.Pages.Lobby.Configure.Configurable.Model as Configurable exposing (Configurable)
import MassiveDecks.Pages.Lobby.Configure.Configurable.Validator as Validator
import MassiveDecks.Pages.Lobby.Configure.Decks as Decks
import MassiveDecks.Pages.Lobby.Configure.Decks.Model as Decks
import MassiveDecks.Pages.Lobby.Configure.Diff as Diff
import MassiveDecks.Pages.Lobby.Configure.Messages exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Model as Config exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Privacy as Privacy
import MassiveDecks.Pages.Lobby.Configure.Privacy.Model as Privacy
import MassiveDecks.Pages.Lobby.Configure.Rules as Rules
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.ComedyWriter.Model as ComedyWriter
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Model as HouseRules
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Rando.Model as Rando
import MassiveDecks.Pages.Lobby.Configure.Rules.Model as Rules
import MassiveDecks.Pages.Lobby.Configure.Stages as Stages
import MassiveDecks.Pages.Lobby.Configure.Stages.Model as Stages
import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Invite as Invite
import MassiveDecks.Pages.Lobby.Messages as Lobby
import MassiveDecks.Pages.Lobby.Model as Lobby exposing (Lobby)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Maybe as Maybe
import MassiveDecks.Util.NeList exposing (NeList(..))
import Material.Button as Button
import Material.Card as Card
import Material.Fab as Fab
import Material.Tabs as Tabs


init : Shared -> Config -> Model
init shared config =
    { localConfig = config
    , tab = Decks
    , decks = Decks.init shared
    , passwordVisible = False
    , conflicts = []
    }


update : Shared -> Msg -> Model -> Config -> ( Model, Shared, Cmd msg )
update shared msg model config =
    let
        allComponent =
            all identity config

        getComponent =
            Configurable.getById allComponent
    in
    case msg of
        DecksMsg decksMsg ->
            let
                ( decks, newShared, cmd ) =
                    Decks.update shared decksMsg model.decks
            in
            ( { model | decks = decks }, newShared, cmd )

        StartGame ->
            ( model, shared, Actions.startGame )

        ChangeTab t ->
            ( { model | tab = t |> Maybe.withDefault model.tab }, shared, Cmd.none )

        ResolveConflict source id ->
            case getComponent id of
                Just conflictComponent ->
                    let
                        local =
                            model.localConfig

                        set =
                            Configurable.set conflictComponent

                        ( newLocal, cmd ) =
                            case source of
                                Remote ->
                                    ( set config local, Cmd.none )

                                Local ->
                                    ( local
                                    , patchFor (set local config) config
                                        |> Maybe.map Actions.configure
                                        |> Maybe.withDefault Cmd.none
                                    )
                    in
                    ( { model | localConfig = newLocal, conflicts = model.conflicts |> List.filter ((/=) id) }, shared, cmd )

                Nothing ->
                    ( model, shared, Cmd.none )

        SaveChanges ->
            if Configurable.isValid allComponent model.localConfig then
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

        ApplyChange id change ->
            case getComponent id of
                Just conflictComponent ->
                    ( { model | localConfig = Configurable.set conflictComponent change model.localConfig }, shared, Cmd.none )

                Nothing ->
                    ( model, shared, Cmd.none )

        SetPasswordVisibility visible ->
            ( { model | passwordVisible = visible }, shared, Cmd.none )


view : (Msg -> msg) -> (Lobby.Msg -> msg) -> Shared -> Maybe msg -> Message msg -> GameCode -> Lobby.LobbyAndConfigure -> Html msg
view wrap wrapLobby shared return disabledReason gameCode { lobby, configure } =
    let
        allComponent =
            all wrap configure.localConfig

        getComponent =
            Configurable.getById allComponent

        model =
            configure

        canEdit =
            disabledReason |> Maybe.isNothing

        conflicts =
            if List.isEmpty model.conflicts then
                Html.nothing

            else
                Html.div [ HtmlA.id "merge-overlay" ]
                    [ Card.view []
                        [ model.conflicts |> List.filterMap getComponent |> viewMerge wrap shared model model.localConfig lobby.config
                        ]
                    ]

        viewComponent component =
            Configurable.viewEditor component shared model model.localConfig canEdit

        tabComponent =
            case model.tab of
                Decks ->
                    [ Decks.view (DecksMsg >> wrap) shared model.decks lobby.config.decks canEdit ]

                Rules ->
                    Rules.All |> RulesId |> getComponent |> Maybe.map viewComponent |> Maybe.withDefault []

                Stages ->
                    Stages.All |> StagesId |> getComponent |> Maybe.map viewComponent |> Maybe.withDefault []

                Privacy ->
                    Privacy.All |> PrivacyId |> getComponent |> Maybe.map viewComponent |> Maybe.withDefault []

        viewReturnButton msg =
            Button.viewWithAttrs
                Button.Raised
                Button.Padded
                (Strings.ReturnViewToGame |> Lang.string shared)
                (Icon.back |> Icon.view |> Just)
                (Just msg)
                [ HtmlA.class "game-in-progress" ]

        returnButton =
            return |> Maybe.map viewReturnButton |> Maybe.withDefault (Html.div [] [])

        nameSection =
            getComponent NameId |> Maybe.map viewComponent |> Maybe.withDefault []

        joiningSection =
            [ Html.div [ HtmlA.class "joining" ]
                [ Invite.button wrapLobby shared
                , Html.label [ Lobby.ToggleInviteDialog |> wrapLobby |> HtmlE.onClick ]
                    [ Strings.GameCode { code = GameCode.toString gameCode } |> Lang.html shared ]
                ]
            ]
    in
    Html.div [ HtmlA.class "configure" ]
        [ Card.view []
            [ Html.div [ HtmlA.class "title" ] (nameSection ++ joiningSection)
            , disabledReason
                |> Message.view shared
                |> Maybe.withDefault Html.nothing
            , Tabs.view
                { selected = model.tab
                , change = ChangeTab >> wrap
                , ids = tabs
                , tab = tab shared
                , equals = (==)
                , stacked = False
                }
            , Html.div [] tabComponent
            , startGameSegment wrap wrapLobby shared canEdit model lobby returnButton
            ]
        , actions wrap shared (model.localConfig /= lobby.config) model.localConfig
        , conflicts
        ]


applyChange : (Msg -> msg) -> Json.Patch -> Config -> Model -> Result Error ( Config, Model )
applyChange wrap change config model =
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
        |> Result.map (\c -> ( c, mergeChange wrap config model.localConfig c model ))



{- Private -}


actions : (Msg -> msg) -> Shared -> Bool -> Config -> Html msg
actions wrap shared hasChanges config =
    Html.div [ HtmlA.class "actions" ]
        [ Fab.view
            Fab.Normal
            (Strings.SaveChanges |> Lang.string shared)
            (Icon.save |> Icon.view)
            (SaveChanges |> wrap |> Maybe.justIf (Configurable.isValid (all wrap config) config))
            [ HtmlA.classList [ ( "action", True ), ( "important", True ), ( "exited", not hasChanges ) ] ]
        , Fab.view
            Fab.Mini
            (Strings.RevertChanges |> Lang.string shared)
            (Icon.undo |> Icon.view)
            (RevertChanges |> wrap |> Just)
            [ HtmlA.classList [ ( "action", True ), ( "exited", not hasChanges ), ( "normal", True ) ] ]
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
viewMerge : (Msg -> msg) -> Shared -> Model -> Config -> Config -> List (Configurable.Component Id Config Model msg) -> Html msg
viewMerge wrap shared model local config conflicts =
    Html.div [ HtmlA.class "merge" ]
        [ Html.div []
            [ Html.h2 [] [ Strings.Conflict |> Lang.html shared ]
            , Html.p [] [ Strings.ConflictDescription |> Lang.html shared ]
            ]
        , Html.div
            [ HtmlA.class "conflicts" ]
            (conflicts |> List.map (viewConflict wrap shared model local config))
        ]


viewConflict : (Msg -> msg) -> Shared -> Model -> Config -> Config -> Configurable.Component Id Config Model msg -> Html msg
viewConflict wrap shared model local config conflict =
    let
        id =
            Configurable.id conflict
    in
    Html.div [ HtmlA.class "conflict" ]
        [ Configurable.viewDiff conflict shared model local config
        , Html.div [ HtmlA.class "resolution" ]
            [ resolveButton wrap shared id Config.Local Strings.YourChanges
            , resolveButton wrap shared id Config.Remote Strings.TheirChanges
            ]
        ]


resolveButton : (Msg -> msg) -> Shared -> Id -> Config.Source -> MdString -> Html msg
resolveButton wrap shared conflict source description =
    Button.viewWithAttrs
        Button.Raised
        Button.Padded
        (description |> Lang.string shared)
        Nothing
        (ResolveConflict source conflict |> wrap |> Just)
        [ HtmlA.class "resolve" ]


all : (Msg -> msg) -> Config -> Configurable.Component Id Config Model msg
all wrap config =
    Configurable.group
        { id = All
        , editor = Editor.group "configure-all" Nothing False False
        , children =
            [ name |> Configurable.wrap identity (.name >> Just) (\v p -> { p | name = v })
            , Rules.all wrap |> Configurable.wrap RulesId (.rules >> Just) (\v p -> { p | rules = v })
            , Stages.all wrap
                |> Configurable.wrap StagesId (.stages >> Just) (\v p -> { p | stages = v })
                |> Configurable.wrap identity (.rules >> Just) (\v p -> { p | rules = v })
            , Privacy.all (SetPasswordVisibility >> wrap)
                |> Configurable.wrap PrivacyId (.privacy >> Just) (\v p -> { p | privacy = v })
            , Decks.all |> Configurable.wrap DecksId (.decks >> Just) (\v p -> { p | decks = v })
            ]
        }
        { noOp = wrap NoOp, config = Just config, update = \i c -> ApplyChange i c |> wrap }


name : Configurable Id String model msg
name =
    Configurable.value
        { id = NameId
        , editor = Editor.string Strings.LobbyNameLabel
        , validator = Validator.nonEmpty
        , messages = always []
        }


mergeChange : (Msg -> msg) -> Config -> Config -> Config -> Model -> Model
mergeChange wrap base local remote model =
    let
        allComponent =
            all wrap local

        getComponent =
            Configurable.getById allComponent

        { updated, conflicts } =
            Diff.merge allComponent base local remote { base | version = remote.version }

        conflictComponent id =
            getComponent id |> Maybe.map (\c -> not (Configurable.equals c local remote)) |> Maybe.withDefault True

        -- If someone else changed the configuration to match yours, the conflict is resolved.
        oldConflicts =
            model.conflicts |> List.filter conflictComponent

        -- We can't have duplicate conflicts.
        newConflicts =
            conflicts |> List.filter (\c -> List.all ((/=) c) model.conflicts)
    in
    { model | localConfig = updated, conflicts = oldConflicts ++ newConflicts }


startGameSegment : (Msg -> msg) -> (Lobby.Msg -> msg) -> Shared -> Bool -> Model -> Lobby -> Html msg -> Html msg
startGameSegment wrap wrapLobby shared canEdit model lobby returnButton =
    let
        config =
            lobby.config

        startErrors =
            startGameProblems shared wrap wrapLobby lobby.users model config
    in
    Html.div []
        [ Form.section
            shared
            "start-game"
            Html.nothing
            (startErrors |> Maybe.justIf canEdit |> Maybe.withDefault [])
        , Html.div [ HtmlA.class "button-spread" ]
            [ returnButton
            , Button.view
                Button.Raised
                Button.Padded
                (Strings.StartGame |> Lang.string shared)
                (Icon.start |> Icon.view |> Just)
                (StartGame |> wrap |> Maybe.justIf (List.isEmpty startErrors && canEdit))
            ]
        ]


startGameProblems : Shared -> (Msg -> msg) -> (Lobby.Msg -> msg) -> Dict User.Id User -> Model -> Config -> List (Message msg)
startGameProblems shared wrap wrapLobby users model remote =
    let
        config =
            model.localConfig

        rules =
            config.rules

        houseRules =
            rules.houseRules

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

        -- Catch the case where "only blank white cards" is enabled.
        numberOfNonBlankResponses =
            case hr.comedyWriter of
                Just { exclusive } ->
                    if exclusive then
                        0

                    else
                        summaries .responses

                Nothing ->
                    summaries .responses

        humanPlayerCount =
            users
                |> Dict.values
                |> List.filter (\u -> u.role == User.Player && u.presence == User.Joined && u.control == User.Human)
                |> List.length

        computerPlayerCount =
            config.rules.houseRules.rando |> Maybe.map .number |> Maybe.withDefault 0

        playerCount =
            humanPlayerCount + computerPlayerCount

        -- 5 is arbitrary, but we have to deal with an additional cards for each slot.
        requiredHumanResponses =
            humanPlayerCount * 5 + humanPlayerCount * rules.handSize

        -- We need enough non-blank responses for every player to have a full hand
        -- otherwise there is a chance humans will hog all the non-blank responses.
        requiredComputerResponses =
            if computerPlayerCount > 0 then
                playerCount * 5 + playerCount * rules.handSize

            else
                0

        deckIssues =
            if noDecks then
                [ Message.errorWithFix
                    Strings.NeedAtLeastOneDeck
                    [ { description = Strings.NoDecksHint
                      , icon = Icon.add
                      , action = shared |> Lang.recommended |> Decks.Add |> DecksMsg |> wrap
                      }
                    ]
                    |> Just
                ]

            else if loadingDecks then
                [ Strings.WaitForDecks |> Message.info |> Just ]

            else
                let
                    diff =
                        requiredHumanResponses - numberOfResponses

                    old =
                        config.rules.houseRules.comedyWriter |> Maybe.map .number |> Maybe.withDefault 0

                    comedyWriter =
                        houseRules.comedyWriter |> Maybe.withDefault { number = 0, exclusive = False }

                    newConfig =
                        { config | rules = { rules | houseRules = { houseRules | comedyWriter = Just { comedyWriter | number = diff + old } } } }

                    fixMsg =
                        ApplyChange
                            (ComedyWriter.Number
                                |> ComedyWriter.Child
                                |> HouseRules.ComedyWriterId
                                |> Rules.HouseRulesId
                                |> RulesId
                            )
                            newConfig
                            |> wrap
                in
                [ Strings.MissingCardType { cardType = Strings.Call }
                    |> Message.error
                    |> Maybe.justIf (summaries .calls < 1)
                , Message.errorWithFix
                    (Strings.NotEnoughCardsOfType { cardType = Strings.Response, needed = requiredHumanResponses, have = numberOfResponses })
                    [ Message.Fix (Strings.AddBlankCards { amount = diff }) Icon.add fixMsg ]
                    |> Maybe.justIf (numberOfResponses < requiredHumanResponses)
                , Message.error
                    (Strings.NotEnoughNonBlankCardsOfType { cardType = Strings.Response, needed = requiredComputerResponses, have = numberOfNonBlankResponses })
                    |> Maybe.justIf (numberOfResponses >= requiredHumanResponses && numberOfNonBlankResponses < requiredComputerResponses)
                ]

        rando =
            houseRules.rando |> Maybe.withDefault { number = max (3 - humanPlayerCount) 1 }

        addAisConfig =
            { config | rules = { rules | houseRules = { houseRules | rando = Just { rando | number = max (3 - humanPlayerCount) 1 } } } }

        addAisFixMsg =
            ApplyChange
                (Rando.Number
                    |> Rando.Child
                    |> HouseRules.RandoId
                    |> Rules.HouseRulesId
                    |> RulesId
                )
                addAisConfig
                |> wrap

        playerIssues =
            [ Message.errorWithFix
                Strings.NeedAtLeastThreePlayers
                [ { description = Strings.Invite
                  , icon = Icon.invite
                  , action = wrapLobby Lobby.ToggleInviteDialog
                  }
                , { description = Strings.AddAnAiPlayer
                  , icon = Icon.computer
                  , action = addAisFixMsg
                  }
                ]
                |> Maybe.justIf (playerCount < 3)
            , Message.errorWithFix
                Strings.NeedAtLeastOneHuman
                [ { description = Strings.Invite
                  , icon = Icon.invite
                  , action = wrapLobby Lobby.ToggleInviteDialog
                  }
                ]
                |> Maybe.justIf (humanPlayerCount < 1)
            ]

        configurationIssues =
            [ Message.errorWithFix Strings.UnsavedChangesWarning
                (List.filterMap identity
                    [ { description = Strings.SaveChanges
                      , icon = Icon.save
                      , action = SaveChanges |> wrap
                      }
                        |> Maybe.justIf (Configurable.isValid (all wrap config) config)
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
    [ deckIssues, playerIssues, configurationIssues ] |> List.concat |> List.filterMap identity


tabs : List Tab
tabs =
    [ Decks, Rules, Stages, Privacy ]


tab : Shared -> Tab -> Tabs.TabModel msg
tab shared target =
    { label = target |> tabName |> Lang.string shared
    , icon = Nothing
    }


tabName : Tab -> MdString
tabName target =
    case target of
        Decks ->
            Strings.ConfigureDecks

        Rules ->
            Strings.ConfigureRules

        Stages ->
            Strings.ConfigureTimeLimits

        Privacy ->
            Strings.ConfigurePrivacy
