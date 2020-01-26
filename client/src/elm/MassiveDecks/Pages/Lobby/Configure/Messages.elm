module MassiveDecks.Pages.Lobby.Configure.Messages exposing (Msg(..), Target(..))

import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Pages.Lobby.Configure.Decks.Model as Decks
import MassiveDecks.Pages.Lobby.Configure.Model exposing (..)


type Msg
    = DeckMsg Decks.Msg
    | ChangeTab Tab
    | StartGame
    | HandSizeChange Target Int
    | ScoreLimitChange Target (Maybe Int)
    | PasswordChange Target (Maybe String)
    | HouseRuleChange Target Rules.HouseRuleChange
    | PublicChange Target Bool
    | TogglePasswordVisibility
    | TimeLimitChangeMode Target Rules.TimeLimitMode
    | TimeLimitChange Target Round.Stage (Maybe Float)
    | RevertChanges
    | SaveChanges
    | NoOp


{-| We don't want to push every tiny change to the server. Instead we only push some changes.
-}
type Target
    = Remote
    | Local
