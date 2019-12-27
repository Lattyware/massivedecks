module MassiveDecks exposing (main)

import Browser
import Browser.Navigation as Navigation
import Html exposing (Html)
import Html.Attributes as HtmlA
import Json.Decode as Json
import MassiveDecks.Cast.Client as Cast
import MassiveDecks.Cast.Model as Cast
import MassiveDecks.Error.Model as Error
import MassiveDecks.Error.Overlay as Overlay
import MassiveDecks.Messages exposing (..)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Models.Decoders as Decoders
import MassiveDecks.Pages as Pages
import MassiveDecks.Pages.Lobby as Lobby
import MassiveDecks.Pages.Lobby.GameCode as GameCode
import MassiveDecks.Pages.Model as Pages exposing (Page)
import MassiveDecks.Pages.Route as Route exposing (Route)
import MassiveDecks.Pages.Spectate as Spectate
import MassiveDecks.Pages.Start as Start
import MassiveDecks.Pages.Unknown as Unknown
import MassiveDecks.Ports as Ports
import MassiveDecks.ServerConnection as ServerConnection
import MassiveDecks.Settings as Settings
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util as Util
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

        { settings, browserLanguages } =
            Json.decodeValue Decoders.flags flags
                |> Result.toMaybe
                |> Maybe.withDefault (Flags Settings.defaults [])

        ( initialisedSettings, settingsCmd ) =
            Settings.init settings

        shared =
            { language = Lang.defaultLanguage
            , key = key
            , origin = Url.origin url
            , settings = initialisedSettings
            , browserLanguage = Lang.findBestMatch browserLanguages
            , castStatus = Cast.NoDevicesAvailable
            }

        ( page, pageCmd ) =
            Pages.fromRoute shared Nothing route |> changePage shared
    in
    ( { page = page, shared = shared, errorOverlay = Overlay.init }, Cmd.batch [ pageCmd, settingsCmd ] )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Cast.subscriptions
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
                changePageFromRoute model.shared route model.page
                    |> Util.modelLift (\p -> { model | page = p })

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
                    case Lobby.init shared { gameCode = auth.claims.gc } (Just auth) of
                        Route.Continue continue ->
                            ( continue |> Util.modelLift Pages.Lobby |> changePage shared
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
            in
            Util.modelLift (\settings -> { model | shared = { shared | settings = settings } })
                (Settings.onTokenUpdate auth shared.settings)

        StartMsg startMsg ->
            case model.page of
                Pages.Start startModel ->
                    Util.modelLift (\newStartModel -> { model | page = Pages.Start newStartModel })
                        (Start.update startMsg startModel)

                _ ->
                    ( model, Cmd.none )

        SpectateMsg spectateMsg ->
            case model.page of
                Pages.Spectate spectateModel ->
                    Util.modelLift (\newSpectateModel -> { model | page = Pages.Spectate newSpectateModel })
                        (Spectate.update spectateMsg spectateModel)

                _ ->
                    ( model, Cmd.none )

        SettingsMsg settingsMsg ->
            let
                shared =
                    model.shared
            in
            Settings.update settingsMsg shared.settings
                |> Util.lift (\s -> { model | shared = { shared | settings = s } }) SettingsMsg

        LobbyMsg lobbyMsg ->
            case model.page of
                Pages.Lobby lobbyModel ->
                    Lobby.update model.shared.key lobbyMsg lobbyModel
                        |> Util.modelLift (\newLobbyModel -> { model | page = Pages.Lobby newLobbyModel })

                _ ->
                    ( model, Cmd.none )

        CastStatusUpdate status ->
            let
                shared =
                    model.shared
            in
            ( { model | shared = { shared | castStatus = status } }, Cmd.none )

        TryCast auth ->
            ( model, Cast.tryCast model.shared auth.token )

        ErrorMsg errorMsg ->
            Overlay.update errorMsg model.errorOverlay
                |> Util.modelLift (\o -> { model | errorOverlay = o })

        Refresh ->
            ( model, Navigation.reload )

        -- TODO: Error? This would be an application error. It's pretty harmless though, probably not worth interrupting.
        BlockedExternalUrl ->
            ( model, Cmd.none )

        Copy id ->
            ( model, Ports.copyText id )

        NoOp ->
            ( model, Cmd.none )

        Batch messages ->
            Util.batchUpdate messages model update


view : Model -> Browser.Document Msg
view model =
    let
        body =
            case model.page of
                Pages.Start m ->
                    Start.view model.shared m

                Pages.Lobby m ->
                    Lobby.view model.shared m

                Pages.Spectate m ->
                    Spectate.view model.shared m

                Pages.Unknown m ->
                    Unknown.view model.shared m

        settingsPanel =
            case model.page of
                Pages.Start _ ->
                    [ Html.div [ HtmlA.class "start-settings" ] [ Settings.view model.shared ] ]

                _ ->
                    []

        errorOverlay =
            Overlay.view model.shared (Pages.toRoute model.page) model.errorOverlay

        defaultTitle =
            Lang.string model.shared Strings.MassiveDecks

        title =
            case model.page of
                Pages.Lobby m ->
                    m.lobby |> Maybe.map (\l -> l.name ++ " (" ++ (m.auth.claims.gc |> GameCode.toString) ++ ")")

                _ ->
                    Nothing
    in
    { title = title |> Maybe.withDefault defaultTitle
    , body = List.concat [ settingsPanel, errorOverlay, body ]
    }



{- Private -}


changePageFromRoute : Shared -> Route -> Page -> ( Page, Cmd Msg )
changePageFromRoute shared route oldPage =
    Pages.fromRoute shared (Just oldPage) route |> changePage shared


changePage : Shared -> ( Page, Cmd Msg ) -> ( Page, Cmd Msg )
changePage shared ( page, cmd ) =
    ( page, Cmd.batch [ page |> Pages.toRoute |> Route.url |> Navigation.pushUrl shared.key, cmd ] )
