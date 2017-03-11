port module MassiveDecks.Components.BrowserNotifications exposing (Model, Message, ConsumerMessage(..), Permission(..), init, update, subscriptions, notify, enable, disable)

import Maybe
import MassiveDecks.Util as Util


init : Bool -> Bool -> Model
init supported enabled =
    { supported = supported
    , enabled = enabled
    , permission = Nothing
    }


type alias Model =
    { supported : Bool
    , enabled : Bool
    , permission : Maybe Permission
    }


type alias Notification =
    { title : String
    , icon : Maybe String
    }


type Permission
    = Granted
    | Denied
    | Default


update : Message -> Model -> ( Model, Cmd Message, Cmd ConsumerMessage )
update message model =
    case message of
        PermissionGiven permission ->
            ( { model | permission = Just permission }, Cmd.none, Util.cmd (PermissionChanged permission) )

        SendNotification notification ->
            if model.supported && model.enabled then
                ( model, notifications notification, Cmd.none )
            else
                ( model, Cmd.none, Cmd.none )

        EnableNotifications ->
            ( { model | enabled = True }, requestPermission (), Cmd.none )

        DisableNotifications ->
            ( { model | enabled = False }, Cmd.none, Cmd.none )


type ConsumerMessage
    = PermissionChanged Permission


type Message
    = PermissionGiven Permission
    | SendNotification Notification
    | EnableNotifications
    | DisableNotifications


subscriptions : Model -> Sub Message
subscriptions model =
    if model.supported && model.enabled && model.permission == Nothing then
        permissions permission
    else
        Sub.none


port permissions : (String -> msg) -> Sub msg


permission : String -> Message
permission name =
    let
        permission =
            case name of
                "granted" ->
                    Granted

                "denied" ->
                    Denied

                "default" ->
                    Default

                _ ->
                    let
                        _ =
                            Debug.log "Unexpected permission for browser notifications, assuming denied" name
                    in
                        Denied
    in
        PermissionGiven permission


notify : Notification -> Message
notify notification =
    SendNotification notification


port notifications : Notification -> Cmd msg


enable : Message
enable =
    EnableNotifications


disable : Message
disable =
    DisableNotifications


port requestPermission : () -> Cmd msg
