module MassiveDecks.Scenes.Config.Models exposing (..)

import MassiveDecks.Components.Input as Input
import MassiveDecks.Models.Game as Game
import MassiveDecks.Scenes.Config.Messages exposing (Message, InputId)


{-| The state of the config screen.
-}
type alias Model =
    { decks : List Game.DeckInfo
    , deckIdInput : Input.Model InputId Message
    , passwordInput : Input.Model InputId Message
    , loadingDecks : List String
    }
