module MassiveDecks.Pages.Lobby.Configure.Messages exposing (Msg(..))

import MassiveDecks.Pages.Lobby.Configure.Decks.Model as Decks
import MassiveDecks.Pages.Lobby.Configure.Model exposing (..)


type Msg
    = ApplyChange Id Config
    | DecksMsg Decks.Msg
    | ChangeTab Tab
    | StartGame
    | ResolveConflict Source Id
    | SetPasswordVisibility Bool
    | SaveChanges
    | RevertChanges
    | NoOp
