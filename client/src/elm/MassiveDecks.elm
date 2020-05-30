module MassiveDecks exposing (main)

import Browser
import Browser.Navigation as Navigation
import Html exposing (Html)
import Html.Attributes as HtmlA
import Http
import Json.Decode as Json
import MassiveDecks.Cast.Client as Cast
import MassiveDecks.Cast.Model as Cast
import MassiveDecks.Cast.Server as Cast
import MassiveDecks.Error.Messages as Error
import MassiveDecks.Error.Model as Error
import MassiveDecks.Error.Overlay as Overlay
import MassiveDecks.Messages exposing (..)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Models.Decoders as Decoders
import MassiveDecks.Notifications as Notifications
import MassiveDecks.Pages as Pages
import MassiveDecks.Pages.Loading as Loading
import MassiveDecks.Pages.Lobby as Lobby
import MassiveDecks.Pages.Lobby.GameCode as GameCode
import MassiveDecks.Pages.Lobby.Messages as Lobby
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Pages.Lobby.Route as Lobby
import MassiveDecks.Pages.Lobby.Token as Token
import MassiveDecks.Pages.Model as Pages exposing (Page)
import MassiveDecks.Pages.Route as Route exposing (Route)
import MassiveDecks.Pages.Start as Start
import MassiveDecks.Pages.Start.Route as Start
import MassiveDecks.Pages.Unknown as Unknown
import MassiveDecks.Requests.Api as Api
import MassiveDecks.Requests.Request as Request
import MassiveDecks.ServerConnection as ServerConnection
import MassiveDecks.Settings as Settings
import MassiveDecks.Settings.Messages as Settings
import MassiveDecks.Speech as Speech
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User
import MassiveDecks.Util.Url as Url
import Url exposing (Url)


type alias Model =
    { page : Page
    , shared : Shared
    , errorOverlay : Error.Overlay
    }


main : Program Json.Value Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }


