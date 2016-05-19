module MassiveDecks exposing (main)

import Html.App as App

import MassiveDecks.Models exposing (Init)
import MassiveDecks.Scenes.Start as Start


{-| The main application loop setup.
-}
main : Program Init
main = App.programWithFlags
  { init = Start.init
  , update = Start.update
  , subscriptions = Start.subscriptions
  , view = Start.view
  }
