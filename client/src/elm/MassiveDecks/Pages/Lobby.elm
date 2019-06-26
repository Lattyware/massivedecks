module MassiveDecks.Pages.Lobby exposing
    ( changeRoute
    , init
    , route
    , subscriptions
    , update
    , view
    )

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
import MassiveDecks.Animated as Animated exposing (Animated)
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Parts as Parts
import MassiveDecks.Cast.Model as Cast
import MassiveDecks.Components as Components
import MassiveDecks.Components.Menu as Menu
import MassiveDecks.Error.Messages as Error
import MassiveDecks.Error.Model as Error
import MassiveDecks.Game as Game
import MassiveDecks.Game.Model as Game exposing (Game)
import MassiveDecks.Game.Player as Player exposing (Player)
import MassiveDecks.Game.Round as Round exposing (Round)
import MassiveDecks.Messages as Global
import MassiveDecks.Model exposing (..)
import MassiveDecks.Models.MdError as MdError
import MassiveDecks.Pages.Lobby.Configure as Configure
import MassiveDecks.Pages.Lobby.Configure.Model as Configure exposing (Config)
import MassiveDecks.Pages.Lobby.Events as Events
import MassiveDecks.Pages.Lobby.GameCode as GameCode
import MassiveDecks.Pages.Lobby.Invite as Invite
import MassiveDecks.Pages.Lobby.Messages exposing (..)
import MassiveDecks.Pages.Lobby.Model exposing (..)
import MassiveDecks.Pages.Lobby.Route exposing (..)
import MassiveDecks.Pages.Route as Route
import MassiveDecks.Pages.Start.Route as Start
import MassiveDecks.ServerConnection as ServerConnection
import MassiveDecks.Settings as Settings
import MassiveDecks.Settings.Messages as Settings
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util as Util
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Maybe as Maybe
import Weightless as Wl
import Weightless.Attributes as WlA


changeRoute : Route -> Model -> ( Model, Cmd Global.Msg )
changeRoute r model =
    ( { model | route = r, lobby = Nothing, selectedUser = Nothing }, Cmd.none )


init : Shared -> Route -> Maybe Auth -> Route.Fork ( Model, Cmd Global.Msg )
init shared r auth =
    let
        fallbackAuth =
            Maybe.first
                [ auth |> Maybe.andThen (Maybe.validate (\a -> a.claims.gc == r.gameCode))
                , Settings.auths shared.settings.settings |> Dict.get (r.gameCode |> GameCode.toString)
                ]
    in
    fallbackAuth
        |> Maybe.map
            (\a ->
                Route.Continue
                    ( { route = r
                      , auth = a
                      , lobby = Nothing
                      , selectedUser = Nothing
                      , configure = Configure.init
                      , notificationId = 0
                      , notifications = []
                      , inviteDialogOpen = False
                      }
                    , ServerConnection.connect a.claims.gc a.token
                    )
            )
        |> Maybe.withDefault (Route.Redirect (Route.Start { section = Start.Join (Just r.gameCode) }))


route : Model -> Route
route model =
    model.route


subscriptions : Model -> Sub Global.Msg
subscriptions model =
    Sub.batch
        [ model.lobby |> Maybe.andThen .game |> Maybe.map Game.subscriptions |> Maybe.withDefault Sub.none
        , model.notifications |> Animated.subscriptions |> Sub.map (NotificationMsg >> Global.LobbyMsg)
        , ServerConnection.notifications
            (EventReceived >> Global.LobbyMsg)
            (ErrorReceived >> Global.LobbyMsg)
            (Error.Json >> Error.Add >> Global.ErrorMsg)
        ]