init : Json.Value -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        route =
            Route.fromUrl url

        { settings, browserLanguages, remoteMode } =
            Json.decodeValue Decoders.flags flags
                |> Result.toMaybe
                |> Maybe.withDefault (Flags Nothing [] False)

        ( initialisedSettings, settingsCmd ) =
            Settings.init SettingsMsg (settings |> Maybe.withDefault Settings.defaults)

        ( speech, speechCmd ) =
            Speech.init

        shared =
            { language = Lang.defaultLanguage
            , key = key
            , origin = Url.origin url
            , settings = initialisedSettings
            , browserLanguage = Lang.findBestMatch browserLanguages
            , castStatus = Cast.NoDevicesAvailable
            , speech = speech
            , notifications = Notifications.init
            , remoteMode = remoteMode
            , sources = { builtIn = Nothing, manyDecks = Nothing, jsonAgainstHumanity = Nothing }
            }

        ( page, pageCmd ) =
            if not remoteMode then
                Pages.fromRoute shared Nothing route |> changePage shared

            else
                ( Pages.Loading, Cmd.none )

        sourceCmd =
            Request.map (Error.Add >> ErrorMsg) never UpdateSources |> Api.sourceInfo |> Http.request
    in
    ( { page = page, shared = shared, errorOverlay = Overlay.init }
    , Cmd.batch [ sourceCmd, pageCmd, settingsCmd, speechCmd ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Cast.subscriptions
        , Speech.subscriptions (Error.Json >> Error.Add >> ErrorMsg) SpeechMsg
        , Notifications.subscriptions (Error.Json >> Error.Add >> ErrorMsg) NotificationMsg
        , Cast.remoteControl RemoteCommand (Error.Json >> Error.Add >> ErrorMsg)
        , model.page |> Pages.subscriptions
        ]


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest urlRequest =
    case urlRequest of
        Browser.Internal url ->
            url |> Route.fromUrl |> ChangePage

        Browser.External _ ->
            -- We intentionally block external URLs. Use `Util.blankA` to make a link that opens in a new window.
            BlockedExternalUrl


onUrlChange : Url -> Msg
onUrlChange url =
    PageChanged url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        oldRoute =
            Pages.toRoute model.page
    in
    case msg of
        ChangePage route ->
            if oldRoute /= route then
                let
                    ( p, cmd ) =
                        changePageFromRoute model.shared route model.page
                in
                ( { model | page = p }, cmd )

            else
                ( model, Cmd.none )

        PageChanged url ->
            let
                route =
                    Route.fromUrl url

                ( page, pageCmd ) =
                    if oldRoute /= route then
                        Pages.fromRoute model.shared (Just model.page) route

                    else
                        ( model.page, Cmd.none )

                cutConnection =
                    case model.page of
                        Pages.Lobby _ ->
                            case page of
                                Pages.Lobby _ ->
                                    Cmd.none

                                _ ->
                                    ServerConnection.disconnect

                        _ ->
                            Cmd.none
            in
            ( { model | page = page }, Cmd.batch [ pageCmd, cutConnection ] )

        JoinLobby name auth ->
            let
                shared =
                    model.shared

                ( ( lobby, lobbyCmd ), ( settings, settingsCmd ) ) =
                    case Lobby.init shared { gameCode = auth.claims.gc, section = Nothing } (Just auth) of
                        Route.Continue ( continue, cmd ) ->
                            ( changePage shared ( continue |> Pages.Lobby, cmd )
                            , Settings.onJoinLobby auth name shared.settings
                            )

                        Route.Redirect redirect ->
                            ( changePageFromRoute model.shared redirect model.page
                            , ( shared.settings, Cmd.none )
                            )
            in
            ( { model
                | shared = { shared | settings = settings }
                , page = lobby
              }
            , Cmd.batch [ lobbyCmd, settingsCmd ]
            )

        UpdateToken auth ->
            let
                shared =
                    model.shared

                ( settings, cmd ) =
                    Settings.onTokenUpdate auth shared.settings
            in
            ( { model | shared = { shared | settings = settings } }, cmd )

        StartMsg startMsg ->
            case model.page of
                Pages.Start startModel ->
                    let
                        ( newStartModel, cmd ) =
                            Start.update model.shared startMsg startModel
                    in
                    ( { model | page = Pages.Start newStartModel }, cmd )

                _ ->
                    ( model, Cmd.none )

        SettingsMsg settingsMsg ->
            let
                shared =
                    model.shared

                ( s, cmd ) =
                    Settings.update shared settingsMsg
            in
            ( { model | shared = { shared | settings = s } }, cmd )

        LobbyMsg lobbyMsg ->
            case model.page of
                Pages.Lobby lobbyModel ->
                    handleLobbyMsg model lobbyMsg lobbyModel

                _ ->
                    ( model, Cmd.none )

        CastStatusUpdate status ->
            let
                shared =
                    model.shared
            in
            ( { model | shared = { shared | castStatus = status } }, Cmd.none )

        ErrorMsg errorMsg ->
            ( { model | errorOverlay = Overlay.update errorMsg model.errorOverlay }, Cmd.none )

        SpeechMsg speechMsg ->
            let
                oldShared =
                    model.shared
            in
            ( { model | shared = { oldShared | speech = Speech.update speechMsg model.shared.speech } }
            , Cmd.none
            )

        NotificationMsg notificationMsg ->
            let
                oldShared =
                    model.shared

                ( notifications, notificationsCmd ) =
                    Notifications.update model.shared.settings.settings.notifications notificationMsg model.shared.notifications
            in
            ( { model | shared = { oldShared | notifications = notifications } }, notificationsCmd )

        UpdateSources info ->
            let
                oldShared =
                    model.shared
            in
            ( { model | shared = { oldShared | sources = info } }, Cmd.none )

        Refresh ->
            ( model, Navigation.reload )

        -- TODO: Error? This would be an application error. It's pretty harmless though, probably not worth interrupting.
        BlockedExternalUrl ->
            ( model, Cmd.none )

        RemoteCommand remoteControlCommand ->
            case remoteControlCommand of
                Cast.Spectate { token, language } ->
                    case token |> Token.decode of
                        Ok auth ->
                            let
                                shared =
                                    model.shared

                                ( settings, settingsCmd ) =
                                    Settings.update model.shared (Settings.ChangeLang (Just language))

                                ( lobby, lobbyCmd ) =
                                    Lobby.initWithAuth shared { gameCode = auth.claims.gc, section = Just Lobby.Spectate } auth
                            in
                            ( { model
                                | page = Pages.Lobby lobby
                                , shared = { shared | settings = settings }
                              }
                            , Cmd.batch [ settingsCmd, lobbyCmd ]
                            )

                        Err tokenDecodeError ->
                            ( { model
                                | errorOverlay =
                                    Overlay.update (tokenDecodeError |> Error.Token |> Error.Add) model.errorOverlay
                              }
                            , Cmd.none
                            )


view : Model -> Browser.Document Msg
view model =
    let
        body =
            case model.page of
                Pages.Start m ->
                    Start.view model.shared m

                Pages.Lobby m ->
                    Lobby.view LobbyMsg SettingsMsg ChangePage model.shared m

                Pages.Unknown m ->
                    Unknown.view model.shared m

                Pages.Loading ->
                    Loading.view

        settingsPanel =
            case model.page of
                Pages.Start _ ->
                    [ Html.div [ HtmlA.class "start-settings" ] [ Settings.view SettingsMsg model.shared ] ]

                _ ->
                    []

        errorOverlay =
            Overlay.view model.shared (Pages.toRoute model.page) model.errorOverlay

        defaultTitle =
            Lang.string model.shared Strings.MassiveDecks

        title =
            case model.page of
                Pages.Lobby m ->
                    m.lobbyAndConfigure |> Maybe.map (\l -> l.lobby.config.name ++ " (" ++ (m.auth.claims.gc |> GameCode.toString) ++ ")")

                _ ->
                    Nothing
    in
    { title = title |> Maybe.withDefault defaultTitle
    , body = List.concat [ settingsPanel, errorOverlay, body ]
    }



{- Private -}


handleLobbyMsg : Model -> Lobby.Msg -> Lobby.Model -> ( Model, Cmd Msg )
handleLobbyMsg baseModel lobbyMsg lobbyModel =
    let
        ( change, shared, lobbyCmd ) =
            Lobby.update LobbyMsg baseModel.shared lobbyMsg lobbyModel

        model =
            { baseModel | shared = shared }
    in
    case change of
        Lobby.Stay newLobbyModel ->
            ( { model | page = Pages.Lobby newLobbyModel }, lobbyCmd )

        Lobby.JoinError gc error ->
            let
                ( page, changePageCmd ) =
                    Start.initWithError shared gc error

                urlCommand =
                    page |> .route |> Route.Start |> Route.url |> Navigation.pushUrl shared.key

                ( settings, settingsCmd ) =
                    Settings.removeToken gc shared.settings
            in
            ( { model | page = Pages.Start page, shared = { shared | settings = settings } }
            , Cmd.batch [ lobbyCmd, settingsCmd, changePageCmd, urlCommand ]
            )

        Lobby.LeftGame gc leaveReason ->
            let
                ( initialPage, changePageCmd ) =
                    Start.init shared { section = Start.New }

                page =
                    case leaveReason of
                        User.Kicked ->
                            { initialPage | overlay = Just Strings.YouWereKicked }

                        _ ->
                            initialPage

                urlCommand =
                    page |> .route |> Route.Start |> Route.url |> Navigation.pushUrl shared.key

                ( settings, settingsCmd ) =
                    Settings.removeToken gc shared.settings
            in
            ( { model | page = Pages.Start page, shared = { shared | settings = settings } }
            , Cmd.batch [ lobbyCmd, settingsCmd, changePageCmd, urlCommand ]
            )

        Lobby.ConfigError error ->
            let
                overlay =
                    model.errorOverlay
            in
            ( { model | errorOverlay = { overlay | errors = overlay.errors ++ [ error ] } }
            , Cmd.none
            )


changePageFromRoute : Shared -> Route -> Page -> ( Page, Cmd Msg )
changePageFromRoute shared route oldPage =
    Pages.fromRoute shared (Just oldPage) route |> changePage shared


changePage : Shared -> ( Page, Cmd Msg ) -> ( Page, Cmd Msg )
changePage shared ( page, cmd ) =
    ( page, Cmd.batch [ page |> Pages.toRoute |> Route.url |> Navigation.pushUrl shared.key, cmd ] )
