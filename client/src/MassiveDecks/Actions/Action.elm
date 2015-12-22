module MassiveDecks.Actions.Action

  ( APICall(..)
  , Action(..)
  , batch

  , eventEffects

  ) where

import Task
import Effects

import MassiveDecks.Models.State exposing (InitialState)
import MassiveDecks.Models.Game exposing (Lobby, LobbyAndHand)
import MassiveDecks.Models.Player as Player
import MassiveDecks.Models.Notification as Notification
import MassiveDecks.Actions.Event exposing (Event, events)


{-| When an API request is made, there must be two actions - the first is the action that triggers the call to server,
and the second is the one that consumes the response from the server. The `APICall` type is used to encapsulate this.
The action takes an `APICall` of the result type of the response, and the API request is triggered with:

  SomeAction Request

And consumed with:

  SomeAction (Result ...)
-}
type APICall result
  = Request
  | Result result


{-| An action represents some kind of interaction with the state of the game. Any user action (or any knock-on effect),
or any input from JavaScript (via ports) is represented by an action.

* Pre-game
  * `SetInitialState` - Sets the initial state from outside Elm. Only used once, before the game loades into a state.
* Global (Used outside of states.)
  * `NoAction` - Do nothing at all - sometimes you are forced into having an action, but don't want to do anything.
  * `DisplayError` - Display a general error (should be avoided for more speicifc errors where possible - see
                     `SetInputError`).
  * `RemoveErrorPanel` - Remove an error.
  * `Batch` - An action that is a group of other actions. Just does them in order.
* General (Used across all states.)
  * `SetInputError` - Set the error text for an input field.
  * `UpdateInputValue` - Update the model to reflect the value of an input field.
* Start State
  * `NewLobby` - Creates a new game lobby.
  * `JoinExistingLobby` - Add a new player to the given lobby.
  * `JoinLobby` - Actually perform the act of joining a lobby.
* Config State
  * `AddDeck` - Add a deck to the game config based on the value of the input field in the model.
  * `AddGivenDeck` - Add a deck to the game with the given play code.
  * `FailAddDeck` - Cancel the deck load animation if the load fails.
  * `StartGame` - Start the actual game.
  * `AddAi` - Add a rando to the game.
* Config & Playing State
  * `Notification` - Update the game to the given lobby state.
  * `UpdateLobbyAndHand` - Change the lobby and hand of the player to match the new state.
  * `DismissPlayerNotification` - Dismiss a notification about players.
  * `LeaveLobby` - Leave the game.
  * `GameEvent` - An `Event`.
* Playing State
  * `Pick` - Pick a card from your hand by id, ready to play.
  * `Withdraw` - Withdraw a picked card by id.
  * `Play` - Play all the currently picked cards.
  * `Consider` - Consider a set of responses while judging.
  * `Choose` - Lock in the choice of winner while judging.
  * `NextRound` - Move to the next round.
  * `AnimatePlayedCards` - Trigger the animation of played cards.
  * `Skip` - Begin skipping the given players.
  * `Back` - Stop skipping this player.
-}
type Action
  {- Pre-game -}
  = SetInitialState InitialState
  {- Global (Used outside of states.) -}
  | NoAction
  | DisplayError String
  | RemoveErrorPanel Int
  | Batch (List Action)
  {- General (Used across all states.) -}
  | SetInputError String (Maybe String)
  | UpdateInputValue String String
  {- Start -}
  | NewLobby (APICall Lobby)
  | JoinExistingLobby
  | JoinLobby String Player.Secret (APICall LobbyAndHand)
  {- Config -}
  | AddDeck
  | AddGivenDeck String (APICall LobbyAndHand)
  | FailAddDeck String
  | StartGame
  | AddAi
  {- Config & Playing Shared -}
  | Notification Lobby
  | UpdateLobbyAndHand LobbyAndHand
  | DismissPlayerNotification (Maybe Notification.Player)
  | LeaveLobby
  | GameEvent Event
  {- Playing -}
  | Pick Int
  | Withdraw Int
  | Play
  | Consider Int
  | Choose Int
  | NextRound
  | AnimatePlayedCards (List Int)
  | Skip (List Player.Id)
  | Back


{-| Create an action that just triggers every action in the given list.
Note that if you are producing effects, it's generally better to batch the effects instead. However, that's not always
possible.
-}
batch : List Action -> Action
batch actions = Batch actions


{-| Creates effects that will cause `GameEvent`s `Action`s for the changes to the lobby.
See the `Event` documentation for more on events.
-}
eventEffects : Lobby -> Lobby -> Effects.Effects Action
eventEffects oldLobby newLobby =
  events oldLobby newLobby |> eventsToEffects


{- Private -}


{-| Turn events into effects so they can be consumed by the application cycle.
-}
eventsToEffects : List Event -> Effects.Effects Action
eventsToEffects events
  = events
  |> List.map GameEvent
  |> List.map Task.succeed
  |> List.map Effects.task
  |> Effects.batch
