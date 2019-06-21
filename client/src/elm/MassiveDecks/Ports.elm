port module MassiveDecks.Ports exposing
    ( castStatus
    , copyText
    , serverRecv
    , serverSend
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
