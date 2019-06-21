module MassiveDecks.Pages.Spectate.Messages exposing (Msg(..))

import MassiveDecks.Card.Play as Play
import MassiveDecks.Pages.Spectate.Model exposing (..)


type Msg
    = Rotations (List { play : Play.Id, rotation : Rotations })
