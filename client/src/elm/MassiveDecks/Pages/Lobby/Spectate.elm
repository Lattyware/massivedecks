module MassiveDecks.Pages.Lobby.Spectate exposing
    ( init
    , update
    , view
    )

import Dict
import FontAwesome.Attributes as Icon
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Components as Component
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Actions as Actions
import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Model as Lobby exposing (Auth)
import MassiveDecks.Pages.Lobby.Route as Lobby
import MassiveDecks.Pages.Lobby.Spectate.Messages exposing (Msg(..))
import MassiveDecks.Pages.Lobby.Spectate.Model exposing (Model)
import MassiveDecks.Pages.Lobby.Spectate.Stages.Postgame as Postgame
import MassiveDecks.Pages.Lobby.Spectate.Stages.Pregame as Pregame
import MassiveDecks.Pages.Lobby.Spectate.Stages.Round as Round
import MassiveDecks.Pages.Route as Route
import MassiveDecks.Pages.Start.Route as Start
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User
import QRCode
import Url exposing (Url)


init : Model
init =
    { advertise = True }


view : (Msg -> msg) -> (Route.Route -> msg) -> Shared -> Lobby.Model -> List (Html msg)
view wrap changePage shared lobby =
    let
        advert =
            if lobby.spectate.advertise then
                advertise shared lobby.route.gameCode

            else
                []
    in
    [ Html.div [ HtmlA.id "spectate" ]
        (List.concat
            [ viewSettings wrap changePage shared lobby
            , advert
            , viewStage shared lobby
            ]
        )
    ]


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        BecomePlayer ->
            ( model, Actions.setUserRole User.Player )

        ToggleAdvert ->
            ( { model | advertise = not model.advertise }, Cmd.none )



{- Private -}


viewSettings : (Msg -> msg) -> (Route.Route -> msg) -> Shared -> Lobby.Model -> List (Html msg)
viewSettings wrap changePage shared lobby =
    if not shared.remoteMode then
        let
            advertiseIcon =
                if lobby.spectate.advertise then
                    Icon.eyeSlash

                else
                    Icon.eye

            route =
                lobby.route

            role l =
                l.users |> Dict.get lobby.auth.claims.uid |> Maybe.map .role

            ( backAction, backDescription ) =
                case lobby.lobby |> Maybe.andThen role |> Maybe.withDefault User.Spectator of
                    User.Player ->
                        ( { route | section = Nothing } |> Route.Lobby |> changePage, Strings.ReturnViewToGameDescription )

                    User.Spectator ->
                        ( wrap BecomePlayer, Strings.BecomePlayerDescription )
        in
        [ Html.div [ HtmlA.id "spectate-actions" ]
            [ Component.iconButton
                [ backAction |> HtmlE.onClick
                , backDescription |> Lang.title shared
                ]
                Icon.arrowLeft
            , Component.iconButton
                [ { route | section = Just Lobby.Configure } |> Route.Lobby |> changePage |> HtmlE.onClick
                , Strings.ViewConfgiurationDescription |> Lang.title shared
                ]
                Icon.cog
            , Component.iconButton
                [ ToggleAdvert |> wrap |> HtmlE.onClick
                , Strings.ToggleAdvertDescription |> Lang.title shared
                ]
                advertiseIcon
            ]
        ]

    else
        []


viewStage : Shared -> Lobby.Model -> List (Html msg)
viewStage shared lobbyModel =
    case lobbyModel.lobby of
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