update : Msg -> Model -> ( Model, Cmd Global.Msg )
update msg model =
    case msg of
        SelectUser user ->
            ( { model | selectedUser = user }, Cmd.none )

        GameMsg gameMsg ->
            case model.lobby of
                Just l ->
                    l.game
                        |> Maybe.map
                            (Game.update gameMsg
                                >> Util.modelLift (\newGame -> { model | lobby = Just { l | game = Just newGame } })
                            )
                        |> Maybe.withDefault ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        EventReceived event ->
            case model.lobby of
                Just lobby ->
                    case event of
                        Events.Sync { state, hand, play } ->
                            applySync model state hand play

                        Events.Configured configured ->
                            ( model.lobby
                                |> Maybe.map (\l -> applyConfigured configured l model)
                                |> Maybe.withDefault model
                            , Cmd.none
                            )

                        Events.GameStarted { round, hand } ->
                            Util.modelLift
                                (\g -> { model | lobby = Just { lobby | game = Just g } })
                                (Game.applyGameStarted lobby round hand)

                        Events.Game gameEvent ->
                            lobby.game
                                |> Maybe.map
                                    (\game ->
                                        Util.modelLift
                                            (\g -> { model | lobby = Just { lobby | game = Just g } })
                                            (Game.applyGameEvent gameEvent game)
                                    )
                                |> Maybe.withDefault ( model, Cmd.none )

                        Events.Connection { user, state } ->
                            let
                                message =
                                    case state of
                                        User.Connected ->
                                            UserConnected user

                                        User.Disconnected ->
                                            UserDisconnected user
                            in
                            addNotification message model

                        Events.Presence { user, state } ->
                            let
                                newUsers =
                                    case state of
                                        Events.UserJoined { name } ->
                                            Dict.insert
                                                user
                                                { name = name
                                                , presence = User.Joined
                                                , connection = User.Connected
                                                , privilege = User.Unprivileged
                                                , role = User.Player
                                                }
                                                lobby.users

                                        Events.UserLeft ->
                                            Dict.remove user lobby.users

                                message =
                                    case state of
                                        Events.UserJoined _ ->
                                            UserJoined user

                                        Events.UserLeft ->
                                            UserLeft user
                            in
                            addNotification message { model | lobby = Just { lobby | users = newUsers } }

                Nothing ->
                    case event of
                        Events.Sync { state, hand, play } ->
                            applySync model state hand play

                        _ ->
                            ( model, Cmd.none )

        ErrorReceived error ->
            case error of
                MdError.Authentication reason ->
                    ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ConfigureMsg configureMsg ->
            case model.lobby of
                Just l ->
                    Util.modelLift (\c -> { model | configure = c })
                        (Configure.update configureMsg model.configure l.config)

                Nothing ->
                    ( model, Cmd.none )

        NotificationMsg notificationMsg ->
            Util.lift
                (\notifications -> { model | notifications = notifications })
                (NotificationMsg >> Global.LobbyMsg)
                (Animated.update { removeDone = Just notificationAnimationDuration } notificationMsg model.notifications)

        ToggleInviteDialog ->
            ( { model | inviteDialogOpen = not model.inviteDialogOpen }, Cmd.none )


view : Shared -> Model -> List (Html Global.Msg)
view shared model =
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
                |> Maybe.map (viewCastButton model.auth)
                |> Maybe.withDefault []

        usersIcon =
            if usersShown then
                Icon.eyeSlash

            else
                Icon.users

        title =
            model.lobby
                |> Maybe.andThen .game
                |> Maybe.map (.game >> .round >> Round.data >> .call >> .body >> Parts.viewSingleLine)

        notifications =
            model.notifications |> List.map (keyedViewNotification shared model.lobby)
    in
    [ Html.div
        [ HtmlA.classList
            [ ( "lobby", True )
            , ( "compact-cards", shared.settings.settings.compactCards )
            ]
        ]
        [ Html.div [ HtmlA.id "top-bar" ]
            [ Html.div [ HtmlA.class "left" ]
                (List.concat
                    [ [ Components.iconButtonStyled
                            [ HtmlE.onClick (usersShown |> not |> Settings.ChangeOpenUserList |> Global.SettingsMsg)
                            , Strings.ToggleUserList |> Lang.title shared
                            ]
                            ( [ Icon.lg ], usersIcon )
                      , gameMenu shared
                      ]
                    , castButton
                    ]
                )
            , title |> Maybe.map (Html.div [ HtmlA.class "title-call" ]) |> Maybe.withDefault Html.nothing
            , Html.div [] [ Settings.view shared ]
            ]
        , model.lobby
            |> Maybe.map (viewLobby shared model.configure usersShown model.auth model.selectedUser)
            |> Maybe.withDefault
                (Html.div [ HtmlA.class "loading" ]
                    [ Icon.viewStyled [ Icon.spin, Icon.fa3x ] Icon.circleNotch ]
                )
        , HtmlK.ol [ HtmlA.class "notifications" ] notifications
        ]
    , Invite.dialog shared
        model.auth.claims.gc
        (model.lobby |> Maybe.andThen (.config >> .password))
        model.inviteDialogOpen
    ]



{- Private -}


