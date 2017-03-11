module MassiveDecks.Scenes.Playing.Messages exposing (..)

import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Components.TTS as TTS
import MassiveDecks.Scenes.History.Messages as History
import MassiveDecks.Models.Player as Player
import MassiveDecks.Models.Game.Round as Round
import MassiveDecks.Models.Card as Card


{-| This type is used for all sending of messages, allowing us to send messages handled outside this scene.
-}
type ConsumerMessage
    = HandUpdate Card.Hand
    | TTSMessage TTS.Message
    | ErrorMessage Errors.Message
    | LocalMessage Message


{-| The messages used in the start screen.
-}
type Message
    = LobbyAndHandUpdated
    | Pick String
    | Withdraw String
    | Play
    | Consider Int
    | Choose Int
    | NextRound
    | AnimatePlayedCards
    | Skip (List Player.Id)
    | Back
    | Redraw
    | FinishRound Round.FinishedRound
    | ViewHistory
    | HistoryMessage History.ConsumerMessage
    | NoOp
