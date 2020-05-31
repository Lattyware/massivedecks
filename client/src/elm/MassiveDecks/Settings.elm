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
import Html as Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Http
import MassiveDecks.Card.Source as Source
import MassiveDecks.Card.Source.Model as Source
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
import MassiveDecks.Ports as Ports
import MassiveDecks.Requests.Api as Api
import MassiveDecks.Requests.Request as Request
import MassiveDecks.Settings.Messages exposing (..)
import MassiveDecks.Settings.Model exposing (..)
import MassiveDecks.Speech as Speech
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Strings.Languages.Model as Lang exposing (Language)
import MassiveDecks.Util.NeList exposing (NeList(..))
import MassiveDecks.Util.Order as Order
import Material.IconButton as IconButton
import Material.Select as Select
import Material.Slider as Slider
import Material.Switch as Switch


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

        langChanged =
            settings.chosenLanguage |> Maybe.map (Lang.code >> Ports.languageChanged)
    in
    ( { settings = settings
      , open = False
      }
    , [ Just cmd, langChanged ] |> List.filterMap identity |> Cmd.batch
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
    , autoAdvance = Nothing
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
            let
                ( newModel, cmd ) =
                    changeSettings (\s -> { s | chosenLanguage = language }) model

                langCmd =
                    language |> Maybe.map (Lang.code >> Ports.languageChanged)
            in
            ( newModel, [ Just cmd, langCmd ] |> List.filterMap identity |> Cmd.batch )

        ChangeCardSize size ->
            changeSettings (\s -> { s | cardSize = size }) model

        ChangeOpenUserList open ->
            changeSettings (\s -> { s | openUserList = open }) model

        RemoveInvalid tokenValidity ->
            let
                newTokens =
                    model.settings.tokens
                        |> Dict.filter (\_ -> \t -> List.member t tokenValidity)
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
                    voice |> Maybe.map (\v -> model.settings.speech |> Speech.selectVoice v)
            in
            changeSettings (\s -> { s | speech = newSpeechSettings |> Maybe.withDefault s.speech }) model

        ToggleAutoAdvance enabled ->
            changeSettings (\s -> { s | autoAdvance = Just enabled }) model

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
            IconButton.view shared Strings.SettingsTitle (NeList (icon |> Icon.present |> Icon.styled [ Icon.lg ]) []) (ToggleOpen |> wrap |> Just)

        panel =
            Html.div [ HtmlA.classList [ ( "settings-panel", True ), ( "mdc-card", True ), ( "open", model.open ) ] ]
                [ Html.h3 [] [ Strings.SettingsTitle |> Lang.html shared ]
                , Html.div [ HtmlA.class "body" ]
                    (List.intersperse (Html.hr [] [])
                        [ languageSelector wrap shared
                        , cardSize wrap shared
                        , autoAdvanceRound wrap shared
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
            [ Html.div
                [ HtmlA.class "card-size-slider" ]
                [ Icon.viewStyled [] Icon.minimalCardSize
                , Slider.view
                    [ HtmlA.class "primary"
                    , Slider.step 1
                    , Slider.min 1
                    , Slider.max 3
                    , Slider.pin
                    , Slider.markers
                    , cardSizeFromValue
                        >> Maybe.withDefault Full
                        >> ChangeCardSize
                        >> wrap
                        |> Slider.onChange
                    , settings.cardSize |> cardSizeToValue |> Slider.value
                    ]
                , Icon.viewStyled [] Icon.callCard
                ]
            ]
        )
        [ Message.info Strings.CardSizeExplanation ]


autoAdvanceRound : (Msg -> msg) -> Shared -> Html msg
autoAdvanceRound wrap shared =
    let
        settings =
            shared.settings.settings
    in
    Form.section shared
        "auto-advance"
        (Html.div
            [ HtmlA.class "multipart" ]
            [ Switch.view
                [ HtmlE.onCheck (ToggleAutoAdvance >> wrap)
                , HtmlA.checked (settings.autoAdvance |> Maybe.withDefault False)
                , HtmlA.id "auto-advance-enable"
                ]
            , Html.label [ HtmlA.for "auto-advance-enable" ]
                [ Icon.viewIcon Icon.commentDots
                , Html.text " "
                , Strings.AutoAdvanceSetting |> Lang.html shared
                ]
            ]
        )
        [ Message.info Strings.AutoAdvanceExplanation ]


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

        currentLanguage =
            shared |> Lang.currentLanguage

        voiceSortOrder =
            combinedOrder (NeList defaultFirst [ languageMatchFirst currentLanguage ])
    in
    Html.div []
        [ Form.section shared
            "speech"
            (Html.div []
                [ Html.div
                    [ HtmlA.class "multipart" ]
                    [ Switch.view
                        [ HtmlE.onCheck (ToggleSpeech >> wrap)
                        , HtmlA.disabled isDisabled
                        , HtmlA.checked enabled
                        , HtmlA.id "speech-enable"
                        ]
                    , Html.label [ HtmlA.for "speech-enable" ]
                        [ Icon.viewIcon Icon.commentDots
                        , Html.text " "
                        , Strings.SpeechSetting |> Lang.html shared
                        ]
                    ]
                , Html.div [ HtmlA.class "children" ]
                    [ Select.view shared
                        { label = Strings.VoiceSetting
                        , idToString = identity
                        , idFromString = Just
                        , selected = selectedVoice
                        , wrap = ChangeSpeech >> wrap
                        }
                        [ HtmlA.disabled (not enabled || isDisabled)
                        , HtmlA.class "secondary"
                        ]
                        (voices |> List.sortWith voiceSortOrder |> List.map speechVoiceOption)
                    ]
                ]
            )
            [ Message.info Strings.SpeechExplanation
            , notPossibleWarning
            ]
        ]


defaultFirst : Speech.Voice -> Speech.Voice -> Order
defaultFirst a b =
    if a.default == b.default then
        EQ

    else if a.default then
        LT

    else
        GT


languageMatchFirst : Language -> Speech.Voice -> Speech.Voice -> Order
languageMatchFirst lang =
    Lang.sortClosestFirst lang |> Order.map (.lang >> Lang.fromCode)


combinedOrder : NeList (a -> a -> Order) -> a -> a -> Order
combinedOrder (NeList first rest) a b =
    case rest of
        [] ->
            first a b

        next :: remaining ->
            let
                result =
                    first a b
            in
            case result of
                EQ ->
                    combinedOrder (NeList next remaining) a b

                _ ->
                    result


speechVoiceOption : Speech.Voice -> Select.ItemModel String msg
speechVoiceOption voice =
    { id = voice.name
    , icon = Nothing
    , primary = [ voice.name |> Html.text ]
    , secondary = Nothing
    , meta = Nothing
    }


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
                [ Switch.view
                    [ HtmlE.onCheck (ToggleNotifications >> wrap)
                    , HtmlA.disabled unsupported
                    , HtmlA.checked enabled
                    , HtmlA.id "notifications-enable"
                    ]
                , Html.label [ HtmlA.for "notifications-enable" ]
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
                        [ Switch.view
                            [ HtmlE.onCheck (ToggleOnlyWhenHidden >> wrap)
                            , HtmlA.disabled visibilityDisabled
                            , HtmlA.checked settings.requireNotVisible
                            , HtmlA.id "only-when-hidden-toggle"
                            ]
                        , Html.label [ HtmlA.for "only-when-hidden-toggle" ]
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
        (Select.view shared
            { label = Strings.LanguageSetting
            , idToString = Lang.code
            , idFromString = Lang.fromCode
            , selected = Just selected
            , wrap = ChangeLang >> wrap
            }
            []
            (Lang.languages |> List.map (languageOption shared selected))
        )
        [ Message.info Strings.MissingLanguage ]


languageOption : Shared -> Language -> Language -> Select.ItemModel Language msg
languageOption shared currentLanguage language =
    let
        nameInCurrentLanguage =
            language
                |> Lang.languageName
                |> Lang.givenLanguageString shared currentLanguage

        viewAutonym n =
            [ Html.span [ language |> Lang.langAttr ]
                [ Strings.AutonymFormat { autonym = n } |> Lang.html shared ]
            ]

        autonym =
            if language /= currentLanguage then
                language
                    |> Lang.autonym shared
                    |> viewAutonym
                    |> Just

            else
                Nothing
    in
    { id = language
    , icon = Nothing
    , primary = [ nameInCurrentLanguage |> Html.text ]
    , secondary = autonym
    , meta = Nothing
    }


ignore : (Msg -> msg) -> a -> msg
ignore wrap =
    always (NoOp |> wrap)
