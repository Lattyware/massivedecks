module MassiveDecks.Pages.Start exposing
    ( changeRoute
    , init
    , route
    , update
    , view
    )

import Dict
import FontAwesome.Attributes as Icon
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Card as Card
import MassiveDecks.Card.Model as Card exposing (Card)
import MassiveDecks.Card.Parts as Parts
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Error as Error
import MassiveDecks.Error.Model as Error exposing (Error)
import MassiveDecks.Messages as Global
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Pages.Lobby.Token as Token
import MassiveDecks.Pages.Route as Route
import MassiveDecks.Pages.Start.LobbyBrowser as LobbyBrowser
import MassiveDecks.Pages.Start.Messages exposing (..)
import MassiveDecks.Pages.Start.Model exposing (..)
import MassiveDecks.Pages.Start.Route exposing (..)
import MassiveDecks.Requests.Api as Api
import MassiveDecks.Requests.HttpData as HttpData
import MassiveDecks.Requests.HttpData.Messages as HttpData
import MassiveDecks.Requests.HttpData.Model as HttpData exposing (HttpData)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util as Util
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Maybe as Maybe
import MassiveDecks.Version as Version
import Reread
import Svg.Attributes as SvgA
import Weightless as Wl
import Weightless.Attributes as WlA


changeRoute : Route -> Model -> ( Model, Cmd Global.Msg )
changeRoute r model =
    let
        ( lobbies, cmd ) =
            case r.section of
                Find ->
                    LobbyBrowser.refresh model.lobbies

                _ ->
                    ( model.lobbies, Cmd.none )
    in
    ( { model
        | route = r
        , gameCode = Maybe.first [ gameCodeForRoute r, model.gameCode ]
        , lobbies = lobbies
      }
    , cmd
    )


init : Shared -> Route -> ( Model, Cmd Global.Msg )
init shared r =
    let
        ( lobbies, lobbiesCmd ) =
            LobbyBrowser.init
    in
    ( { route = r
      , name = shared.settings.settings.lastUsedName |> Maybe.withDefault ""
      , gameCode = gameCodeForRoute r
      , lobbies = lobbies
      , newLobbyRequest = HttpData.initLazy
      , joinLobbyRequest = HttpData.initLazy
      }
    , lobbiesCmd
    )


route : Model -> Route
route model =
    model.route


update : Msg -> Model -> ( Model, Cmd Global.Msg )
update msg model =
    case msg of
        GameCodeChanged gameCode ->
            ( { model | gameCode = gameCode |> GameCode.fromString }, Cmd.none )

        NameChanged name ->
            ( { model | name = name }, Cmd.none )

        StartGame httpDataMsg ->
            Util.modelLift (\nlr -> { model | newLobbyRequest = nlr })
                (HttpData.update (startGameRequest model.name) httpDataMsg model.newLobbyRequest)

        JoinGame httpDataMsg ->
            case model.gameCode of
                Just gc ->
                    Util.modelLift (\jlr -> { model | joinLobbyRequest = jlr })
                        (HttpData.update
                            (joinGameRequest gc model.name)
                            httpDataMsg
                            model.joinLobbyRequest
                        )

                _ ->
                    ( model, Cmd.none )

        LobbyBrowserMsg lbm ->
            Util.modelLift (\lobbies -> { model | lobbies = lobbies }) (LobbyBrowser.update lbm model.lobbies)


view : Shared -> Model -> List (Html Global.Msg)
view shared model =
    [ Html.div [ HtmlA.class "page start" ]
        [ Html.header [ HtmlA.class "title-card" ]
            [ Html.h1 [] [ Html.div [ HtmlA.class "card-slicer" ] [ Card.viewUnknownCall [] ] ]
            , Html.div [ HtmlA.class "subtitle" ]
                [ Html.div [ HtmlA.class "card-slicer" ]
                    [ Card.view shared [] Card.Front [] (subtitleCard shared)
                    ]
                ]
            ]
        , Wl.card []
            [ Wl.tabGroup [ WlA.align WlA.Center ]
                [ tab shared New model Icon.plus Strings.NewGame
                , tab shared (Join model.gameCode) model Icon.signInAlt Strings.JoinPrivateGame
                , tab shared Find model Icon.search Strings.FindPublicGame
                , tab shared About model Icon.questionCircle Strings.AboutTheGame
                ]
            , sectionContent shared model
            ]
        , Html.footer [ HtmlA.class "version-info" ]
            [ Html.div [ HtmlA.class "logos" ]
                [ Html.blankA
                    [ HtmlA.class "logo"
                    , Strings.MDProject |> Lang.title shared
                    , HtmlA.href "https://github.com/Lattyware/massivedecks"
                    ]
                    [ Icon.viewStyled [ Strings.MDLogoDescription |> Lang.alt shared ] Reread.mdIcon ]
                , Html.blankA
                    [ HtmlA.class "logo"
                    , Strings.DevelopedByReread |> Lang.title shared
                    , HtmlA.href "https://www.rereadgames.com/"
                    ]
                    [ Icon.viewStyled [ Strings.RereadLogoDescription |> Lang.alt shared ] Reread.icon ]
                ]
            , Html.p [ HtmlA.class "version" ]
                [ Html.text "\""
                , Strings.MassiveDecks |> Lang.html shared
                , Html.text "\" "
                , Strings.Version { versionNumber = Version.version } |> Lang.html shared
                ]
            ]
        ]
    ]



