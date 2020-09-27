module MassiveDecks.Pages.Lobby exposing
    ( changeRoute
    , init
    , initWithAuth
    , route
    , subscriptions
    , update
    , view
    )

import Browser.Navigation as Navigation
import Dict exposing (Dict)
import FontAwesome.Attributes as Icon
import FontAwesome.Brands as Icon
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Layering as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Html.Keyed as HtmlK
import Json.Patch as Json
import MassiveDecks.Animated as Animated exposing (Animated)
import MassiveDecks.Card.Model as Card
import MassiveDecks.Cast.Client as Cast
import MassiveDecks.Cast.Model as Cast
import MassiveDecks.Components.Form.Message as Message exposing (Message)
import MassiveDecks.Components.Menu as Menu
import MassiveDecks.Components.Menu.Model as Menu
import MassiveDecks.Error as MdError
import MassiveDecks.Error.Model as Error exposing (Error)
import MassiveDecks.Game as Game
import MassiveDecks.Game.Messages as Game
import MassiveDecks.Game.Model as Game exposing (Game)
import MassiveDecks.Game.Player as Player exposing (Player)
import MassiveDecks.Game.Round as Round exposing (Round)
import MassiveDecks.Game.Time as Time
import MassiveDecks.Model exposing (..)
import MassiveDecks.Models.MdError as MdError exposing (MdError)
import MassiveDecks.Pages.Lobby.Actions as Actions
import MassiveDecks.Pages.Lobby.Configure as Configure
import MassiveDecks.Pages.Lobby.Configure.Model as Configure exposing (Config)
import MassiveDecks.Pages.Lobby.Events as Events
import MassiveDecks.Pages.Lobby.GameCode as GameCode
import MassiveDecks.Pages.Lobby.Invite as Invite
import MassiveDecks.Pages.Lobby.Messages exposing (..)
import MassiveDecks.Pages.Lobby.Model exposing (..)
import MassiveDecks.Pages.Lobby.Route exposing (..)
import MassiveDecks.Pages.Lobby.Spectate as Spectate
import MassiveDecks.Pages.Route as Route
import MassiveDecks.Pages.Start.Route as Start
import MassiveDecks.Ports as Ports
import MassiveDecks.ServerConnection as ServerConnection
import MassiveDecks.Settings as Settings
import MassiveDecks.Settings.Messages as Settings
import MassiveDecks.Settings.Model as Settings exposing (Settings)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Html.Attributes as HtmlA
import MassiveDecks.Util.Maybe as Maybe
import MassiveDecks.Util.NeList as NeList
import Material.Button as Button
import Material.Card as Card
import Material.IconButton as IconButton


changeRoute : Shared -> Route -> Model -> Route.Fork ( Model, Cmd msg )
changeRoute shared r model =
    if model.route.gameCode == r.gameCode then
        Route.Continue ( { model | route = r }, Cmd.none )

    else
        init shared r Nothing


init : Shared -> Route -> Maybe Auth -> Route.Fork ( Model, Cmd msg )
init shared r auth =
    let
        fallbackAuth =
            Maybe.first
                [ auth |> Maybe.andThen (Maybe.validate (\a -> a.claims.gc == r.gameCode))
                , Settings.auths shared.settings.settings |> Dict.get (r.gameCode |> GameCode.toString)
                ]
    in
    fallbackAuth
        |> Maybe.map (initWithAuth shared r >> Route.Continue)
        |> Maybe.withDefault (Route.Redirect (Route.Start { section = Start.Join (Just r.gameCode) }))


initWithAuth : Shared -> Route -> Auth -> ( Model, Cmd msg )
initWithAuth _ r auth =
    ( { route = r
      , auth = auth
      , lobbyAndConfigure = Nothing
      , notificationId = 0
      , notifications = []
      , inviteDialogOpen = False
      , timeAnchor = Nothing
      , spectate = Spectate.init
      , gameMenu = Menu.Closed
      , userMenu = Nothing
      }
    , ServerConnection.connect auth.claims.gc auth.token
    )


route : Model -> Route
route model =
    model.route


subscriptions : (Msg -> msg) -> (Error -> msg) -> Model -> Sub msg
subscriptions wrap handleError model =
    Sub.batch
        [ Maybe.map2 (Game.subscriptions (GameMsg >> wrap))
            model.timeAnchor
            (model.lobbyAndConfigure |> Maybe.map .lobby |> Maybe.andThen .game)
            |> Maybe.withDefault Sub.none
        , model.notifications |> Animated.subscriptions (NotificationMsg >> wrap)
        , ServerConnection.notifications
            (EventReceived >> wrap)
            (ErrorReceived >> wrap)
            (Error.Json >> handleError)
        ]


