module MassiveDecks.Scenes.Start.Models exposing (..)

import MassiveDecks.Models exposing (Init, Path)
import MassiveDecks.Scenes.Lobby.Models as Lobby
import MassiveDecks.Components.Tabs as Tabs
import MassiveDecks.Components.Input as Input
import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Components.Overlay as Overlay
import MassiveDecks.Components.Storage as Storage
import MassiveDecks.Scenes.Start.Messages exposing (Message, InputId, Tab)


{-| The state of the start screen.
-}
type alias Model =
    { lobby : Maybe Lobby.Model
    , init : Init
    , path : Path
    , nameInput : Input.Model InputId Message
    , gameCodeInput : Input.Model InputId Message
    , passwordInput : Input.Model InputId Message
    , passwordRequired : Maybe String
    , errors : Errors.Model
    , overlay : Overlay.Model Message
    , buttonsEnabled : Bool
    , tabs : Tabs.Model Tab Message
    , storage : Storage.Model
    }
