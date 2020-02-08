module MassiveDecks.Settings exposing
    ( auths
    , defaults
    , init
    , onAddDeck
    , onJoinLobby
    , onTokenUpdate
    , removeToken
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
import MassiveDecks.Card.Source as Source
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Components as Components
import MassiveDecks.Components.Form as Form
import MassiveDecks.Components.Form.Message as Message
import MassiveDecks.Icon as Icon
import MassiveDecks.LocalStorage as LocalStorage
import MassiveDecks.Model exposing (..)
import MassiveDecks.Notifications as Notifications
import MassiveDecks.Notifications.Model as Notifications
import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Pages.Lobby.Token as Token
import MassiveDecks.Requests.Api as Api
import MassiveDecks.Requests.Request as Request
import MassiveDecks.Settings.Messages exposing (..)
import MassiveDecks.Settings.Model exposing (..)
import MassiveDecks.Speech as Speech
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Strings.Languages.Model as Lang exposing (Language)
import Weightless as Wl
import Weightless.Attributes as WlA
import Weightless.Slider as Slider


init : (Msg -> msg) -> Settings -> ( Model, Cmd msg )
init wrap settings =
    let
        cmd =
            if Dict.isEmpty settings.tokens then
                Cmd.none

            else
                settings.tokens
                    |> Dict.values
                    |> Api.checkAlive (Request.map (ignore wrap) (ignore wrap) (RemoveInvalid >> wrap))
                    |> Http.request
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
    , cardSize = Full
    , speech = Speech.default
    , notifications = Notifications.default
    }


update : Shared -> Msg -> ( Model, Cmd msg )
update shared msg =
    let
        model =
            shared.settings
    in
    case msg of
        ToggleOpen ->
            ( { model | open = not model.open }, Cmd.none )

        ChangeLang language ->
            changeSettings (\s -> { s | chosenLanguage = language }) model

        ChangeCardSize size ->
            changeSettings (\s -> { s | cardSize = size }) model

        ChangeOpenUserList open ->
            changeSettings (\s -> { s | openUserList = open }) model

        RemoveInvalid tokenValidity ->
            let
                newTokens =
                    model.settings.tokens
                        |> Dict.filter (\_ -> \t -> Dict.get t tokenValidity |> Maybe.withDefault True)
            in
            changeSettings (\s -> { s | tokens = newTokens }) model

        ToggleSpeech enabled ->
            let
                newSpeechSettings =
                    model.settings.speech |> Speech.toggle enabled
            in
            changeSettings (\s -> { s | speech = newSpeechSettings }) model

        ChangeSpeech voice ->
            let
                newSpeechSettings =
                    model.settings.speech |> Speech.selectVoice voice
            in
            changeSettings (\s -> { s | speech = newSpeechSettings }) model

        ToggleNotifications enabled ->
            let
                ( notificationSettings, notificationsCmd ) =
                    model.settings.notifications |> Notifications.setEnabled shared.notifications enabled

                ( settings, settingsCmd ) =
                    changeSettings (\s -> { s | notifications = notificationSettings }) model
            in
            ( settings, Cmd.batch [ notificationsCmd, settingsCmd ] )

        ToggleOnlyWhenHidden enabled ->
            changeSettings (\s -> { s | notifications = Notifications.requireNotVisible enabled s.notifications }) model

        NoOp ->
            ( model, Cmd.none )


view : (Msg -> msg) -> Shared -> Html msg
view wrap shared =
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
                , ToggleOpen |> wrap |> HtmlE.onClick
                , Strings.SettingsTitle |> Lang.title shared
                ]
                ( [ Icon.lg ], icon )

        panel =
            Wl.card [ HtmlA.classList [ ( "settings-panel", True ), ( "open", model.open ) ] ]
                [ Html.h3 [] [ Strings.SettingsTitle |> Lang.html shared ]
                , Html.div [ HtmlA.class "body" ]
                    (List.intersperse (Html.hr [] [])
                        [ languageSelector wrap shared
                        , cardSize wrap shared
                        , speechVoiceSelector wrap shared
                        , notificationsSwitch wrap shared
                        ]
                    )
                ]
    in
    Html.div [] [ button, panel ]


