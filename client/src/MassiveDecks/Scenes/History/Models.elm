module MassiveDecks.Scenes.History.Models exposing (Model)

import MassiveDecks.Models.Game as Game


{-| The state of the lobby.
-}
type alias Model =
  { rounds : Maybe (List Game.FinishedRound)
  }