update : (Msg -> msg) -> Shared -> Msg -> Model -> ( Change, Shared, Cmd msg )
update wrap shared msg model =
    case msg of
        GameMsg gameMsg ->
            case model.lobbyAndConfigure of
                Just lobbyAndConfigure ->
                    let
                        l =
                            lobbyAndConfigure.lobby
                    in
                    case lobbyAndConfigure.lobby.game of
                        Just g ->
                            let
                                ( updatedGame, gameCmd ) =
                                    Game.update (GameMsg >> wrap) shared gameMsg g
                            in
                            ( Stay
                                { model
                                    | lobbyAndConfigure =
                                        Just { lobbyAndConfigure | lobby = { l | game = Just updatedGame } }
                                }
                            , shared
                            , gameCmd
                            )

                        Nothing ->
                            ( Stay model, shared, Cmd.none )

                Nothing ->
                    ( Stay model, shared, Cmd.none )

        SpectateMsg spectateMsg ->
            let
                ( spectate, cmd ) =
                    Spectate.update spectateMsg model.spectate
            in
            ( Stay { model | spectate = spectate }, shared, cmd )

        EventReceived event ->
            case model.lobbyAndConfigure of
                Just lobbyAndConfigure ->
                    let
                        { lobby, configure } =
                            lobbyAndConfigure

                        updatedLobby l m =
                            let
                                f lAndC =
                                    { lAndC | lobby = l lAndC.lobby }
                            in
                            { m | lobbyAndConfigure = m.lobbyAndConfigure |> Maybe.map f }

                        updatedGame g =
                            updatedLobby (\l -> { l | game = g })

                        updatedUsers u =
                            updatedLobby (\l -> { l | users = u })

                        updatedErrors e =
                            updatedLobby (\l -> { l | errors = e })
                    in
                    case event of
                        Events.Sync { state, hand, play, partialTimeAnchor } ->
                            applySync wrap shared model state hand play partialTimeAnchor

                        Events.Configured { change } ->
                            ( applyConfigured wrap change model, shared, Cmd.none )

                        Events.GameStarted { round, hand } ->
                            let
                                ( g, gameCmd ) =
                                    Game.applyGameStarted
                                        (GameMsg >> wrap)
                                        lobby
                                        (round |> Round.withStage (Round.P round.stage))
                                        (hand |> Maybe.withDefault [])

                                r =
                                    model.route

                                changeCmd =
                                    if r.section == Just Configure then
                                        { r | section = Nothing }
                                            |> Route.Lobby
                                            |> Route.url
                                            |> Navigation.replaceUrl shared.key
                                            |> Just

                                    else
                                        Nothing

                                cmd =
                                    [ Just gameCmd, changeCmd ] |> List.filterMap identity |> Cmd.batch
                            in
                            ( model |> updatedGame (Just g) |> Stay, shared, cmd )

                        Events.Game gameEvent ->
                            let
                                withGame game =
                                    let
                                        ( g, cmd ) =
                                            Game.applyGameEvent (GameMsg >> wrap)
                                                (EventReceived >> wrap)
                                                model.auth
                                                shared
                                                gameEvent
                                                game
                                    in
                                    ( model |> updatedGame (Just g) |> Stay, shared, cmd )
                            in
                            lobby.game
                                |> Maybe.map withGame
                                |> Maybe.withDefault ( Stay model, shared, Cmd.none )

                        Events.Connection { user, state } ->
                            let
                                ( newUsers, message ) =
                                    case state of
                                        User.Connected ->
                                            ( lobby.users |> Dict.update user (Maybe.map (\u -> { u | connection = User.Connected }))
                                            , UserConnected user
                                            )

                                        User.Disconnected ->
                                            ( lobby.users |> Dict.update user (Maybe.map (\u -> { u | connection = User.Disconnected }))
                                            , UserDisconnected user
                                            )
                            in
                            addNotification wrap
                                shared
                                message
                                (model |> updatedUsers newUsers)

                        Events.Presence { user, state } ->
                            case ( state, user == model.auth.claims.uid ) of
                                ( Events.UserLeft { reason }, True ) ->
                                    ( LeftGame model.auth.claims.gc reason, shared, Cmd.none )

                                _ ->
                                    let
                                        { newUsers, game, message } =
                                            case state of
                                                Events.UserJoined { name, privilege, control } ->
                                                    let
                                                        newUser =
                                                            { name = name
                                                            , presence = User.Joined
                                                            , connection = User.Connected
                                                            , privilege = privilege
                                                            , role = User.Player
                                                            , control = control
                                                            }
                                                    in
                                                    { newUsers =
                                                        Dict.insert
                                                            user
                                                            newUser
                                                            lobby.users
                                                    , game = lobby.game |> Maybe.map (Game.hotJoinPlayer user newUser)
                                                    , message = UserJoined user
                                                    }

                                                Events.UserLeft { reason } ->
                                                    { newUsers =
                                                        lobby.users
                                                            |> Dict.update user (Maybe.map (\u -> { u | presence = User.Left }))
                                                    , game = lobby.game
                                                    , message = UserLeft user reason
                                                    }
                                    in
                                    addNotification wrap
                                        shared
                                        message
                                        (model |> updatedUsers newUsers |> updatedGame game)

                        Events.PrivilegeChanged { user, privilege } ->
                            let
                                users =
                                    lobby.users |> Dict.update user (Maybe.map (\u -> { u | privilege = privilege }))
                            in
                            ( model |> updatedUsers users |> Stay, shared, Cmd.none )

                        Events.ErrorEncountered { error } ->
                            ( model |> updatedErrors (lobby.errors ++ [ error ]) |> Stay, shared, Cmd.none )

                        Events.UserRoleChanged { user, role, hand } ->
                            let
                                users =
                                    lobby.users |> Dict.update user (Maybe.map (\u -> { u | role = role }))

                                updatePlayer =
                                    case role of
                                        User.Player ->
                                            Dict.insert user Player.default

                                        User.Spectator ->
                                            Dict.remove user

                                updateGame gameModel =
                                    let
                                        game =
                                            gameModel.game
                                    in
                                    { gameModel
                                        | game = { game | players = updatePlayer game.players }
                                        , hand = hand |> Maybe.withDefault gameModel.hand
                                    }

                                newGame =
                                    lobby.game |> Maybe.map updateGame
                            in
                            ( (model |> updatedUsers users |> updatedGame newGame) |> Stay
                            , shared
                            , Cmd.none
                            )

                Nothing ->
                    case event of
                        Events.Sync { state, hand, play, partialTimeAnchor } ->
                            applySync wrap shared model state hand play partialTimeAnchor

                        _ ->
                            ( Stay model, shared, Cmd.none )

        ErrorReceived error ->
            case error of
                MdError.Authentication _ ->
                    ( JoinError model.auth.claims.gc error, shared, Cmd.none )

                MdError.LobbyNotFound _ ->
                    ( JoinError model.auth.claims.gc error, shared, Cmd.none )

                MdError.ActionExecution (MdError.ConfigEditConflict _) ->
                    let
                        reset { lobby, configure } =
                            { lobby = lobby, configure = { configure | localConfig = lobby.config } }
                    in
                    addNotification wrap
                        shared
                        (Error error)
                        { model | lobbyAndConfigure = model.lobbyAndConfigure |> Maybe.map reset }

                _ ->
                    addNotification wrap shared (Error error) model

        ConfigureMsg configureMsg ->
            case model.lobbyAndConfigure of
                Just { lobby, configure } ->
                    let
                        ( c, s, cmd ) =
                            Configure.update shared configureMsg configure lobby.config
                    in
                    ( Stay { model | lobbyAndConfigure = Just { lobby = lobby, configure = c } }, s, cmd )

                Nothing ->
                    ( Stay model, shared, Cmd.none )

        NotificationMsg notificationMsg ->
            let
                ( notifications, cmd ) =
                    Animated.update (NotificationMsg >> wrap) { removeDone = Just Animated.defaultDuration } notificationMsg model.notifications
            in
            ( Stay { model | notifications = notifications }, shared, cmd )

        ToggleInviteDialog ->
            ( Stay { model | inviteDialogOpen = not model.inviteDialogOpen }, shared, Cmd.none )

        Leave ->
            ( Stay model, shared, Actions.leave )

        Kick id ->
            ( Stay model, shared, Actions.kick id )

        SetAway id ->
            ( Stay model, shared, Actions.setPlayerAway id )

        SetPrivilege id privilege ->
            ( Stay model, shared, Actions.setPrivilege id privilege )

        SetTimeAnchor anchor ->
            ( Stay { model | timeAnchor = Just anchor }, shared, Cmd.none )

        SetUserRole id role ->
            ( Stay model, shared, Actions.setUserRole id role )

        EndGame ->
            ( Stay model, shared, Actions.endGame )

        TryCast auth ->
            ( Stay model, shared, Cast.tryCast shared auth.token )

        Copy id ->
            ( Stay model, shared, Ports.copyText id )

        ChangeSection s ->
            let
                r =
                    route model

                newRoute =
                    { r | section = s }
            in
            ( Stay { model | route = newRoute }, shared, newRoute |> Route.Lobby |> Route.url |> Navigation.replaceUrl shared.key )

        SetGameMenuState newState ->
            ( Stay { model | gameMenu = newState }, shared, Cmd.none )

        SetUserMenuState id state ->
            let
                old =
                    model.userMenu

                new =
                    case state of
                        Menu.Open ->
                            Just id

                        Menu.Closed ->
                            if old /= Just id then
                                old

                            else
                                Nothing
            in
            ( Stay { model | userMenu = new }, shared, Cmd.none )

        NoOp ->
            ( Stay model, shared, Cmd.none )