{-| Add a deck to the recent decks list, shuffling the oldest off if needed.
-}
onAddDeck : Source.External -> Model -> ( Model, Cmd msg )
onAddDeck source model =
    let
        settings =
            model.settings

        newRecentDecks =
            (source :: (settings.recentDecks |> List.filter (Source.equals source >> not)))
                |> List.take maxRecentDecks

        updatedSettings =
            { settings | recentDecks = newRecentDecks }
    in
    ( { model | settings = updatedSettings }, LocalStorage.store updatedSettings )


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


{-| Replace a token in our storage because it has been updated.
-}
onTokenUpdate : Lobby.Auth -> Model -> ( Model, Cmd msg )
onTokenUpdate auth model =
    let
        settings =
            model.settings

        updatedSettings =
            { settings
                | tokens = Dict.insert (auth.claims.gc |> GameCode.toString) auth.token settings.tokens
            }
    in
    ( { model | settings = updatedSettings }, LocalStorage.store updatedSettings )


{-| Remove any token in the settings for the given game code.
-}
removeToken : GameCode -> Model -> ( Model, Cmd msg )
removeToken gc model =
    let
        settings =
            model.settings

        updatedSettings =
            { settings
                | tokens = Dict.filter (\k -> \_ -> k /= (gc |> GameCode.toString)) settings.tokens
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


maxRecentDecks : Int
maxRecentDecks =
    20


changeSettings : (Settings -> Settings) -> Model -> ( Model, Cmd msg )
changeSettings f model =
    let
        settings =
            f model.settings
    in
    ( { model | settings = settings }, LocalStorage.store settings )


cardSize : (Msg -> msg) -> Shared -> Html msg
cardSize wrap shared =
    let
        settings =
            shared.settings.settings
    in
    Form.section shared
        "card-size"
        (Html.div
            [ HtmlA.class "multipart" ]
            [ Wl.slider
                [ HtmlA.class "primary"
                , Slider.step 1
                , Slider.min 1
                , Slider.max 3
                , WlA.label "Card Size"
                , WlA.outlined
                , Slider.thumbLabel True
                , String.toInt
                    >> Maybe.andThen cardSizeFromValue
                    >> Maybe.withDefault Full
                    >> ChangeCardSize
                    >> wrap
                    |> HtmlE.onInput
                , settings.cardSize |> cardSizeToValue |> String.fromInt |> WlA.value
                ]
                [ Icon.viewStyled [ Slider.slot Slider.Before ] Icon.searchMinus
                , [ settings.cardSize |> cardSizeThumb ] |> Html.span [ Slider.slot Slider.ThumbLabel ]
                , Icon.viewStyled [ Slider.slot Slider.After ] Icon.searchPlus
                ]
            ]
        )
        [ Message.info Strings.CardSizeExplanation ]


cardSizeThumb : CardSize -> Html msg
cardSizeThumb size =
    case size of
        Minimal ->
            Icon.viewIcon Icon.minimalCardSize

        Square ->
            Icon.viewIcon Icon.squareCardSize

        Full ->
            Icon.viewIcon Icon.callCard


speechVoiceSelector : (Msg -> msg) -> Shared -> Html msg
speechVoiceSelector wrap shared =
    let
        selectedVoice =
            shared.settings.settings.speech.selectedVoice

        voices =
            shared.speech.voices

        enabled =
            shared.settings.settings.speech.enabled

        isDisabled =
            List.isEmpty voices

        notPossibleWarning =
            if isDisabled then
                Message.warning Strings.SpeechNotSupportedExplanation

            else
                Message.none
    in
    Html.div []
        [ Form.section shared
            "speech"
            (Html.div []
                [ Html.div
                    [ HtmlA.class "multipart" ]
                    [ Wl.switch
                        [ HtmlE.onCheck (ToggleSpeech >> wrap)
                        , HtmlA.disabled isDisabled
                        , HtmlA.checked enabled
                        ]
                    , Html.label []
                        [ Icon.viewIcon Icon.commentDots
                        , Html.text " "
                        , Strings.SpeechSetting |> Lang.html shared
                        ]
                    ]
                , Wl.select
                    [ HtmlE.onInput (ChangeSpeech >> wrap)
                    , Strings.VoiceSetting |> Lang.string shared |> WlA.label
                    , WlA.outlined
                    , HtmlA.disabled (not enabled || isDisabled)
                    ]
                    (voices |> List.sortWith defaultFirst |> List.map (speechVoiceOption selectedVoice))
                ]
            )
            [ Message.info Strings.SpeechExplanation
            , notPossibleWarning
            ]
        ]


defaultFirst : Speech.Voice -> Speech.Voice -> Order
defaultFirst a b =
    if a.default && b.default then
        EQ

    else if a.default then
        LT

    else
        GT


speechVoiceOption : Maybe String -> Speech.Voice -> Html msg
speechVoiceOption selectedVoice voice =
    let
        selected =
            if selectedVoice == Just voice.name then
                [ WlA.selected ]

            else
                []
    in
    Html.option
        (HtmlA.value voice.name :: selected)
        [ Html.text (voice.name ++ " (" ++ voice.lang ++ ")") ]


notificationsSwitch : (Msg -> msg) -> Shared -> Html msg
notificationsSwitch wrap shared =
    let
        settings =
            shared.settings.settings.notifications

        unsupported =
            not (Notifications.supportsNotifications shared.notifications)

        enabled =
            not unsupported && settings.enabled

        visibilityUnsupported =
            not (Notifications.supportsVisibility shared.notifications)

        visibilityDisabled =
            visibilityUnsupported || unsupported || not settings.enabled
    in
    Form.section shared
        "notifications"
        (Html.div []
            [ Html.div
                [ HtmlA.class "multipart" ]
                [ Wl.switch
                    [ HtmlE.onCheck (ToggleNotifications >> wrap)
                    , HtmlA.disabled unsupported
                    , HtmlA.checked enabled
                    ]
                , Html.label []
                    [ Icon.viewIcon Icon.bell
                    , Html.text " "
                    , Strings.NotificationsSetting |> Lang.html shared
                    ]
                ]
            , Html.div [ HtmlA.classList [ ( "children", True ), ( "inactive", not enabled ) ] ]
                [ Form.section
                    shared
                    "only-when-hidden"
                    (Html.div
                        [ HtmlA.class "multipart" ]
                        [ Wl.switch
                            [ HtmlE.onCheck (ToggleOnlyWhenHidden >> wrap)
                            , HtmlA.disabled visibilityDisabled
                            , HtmlA.checked settings.requireNotVisible
                            ]
                        , Html.label []
                            [ Icon.viewIcon Icon.eyeSlash
                            , Html.text " "
                            , Strings.NotificationOnlyWhenHiddenSetting |> Lang.html shared
                            ]
                        ]
                    )
                    [ Message.info Strings.NotificationsOnlyWhenHiddenExplanation
                    , if visibilityUnsupported then
                        Message.warning Strings.NotificationsUnsupportedExplanation

                      else
                        Message.none
                    ]
                ]
            ]
        )
        [ Message.info Strings.NotificationsExplanation
        , Message.info Strings.NotificationsBrowserPermissions
        , if unsupported then
            Message.warning Strings.NotificationsUnsupportedExplanation

          else
            Message.none
        ]


languageSelector : (Msg -> msg) -> Shared -> Html msg
languageSelector wrap shared =
    let
        selected =
            Lang.currentLanguage shared
    in
    Form.section
        shared
        "language"
        (Wl.select
            [ HtmlE.onInput (Lang.fromCode >> ChangeLang >> wrap)
            , Strings.LanguageSetting |> Lang.string shared |> WlA.label
            , WlA.outlined
            ]
            (Lang.languages |> List.map (languageOption selected))
        )
        [ Message.info Strings.MissingLanguage ]


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


ignore : (Msg -> msg) -> a -> msg
ignore wrap =
    always (NoOp |> wrap)
