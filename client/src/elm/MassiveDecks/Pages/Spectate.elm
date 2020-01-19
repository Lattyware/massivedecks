module MassiveDecks.Pages.Spectate exposing
    ( changeRoute
    , init
    , initWithAuth
    , route
    , subscriptions
    , update
    , view
    )

import FontAwesome.Attributes as Icon
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Error.Model exposing (Error)
import MassiveDecks.Messages as Global
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby as Lobby
import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Model as Lobby exposing (Auth)
import MassiveDecks.Pages.Route as Route
import MassiveDecks.Pages.Spectate.Messages exposing (Msg(..))
import MassiveDecks.Pages.Spectate.Model exposing (Model)
import MassiveDecks.Pages.Spectate.Route exposing (Route)
import MassiveDecks.Pages.Spectate.Stages.Postgame as Postgame
import MassiveDecks.Pages.Spectate.Stages.Pregame as Pregame
import MassiveDecks.Pages.Spectate.Stages.Round as Round
import MassiveDecks.Pages.Start.Route as Start
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import QRCode
import Url exposing (Url)


changeRoute : Route -> Model -> ( Model, Cmd Global.Msg )
changeRoute r model =
    let
        ( lobby, cmd ) =
            Lobby.changeRoute r.lobby model.lobby
    in
    ( { model | lobby = lobby }, cmd )


route : Model -> Route
route model =
    { lobby = model.lobby.route }


init : Shared -> Route -> Maybe Auth -> Route.Fork ( Model, Cmd Global.Msg )
init shared initialRoute auth =
    case Lobby.init shared initialRoute.lobby auth of
        Route.Continue ( lobby, cmd ) ->
            Route.Continue ( { lobby = lobby, advertise = True }, cmd )

        Route.Redirect redirectTo ->
            Route.Redirect redirectTo


initWithAuth : Auth -> ( Model, Cmd Global.Msg )
initWithAuth auth =
    let
        ( lobby, cmd ) =
            Lobby.initWithAuth { gameCode = auth.claims.gc } auth
    in
    ( { lobby = lobby, advertise = True }, cmd )


view : Shared -> Model -> List (Html msg)
view shared model =
    let
        advert =
            if model.advertise then
                advertise shared model.lobby.route.gameCode

            else
                []
    in
    [ Html.div [ HtmlA.id "spectate" ]
        (List.concat
            [ advert
            , viewStage shared model
            ]
        )
    ]


subscriptions : (Msg -> msg) -> (Error -> msg) -> Model -> Sub msg
subscriptions wrap handleError model =
    Lobby.subscriptions (LobbyMsg >> wrap) handleError model.lobby


update : (Msg -> msg) -> Shared -> Msg -> Model -> ( Model, Cmd msg )
update wrap shared msg model =
    case msg of
        LobbyMsg lobbyMsg ->
            case Lobby.update (LobbyMsg >> wrap) shared lobbyMsg model.lobby of
                ( Lobby.Stay newModel, cmd ) ->
                    ( { model | lobby = newModel }, cmd )

                _ ->
                    ( model, Cmd.none )



{- Private -}


viewStage : Shared -> Model -> List (Html msg)
viewStage shared model =
    case model.lobby.lobby of
        Just lobby ->
            case lobby.game of
                Just game ->
                    case game.game.winner of
                        Just winner ->
                            Postgame.view shared lobby game.game winner

                        Nothing ->
                            Round.view shared lobby.config lobby.users game

                Nothing ->
                    Pregame.view shared lobby

        Nothing ->
            [ Icon.viewStyled [ Icon.spin ] Icon.sync ]


advertise : Shared -> GameCode -> List (Html msg)
advertise shared gameCode =
    let
        qr =
            Route.externalUrl shared.origin (Route.Start { section = Start.Join (Just gameCode) })
                |> QRCode.encodeWith QRCode.Low
                |> Result.map (\encoded -> [ QRCode.toSvg encoded ])
                |> Result.withDefault []
    in
    [ Html.div [ HtmlA.class "join-info" ]
        [ Html.p [] [ Strings.JoinTheGame |> Lang.html shared ]
        , Html.p [] [ Strings.GameCode { code = GameCode.toString gameCode } |> Lang.html shared ]
        , Html.p [] [ Html.text (stripProtocol shared.origin) ]
        ]
    , Html.div [ HtmlA.class "qr-code" ] qr
    ]


{-| We assume that the protocol and root path don't matter, to simplify the shown URL.
This should be fine as long as http redirects to https, which is good practice.
If the origin doesn't parse we probably have bigger problems, but we just return it unaltered.
-}
stripProtocol : String -> String
stripProtocol stringUrl =
    Url.fromString stringUrl
        |> Maybe.map fromUrl
        |> Maybe.withDefault stringUrl


fromUrl : Url -> String
fromUrl url =
    let
        portPart =
            case url.port_ of
                Nothing ->
                    ""

                Just port_ ->
                    ":" ++ String.fromInt port_

        pathPart =
            if url.path == "/" then
                ""

            else
                url.path
    in
    url.host ++ portPart ++ pathPart
