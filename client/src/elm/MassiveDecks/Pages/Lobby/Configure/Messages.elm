module MassiveDecks.Pages.Lobby.Configure.Messages exposing (Msg(..))

import MassiveDecks.Pages.Lobby.Configure.Decks.Model as Decks
import MassiveDecks.Pages.Lobby.Configure.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Privacy.Model as Privacy
import MassiveDecks.Pages.Lobby.Configure.Rules.Model as Rules
import MassiveDecks.Pages.Lobby.Configure.TimeLimits.Model as TimeLimits


type Msg
    = NameChange String
    | DecksMsg Decks.Msg
    | PrivacyMsg Privacy.Msg
    | TimeLimitsMsg TimeLimits.Msg
    | RulesMsg Rules.Msg
    | ChangeTab Tab
    | StartGame
    | ResolveConflict Source Id
    | SaveChanges
    | RevertChanges
    | NoOp
