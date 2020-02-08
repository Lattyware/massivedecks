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
import MassiveDecks.Components as Components
import MassiveDecks.Components.Menu as Menu
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
import MassiveDecks.Pages.Route as Route
import MassiveDecks.Pages.Spectate.Route as Spectate
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
import Weightless as Wl
import Weightless.Attributes as WlA


changeRoute : Route -> Model -> ( Model, Cmd msg )
changeRoute r model =
    ( { model | route = r, lobby = Nothing }, Cmd.none )


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
        |> Maybe.map (initWithAuth r >> Route.Continue)
        |> Maybe.withDefault (Route.Redirect (Route.Start { section = Start.Join (Just r.gameCode) }))


initWithAuth : Route -> Auth -> ( Model, Cmd msg )
initWithAuth r auth =
    ( { route = r
      , auth = auth
      , lobby = Nothing
      , configure = Configure.init
      , notificationId = 0
      , notifications = []
      , inviteDialogOpen = False
      , timeAnchor = Nothing
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
            (model.lobby |> Maybe.andThen .game)
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
            case model.lobby of
                Just l ->
                    case l.game of
                        Just g ->
                            let
                                ( updatedGame, gameCmd ) =
                                    Game.update (GameMsg >> wrap) shared gameMsg g
                            in
                            ( Stay { model | lobby = Just { l | game = Just updatedGame } }, shared, gameCmd )

                        Nothing ->
                            ( Stay model, shared, Cmd.none )

                Nothing ->
                    ( Stay model, shared, Cmd.none )

        EventReceived event ->
            case model.lobby of
                Just lobby ->
                    case event of
                        Events.Sync { state, hand, play, partialTimeAnchor } ->
                            applySync wrap shared model state hand play partialTimeAnchor

                        Events.Configured { change } ->
                            ( applyConfigured change model
                            , shared
                            , Cmd.none
                            )

                        Events.GameStarted { round, hand } ->
                            let
                                r =
                                    model.route

                                ( g, cmd ) =
                                    Game.applyGameStarted (GameMsg >> wrap) lobby round hand

                                newGame =
                                    Stay
                                        { model
                                            | lobby = Just { lobby | game = Just g }
                                            , route = { r | section = Just Play }
                                        }
                            in
                            ( newGame, shared, cmd )

                        Events.Game gameEvent ->
                            let
                                withGame game =
                                    let
                                        ( g, cmd ) =
                                            Game.applyGameEvent (GameMsg >> wrap) (EventReceived >> wrap) model.auth shared gameEvent game
                                    in
                                    ( Stay { model | lobby = Just { lobby | game = Just g } }, shared, cmd )
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
                            addNotification wrap shared message { model | lobby = Just { lobby | users = newUsers } }

                        Events.Presence { user, state } ->
                            case ( state, user == model.auth.claims.uid ) of
                                ( Events.UserLeft { reason }, True ) ->
                                    ( LeftGame model.auth.claims.gc reason, shared, Cmd.none )

                                _ ->
                                    let
                                        { newUsers, game, message } =
                                            case state of
                                                Events.UserJoined { name, privilege, control } ->
                                                    { newUsers =
                                                        Dict.insert
                                                            user
                                                            { name = name
                                                            , presence = User.Joined
                                                            , connection = User.Connected
                                                            , privilege = privilege
                                                            , role = User.Player
                                                            , control = control
                                                            }
                                                            lobby.users
                                                    , game = lobby.game |> Maybe.map (Game.hotJoinPlayer user)
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
                                        { model | lobby = Just { lobby | users = newUsers, game = game } }

                        Events.PrivilegeChanged { user, privilege } ->
                            let
                                users =
                                    lobby.users |> Dict.update user (Maybe.map (\u -> { u | privilege = privilege }))
                            in
                            ( Stay { model | lobby = Just { lobby | users = users } }, shared, Cmd.none )

                        Events.ErrorEncountered { error } ->
                            ( Stay { model | lobby = Just { lobby | errors = lobby.errors ++ [ error ] } }, shared, Cmd.none )

                Nothing ->
                    case event of
                        Events.Sync { state, hand, play, partialTimeAnchor } ->
                            applySync wrap shared model state hand play partialTimeAnchor

                        _ ->
                            ( Stay model, shared, Cmd.none )

        ErrorReceived error ->
            case error of
                MdError.Authentication reason ->
                    ( AuthError model.auth.claims.gc reason, shared, Cmd.none )

                MdError.ActionExecution (MdError.ConfigEditConflict _) ->
                    let
                        configure =
                            model.configure
                    in
                    addNotification wrap
                        shared
                        (Error error)
                        { model
                            | configure =
                                model.lobby
                                    |> Maybe.map (\l -> { configure | localConfig = l.config })
                                    |> Maybe.withDefault model.configure
                        }

                _ ->
                    addNotification wrap shared (Error error) model

        ConfigureMsg configureMsg ->
            case model.lobby of
                Just l ->
                    let
                        ( c, s, cmd ) =
                            Configure.update shared configureMsg model.configure l.config
                    in
                    ( Stay { model | configure = c }, s, cmd )

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
                    { r | section = Just s }
            in
            ( Stay { model | route = newRoute }, shared, newRoute |> Route.Lobby |> Route.url |> Navigation.replaceUrl shared.key )

        NoOp ->
            ( Stay model, shared, Cmd.none )


view : (Msg -> msg) -> (Settings.Msg -> msg) -> Shared -> Model -> List (Html msg)
view wrap wrapSettings shared model =
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
                |> Maybe.map (viewCastButton wrap model.auth)
                |> Maybe.withDefault []

        usersIcon =
            if usersShown then
                Icon.eyeSlash

            else
                Icon.users

        notifications =
            model.notifications |> List.map (keyedViewNotification wrap shared model.lobby)

        localUser =
            model.lobby |> Maybe.andThen (.users >> Dict.get model.auth.claims.uid)

        maybeGame =
            model.lobby |> Maybe.andThen .game

        localPlayer =
            maybeGame |> Maybe.andThen (.game >> .players >> Dict.get model.auth.claims.uid)
    in
    [ Html.div
        [ HtmlA.id "lobby"
        , HtmlA.classList [ ( "collapsed-users", not usersShown ) ]
        , shared.settings.settings.cardSize |> cardSizeToAttr
        ]
        (Html.div [ HtmlA.id "top-bar" ]
            [ Html.div [ HtmlA.class "left" ]
                (List.concat
                    [ [ Components.iconButtonStyled
                            [ HtmlE.onClick (usersShown |> not |> Settings.ChangeOpenUserList |> wrapSettings)
                            , Strings.ToggleUserList |> Lang.title shared
                            ]
                            ( [ Icon.lg ], usersIcon )
                      , lobbyMenu wrap shared model.route localUser localPlayer (maybeGame |> Maybe.map .game)
                      ]
                    , castButton
                    ]
                )
            , Html.div [] [ Settings.view wrapSettings shared ]
            ]
            :: HtmlK.ol [ HtmlA.class "notifications" ] notifications
            :: (model.lobby
                    |> Maybe.map2 (viewLobby wrap shared model.route model.configure model.auth) model.timeAnchor
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
        (model.lobby |> Maybe.andThen (.config >> .privacy >> .password))
        model.inviteDialogOpen
    ]



{- Private -}


cardSizeToAttr : Settings.CardSize -> Html.Attribute msg
cardSizeToAttr cardSize =
    case cardSize of
        Settings.Minimal ->
            HtmlA.class "minimal-card-size"

        Settings.Square ->
            HtmlA.class "square-card-size"

        Settings.Full ->
            HtmlA.nothing


lobbyMenu : (Msg -> msg) -> Shared -> Route -> Maybe User -> Maybe Player -> Maybe Game -> Html msg
lobbyMenu wrap shared r user player game =
    let
        id =
            "lobby-menu-button"

        lobbyMenuItems =
            [ Menu.button Icon.bullhorn Strings.InvitePlayers Strings.InvitePlayersDescription (ToggleInviteDialog |> wrap |> Just) ]

        setPresence =
            setPresenceMenuItem wrap player

        userLobbyMenuItems =
            [ setPresence
            , Menu.button Icon.signOutAlt Strings.LeaveGame Strings.LeaveGameDescription (Leave |> wrap |> Just)
            ]

        viewMenuItems =
            [ Menu.link Icon.tv Strings.Spectate Strings.SpectateDescription (r.gameCode |> Spectate.Route |> Route.Spectate |> Route.url |> Just)
            , case section r game of
                Configure ->
                    Menu.button Icon.play Strings.ViewGame Strings.ViewGameDescription (ChangeSection Play |> wrap |> Maybe.justIf (game /= Nothing))

                Play ->
                    Menu.button Icon.cog Strings.ViewConfgiuration Strings.ViewConfgiurationDescription (ChangeSection Configure |> wrap |> Just)
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
    Html.div []
        [ Components.iconButtonStyled [ HtmlA.id id, Strings.GameMenu |> Lang.title shared ]
            ( [ Icon.lg ], Icon.bars )
        , Menu.view shared id ( WlA.XCenter, WlA.YBottom ) ( WlA.XLeft, WlA.YTop ) separatedMenuItems
        ]


applyConfigured : Json.Patch -> Model -> Change
applyConfigured change oldModel =
    case oldModel.lobby of
        Just oldLobby ->
            let
                updatedConfig =
                    Configure.applyChange change oldLobby.config oldModel.configure
            in
            case updatedConfig of
                Ok ( config, model ) ->
                    { oldModel | lobby = Just { oldLobby | config = config }, configure = model } |> Stay

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
    -> Maybe (List Card.PotentiallyBlankResponse)
    -> Maybe (List Card.Played)
    -> Time.PartialAnchor
    -> ( Change, Shared, Cmd msg )
applySync wrap shared model state hand pick partialTimeAnchor =
    let
        play =
            pick |> Maybe.map (\cards -> { state = Round.Submitted, cards = cards }) |> Maybe.withDefault Round.noPick

        ( game, gameCmd ) =
            case state.game of
                Just g ->
                    let
                        ( newGame, cmd ) =
                            Game.init (GameMsg >> wrap) g.game (hand |> Maybe.withDefault []) play
                    in
                    ( Just newGame, cmd )

                Nothing ->
                    ( Nothing, Cmd.none )

        timeCmd =
            Time.anchor (SetTimeAnchor >> wrap) partialTimeAnchor

        configure =
            model.configure
    in
    ( Stay
        { model
            | lobby = Just { state | game = game }
            , configure = { configure | localConfig = state.config }
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
    Wl.card
        [ HtmlA.class "notification", animationState, class |> Maybe.map HtmlA.class |> Maybe.withDefault HtmlA.nothing ]
        [ Html.div [ HtmlA.class "content" ]
            [ Html.span [ HtmlA.class "icon" ] [ icon ]
            , Html.span [ HtmlA.class "message" ] [ message ]
            , Wl.button
                [ WlA.flat
                , WlA.inverted
                , notification |> Animated.Exit |> NotificationMsg |> wrap |> HtmlE.onClick
                , HtmlA.class "action"
                ]
                [ Strings.Dismiss |> Lang.html shared ]
            ]
        ]


username : Shared -> Maybe (Dict User.Id User) -> User.Id -> String
username shared users id =
    users
        |> Maybe.andThen (\u -> Dict.get id u)
        |> Maybe.map .name
        |> Maybe.withDefault (Strings.UnknownUser |> Lang.string shared)


viewLobby : (Msg -> msg) -> Shared -> Route -> Configure.Model -> Auth -> Time.Anchor -> Lobby -> List (Html msg)
viewLobby wrap shared r configure auth timeAnchor lobby =
    let
        game =
            lobby.game |> Maybe.map .game

        privileged =
            (lobby.users |> Dict.get auth.claims.uid |> Maybe.map .privilege) == Just User.Privileged

        canEdit =
            privileged && (game |> Maybe.map (.winner >> Maybe.isJust) |> Maybe.withDefault True)

        content =
            case section r (lobby.game |> Maybe.map .game) of
                Configure ->
                    Configure.view (ConfigureMsg >> wrap)
                        wrap
                        shared
                        (ChangeSection Play |> wrap |> Maybe.justIf (lobby.game /= Nothing))
                        canEdit
                        configure
                        auth.claims.gc
                        lobby

                Play ->
                    lobby.game
                        |> Maybe.map (Game.view (GameMsg >> wrap) shared auth timeAnchor lobby.name lobby.config lobby.users)
                        |> Maybe.withDefault (Html.div [] [ Strings.GameNotStartedError |> Lang.html shared ])
    in
    [ Html.div [ HtmlA.id "lobby-content" ]
        [ viewUsers wrap shared auth.claims.uid lobby.users game
        , Html.div [ HtmlA.id "scroll-frame" ] [ content ]
        , lobby.errors |> viewErrors shared
        ]
    ]


viewErrors : Shared -> List MdError.GameStateError -> Html msg
viewErrors shared errors =
    if errors |> List.isEmpty then
        Html.nothing

    else
        Html.div [ HtmlA.class "lobby-errors" ] (errors |> List.map (viewError shared))


viewError : Shared -> MdError.GameStateError -> Html msg
viewError shared error =
    error |> MdError.Game |> MdError.viewSpecific shared


section : Route -> Maybe Game -> Section
section r game =
    r.section |> Maybe.withDefault (game |> Maybe.map (always Play) |> Maybe.withDefault Configure)


viewUsers : (Msg -> msg) -> Shared -> User.Id -> Dict User.Id User -> Maybe Game -> Html msg
viewUsers wrap shared localUserId users game =
    let
        localUserPrivilege =
            users |> Dict.get localUserId |> Maybe.map .privilege |> Maybe.withDefault User.Unprivileged

        ( active, inactive ) =
            users |> Dict.toList |> List.partition (\( _, user ) -> user.presence == User.Joined)

        activeGroups =
            active |> byRole |> List.map (viewRoleGroup wrap shared localUserId localUserPrivilege game)

        inactiveGroup =
            if List.isEmpty inactive then
                []

            else
                [ viewUserListGroup wrap shared localUserId localUserPrivilege game ( ( "left", Strings.Left ), inactive ) ]

        groups =
            List.concat [ activeGroups, inactiveGroup ]
    in
    Wl.card [ HtmlA.id "users" ]
        [ Html.div [ HtmlA.class "collapsible" ] [ HtmlK.ol [] groups ] ]


viewRoleGroup : (Msg -> msg) -> Shared -> User.Id -> User.Privilege -> Maybe Game -> ( User.Role, List ( User.Id, User ) ) -> ( String, Html msg )
viewRoleGroup wrap shared localUserId localUserPrivilege game ( role, users ) =
    let
        idAndDescription =
            case role of
                User.Player ->
                    ( "players", Strings.Players )

                User.Spectator ->
                    ( "spectators", Strings.Spectators )
    in
    viewUserListGroup wrap shared localUserId localUserPrivilege game ( idAndDescription, users )


viewUserListGroup : (Msg -> msg) -> Shared -> User.Id -> User.Privilege -> Maybe Game -> ( ( String, MdString ), List ( User.Id, User ) ) -> ( String, Html msg )
viewUserListGroup wrap shared localUserId localUserPrivilege game ( ( id, description ), users ) =
    ( id
    , Html.li [ HtmlA.class id ]
        [ Html.span [] [ description |> Lang.html shared ]
        , HtmlK.ol [] (users |> List.map (viewUser wrap shared localUserId localUserPrivilege game))
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


viewUser : (Msg -> msg) -> Shared -> User.Id -> User.Privilege -> Maybe Game -> ( User.Id, User ) -> ( String, Html msg )
viewUser wrap shared localUserId localUserPrivilege game ( userId, user ) =
    let
        ( secondary, score ) =
            userDetails shared game userId user

        id =
            "user-" ++ userId

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
                                            [ Menu.button Icon.userPlus Strings.Promote Strings.Promote (SetPrivilege userId User.Privileged |> wrap |> Just) |> Just ]

                                        User.Privileged ->
                                            [ Menu.button Icon.userMinus Strings.Demote Strings.Demote (SetPrivilege userId User.Unprivileged |> wrap |> Just) |> Just ]

                                else
                                    []

                            User.Unprivileged ->
                                []

                    --playerState =
                    --    case user.role of
                    --        User.Player ->
                    --            [ Menu.button Icon.eye Strings.BecomeSpectator Strings.BecomeSpectatorDescription Nothing |> Just ]
                    --
                    --        User.Spectator ->
                    --            [ Menu.button Icon.chessPawn Strings.BecomePlayer Strings.BecomePlayerDescription Nothing |> Just ]
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
                                        if userId == localUserId then
                                            setPresenceMenuItem wrap player |> Just

                                        else if not isAway then
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

                --, playerState
                , presenceMenuItems
                ]
                    |> List.filterMap (\part -> part |> List.filterMap identity |> (\l -> l |> Maybe.justIf (l |> List.isEmpty >> not)))
                    |> List.intersperse [ Menu.Separator ]
                    |> List.concat

            else
                []

        ( menu, clickable ) =
            if user.presence == User.Left || List.isEmpty menuItems then
                ( Html.nothing, HtmlA.nothing )

            else
                ( menuItems |> Menu.view shared id ( WlA.XCenter, WlA.YBottom ) ( WlA.XCenter, WlA.YTop )
                , WlA.clickable
                )
    in
    ( userId
    , Html.li []
        [ Wl.listItem
            [ HtmlA.classList [ ( "you", localUserId == userId ), ( "away", isAway ) ]
            , clickable
            , HtmlA.id id
            ]
            [ Html.span [ HtmlA.class "user", HtmlA.title user.name ] [ Html.text user.name ]
            , Html.div [ HtmlA.class "compressed-terms" ] secondary
            , Html.span [ WlA.listItemSlot WlA.AfterItem ] score
            ]
        , menu
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
            [ Strings.Privileged |> Maybe.justIf (user.privilege == User.Privileged)
            , Strings.Ai |> Maybe.justIf (user.control == User.Computer)
            , round |> Maybe.andThen (\r -> Strings.Czar |> Maybe.justIf (Player.isCzar r userId))
            , Strings.Disconnected |> Maybe.justIf (user.connection == User.Disconnected && user.presence /= User.Left)
            , Strings.Away |> Maybe.justIf ((player |> Maybe.map .presence) == Just Player.Away)
            , playStateDetail round userId
            ]

        score =
            player |> Maybe.map (\p -> Strings.Score { total = p.score })

        likes =
            player |> Maybe.map (\p -> Strings.Likes { total = p.likes })
    in
    ( viewDetails shared details, viewDetails shared [ score, likes ] )


playStateDetail : Maybe Round -> User.Id -> Maybe MdString
playStateDetail round userId =
    case round of
        Just (Round.P p) ->
            case Player.playState p userId of
                Player.Playing ->
                    Just Strings.StillPlaying

                Player.Played ->
                    Just Strings.Played

                Player.NotInRound ->
                    Nothing

        _ ->
            Nothing


viewDetails : Shared -> List (Maybe MdString) -> List (Html msg)
viewDetails shared details =
    details |> List.filterMap identity |> List.map (Lang.html shared) |> List.intersperse (Html.text " ")


viewCastButton : (Msg -> msg) -> Auth -> List (Html.Attribute msg) -> List (Html msg)
viewCastButton wrap auth attrs =
    [ Components.iconButtonStyled
        (List.concat
            [ [ HtmlA.class "cast-button"
              , auth |> TryCast |> wrap |> HtmlE.onClick
              ]
            , attrs
            ]
        )
        ( [ Icon.lg ], Icon.chromecast )
    ]
