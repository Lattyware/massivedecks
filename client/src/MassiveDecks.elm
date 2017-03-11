module MassiveDecks exposing (main)

import Navigation
import MassiveDecks.Models exposing (Init, Path, pathFromLocation)
import MassiveDecks.Scenes.Start as Start
import MassiveDecks.Scenes.Start.Messages as Start
import MassiveDecks.Scenes.Start.Models as Start


{-| The main application loop setup.
-}
main : Program Init Start.Model Start.Message
main =
    Navigation.programWithFlags
        locationToMessage
        { init = Start.init
        , update = Start.update
        , subscriptions = Start.subscriptions
        , view = Start.view
        }


locationToMessage : Navigation.Location -> Start.Message
locationToMessage location =
    pathFromLocation location |> Start.PathChange