{- Private -}


startGameRequest : String -> HttpData.Pull Global.Msg
startGameRequest name =
    HttpData.interceptedRequest
        (Api.newLobby { owner = { name = name } })
        (Token.decode >> Result.mapError Error.Token)
        (StartGame >> Global.StartMsg)
        (Global.JoinLobby name)


joinGameRequest : GameCode -> String -> HttpData.Pull Global.Msg
joinGameRequest gameCode name =
    HttpData.interceptedRequest
        (Api.joinLobby gameCode { name = name })
        (Token.decode >> Result.mapError Error.Token)
        (StartGame >> Global.StartMsg)
        (Global.JoinLobby name)


loadingOrLoaded : Model -> Bool
loadingOrLoaded model =
    [ model.newLobbyRequest ] |> List.any HttpData.loadingOrLoaded


subtitleCard : Shared -> Card
subtitleCard shared =
    Card.response (Strings.ShortGameDescription |> Lang.string shared) "" Source.Fake |> Card.R


gameCodeForRoute : Route -> Maybe GameCode
gameCodeForRoute r =
    case r.section of
        Join (Just gc) ->
            Just gc

        _ ->
            Nothing


tab : Shared -> Section -> Model -> Icon -> MdString -> Html Global.Msg
tab shared targetSection model icon title =
    let
        r =
            model.route
    in
    Wl.tab
        (List.concat
            [ [ Route.Start { r | section = targetSection } |> Global.ChangePage |> HtmlE.onClick
              ]
            , [ WlA.checked ] |> Maybe.justIf (sectionsMatch r.section targetSection) |> Maybe.withDefault []
            ]
        )
        [ Icon.view icon
        , title |> Lang.html shared
        ]


sectionsMatch : Section -> Section -> Bool
sectionsMatch first second =
    case first of
        Join _ ->
            case second of
                Join _ ->
                    True

                _ ->
                    False

        other ->
            other == second


sectionContent : Shared -> Model -> Html Global.Msg
sectionContent shared model =
    case model.route.section of
        New ->
            newContent shared model

        Join _ ->
            joinContent shared model

        Find ->
            LobbyBrowser.view shared (Route.Start model.route) model.lobbies

        About ->
            aboutContent shared


newContent : Shared -> Model -> Html Global.Msg
newContent shared model =
    let
        loading =
            loadingOrLoaded model

        buttonAttr =
            if model.name == "" || loading then
                HtmlA.disabled True

            else
                StartGame HttpData.Pull |> Global.StartMsg |> HtmlE.onClick

        buttonIcon =
            if loading then
                Icon.viewStyled [ Icon.spin ] Icon.circleNotch

            else
                Icon.view Icon.play

        error =
            model.newLobbyRequest.error
                |> Maybe.map
                    (\e ->
                        [ Error.view shared (Route.Start model.route) e ]
                    )
                |> Maybe.withDefault []
    in
    Html.div [ HtmlA.class "new-game start-tab" ]
        (List.concat
            [ error
            , nameField shared model
            , [ Wl.button
                    [ buttonAttr
                    ]
                    [ buttonIcon, Strings.PlayGame |> Lang.html shared ]
              ]
            ]
        )


joinContent : Shared -> Model -> Html Global.Msg
joinContent shared model =
    let
        loading =
            loadingOrLoaded model

        buttonAttr =
            if String.isEmpty model.name || model.gameCode == Nothing || loading then
                HtmlA.disabled True

            else
                JoinGame HttpData.Pull |> Global.StartMsg |> HtmlE.onClick

        buttonIcon =
            if loading then
                Icon.viewStyled [ Icon.spin ] Icon.circleNotch

            else
                Icon.view Icon.play
    in
    Html.div [ HtmlA.class "join-game start-tab" ]
        (List.concat
            [ rejoinSection shared model
            , nameField shared model
            , [ Html.div [ HtmlA.class "form-chunk" ]
                    [ Wl.textField
                        [ HtmlA.class "game-code-input"
                        , GameCodeChanged >> Global.StartMsg |> HtmlE.onInput
                        , WlA.value (model.gameCode |> Maybe.map GameCode.toString |> Maybe.withDefault "")
                        , WlA.outlined
                        , Strings.GameCodeTerm |> Lang.label shared
                        ]
                        -- "game-code"
                        -- (Weightless.Help [ Strings.GameCodeHowToAcquire |> Lang.html shared ])
                        []
                    ]
              , Wl.button
                    [ buttonAttr
                    ]
                    [ buttonIcon, Strings.PlayGame |> Lang.html shared ]
              ]
            ]
        )


