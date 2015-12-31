module MassiveDecks.States.Start

  ( update
  , model
  , view
  , initialData

  ) where


import Task
import Maybe
import Effects
import Html exposing (Html)

import MassiveDecks.API as API
import MassiveDecks.API.Request as Request
import MassiveDecks.Models.Input.Change as Change
import MassiveDecks.Models.Input.Identity as Identity
import MassiveDecks.Models.State exposing (Model, State(..))
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.Models.State exposing (State(..), StartData, playingData, configData, Error, Global)
import MassiveDecks.States.Start.UI as UI
import MassiveDecks.States.Config as Config
import MassiveDecks.States.Playing as Playing


{-| Update the game model given the action that needs to happen.
-}
update : Action -> Global -> StartData -> (Model, Effects.Effects Action)
update action global data = case action of
  InputUpdate change ->
    case change of
      Change.Start change -> (model global (change data), Effects.none)
      Change.Config change -> (model global data, Effects.none)

  NewLobby Request ->
    (model global data, API.createLobby
      |> Request.toEffect (\error -> DisplayError (toString error)) (NewLobby << Result))

  NewLobby (Result lobby) ->
    (model global data,
      (API.newPlayer lobby.id data.name.value)
        |> Request.toEffect newPlayerErrorHandler (\secret -> JoinLobby lobby.id secret Request))

  JoinExistingLobby ->
    (model global data,
      (API.newPlayer data.lobbyId.value data.name.value)
        |> Request.toEffect newPlayerErrorHandler (\secret -> JoinLobby data.lobbyId.value secret Request))

  JoinLobby lobbyId secret Request ->
    (model global data,
      (API.getLobbyAndHand lobbyId secret)
        |> Request.toEffect (\error -> DisplayError (toString error)) (\lobbyAndHand -> JoinLobby lobbyId secret (Result lobbyAndHand)))

  JoinLobby lobbyId secret (Result lobbyAndHand) ->
    case lobbyAndHand.lobby.round of
      Just _ ->
        ( Playing.modelSub global lobbyId secret (playingData lobbyAndHand.lobby lobbyAndHand.hand secret)
        , Effects.none
        )

      Nothing ->
        (Config.modelSub global lobbyId secret
          (configData lobbyAndHand.lobby secret), Effects.none)

  Notification _ ->
    (model global data, Effects.none)

  DismissPlayerNotification _ ->
    (model global data, Effects.none)

  other ->
    (model global data,
      DisplayError ("Got an action (" ++ (toString other) ++ ") that can't be handled in the current state (Start).")
      |> Task.succeed
      |> Effects.task)


{-| Create a model for the start state.
-}
model : Global -> StartData -> Model
model global data =
  { state = SStart data
  , subscription = Nothing
  , global = global
  }


{-| Blank start data.
-}
initialData : String -> StartData
initialData lobbyId =
  { name = {value = "", error = Nothing}
  , lobbyId = { value = lobbyId, error = Nothing }
  }


{-| Render the start state.
-}
view : Signal.Address Action -> Global -> StartData -> Html
view address global data = UI.view address global data


{- Private -}


newPlayerErrorHandler : API.NewPlayerError -> Action
newPlayerErrorHandler error =
  let
    change = case error of
      API.LobbyNotFound ->
        Identity.target (Change.error "This game doesn't exist - check you have the right code.") Identity.lobbyId

      API.NameInUse ->
        Identity.target (Change.error "This name is in use in the game, try something else.") Identity.name
  in
    InputUpdate change
