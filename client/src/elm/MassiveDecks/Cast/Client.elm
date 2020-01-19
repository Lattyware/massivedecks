module MassiveDecks.Cast.Client exposing
    ( subscriptions
    , tryCast
    )

import Json.Decode as Json
import MassiveDecks.Cast.Model exposing (..)
import MassiveDecks.Messages exposing (..)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Models.Decoders as Decoders
import MassiveDecks.Models.Encoders as Encoders
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Ports as Ports
import MassiveDecks.Strings.Languages as Lang


{-| Try to start a cast session.
-}
tryCast : Shared -> Lobby.Token -> Cmd msg
tryCast shared token =
    Spectate { token = token, language = Lang.currentLanguage shared } |> Encoders.remoteControlCommand |> Ports.tryCast


{-| The subscription to get messages about cast status changes.
-}
subscriptions : Sub Msg
subscriptions =
    Json.decodeValue Decoders.castStatus
        >> Result.toMaybe
        >> Maybe.withDefault NoDevicesAvailable
        >> CastStatusUpdate
        |> Ports.castStatus
