module MassiveDecks.Models.Input

  ( State
  , empty
  ) where


{-| The state of an input.
-}
type alias State =
  { value : String
  , error : Maybe String
  }


{-| An empty state for an input.
-}
empty : State
empty =
  { value = ""
  , error = Nothing
  }