view : (Msg -> msg) -> (Settings.Msg -> msg) -> (Route.Route -> msg) -> Shared -> Model -> List (Html msg)
view wrap wrapSettings changePage shared model =
    let
        s =
            model.route.section
                |> Maybe.withDefault (section model.route model.auth (model.lobbyAndConfigure |> Maybe.map .lobby))
    in
    case s of
        Play ->
            let
                viewContent _ auth timeAnchor { lobby, configure } =
                    lobby.game
                        |> Maybe.map (Game.view wrap (GameMsg >> wrap) shared auth timeAnchor lobby.config.name lobby.config lobby.users)
                        |> Maybe.withDefault (Html.div [] [ Strings.GameNotStartedError |> Lang.html shared ])
            in
            viewWithUsers wrap wrapSettings shared s viewContent model

        Configure ->
            let
                viewContent canEdit auth _ lobbyAndConfigure =
                    Configure.view (ConfigureMsg >> wrap)
                        wrap
                        shared
                        (Nothing |> ChangeSection |> wrap |> Maybe.justIf (lobbyAndConfigure.lobby.game /= Nothing))
                        canEdit
                        auth.claims.gc
                        lobbyAndConfigure
            in
            viewWithUsers wrap wrapSettings shared s viewContent model

        Spectate ->
            Spectate.view (SpectateMsg >> wrap) (GameMsg >> wrap) changePage shared model



