module MassiveDecks.Models.Input.Change

  ( WithTarget(..)

  , Change
  , update
  , setError
  , clearError
  , error

  ) where

import MassiveDecks.Models.Input exposing (State)
import MassiveDecks.Models.State exposing (StartData, ConfigData)


{-| A change in the state of an input, targeted at a specific input.

See `Actions.Action.InputUpdate` to use.
-}
type WithTarget
  = Start (StartData -> StartData)
  | Config (ConfigData -> ConfigData)


{-| A change in the state of an input.
-}
type alias Change = State -> State


{-| Update the value of an input.
-}
update : String -> Change
update value state = { state | value = value }


{-| Update or clear the error for an input.
-}
setError : Maybe String -> Change
setError error state = { state | error = error }


{-| Clear the error for an input.
-}
clearError : Change
clearError = setError Nothing


{-| Update the error for an input.
-}
error : String -> Change
error error = setError (Just error)
