module MassiveDecks.Pages.Start exposing
    ( changeRoute
    , init
    , initWithError
    , route
    , update
    , view
    )

import Browser.Navigation as Navigation
import Dict
import FontAwesome.Attributes as Icon
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Http
import MassiveDecks.Card.Call as Call
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Parts as Parts
import MassiveDecks.Card.Response as Response
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Components.Form as Form
import MassiveDecks.Components.Form.Message as Message exposing (Message)
import MassiveDecks.Error as Error
import MassiveDecks.Error.Model as Error
import MassiveDecks.Icon as Icon
import MassiveDecks.Messages as Global
import MassiveDecks.Model exposing (..)
import MassiveDecks.Models.MdError as MdError exposing (MdError)
import MassiveDecks.Pages.Lobby.Configure.Model as Configure
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
import MassiveDecks.Requests.Request as Request
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Maybe as Maybe
import MassiveDecks.Util.NeList as NeList exposing (NeList(..))
import MassiveDecks.Version as Version
import Material.Button as Button
import Material.Card as Card
import Material.IconButton as IconButton
import Material.Tabs as Tabs
import Material.TextField as TextField
import Svg.Attributes as SvgA


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
      , password = Nothing
      , overlay = Nothing
      }
    , lobbiesCmd
    )


initWithError : Shared -> GameCode -> MdError -> ( Model, Cmd Global.Msg )
initWithError shared gameCode error =
    let
        ( model, cmd ) =
            init shared { section = Join (Just gameCode) }

        jlr =
            model.joinLobbyRequest
    in
    ( { model | joinLobbyRequest = { jlr | error = error |> Just } }, cmd )


route : Model -> Route
route model =
    model.route


update : Shared -> Msg -> Model -> ( Model, Cmd Global.Msg )
update shared msg model =
    case msg of
        GameCodeChanged gameCode ->
            let
                gc =
                    gameCode |> GameCode.fromString
            in
            ( { model | gameCode = gc }
            , { section = Join gc } |> Route.Start |> Route.url |> Navigation.replaceUrl shared.key
            )

        NameChanged name ->
            ( { model | name = name }, Cmd.none )

        StartGame httpDataMsg ->
            let
                ( nlr, cmd ) =
                    HttpData.update
                        (startGameRequest (Strings.DefaultLobbyName { owner = model.name } |> Lang.string shared) model.name)
                        httpDataMsg
                        model.newLobbyRequest
            in
            ( { model | newLobbyRequest = nlr }, cmd )

        JoinGame httpDataMsg ->
            case model.gameCode of
                Just gc ->
                    let
                        ( jlr, cmd ) =
                            HttpData.update
                                (joinGameRequest gc model.name model.password)
                                httpDataMsg
                                model.joinLobbyRequest
                    in
                    ( { model | joinLobbyRequest = jlr }, cmd )

                _ ->
                    ( model, Cmd.none )

        LobbyBrowserMsg lbm ->
            let
                ( lobbies, cmd ) =
                    LobbyBrowser.update lbm model.lobbies
            in
            ( { model | lobbies = lobbies }, cmd )

        PasswordChanged newPassword ->
            ( { model | password = Just newPassword }, Cmd.none )

        JoinFailure error ->
            let
                jlr =
                    model.joinLobbyRequest

                newJlr =
                    { jlr
                        | error = Just error
                        , loading = False
                    }

                showError =
                    ( { model | joinLobbyRequest = newJlr }, Cmd.none )
            in
            case error of
                MdError.Authentication MdError.InvalidLobbyPassword ->
                    if Maybe.isJust model.password then
                        showError

                    else
                        ( { model | password = Just "", joinLobbyRequest = HttpData.initLazy }, Cmd.none )

                _ ->
                    showError

        HideOverlay ->
            ( { model | overlay = Nothing }, Cmd.none )


