module MassiveDecks.Notifications exposing
    ( init
    , notify
    , requireNotVisible
    , setEnabled
    , subscriptions
    , supportsNotifications
    , supportsVisibility
    , update
    )

import Json.Decode
import Json.Encode as Json
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Notifications.Model exposing (..)
import MassiveDecks.Ports as Ports
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Result as Result


{-| The initial state of the model.
-}
init : Model
init =
    { permission = NotificationsUnsupported
    , visibility = VisibilityUnsupported
    }


{-| Change if notifications are enabled.
-}
setEnabled : Model -> Bool -> Settings -> ( Settings, Cmd msg )
setEnabled model enabled settings =
    let
        newSettings =
            { settings | enabled = enabled }
    in
    ( newSettings, requestPermission model newSettings )


{-| Change if we only send notifications when the browser tells us the page isn't visible.
-}
requireNotVisible : Bool -> Settings -> Settings
requireNotVisible rnv settings =
    { settings | requireNotVisible = rnv }


{-| If notifications are supported.
-}
supportsNotifications : Model -> Bool
supportsNotifications model =
    model.permission /= NotificationsUnsupported


{-| If visibility checks are supported.
-}
supportsVisibility : Model -> Bool
supportsVisibility model =
    model.visibility /= VisibilityUnsupported


{-| Send a notification to the user.
-}
notify : Shared -> Message -> Cmd msg
notify shared notification =
    let
        model =
            shared.notifications

        settings =
            shared.settings.settings.notifications
    in
    if settings.enabled && model.permission == Granted && (not settings.requireNotVisible || model.visibility /= Visible) then
        let
            message =
                Json.object
                    [ ( "title", notification.title |> Lang.string shared |> Json.string )
                    , ( "body", notification.body |> Lang.string shared |> Json.string )
                    ]
        in
        Ports.notificationCommands message

    else
        Cmd.none


{-| Update the state of the notification system with the given message.
-}
update : Settings -> Msg -> Model -> ( Model, Cmd msg )
update settings msg model =
    let
        newModel =
            { permission = msg.permission |> Maybe.withDefault model.permission
            , visibility = msg.visibility |> Maybe.withDefault model.visibility
            }

        cmd =
            if model.permission == NotificationsUnsupported then
                requestPermission model settings

            else
                Cmd.none
    in
    ( newModel, cmd )


{-| The subscriptions needed to operate the notification system.
-}
subscriptions : (Json.Decode.Error -> msg) -> (Msg -> msg) -> Sub msg
subscriptions wrapError wrapSuccess =
    (decodeMsg |> Json.Decode.decodeValue) >> Result.unifiedMap wrapError wrapSuccess |> Ports.notificationState



{- Private -}


decodeMsg : Json.Decode.Decoder Msg
decodeMsg =
    Json.Decode.map2 Msg
        (Json.Decode.maybe (Json.Decode.field "permission" decodePermission))
        (Json.Decode.maybe (Json.Decode.field "visibility" decodeVisibility))


decodePermission : Json.Decode.Decoder Permission
decodePermission =
    Json.Decode.string |> Json.Decode.andThen decodePermissionByName


decodePermissionByName : String -> Json.Decode.Decoder Permission
decodePermissionByName permission =
    case permission of
        "default" ->
            Json.Decode.succeed Default

        "denied" ->
            Json.Decode.succeed Denied

        "granted" ->
            Json.Decode.succeed Granted

        "unsupported" ->
            Json.Decode.succeed NotificationsUnsupported

        _ ->
            Json.Decode.fail ("Unknown notification permission '" ++ permission ++ "'.")


decodeVisibility : Json.Decode.Decoder Visibility
decodeVisibility =
    Json.Decode.string |> Json.Decode.andThen decodeVisibilityByName


decodeVisibilityByName : String -> Json.Decode.Decoder Visibility
decodeVisibilityByName visibility =
    case visibility of
        "visible" ->
            Json.Decode.succeed Visible

        "hidden" ->
            Json.Decode.succeed Hidden

        "unsupported" ->
            Json.Decode.succeed VisibilityUnsupported

        _ ->
            Json.Decode.fail ("Unknown page visibility '" ++ visibility ++ "'.")


requestPermission : Model -> Settings -> Cmd msg
requestPermission model settings =
    if settings.enabled && model.permission /= Granted && model.permission /= NotificationsUnsupported then
        Ports.notificationCommands (Json.string "request-permissions")

    else
        Cmd.none
