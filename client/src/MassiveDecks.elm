module MassiveDecks exposing (main)

import String

import Navigation

import MassiveDecks.Models exposing (Init, Path)
import MassiveDecks.Scenes.Start as Start


{-| The main application loop setup.
-}
main : Program Init
main = Navigation.programWithFlags
  (Navigation.makeParser pathParser)
  { init = Start.init
  , update = Start.update
  , urlUpdate = Start.urlUpdate
  , subscriptions = Start.subscriptions
  , view = Start.view
  }

pathParser : Navigation.Location -> Path
pathParser location =
  { gameCode = Maybe.map snd (String.uncons location.hash)
  }
