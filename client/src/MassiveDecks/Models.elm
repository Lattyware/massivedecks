module MassiveDecks.Models exposing (..)

import Navigation
import MassiveDecks.Models.Game exposing (GameCodeAndSecret)


{-| Data required to create the initial application state.
-}
type alias Init =
    { version : String
    , url : String
    , existingGames : List GameCodeAndSecret
    , seed : String
    , browserNotificationsSupported : Bool
    }


{-| A path to a part of the application.
-}
type alias Path =
    { gameCode : Maybe String
    }


pathFromLocation : Navigation.Location -> Path
pathFromLocation location =
    { gameCode = Maybe.map Tuple.second (String.uncons location.hash)
    }
