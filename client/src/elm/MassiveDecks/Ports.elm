port module MassiveDecks.Ports exposing
    ( castStatus
    , copyText
    , languageChanged
    , notificationCommands
    , notificationState
    , remoteControl
    , serverRecv
    , serverSend
    , speechCommands
    , speechVoices
    , startConfetti
    , storeSettings
    , tryCast
    )

import Json.Decode as Json


port storeSettings : Json.Value -> Cmd msg


port tryCast : Json.Value -> Cmd msg


port castStatus : (Json.Value -> msg) -> Sub msg


port serverSend : Json.Value -> Cmd msg


port serverRecv : (String -> msg) -> Sub msg


port copyText : String -> Cmd msg


port speechCommands : Json.Value -> Cmd msg


port speechVoices : (Json.Value -> msg) -> Sub msg


port notificationCommands : Json.Value -> Cmd msg


port notificationState : (Json.Value -> msg) -> Sub msg


port remoteControl : (Json.Value -> msg) -> Sub msg


port languageChanged : String -> Cmd msg


port startConfetti : String -> Cmd msg