rejoinSection : Shared -> Model -> List (Html Global.Msg)
rejoinSection shared model =
    let
        lobbies =
            shared.settings.settings.tokens |> Dict.values |> List.map Token.decode
    in
    if List.isEmpty lobbies then
        []

    else
        [ Html.div [ HtmlA.class "rejoin" ]
            [ Html.h3 [] [ Strings.RejoinTitle |> Lang.html shared ]
            , Html.ul [] (lobbies |> List.filterMap (rejoinLobby shared))
            ]
        ]


rejoinLobby : Shared -> Result Lobby.TokenDecodingError Lobby.Auth -> Maybe (Html Global.Msg)
rejoinLobby shared result =
    case result of
        Ok auth ->
            Html.li []
                [ Html.a [ Route.Lobby { gameCode = auth.claims.gc } |> Route.href ]
                    [ Strings.RejoinGame { code = auth.claims.gc } |> Lang.html shared
                    ]
                ]
                |> Just

        Err _ ->
            Nothing


nameField : Shared -> Model -> List (Html Global.Msg)
nameField shared model =
    let
        -- TODO: Wire to real error.
        --        help =
        --            if False then
        --                Wl.Error [ Strings.NameInUse |> Lang.html shared ]
        --
        --            else
        --                Wl.None
        _ =
            ""
    in
    [ Html.div [ HtmlA.class "form-chunk" ]
        [ Wl.textField
            [ NameChanged
                >> Global.StartMsg
                |> HtmlE.onInput
            , WlA.value model.name
            , Strings.NameLabel |> Lang.label shared
            , WlA.outlined
            ]
            []
        ]
    ]


aboutContent : Shared -> Html Global.Msg
aboutContent shared =
    let
        html =
            Lang.html shared
    in
    Html.div [ HtmlA.class "about" ]
        [ Html.h2 [] [ Strings.WhatIsThis |> html ]
        , Html.p [] [ Strings.GameDescription |> html ]
        , Html.h2 [] [ Strings.Rules |> html ]
        , Html.p [] [ Strings.RulesHand |> html ]
        , Html.p [] [ Strings.RulesCzar |> html ]
        , Html.p [] [ Strings.RulesPlaying |> html ]
        , Html.p [] [ Strings.RulesJudging |> html ]
        , Html.figure [ HtmlA.class "example-card" ]
            [ Card.view shared [] Card.Front [] examplePick2
            , Html.figcaption []
                [ Strings.ExamplePickDescription |> html ]
            ]
        , Html.h3 [] [ Strings.RulesPickTitle |> html ]
        , Html.p [] [ Strings.RulesPick |> html ]
        , Html.p [] [ Strings.RulesDraw |> html ]
        , Html.h2 [] [ Strings.HouseRulesTitle |> html ]
        , Html.p [] [ Strings.HouseRules |> html ]
        , Html.ul [ Icon.ul, SvgA.class "rule-list" ] (houseRules |> List.map (houseRule shared))
        ]


houseRules : List ( MdString, MdString )
houseRules =
    [ ( Strings.HouseRuleReboot, Strings.HouseRuleRebootDescription { cost = Nothing } )
    , ( Strings.HouseRulePackingHeat, Strings.HouseRulePackingHeatDescription )
    , ( Strings.HouseRuleRandoCardrissian, Strings.HouseRuleRandoCardrissianDescription )
    ]


houseRule : Shared -> ( MdString, MdString ) -> Html msg
houseRule shared ( name, description ) =
    Html.li []
        [ Html.h3 [] [ name |> Lang.html shared ]
        , Html.p [] [ description |> Lang.html shared ]
        ]


examplePick2 : Card
examplePick2 =
    Card.call
        (Parts.unsafeFromList
            [ [ Parts.Slot Parts.None, Parts.Text " + ", Parts.Slot Parts.None ]
            , [ Parts.Text " = ", Parts.Slot Parts.None ]
            ]
        )
        ""
        Source.Fake
        |> Card.C
