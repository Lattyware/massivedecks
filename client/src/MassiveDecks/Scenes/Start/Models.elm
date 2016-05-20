module MassiveDecks.Scenes.Start.Models exposing (..)

import MassiveDecks.Models exposing (Init)
import MassiveDecks.Scenes.Lobby.Models as Lobby
import MassiveDecks.Components.Input as Input
import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Scenes.Start.Messages exposing (Message, InputId(..))


{-| The state of the start screen.
-}
type alias Model =
  { lobby : Maybe Lobby.Model
  , init : Init
  , nameInput : Input.Model InputId Message
  , gameCodeInput : Input.Model InputId Message
  , info : Maybe String
  , errors : Errors.Model
  }