view : Shared -> Model -> List (Html Global.Msg)
view shared model =
    let
        r =
            model.route

        manyDecksAd { baseUrl } =
            Html.blankA
                [ HtmlA.href baseUrl, HtmlA.id "many-decks-ad", Strings.ManyDecksWhereToGet |> Lang.title shared ]
                [ Html.div []
                    [ Icon.boxOpen |> Icon.viewIcon
                    , Html.span [] [ Strings.ManyDecks |> Lang.string shared |> Html.text ]
                    ]
                ]
    in
    [ Html.div [ HtmlA.class "page start" ]
        [ overlay shared model.overlay
        , Html.header [ HtmlA.class "title-card" ]
            [ Html.h1 [] [ Html.div [ HtmlA.class "card-slicer" ] [ Call.viewUnknown shared [] ] ]
            , Html.div [ HtmlA.class "subtitle" ]
                [ Html.div [ HtmlA.class "card-slicer" ]
                    [ Response.view shared Configure.fake Card.Front [] (subtitleCard shared)
                    ]
                ]
            ]
        , Card.view []
            [ Tabs.view shared
                { selected = r.section
                , change = \s -> Route.Start { r | section = s } |> Global.ChangePage
                , ids = NeList New [ Join model.gameCode, Find, About ]
                , tab = tabFor
                , equals = sectionsMatch
                }
            , sectionContent shared model
            ]
        , Html.footer [ HtmlA.class "version-info" ]
            [ Html.div [ HtmlA.class "logos" ]
                [ Html.blankA
                    [ HtmlA.class "logo"
                    , Strings.MDProject |> Lang.title shared
                    , HtmlA.href "https://github.com/Lattyware/massivedecks"
                    ]
                    [ Icon.viewStyled [ Strings.MDLogoDescription |> Lang.alt shared ] Icon.massiveDecks ]
                , Html.blankA
                    [ HtmlA.class "logo"
                    , Strings.DevelopedByReread |> Lang.title shared
                    , HtmlA.href "https://www.rereadgames.com/"
                    ]
                    [ Icon.viewStyled [ Strings.RereadLogoDescription |> Lang.alt shared ] Icon.rereadGames ]
                ]
            , Html.p [ HtmlA.class "version" ]
                [ Html.text "\""
                , Strings.MassiveDecks |> Lang.html shared
                , Html.text "\" "
                , Strings.Version { versionNumber = Version.version } |> Lang.html shared
                ]
            ]
        ]
    , shared.sources.manyDecks |> Maybe.map manyDecksAd |> Maybe.withDefault Html.nothing
    ]



{- Private -}


tabFor : Section -> Tabs.TabModel
tabFor section =
    case section of
        New ->
            Tabs.TabModel Strings.NewGame (Just Icon.plus)

        Join _ ->
            Tabs.TabModel Strings.JoinPrivateGame (Just Icon.signInAlt)

        Find ->
            Tabs.TabModel Strings.FindPublicGame (Just Icon.search)

        About ->
            Tabs.TabModel Strings.AboutTheGame (Just Icon.questionCircle)


overlay : Shared -> Maybe MdString -> Html Global.Msg
overlay shared content =
    case content of
        Just text ->
            Html.div [ HtmlA.id "overlay" ]
                [ IconButton.view shared
                    Strings.Close
                    (Icon.times |> Icon.present |> NeList.just)
                    (HideOverlay |> Global.StartMsg |> Just)
                , Card.view []
                    [ text |> Lang.html shared
                    ]
                ]

        Nothing ->
            Html.nothing


startGameRequest : String -> String -> HttpData.Pull Global.Msg
startGameRequest gameName userName =
    Api.newLobby
        ((HttpData.Response >> StartGame >> Global.StartMsg)
            |> Request.intercept Request.passthrough Request.passthrough (Request.replace (Global.JoinLobby userName))
        )
        { name = gameName, owner = { name = userName, password = Nothing } }
        |> Http.request


joinGameRequest : GameCode -> String -> Maybe String -> HttpData.Pull Global.Msg
joinGameRequest gameCode name password =
    Api.joinLobby
        ((HttpData.Response >> JoinGame >> Global.StartMsg)
            |> Request.intercept Request.passthrough (Request.maybeReplace onJoinError) (Request.replace (Global.JoinLobby name))
        )
        gameCode
        { name = name, password = password }
        |> Http.request


onJoinError : MdError -> Maybe Global.Msg
onJoinError error =
    error |> JoinFailure |> Global.StartMsg |> Just


loadingOrLoaded : Model -> Bool
loadingOrLoaded model =
    [ model.newLobbyRequest ] |> List.any HttpData.loadingOrLoaded


subtitleCard : Shared -> Card.Response
subtitleCard shared =
    Card.response (Strings.ShortGameDescription |> Lang.string shared) "" (Source.Fake Nothing)