{- Private -}


section : Route -> Auth -> Maybe Lobby -> Section
section r auth lobby =
    let
        game =
            lobby |> Maybe.andThen .game

        gameSection =
            case lobby |> Maybe.andThen (.users >> Dict.get auth.claims.uid) |> Maybe.map .role |> Maybe.withDefault User.Player of
                User.Player ->
                    Play

                User.Spectator ->
                    Spectate
    in
    r.section |> Maybe.withDefault (game |> Maybe.map (always gameSection) |> Maybe.withDefault Configure)


type alias ViewContent msg =
    Message msg -> Auth -> Time.Anchor -> LobbyAndConfigure -> Html msg


viewWithUsers : (Msg -> msg) -> (Settings.Msg -> msg) -> Shared -> Section -> ViewContent msg -> Model -> List (Html msg)
viewWithUsers wrap wrapSettings shared s viewContent model =
    let
        usersShown =
            shared.settings.settings.openUserList

        castAttrs =
            case shared.castStatus of
                Cast.NoDevicesAvailable ->
                    Nothing

                Cast.NotConnected ->
                    Just [ Strings.Cast |> Lang.title shared ]

                Cast.Connecting ->
                    Just [ Strings.CastConnecting |> Lang.title shared, HtmlA.class "connecting" ]

                Cast.Connected name ->
                    Just [ Strings.CastConnected { deviceName = name } |> Lang.title shared, HtmlA.class "connected" ]

        castButton =
            castAttrs
                |> Maybe.map (viewCastButton wrap shared model.auth)
                |> Maybe.withDefault []

        usersIcon =
            if usersShown then
                Icon.eyeSlash

            else
                Icon.users

        lobby =
            model.lobbyAndConfigure |> Maybe.map .lobby

        notifications =
            model.notifications |> List.map (keyedViewNotification wrap shared lobby)

        localUser =
            lobby |> Maybe.andThen (.users >> Dict.get model.auth.claims.uid)

        maybeGame =
            lobby |> Maybe.andThen .game

        localPlayer =
            maybeGame |> Maybe.andThen (.game >> .players >> Dict.get model.auth.claims.uid)

        audienceMode =
            lobby |> Maybe.map (.config >> .privacy >> .audienceMode) |> Maybe.withDefault True
    in
    [ Html.div
        [ HtmlA.id "lobby"
        , HtmlA.classList [ ( "collapsed-users", not usersShown ) ]
        , shared.settings.settings.cardSize |> cardSizeToAttr
        ]
        (Html.div [ HtmlA.id "top-bar" ]
            [ Html.div [ HtmlA.class "left" ]
                (List.concat
                    [ [ IconButton.view shared
                            Strings.ToggleUserList
                            (usersIcon |> Icon.present |> Icon.styled [ Icon.lg ] |> NeList.just)
                            (usersShown |> not |> Settings.ChangeOpenUserList |> wrapSettings |> Just)
                      , lobbyMenu wrap shared model.gameMenu model.route s audienceMode localUser localPlayer (maybeGame |> Maybe.map .game)
                      ]
                    , castButton
                    ]
                )
            , Html.div [] [ Settings.view wrapSettings shared ]
            ]
            :: HtmlK.ol [ HtmlA.class "notifications" ] notifications
            :: (model.lobbyAndConfigure
                    |> Maybe.map2 (viewLobby wrap shared model.auth model.userMenu viewContent) model.timeAnchor
                    |> Maybe.withDefault
                        [ Html.div [ HtmlA.class "loading" ]
                            [ Icon.viewStyled [ Icon.spin, Icon.fa3x ] Icon.circleNotch ]
                        ]
               )
        )
    , Invite.dialog
        wrap
        shared
        model.auth.claims.gc
        (lobby |> Maybe.andThen (.config >> .privacy >> .password))
        model.inviteDialogOpen
    ]


viewLobby : (Msg -> msg) -> Shared -> Auth -> Maybe User.Id -> ViewContent msg -> Time.Anchor -> LobbyAndConfigure -> List (Html msg)
viewLobby wrap shared auth openUserMenu viewContent timeAnchor lobbyAndConfigure =
    let
        lobby =
            lobbyAndConfigure.lobby

        game =
            lobby.game |> Maybe.map .game

        privileged =
            (lobby.users |> Dict.get auth.claims.uid |> Maybe.map .privilege) == Just User.Privileged

        configDisabledReason =
            if not privileged then
                Message.info Strings.ConfigurationDisabledIfNotPrivileged

            else if game |> Maybe.map (.winner >> Maybe.isNothing) |> Maybe.withDefault False then
                Message.infoWithFix Strings.ConfigurationDisabledWhileInGame
                    [ { description = Strings.EndGame
                      , icon = Icon.stopCircle
                      , action = wrap EndGame
                      }
                    ]

            else
                Message.none
    in
    [ Html.div [ HtmlA.id "lobby-content" ]
        [ viewUsers wrap shared auth.claims.uid lobby openUserMenu game
        , Html.div [ HtmlA.id "scroll-frame" ] [ viewContent configDisabledReason auth timeAnchor lobbyAndConfigure ]
        , lobby.errors |> viewErrors shared
        ]
    ]


