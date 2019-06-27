module MassiveDecks.Pages.Lobby.Configure.Messages exposing (Msg(..), Target(..))

import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Pages.Lobby.Configure.Model exposing (..)


type Msg
    = AddDeck Source.External
    | RemoveDeck Source.External
    | UpdateSource Source.External
    | ChangeTab Tab
    | StartGame
    | HandSizeChange Target Int
    | ScoreLimitChange Target (Maybe Int)
    | PasswordChange Target (Maybe String)
    | HouseRuleChange Target Rules.HouseRuleChange
    | PublicChange Target Bool
    | TogglePasswordVisibility


{-| We don't want to push every tiny change to the server. Instead we only push some changes.
-}
type Target
    = Remote
    | Local