gameCodeForRoute : Route -> Maybe GameCode
gameCodeForRoute r =
    case r.section of
        Join (Just gc) ->
            Just gc

        _ ->
            Nothing


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
                Icon.viewIcon Icon.play

        error =
            model.newLobbyRequest.generalError
                |> Maybe.map (Error.view shared (Route.Start model.route))
                |> Maybe.withDefault Html.nothing
    in
    Html.div [ HtmlA.class "new-game start-tab" ]
        [ Html.div [ HtmlA.class "tab-content" ]
            [ Html.h2 [] [ Strings.NewGame |> Lang.html shared ]
            , Html.p [] [ Strings.NewGameDescription |> Lang.html shared ]
            , error
            , nameField shared model Nothing
            , Button.view shared
                Button.Raised
                Strings.PlayGame
                Strings.PlayGame
                buttonIcon
                [ buttonAttr ]
            ]
        ]


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
                Icon.viewIcon Icon.play

        error =
            model.joinLobbyRequest.generalError
                |> Maybe.map (Error.view shared (Route.Start model.route))
                |> Maybe.withDefault Html.nothing

        ( gameError, nameError, passwordError ) =
            case model.joinLobbyRequest.error of
                Just (MdError.Authentication MdError.InvalidLobbyPassword) ->
                    ( Nothing, Nothing, model.joinLobbyRequest.error )

                Just (MdError.Registration (MdError.UsernameAlreadyInUseError _)) ->
                    ( Nothing, model.joinLobbyRequest.error, Nothing )

                _ ->
                    ( model.joinLobbyRequest.error, Nothing, Nothing )

        maybePasswordField =
            model.password
                |> Maybe.map (passwordField shared passwordError)
                |> Maybe.withDefault []
    in
    Html.div [ HtmlA.class "join-game start-tab" ]
        [ Html.div [ HtmlA.class "tab-content" ]
            (List.concat
                [ [ Html.h2 [] [ Strings.JoinPrivateGame |> Lang.html shared ]
                  , Html.p [] [ Strings.JoinPrivateGameDescription |> Lang.html shared ]
                  , error
                  ]
                , rejoinSection shared model
                , [ nameField shared model nameError
                  , Form.section shared
                        "game-code-input"
                        (TextField.view shared
                            Strings.GameCodeTerm
                            TextField.Text
                            (model.gameCode |> Maybe.map GameCode.toString |> Maybe.withDefault "")
                            [ HtmlA.class "game-code-input"
                            , GameCodeChanged >> Global.StartMsg |> HtmlE.onInput
                            ]
                        )
                        [ Message.info Strings.GameCodeHowToAcquire
                        , gameError |> Maybe.map Message.mdError |> Maybe.withDefault Message.none
                        ]
                  ]
                , maybePasswordField
                , [ Button.view shared
                        Button.Raised
                        Strings.PlayGame
                        Strings.PlayGame
                        buttonIcon
                        [ buttonAttr ]
                  ]
                ]
            )
        ]


passwordField : Shared -> Maybe MdError -> String -> List (Html Global.Msg)
passwordField shared error password =
    [ Form.section shared
        "password-input"
        (TextField.view shared
            Strings.LobbyPassword
            TextField.Password
            password
            [ PasswordChanged >> Global.StartMsg |> HtmlE.onInput ]
        )
        [ Message.info Strings.LobbyRequiresPassword
        , error |> Maybe.map (MdError.describe >> Message.error) |> Maybe.withDefault Message.none
        ]
    ]


rejoinSection : Shared -> Model -> List (Html Global.Msg)
rejoinSection shared _ =
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


rejoinLobby : Shared -> Result Error.TokenDecodingError Lobby.Auth -> Maybe (Html Global.Msg)
rejoinLobby shared result =
    case result of
        Ok auth ->
            Html.li []
                [ Html.a [ Route.Lobby { gameCode = auth.claims.gc, section = Nothing } |> Route.href ]
                    [ Strings.RejoinGame { code = GameCode.toString auth.claims.gc } |> Lang.html shared
                    ]
                ]
                |> Just

        Err _ ->
            Nothing


nameField : Shared -> Model -> Maybe MdError -> Html Global.Msg
nameField shared model error =
    Form.section shared
        "name-input"
        (TextField.view shared
            Strings.NameLabel
            TextField.Text
            model.name
            [ NameChanged >> Global.StartMsg |> HtmlE.onInput ]
        )
        [ error |> Maybe.map (MdError.describe >> Message.error) |> Maybe.withDefault Message.none ]


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
            [ Call.view shared Configure.fake Card.Front [] examplePick2
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
    , ( Strings.HouseRuleComedyWriter, Strings.HouseRuleComedyWriterDescription )
    , ( Strings.HouseRuleNeverHaveIEver, Strings.HouseRuleNeverHaveIEverDescription )
    , ( Strings.HouseRuleHappyEnding, Strings.HouseRuleHappyEndingDescription )
    ]


houseRule : Shared -> ( MdString, MdString ) -> Html msg
houseRule shared ( name, description ) =
    Html.li []
        [ Html.h3 [] [ name |> Lang.html shared ]
        , Html.p [] [ description |> Lang.html shared ]
        ]


examplePick2 : Card.Call
examplePick2 =
    Card.call
        (Parts.unsafeFromList
            [ [ Parts.Slot 0 Parts.NoTransform Parts.NoStyle
              , Parts.Text " + " Parts.NoStyle
              , Parts.Slot 1 Parts.NoTransform Parts.NoStyle
              ]
            , [ Parts.Text " = " Parts.NoStyle
              , Parts.Slot 2 Parts.NoTransform Parts.NoStyle
              ]
            ]
        )
        ""
        (Source.Fake Nothing)
