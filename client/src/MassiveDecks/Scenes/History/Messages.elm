module MassiveDecks.Scenes.History.Messages exposing (..)

import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Models.Game as Game


{-| This type is used for all sending of messages, allowing us to send messages handled outside this scene.
-}
type ConsumerMessage
  = ErrorMessage Errors.Message
  | Close
  | LocalMessage Message


{-| The messages used in the history scene.
-}
type Message
  = Load (List Game.FinishedRound)
