module MassiveDecks.Models.Input.Identity

  ( Identity
  , target

  , name
  , lobbyId

  , deckId

  ) where

import MassiveDecks.Models.Input.Change as Change exposing (Change)


{-| The identity of an input - used to target it for changes.

Impelementation-wise the identity is actually a description of how to change the data for the state to update the
state of the input given the change to make. This is done by making the change a targeted change for the correct state.
-}
type alias Identity = Change -> Change.WithTarget


{-| Target the given change at the given identity.
-}
target : Change -> Identity -> Change.WithTarget
target change input = input change


{-| The name in the start state.
-}
name : Identity
name change = Change.Start (\startData -> { startData | name = change startData.name })


{-| The lobby id in the start state.
-}
lobbyId : Identity
lobbyId change = Change.Start (\startData -> { startData | lobbyId = change startData.lobbyId })


{-| The deck id in the config state.
-}
deckId : Identity
deckId change = Change.Config (\configData -> { configData | deckId = change configData.deckId })
