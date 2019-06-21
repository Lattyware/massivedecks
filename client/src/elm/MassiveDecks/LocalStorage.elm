module MassiveDecks.LocalStorage exposing
    ( Store
    , store
    )

import Json.Decode as Json
import MassiveDecks.Models.Encoders as Encoders
import MassiveDecks.Ports as Ports
import MassiveDecks.Settings.Model as Settings exposing (Settings)


{-| The type for an outbound port for storing user settings in local storage.
-}
type alias Store msg =
    Json.Value -> Cmd msg


store : Settings -> Cmd msg
store settings =
    settings |> Encoders.settings |> Ports.storeSettings
