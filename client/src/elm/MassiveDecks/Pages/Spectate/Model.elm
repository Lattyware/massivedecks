module MassiveDecks.Pages.Spectate.Model exposing (..)

import MassiveDecks.Pages.Lobby.Model as Lobby


type alias Model =
    { lobby : Lobby.Model
    , advertise : Bool
    }