cardSizeToAttr : Settings.CardSize -> Html.Attribute msg
cardSizeToAttr cardSize =
    case cardSize of
        Settings.Minimal ->
            HtmlA.class "minimal-card-size"

        Settings.Square ->
            HtmlA.class "square-card-size"

        Settings.Full ->
            HtmlA.nothing


lobbyMenu : (Msg -> msg) -> Shared -> Menu.State -> Route -> Section -> Bool -> Maybe User -> Maybe Player -> Maybe Game -> Html msg
lobbyMenu wrap shared menuState r s audienceMode user player game =
    let
        lobbyMenuItems =
            [ Menu.button Icon.bullhorn Strings.InvitePlayers Strings.InvitePlayersDescription (ToggleInviteDialog |> wrap |> Just) ]

        setPresence =
            setPresenceMenuItem wrap player

        playerState role =
            case role of
                User.Player ->
                    Menu.button Icon.eye Strings.BecomeSpectator Strings.BecomeSpectatorDescription (SetUserRole Nothing User.Spectator |> wrap |> Just)

                User.Spectator ->
                    Menu.button Icon.chessPawn Strings.BecomePlayer Strings.BecomePlayerDescription (SetUserRole Nothing User.Player |> wrap |> Just)

        userLobbyMenuItems =
            [ setPresence |> Just
            , user
                |> Maybe.andThen (\u -> u |> Maybe.justIf (u.privilege == User.Privileged || not audienceMode))
                |> Maybe.map (.role >> playerState)
            , Menu.button
                Icon.signOutAlt
                Strings.LeaveGame
                Strings.LeaveGameDescription
                (Leave |> wrap |> Just)
                |> Just
            ]
                |> List.filterMap identity

        viewMenuItems =
            [ Menu.link Icon.tv Strings.Spectate Strings.SpectateDescription ({ r | section = Just Spectate } |> Route.Lobby |> Route.url |> Just)
            , case s of
                Configure ->
                    Menu.button Icon.play Strings.ReturnViewToGame Strings.ReturnViewToGameDescription (Nothing |> ChangeSection |> wrap |> Maybe.justIf (game /= Nothing))

                _ ->
                    Menu.button Icon.cog Strings.ViewConfiguration Strings.ViewConfigurationDescription (Configure |> Just |> ChangeSection |> wrap |> Just)
            ]

        privilegedLobbyMenuItems =
            [ Menu.button Icon.stopCircle Strings.EndGame Strings.EndGameDescription (game |> Maybe.andThen (\g -> EndGame |> wrap |> Maybe.justIf (g.winner == Nothing)))
            ]

        mdMenuItems =
            [ Menu.link Icon.info Strings.AboutTheGame Strings.AboutTheGameDescription (Just "https://github.com/lattyware/massivedecks")
            , Menu.link Icon.bug Strings.ReportError Strings.ReportErrorDescription (Just "https://github.com/Lattyware/massivedecks/issues/new")
            ]

        menuItems =
            [ lobbyMenuItems |> Just
            , userLobbyMenuItems |> Just
            , viewMenuItems |> Just
            , privilegedLobbyMenuItems |> Maybe.justIf ((user |> Maybe.map .privilege) == Just User.Privileged)
            , mdMenuItems |> Just
            ]

        separatedMenuItems =
            menuItems |> List.filterMap identity |> List.intersperse [ Menu.Separator ] |> List.concat
    in
    Menu.view shared
        (Menu.Closed |> SetGameMenuState |> wrap)
        menuState
        Menu.BottomEnd
        (IconButton.view shared
            Strings.GameMenu
            (Icon.bars |> Icon.present |> Icon.styled [ Icon.lg ] |> NeList.just)
            (menuState |> Menu.toggle |> SetGameMenuState |> wrap |> Just)
        )
        separatedMenuItems


applyConfigured : (Msg -> msg) -> Json.Patch -> Model -> Change
applyConfigured wrap change oldModel =
    case oldModel.lobbyAndConfigure of
        Just { lobby, configure } ->
            let
                updatedConfig =
                    Configure.applyChange (ConfigureMsg >> wrap) change lobby.config configure
            in
            case updatedConfig of
                Ok ( config, model ) ->
                    { oldModel
                        | lobbyAndConfigure =
                            Just { lobby = { lobby | config = config }, configure = model }
                    }
                        |> Stay

                Err error ->
                    error |> ConfigError

        Nothing ->
            Stay oldModel


notificationDuration : Int
notificationDuration =
    3500


applySync :
    (Msg -> msg)
    -> Shared
    -> Model
    -> Lobby
    -> Maybe (List Card.Response)
    -> Maybe (List Card.Id)
    -> Time.PartialAnchor
    -> ( Change, Shared, Cmd msg )
