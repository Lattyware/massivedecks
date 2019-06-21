module MassiveDecks.Settings exposing
    ( auths
    , defaults
    , init
    , onJoinLobby
    , update
    , view
    )

import Dict exposing (Dict)
import Dict.Extra as Dict
import FontAwesome.Attributes as Icon
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Http
import MassiveDecks.Components as Components
import MassiveDecks.LocalStorage as LocalStorage
import MassiveDecks.Messages as Global
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Pages.Lobby.Token as Token
import MassiveDecks.Requests.Api as Api
import MassiveDecks.Settings.Messages exposing (..)
import MassiveDecks.Settings.Model exposing (..)
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Strings.Languages.Model as Lang exposing (Language)
import MassiveDecks.Util.Result as Result
import Weightless as Wl
import Weightless.Attributes as WlA


init : Settings -> ( Model, Cmd Global.Msg )
init settings =
    let
        cmd =
            if Dict.isEmpty settings.tokens then
                Cmd.none

            else
                settings.tokens
                    |> Dict.values
                    |> Api.checkAlive
                    |> Http.request
                    |> Cmd.map
                        (Result.map (RemoveInvalid >> Global.SettingsMsg)
                            >> Result.mapError (always Global.NoOp)
                            >> Result.unify
                        )
    in
    ( { settings = settings
      , open = False
      }
    , cmd
    )


defaults : Settings
defaults =
    { tokens = Dict.empty
    , lastUsedName = Nothing
    , openUserList = False
    , recentDecks = []
    , chosenLanguage = Nothing
    , compactCards = False
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleOpen ->
            ( { model | open = not model.open }, Cmd.none )

        ChangeLang language ->
            changeSettings (\s -> { s | chosenLanguage = language }) model

        ChangeCompactCards enabled ->
            changeSettings (\s -> { s | compactCards = enabled }) model

        ChangeOpenUserList open ->
            changeSettings (\s -> { s | openUserList = open }) model

        RemoveInvalid tokenValidity ->
            let
                newTokens =
                    model.settings.tokens
                        |> Dict.filter (\_ -> \t -> Dict.get t tokenValidity |> Maybe.withDefault True)
            in
            changeSettings (\s -> { s | tokens = newTokens }) model


view : Shared -> Html Global.Msg
view shared =
    let
        model =
            shared.settings

        icon =
            if model.open then
                Icon.check

            else
                Icon.cog

        button =
            Components.iconButtonStyled
                [ HtmlA.id "settings-button"
                , ToggleOpen |> Global.SettingsMsg |> HtmlE.onClick
                , Strings.SettingsTitle |> Lang.title shared
                ]
                ( [ Icon.lg ], icon )

        panel =
            Wl.card [ HtmlA.classList [ ( "settings-panel", True ), ( "open", model.open ) ] ]
                [ Html.h3 [] [ Strings.SettingsTitle |> Lang.html shared ]
                , Html.div [ HtmlA.class "body" ]
                    [ languageSelector shared
                    , compactSwitch shared
                    , speechSwitch shared
                    , notificationsSwitch shared
                    ]
                ]
    in
    Html.div [] [ button, panel ]


{-| Add a token to the token list and set the last used name, because the user has joined a lobby.
We take an `Auth` here even though we don't really use it to ensure the token has been successfully parsed.
-}
onJoinLobby : Lobby.Auth -> String -> Model -> ( Model, Cmd msg )
onJoinLobby auth name model =
    let
        settings =
            model.settings

        updatedSettings =
            { settings
                | tokens = Dict.insert (auth.claims.gc |> GameCode.toString) auth.token settings.tokens
                , lastUsedName = Just name
            }
    in
    ( { model | settings = updatedSettings }, LocalStorage.store updatedSettings )


{-| Get all the tokens in settings as `Auth`s by game code.
-}
auths : Settings -> Dict String Lobby.Auth
auths settings =
    -- Only legit tokens should be in settings, so we ignore any that aren't.
    settings.tokens
        |> Dict.filterMap (\_ -> \v -> v |> Token.decode |> Result.toMaybe)



{- Private -}


changeSettings : (Settings -> Settings) -> Model -> ( Model, Cmd msg )
changeSettings f model =
    let
        settings =
            f model.settings
    in
    ( { model | settings = settings }, LocalStorage.store settings )


compactSwitch : Shared -> Html Global.Msg
compactSwitch shared =
    let
        model =
            shared.settings

        settings =
            model.settings
    in
    Components.formSection shared
        "compact-cards"
        (Html.div
            [ HtmlA.class "multipart" ]
            [ Wl.switch
                [ HtmlA.checked settings.compactCards
                , HtmlE.onCheck (ChangeCompactCards >> Global.SettingsMsg)
                ]
            , Html.label []
                [ Icon.view Icon.searchMinus
                , Html.text " "
                , Strings.CompactCardsSetting |> Lang.html shared
                ]
            ]
        )
        [ Components.info Strings.CompactCardsExplanation ]



-- TODO: Impl


speechSwitch : Shared -> Html Global.Msg
speechSwitch shared =
    Components.formSection shared
        "speech"
        (Html.div
            [ HtmlA.class "multipart" ]
            [ Wl.switch []
            , Html.label []
                [ Icon.view Icon.volumeUp
                , Html.text " "
                , Strings.SpeechSetting |> Lang.html shared
                ]
            ]
        )
        [ Components.info Strings.SpeechExplanation ]



-- TODO: Impl


notificationsSwitch : Shared -> Html Global.Msg
notificationsSwitch shared =
    Components.formSection shared
        "notifications"
        (Html.div
            [ HtmlA.class "multipart" ]
            [ Wl.switch []
            , Html.label []
                [ Icon.view Icon.bell
                , Html.text " "
                , Strings.NotificationsSetting |> Lang.html shared
                ]
            ]
        )
        [ Components.info Strings.NotificationsExplanation
        , Components.info Strings.NotificationsBrowserPermissions
        ]


languageSelector : Shared -> Html Global.Msg
languageSelector shared =
    let
        selected =
            Lang.currentLanguage shared
    in
    Components.formSection
        shared
        "language"
        (Wl.select
            [ HtmlE.onInput onChangeLang
            , Strings.LanguageSetting |> Lang.string shared |> WlA.label
            , WlA.outlined
            ]
            (Lang.languages |> List.map (languageOption selected))
        )
        [ Components.info Strings.MissingLanguage ]


onChangeLang : String -> Global.Msg
onChangeLang code =
    Lang.fromCode code |> ChangeLang |> Global.SettingsMsg


languageOption : Language -> Language -> Html msg
languageOption currentLanguage language =
    let
        autonym =
            language |> Lang.autonym

        nameInCurrentLanguage =
            language |> Lang.languageName |> Lang.givenLanguageString currentLanguage

        name =
            if autonym == nameInCurrentLanguage then
                [ autonym |> Html.text ]

            else
                [ autonym |> Html.text
                , Html.text "("
                , nameInCurrentLanguage |> Html.text
                , Html.text ")"
                ]
    in
    Html.option
        [ language |> Lang.code |> HtmlA.value, HtmlA.selected (currentLanguage == language) ]
        name