gameMenu : Shared -> Html Global.Msg
gameMenu shared =
    let
        id =
            "game-menu-button"

        menuItems =
            [ Menu.button Icon.bullhorn Strings.InvitePlayers Strings.InvitePlayers (ToggleInviteDialog |> Global.LobbyMsg |> Just)
            , Menu.Separator
            , Menu.button Icon.userClock Strings.SetAway Strings.SetAway Nothing
            , Menu.button Icon.signOutAlt Strings.LeaveGame Strings.LeaveGame Nothing
            , Menu.Separator
            , Menu.link Icon.info Strings.AboutTheGame Strings.AboutTheGame (Just "https://github.com/lattyware/massivedecks")
            , Menu.link Icon.bug Strings.ReportError Strings.ReportError (Just "https://github.com/Lattyware/massivedecks/issues/new")
            ]
    in
    Html.div []
        [ Components.iconButtonStyled [ HtmlA.id id, Strings.GameMenu |> Lang.title shared ]
            ( [ Icon.lg ], Icon.bars )
        , Menu.view shared id WlA.XCenter WlA.YBottom menuItems
        ]


applyConfigured : { change : Events.ConfigChanged, version : String } -> Lobby -> Model -> Model
applyConfigured { change, version } oldLobby oldModel =
    let
        ( config, configure ) =
            Configure.applyChange change oldLobby.config oldModel.configure

        lobby =
            Just { oldLobby | config = { config | version = version } }
    in
    { oldModel | lobby = lobby, configure = configure }


notificationDuration : Int
notificationDuration =
    3500


notificationAnimationDuration : Int
notificationAnimationDuration =
    200


applySync : Model -> Lobby -> Maybe (List Card.Response) -> Maybe (List Card.Id) -> ( Model, Cmd Global.Msg )
applySync model state hand pick =
    let
        play =
            pick |> Maybe.map (\cards -> { state = Round.Submitted, cards = cards }) |> Maybe.withDefault Round.noPick

        ( game, cmd ) =
            case state.game of
                Just g ->
                    Util.modelLift Just (Game.init g.game (hand |> Maybe.withDefault []) play)

                Nothing ->
                    ( Nothing, Cmd.none )
    in
    ( { model
        | lobby = Just { state | game = game }
        , configure = Configure.updateFromConfig state.config model.configure
      }
    , cmd
    )


addNotification : NotificationMessage -> Model -> ( Model, Cmd Global.Msg )
addNotification message model =
    let
        notification =
            { id = model.notificationId, message = message }

        notifications =
            model.notifications ++ [ Animated.animate notification ]
    in
    ( { model | notifications = notifications, notificationId = model.notificationId + 1 }
    , Animated.exitAfter notificationDuration notification
        |> Cmd.map (NotificationMsg >> Global.LobbyMsg)
    )


keyedViewNotification : Shared -> Maybe Lobby -> Animated Notification -> ( String, Html Global.Msg )
keyedViewNotification shared lobby notification =
    ( String.fromInt notification.item.id
    , Html.li [] [ Animated.view (viewNotification shared (lobby |> Maybe.map .users)) notification ]
    )