applySync wrap shared model state hand pick partialTimeAnchor =
    let
        toPick cards =
            { state = Round.Submitted, cards = cards |> List.indexedMap (\i id -> ( i, id )) |> Dict.fromList }

        play =
            pick |> Maybe.map toPick |> Maybe.withDefault Round.noPick

        -- We keep fills over syncs to try and preserve user input if possible.
        -- If things have changed, it won't matter, we'll just clear them at the end of the next round.
        keptFills =
            model.lobbyAndConfigure |> Maybe.map .lobby |> Maybe.andThen .game |> Maybe.map .filledCards

        ( game, gameCmd ) =
            case state.game of
                Just g ->
                    let
                        ( newGame, cmd ) =
                            Game.init (GameMsg >> wrap) g.game (hand |> Maybe.withDefault []) play
                    in
                    ( Just { newGame | filledCards = keptFills |> Maybe.withDefault newGame.filledCards }, cmd )

                Nothing ->
                    ( Nothing, Cmd.none )

        timeCmd =
            Time.anchor (SetTimeAnchor >> wrap) partialTimeAnchor

        configure =
            model.lobbyAndConfigure |> Maybe.map .configure |> Maybe.withDefault (Configure.init shared state.config)
    in
    ( Stay
        { model
            | lobbyAndConfigure =
                Just
                    { lobby = { state | game = game }
                    , configure = { configure | localConfig = state.config }
                    }
        }
    , shared
    , Cmd.batch [ timeCmd, gameCmd ]
    )


addNotification : (Msg -> msg) -> Shared -> NotificationMessage -> Model -> ( Change, Shared, Cmd msg )
addNotification wrap shared message model =
    let
        notification =
            { id = model.notificationId, message = message }

        notifications =
            model.notifications ++ [ Animated.animate notification ]
    in
    ( Stay { model | notifications = notifications, notificationId = model.notificationId + 1 }
    , shared
    , Animated.exitAfter (NotificationMsg >> wrap) notificationDuration notification
    )


keyedViewNotification : (Msg -> msg) -> Shared -> Maybe Lobby -> Animated Notification -> ( String, Html msg )
keyedViewNotification wrap shared lobby notification =
    ( String.fromInt notification.item.id
    , Html.li [] [ Animated.view (viewNotification wrap shared (lobby |> Maybe.map .users)) notification ]
    )


viewNotification : (Msg -> msg) -> Shared -> Maybe (Dict User.Id User) -> Html.Attribute msg -> Notification -> Html msg
viewNotification wrap shared users animationState notification =
    let
        ( icon, message, class ) =
            case notification.message of
                UserConnected id ->
                    ( Icon.viewIcon Icon.plug
                    , Strings.UserConnected { username = username shared users id } |> Lang.html shared
                    , Nothing
                    )

                UserDisconnected id ->
                    ( Icon.layers [] [ Icon.viewIcon Icon.plug, Icon.viewIcon Icon.slash ]
                    , Strings.UserDisconnected { username = username shared users id } |> Lang.html shared
                    , Nothing
                    )

                UserJoined id ->
                    ( Icon.viewIcon Icon.signInAlt
                    , Strings.UserJoined { username = username shared users id } |> Lang.html shared
                    , Nothing
                    )

                UserLeft id leaveReason ->
                    ( Icon.viewIcon Icon.signOutAlt
                    , case leaveReason of
                        User.LeftNormally ->
                            Strings.UserLeft { username = username shared users id } |> Lang.html shared

                        User.Kicked ->
                            Strings.UserKicked { username = username shared users id } |> Lang.html shared
                    , Nothing
                    )

                Error mdError ->
                    ( Icon.viewIcon Icon.exclamationTriangle
                    , MdError.describe mdError |> Lang.html shared
                    , Just "error"
                    )
    in
    Card.view
        [ HtmlA.class "notification", animationState, class |> Maybe.map HtmlA.class |> Maybe.withDefault HtmlA.nothing ]
        [ Html.div [ HtmlA.class "content" ]
            [ Html.span [ HtmlA.class "icon" ] [ icon ]
            , Html.span [ HtmlA.class "message" ] [ message ]
            , Button.view shared
                Button.Standard
                Strings.Dismiss
                Strings.Dismiss
                Html.nothing
                [ notification |> Animated.Exit |> NotificationMsg |> wrap |> HtmlE.onClick
                , HtmlA.class "action"
                ]
            ]
        ]


username : Shared -> Maybe (Dict User.Id User) -> User.Id -> String
username shared users id =
    users
        |> Maybe.andThen (\u -> Dict.get id u)
        |> Maybe.map .name
        |> Maybe.withDefault (Strings.UnknownUser |> Lang.string shared)


viewErrors : Shared -> List MdError.GameStateError -> Html msg
viewErrors shared errors =
    if errors |> List.isEmpty then
        Html.nothing

    else
        Html.div [ HtmlA.class "lobby-errors" ] (errors |> List.map (viewError shared))


viewError : Shared -> MdError.GameStateError -> Html msg
viewError shared error =
    error |> MdError.Game |> MdError.viewSpecific shared


