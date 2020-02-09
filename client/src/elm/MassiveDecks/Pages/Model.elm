module MassiveDecks.Pages.Model exposing (Page(..))

import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Pages.Start.Model as Start
import MassiveDecks.Pages.Unknown.Model as Unknown


{-| A distinct page within the app.
-}
type Page
    = Start Start.Model
    | Lobby Lobby.Model
    | Unknown Unknown.Model
    | Loading
