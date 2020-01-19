module MassiveDecks.Cast.Server exposing (..)

import Json.Decode as Json
import MassiveDecks.Cast.Model exposing (..)
import MassiveDecks.Models.Decoders as Decoders
import MassiveDecks.Ports as Ports
import MassiveDecks.Util.Result as Result


{-| A subscription to remote control events.
-}
remoteControl : (RemoteControlCommand -> msg) -> (Json.Error -> msg) -> Sub msg
remoteControl wrapCommand wrapError =
    Ports.remoteControl (Json.decodeValue Decoders.remoteControlCommand >> Result.unifiedMap wrapError wrapCommand)