viewNotification : Shared -> Maybe (Dict User.Id User) -> Html.Attribute Global.Msg -> Notification -> Html Global.Msg
viewNotification shared users animationState notification =
    let
        ( icon, message ) =
            case notification.message of
                UserConnected id ->
                    ( Icon.view Icon.plug
                    , Strings.UserConnected { username = username shared users id } |> Lang.html shared
                    )

                UserDisconnected id ->
                    ( Icon.layers [] [ Icon.view Icon.plug, Icon.view Icon.slash ]
                    , Strings.UserDisconnected { username = username shared users id } |> Lang.html shared
                    )

                UserJoined id ->
                    ( Icon.view Icon.signInAlt
                    , Strings.UserJoined { username = username shared users id } |> Lang.html shared
                    )

                UserLeft id ->
                    ( Icon.view Icon.signOutAlt
                    , Strings.UserLeft { username = username shared users id } |> Lang.html shared
                    )
    in
    Wl.card
        [ HtmlA.class "notification", animationState ]
        [ Html.div [ HtmlA.class "content" ]
            [ Html.span [ HtmlA.class "icon" ] [ icon ]
            , Html.span [ HtmlA.class "message" ] [ message ]
            , Wl.button
                [ WlA.flat
                , WlA.inverted
                , notification |> Animated.Exit |> NotificationMsg |> Global.LobbyMsg |> HtmlE.onClick
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


viewLobby : Shared -> Configure.Model -> Bool -> Auth -> Maybe User.Id -> Lobby -> Html Global.Msg
viewLobby shared configure usersShown auth selectedUser lobby =
    let
        game =
            lobby.game |> Maybe.map .game

        privileged =
            auth.claims.pvg == User.Privileged

        content =
            [ viewUsers shared auth.claims.uid selectedUser lobby.users game
            , Html.div [ HtmlA.id "scroll-frame" ]
                [ lobby.game
                    |> Maybe.map (Game.view shared auth lobby.config.decks lobby.users)
                    |> Maybe.withDefault (Configure.view shared privileged configure auth.claims.gc lobby lobby.config)
                ]
            ]
    in
    Html.div [ HtmlA.classList [ ( "content-wrapper", True ), ( "collapsed-users", not usersShown ) ] ] content


viewUsers : Shared -> User.Id -> Maybe User.Id -> Dict User.Id User -> Maybe Game -> Html Global.Msg
viewUsers shared player selectedUser users game =
    Wl.card [ HtmlA.class "users" ]
        [ Html.div [ HtmlA.class "collapsible" ]
            [ users
                |> Dict.toList
                |> byRole
                |> List.map (viewRoleGroup shared player selectedUser game)
                |> HtmlK.ol []
            ]
        ]


viewRoleGroup : Shared -> User.Id -> Maybe User.Id -> Maybe Game -> ( User.Role, List ( User.Id, User ) ) -> ( String, Html Global.Msg )
viewRoleGroup shared player selectedUser game ( role, users ) =
    ( role |> roleId
    , Html.li []
        [ Html.span [] [ role |> roleDescription |> Lang.html shared ]
        , HtmlK.ol [] (users |> List.map (viewUser shared player selectedUser game))
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


viewUser : Shared -> User.Id -> Maybe User.Id -> Maybe Game -> ( User.Id, User ) -> ( String, Html Global.Msg )
viewUser shared player selectedUser game ( userId, user ) =
    let
        ( secondary, score ) =
            userDetails shared game userId user

        id =
            "user-" ++ userId

        menuItems =
            [ Menu.button Icon.userCog Strings.Promote Strings.Promote Nothing
            , Menu.Separator
            , Menu.button Icon.userClock Strings.SetAway Strings.SetAway Nothing
            , Menu.button Icon.ban Strings.KickUser Strings.KickUser Nothing
            ]
    in
    ( userId
    , Html.li []
        [ Wl.listItem
            [ Just userId |> SelectUser |> Global.LobbyMsg |> HtmlE.onClick
            , HtmlA.classList [ ( "mdc-menu-surface--anchor", True ), ( "you", player == userId ) ]
            , WlA.clickable
            , HtmlA.id id
            ]
            [ Html.div [ HtmlA.class "user compressed-terms" ]
                (Html.span [ HtmlA.title user.name ] [ Html.text user.name ]
                    :: secondary
                )
            , Html.span [ WlA.listItemSlot WlA.AfterItem ] score
            ]
        , Menu.view shared id WlA.XRight WlA.YTop menuItems
        ]
    )


userDetails : Shared -> Maybe Game -> User.Id -> User -> ( List (Html Global.Msg), List (Html Global.Msg) )
userDetails shared game userId user =
    let
        player =
            game |> Maybe.map .players |> Maybe.andThen (Dict.get userId)

        round =
            game |> Maybe.map .round

        details =
            [ Strings.Privileged |> Maybe.justIf (user.privilege == User.Privileged)
            , player |> Maybe.andThen (\p -> Strings.Ai |> Maybe.justIf (p.control == Player.Computer))
            , round |> Maybe.andThen (\r -> Strings.Czar |> Maybe.justIf (Player.isCzar r userId))
            , playStateDetail round userId
            ]

        score =
            player |> Maybe.map (\p -> Strings.Score { total = p.score })
    in
    ( viewDetails shared details, viewDetails shared [ score ] )


playStateDetail : Maybe Round -> User.Id -> Maybe MdString
playStateDetail round userId =
    case round of
        Just (Round.P p) ->
            case Player.playState p userId of
                Player.Playing ->
                    Just Strings.Playing

                Player.Played ->
                    Just Strings.Played

                Player.NotInRound ->
                    Nothing

        _ ->
            Nothing


viewDetails : Shared -> List (Maybe MdString) -> List (Html Global.Msg)
viewDetails shared details =
    details |> List.filterMap identity |> List.map (Lang.html shared) |> List.intersperse (Html.text " ")


roleDescription : User.Role -> Strings.MdString
roleDescription role =
    case role of
        User.Player ->
            Strings.Players

        User.Spectator ->
            Strings.Spectators


roleId : User.Role -> String
roleId role =
    case role of
        User.Player ->
            "players"

        User.Spectator ->
            "spectators"


viewCastButton : Auth -> List (Html.Attribute Global.Msg) -> List (Html Global.Msg)
viewCastButton auth attrs =
    [ Components.iconButtonStyled
        (List.concat
            [ [ HtmlA.class "cast-button"
              , auth |> Global.TryCast |> HtmlE.onClick
              ]
            , attrs
            ]
        )
        ( [ Icon.lg ], Icon.chromecast )
    ]
