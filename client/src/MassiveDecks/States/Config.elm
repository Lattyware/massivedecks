module MassiveDecks.States.Config where

import Time
import String
import Task
import Effects
import Html exposing (Html)

import MassiveDecks.States.Config.UI as UI
import MassiveDecks.Models.Player exposing (Secret)
import MassiveDecks.Models.Game exposing (Lobby)
import MassiveDecks.Models.State exposing (Model, State(..), ConfigData, StartData, playingData, Error, Global)
import MassiveDecks.Models.Notification as Notification
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..), eventEffects)
import MassiveDecks.Actions.Event exposing (Event(..))
import MassiveDecks.API as API
import MassiveDecks.API.Request as Request
import MassiveDecks.States.Playing as Playing


update : Action -> Global -> ConfigData -> (Model, Effects.Effects Action)
update action global data = case action of
  UpdateInputValue input value ->
    case input of
      "deckId" -> (model global { data | deckId = value }, Effects.none)
      _ -> (model global data, DisplayError "Got an update for an unknown input." |> Task.succeed |> Effects.task)

  SetInputError input error ->
    case input of
      "deckId" -> (model global { data | deckIdError = error }, Effects.none)
      _ -> (model global data, DisplayError "Got an error for an unknown input." |> Task.succeed |> Effects.task)

  AddDeck ->
    (model global data, AddGivenDeck data.deckId Request |> Task.succeed |> Effects.task)

  AddGivenDeck deckId Request ->
    (model global { data | loadingDecks = List.append data.loadingDecks [ deckId ] },
      ((API.addDeck data.lobby.id data.secret (String.toUpper deckId))
        |> Request.toEffectsWithOnError
            addDeckErrorHandler
            (AddGivenDeck deckId << Result)
            (\error -> FailAddDeck deckId)))

  AddGivenDeck deckId (Result lobbyAndHand) ->
    let
      (data, effects) = updateLobby data lobbyAndHand.lobby
    in
      (model global { data | loadingDecks = List.filter ((/=) deckId) data.loadingDecks
                           , deckIdError = Nothing
                           }, effects)

  FailAddDeck deckId ->
      (model global { data | loadingDecks = List.filter ((/=) deckId) data.loadingDecks }, Effects.none)

  AddAi ->
    (model global data,
      (API.newAi data.lobby.id)
        |> Request.toEffect (\_ -> NoAction) (\_ -> NoAction))

  StartGame ->
    (model global data, (API.newGame data.lobby.id data.secret)
      |> Request.toEffect (\error -> DisplayError (toString error)) UpdateLobbyAndHand)

  UpdateLobbyAndHand lobbyAndHand ->
    (Playing.model global (playingData lobbyAndHand.lobby lobbyAndHand.hand data.secret),
      eventEffects data.lobby lobbyAndHand.lobby)

  Notification lobby ->
    case lobby.round of
      Just _ -> (model global data,
        (API.getLobbyAndHand lobby.id data.secret)
          |> Request.toEffect (\error -> DisplayError (toString error))
            (\lobbyAndHand -> JoinLobby lobby.id data.secret (Result lobbyAndHand)))
      Nothing ->
        let
          (data, effects) = updateLobby data lobby
        in
          (model global data, effects)

  JoinLobby lobbyId secret (Result lobbyAndHand) ->
    case lobbyAndHand.lobby.round of
      Just _ ->
        (Playing.model global (playingData lobbyAndHand.lobby lobbyAndHand.hand secret),
          eventEffects data.lobby lobbyAndHand.lobby)
      Nothing ->
        let
          (data, effects) = updateLobby data lobbyAndHand.lobby
        in
          (model global data, effects)

  DismissPlayerNotification notification ->
    let
      updatedData =
        if data.playerNotification == notification then
          { data | playerNotification = Maybe.map Notification.hide data.playerNotification }
        else
          data
    in
      (model global updatedData, Effects.none)

  LeaveLobby ->
    ({ state = SStart (StartData "" Nothing "" Nothing), subscription = Just Nothing, global = global },
      (API.leave data.lobby.id data.secret)
        |> Request.toEffect (\_ -> NoAction) (\_ -> NoAction))

  GameEvent event ->
    case event of
      PlayerJoin id ->
        notificationChange global data (Notification.playerJoin id data.lobby.players)

      PlayerReconnect id ->
        notificationChange global data (Notification.playerReconnect id data.lobby.players)

      PlayerDisconnect id ->
        notificationChange global data (Notification.playerDisconnect id data.lobby.players)

      PlayerLeft id ->
        notificationChange global data (Notification.playerLeft id data.lobby.players)

      _ ->
        (model global data, Effects.none)

  other ->
    (model global data,
      DisplayError ("Got an action (" ++ (toString other) ++ ") that can't be handled in the current state (Config).")
      |> Task.succeed
      |> Effects.task)


addDeckErrorHandler : API.AddDeckError -> Action
addDeckErrorHandler error = case error of
  API.DeckNotFound -> SetInputError "deckId" (Just "The given deck doesn't exist, check the id is correct.")
  API.CardCastTimeout -> SetInputError "deckId" (Just "We couldn't get a response from CardCast. Try again later.")


notificationChange : Global -> ConfigData -> Maybe Notification.Player -> (Model, Effects.Effects Action)
notificationChange global data notification =
  let
    newNotification = Maybe.oneOf
      [ notification
      , data.playerNotification
      ]
  in
    ( model global { data | playerNotification = newNotification}
    , Task.sleep (Time.second * 5) `Task.andThen` (\_ -> Task.succeed (DismissPlayerNotification newNotification))
      |> Effects.task
    )


updateLobby : ConfigData -> Lobby -> (ConfigData, Effects.Effects Action)
updateLobby data lobby =
  let
    events = eventEffects data.lobby lobby
  in
    ({ data | lobby = lobby }, events)


model : Global -> ConfigData -> Model
model global data =
  { state = SConfig data
  , subscription = Nothing
  , global = global
  }


modelSub : Global -> String -> Secret -> ConfigData -> Model
modelSub global lobbyId secret data =
  { state = SConfig data
  , subscription = Just (Just { lobbyId = lobbyId, secret = secret })
  , global = global
  }


view : Signal.Address Action -> Global -> ConfigData -> Html
view address global data = UI.view address data global