viewUsers : (Msg -> msg) -> Shared -> User.Id -> Lobby -> Maybe User.Id -> Maybe Game -> Html msg
viewUsers wrap shared localUserId lobby openUserMenu game =
    let
        users =
            lobby.users

        localUserPrivilege =
            users |> Dict.get localUserId |> Maybe.map .privilege |> Maybe.withDefault User.Unprivileged

        ( active, inactive ) =
            users |> Dict.toList |> List.partition (\( _, user ) -> user.presence == User.Joined)

        activeGroups =
            active |> byRole |> List.map (viewRoleGroup wrap shared localUserId localUserPrivilege lobby.config.privacy.audienceMode openUserMenu game)

        inactiveGroup =
            if List.isEmpty inactive then
                []

            else
                [ viewUserListGroup wrap shared localUserId localUserPrivilege lobby.config.privacy.audienceMode openUserMenu game ( ( "left", Strings.Left ), inactive ) ]

        groups =
            List.concat [ activeGroups, inactiveGroup ]
    in
    Card.view [ HtmlA.id "users" ] [ Html.div [ HtmlA.class "collapsible" ] [ HtmlK.ol [] groups ] ]


viewRoleGroup : (Msg -> msg) -> Shared -> User.Id -> User.Privilege -> Bool -> Maybe User.Id -> Maybe Game -> ( User.Role, List ( User.Id, User ) ) -> ( String, Html msg )
viewRoleGroup wrap shared localUserId localUserPrivilege audienceMode openUserMenu game ( role, users ) =
    let
        idAndDescription =
            case role of
                User.Player ->
                    ( "players", Strings.Players )

                User.Spectator ->
                    ( "spectators", Strings.Spectators )
    in
    viewUserListGroup wrap shared localUserId localUserPrivilege audienceMode openUserMenu game ( idAndDescription, users )


viewUserListGroup : (Msg -> msg) -> Shared -> User.Id -> User.Privilege -> Bool -> Maybe User.Id -> Maybe Game -> ( ( String, MdString ), List ( User.Id, User ) ) -> ( String, Html msg )
viewUserListGroup wrap shared localUserId localUserPrivilege audienceMode openUserMenu game ( ( id, description ), users ) =
    ( id
    , Html.li [ HtmlA.class id ]
        [ Html.span [] [ description |> Lang.html shared ]
        , HtmlK.ol [] (users |> List.map (viewUser wrap shared localUserId localUserPrivilege audienceMode openUserMenu game))
        ]
    )


roles : List User.Role
roles =
    [ User.Player, User.Spectator ]


byRole : List ( User.Id, User ) -> List ( User.Role, List ( User.Id, User ) )
byRole users =
    roles
        |> List.map (\role -> ( role, users |> List.filter (\( _, user ) -> user.role == role) ))
        |> List.filter (\( _, us ) -> not (List.isEmpty us))


viewUser : (Msg -> msg) -> Shared -> User.Id -> User.Privilege -> Bool -> Maybe User.Id -> Maybe Game -> ( User.Id, User ) -> ( String, Html msg )
viewUser wrap shared localUserId localUserPrivilege audienceMode openUserMenu game ( userId, user ) =
    let
        ( secondary, score ) =
            userDetails shared game userId user

        player =
            game |> Maybe.map .players |> Maybe.andThen (Dict.get userId)

        isAway =
            player |> Maybe.map (.presence >> (==) Player.Away) |> Maybe.withDefault False

        menuItems =
            if user.control == User.Human then
                let
                    privilegeMenuItems =
                        case localUserPrivilege of
                            User.Privileged ->
                                if localUserId /= userId then
                                    case user.privilege of
                                        User.Unprivileged ->
                                            [ Menu.button Icon.userPlus
                                                Strings.Promote
                                                Strings.Promote
                                                (SetPrivilege userId User.Privileged |> wrap |> Just)
                                                |> Just
                                            ]

                                        User.Privileged ->
                                            [ Menu.button
                                                Icon.userMinus
                                                Strings.Demote
                                                Strings.Demote
                                                (SetPrivilege userId User.Unprivileged |> wrap |> Just)
                                                |> Just
                                            ]

                                else
                                    []

                            User.Unprivileged ->
                                []

                    playerState =
                        if (localUserId == userId && not audienceMode) || localUserPrivilege == User.Privileged then
                            case user.role of
                                User.Player ->
                                    [ Menu.button Icon.eye
                                        Strings.BecomeSpectator
                                        Strings.BecomeSpectatorDescription
                                        (SetUserRole (Just userId) User.Spectator |> wrap |> Just)
                                        |> Just
                                    ]

                                User.Spectator ->
                                    [ Menu.button Icon.chessPawn
                                        Strings.BecomePlayer
                                        Strings.BecomePlayerDescription
                                        (SetUserRole (Just userId) User.Player |> wrap |> Just)
                                        |> Just
                                    ]

                        else
                            []

                    presenceMenuItems =
                        case user.presence of
                            User.Joined ->
                                let
                                    kickOrLeave =
                                        if userId == localUserId then
                                            Menu.button Icon.signOutAlt Strings.LeaveGame Strings.LeaveGame (Leave |> wrap |> Just) |> Just

                                        else
                                            case localUserPrivilege of
                                                User.Privileged ->
                                                    Menu.button Icon.ban Strings.KickUser Strings.KickUser (userId |> Kick |> wrap |> Just) |> Just

                                                User.Unprivileged ->
                                                    Nothing
                                in
                                let
                                    setAway =
                                        if userId == localUserId && game /= Nothing then
                                            setPresenceMenuItem wrap player |> Just

                                        else if not isAway && game /= Nothing then
                                            case localUserPrivilege of
                                                User.Privileged ->
                                                    Menu.button Icon.userClock Strings.SetAway Strings.SetAway (userId |> SetAway |> wrap |> Just) |> Just

                                                User.Unprivileged ->
                                                    Nothing

                                        else
                                            Nothing
                                in
                                [ setAway
                                , kickOrLeave
                                ]

                            User.Left ->
                                []
                in
                [ privilegeMenuItems
                , playerState
                , presenceMenuItems
                ]
                    |> List.filterMap (\part -> part |> List.filterMap identity |> (\l -> l |> Maybe.justIf (l |> List.isEmpty >> not)))
                    |> List.intersperse [ Menu.Separator ]
                    |> List.concat

            else
                []

        ( menu, attrs ) =
            if user.presence == User.Left || List.isEmpty menuItems then
                ( identity, [] )

            else
                let
                    isOpen =
                        Just userId == openUserMenu
                in
                ( \c ->
                    Menu.view shared
                        (SetUserMenuState userId Menu.Closed |> wrap)
                        (isOpen |> Menu.open)
                        Menu.BottomRight
                        c
                        menuItems
                , [ not isOpen |> Menu.open |> SetUserMenuState userId |> wrap |> HtmlE.onClick
                  , HtmlA.classList [ ( "active", isOpen ), ( "has-menu", True ) ]
                  ]
                )
    in
    ( userId
    , Html.li []
        [ Html.div
            (HtmlA.classList [ ( "user", True ), ( "you", localUserId == userId ), ( "away", isAway ) ] :: attrs)
            [ Html.div [ HtmlA.class "about" ]
                [ Html.div [ HtmlA.class "name", HtmlA.title user.name ] [ Html.text user.name ]
                , Html.div [ HtmlA.class "state", HtmlA.class "compressed-terms" ] secondary
                ]
            , Html.span [ HtmlA.class "scores" ] score
            ]
        , Html.div [] [] |> menu
        ]
    )


