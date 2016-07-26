module MassiveDecks.Models exposing (..)

import MassiveDecks.Models.Game exposing (GameCodeAndSecret)


{-| Data required to create the initial application state.
-}
type alias Init =
  { version : String
  , url : String
  , existingGame : Maybe GameCodeAndSecret
  , seed : String
  , browserNotificationsSupported : Bool
  }


{-| A path to a part of the application.
-}
type alias Path =
  { gameCode : Maybe String
  }
