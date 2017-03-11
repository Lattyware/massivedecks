module MassiveDecks.Scenes.Config.Messages exposing (..)

import MassiveDecks.Components.Input as Input
import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Models.Card as Card
import MassiveDecks.Scenes.Playing.HouseRule.Id as HouseRule


{-| This type is used for all sending of messages, allowing us to send messages handled outside this scene.
-}
type ConsumerMessage
    = HandUpdate Card.Hand
    | ErrorMessage Errors.Message
    | LocalMessage Message


{-| The messages used in the start screen.
-}
type Message
    = AddDeck
    | ConfigureDecks Deck
    | InputMessage (Input.Message InputId)
    | AddAi
    | StartGame
    | EnableRule HouseRule.Id
    | DisableRule HouseRule.Id
    | SetPassword
    | NoOp


type Deck
    = Request DeckId
    | Add DeckId
    | Fail DeckId FailureMessage


type alias DeckId =
    String


type alias FailureMessage =
    String


{-| IDs for the inputs to differentiate between them in messages.
-}
type InputId
    = DeckId
    | Password