setPresenceMenuItem : (Msg -> msg) -> Maybe Player -> Menu.Part msg
setPresenceMenuItem wrap player =
    case player |> Maybe.map .presence of
        Just Player.Active ->
            Menu.button Icon.userClock Strings.SetAway Strings.SetAway (Player.Away |> Game.SetPresence |> GameMsg |> wrap |> Just)

        Just Player.Away ->
            Menu.button Icon.userCheck Strings.SetBack Strings.SetBack (Player.Active |> Game.SetPresence |> GameMsg |> wrap |> Just)

        Nothing ->
            Menu.button Icon.userClock Strings.SetAway Strings.SetAway Nothing


userDetails : Shared -> Maybe Game -> User.Id -> User -> ( List (Html msg), List (Html msg) )
userDetails shared game userId user =
    let
        player =
            game |> Maybe.map .players |> Maybe.andThen (Dict.get userId)

        round =
            game |> Maybe.map .round

        details =
            [ ( "privileged", Strings.Privileged ) |> Maybe.justIf (user.privilege == User.Privileged)
            , ( "ai", Strings.Ai ) |> Maybe.justIf (user.control == User.Computer)
            , round |> Maybe.andThen (\r -> ( "czar", Strings.Czar ) |> Maybe.justIf (Player.isCzar r userId))
            , ( "disconnected", Strings.Disconnected ) |> Maybe.justIf (user.connection == User.Disconnected && user.presence /= User.Left)
            , ( "away", Strings.Away ) |> Maybe.justIf ((player |> Maybe.map .presence) == Just Player.Away)
            , playStateDetail round userId
            ]

        score =
            player |> Maybe.map (\p -> ( "score", Strings.Score { total = p.score } ))

        likes =
            player |> Maybe.map (\p -> ( "likes", Strings.Likes { total = p.likes } ))
    in
    ( viewDetails shared details, viewDetails shared [ score, likes ] )


playStateDetail : Maybe Round -> User.Id -> Maybe ( String, MdString )
playStateDetail maybeRound userId =
    let
        givenRound round =
            case round.stage of
                Round.P stage ->
                    case Player.playState (Round.withStage stage round) userId of
                        Player.Playing ->
                            Just ( "playing", Strings.StillPlaying )

                        Player.Played ->
                            Just ( "played", Strings.Played )

                        Player.NotInRound ->
                            Nothing

                _ ->
                    Nothing
    in
    maybeRound |> Maybe.andThen givenRound


viewDetails : Shared -> List (Maybe ( String, MdString )) -> List (Html msg)
viewDetails shared =
    List.filterMap identity
        >> List.map (\( cls, str ) -> Html.span [ HtmlA.class cls ] [ str |> Lang.html shared ])


viewCastButton : (Msg -> msg) -> Shared -> Auth -> List (Html.Attribute msg) -> List (Html msg)
viewCastButton wrap shared auth attrs =
    [ Html.div (HtmlA.class "cast-button" :: attrs)
        [ IconButton.view shared
            Strings.Cast
            (Icon.chromecast |> Icon.present |> Icon.styled [ Icon.lg ] |> NeList.just)
            (auth |> TryCast |> wrap |> Just)
        ]
    ]
