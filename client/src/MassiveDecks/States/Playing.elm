module MassiveDecks.States.Playing

  ( update
  , model
  , modelSub
  , view

  ) where


import Time
import Task
import Effects
import Html exposing (Html, Attribute)
import Html.Attributes exposing (style)
import Random exposing (Generator, Seed, list, bool, int)

import MassiveDecks.Models.Player exposing (Secret)
import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.Game exposing (Lobby, FinishedRound)
import MassiveDecks.Models.State exposing (State(..), Model, ConfigData, StartData, configData, PlayingData, Error, Global)
import MassiveDecks.Models.Notification as Notification
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..), eventEffects)
import MassiveDecks.Actions.Event exposing (Event(..))
import MassiveDecks.States.Playing.UI as UI
import MassiveDecks.API as API
import MassiveDecks.API.Request as Request
import MassiveDecks.Util as Util


{-| Update the game model given the action that needs to happen.
-}
update : Action -> Global -> PlayingData -> (Model, Effects.Effects Action)
update action global data = case action of
  Pick card ->
    let
      canPlay = (List.length data.picked) < Maybe.withDefault 0 (Maybe.map (\round -> Card.slots round.call) data.lobby.round)
      playing = Maybe.withDefault False (Maybe.map (\round -> case round.responses of
        Card.Revealed _ -> False
        Card.Hidden _ -> True
      ) data.lobby.round)
    in
      if playing && canPlay then
        (model global { data | picked = List.append data.picked [card] }, Effects.none)
      else
        (model global data, Effects.none)

  Withdraw card ->
    (model global { data | picked = List.filter ((/=) card) data.picked }, Effects.none)

  Play ->
    (model global data,
      (API.play data.lobby.id data.secret data.picked)
        |> Request.toEffect (\error -> DisplayError (toString error)) UpdateLobbyAndHand)

  Notification lobby ->
    case lobby.round of
      Just _ -> (model global { data | lobby = lobby }, eventEffects data.lobby lobby)
      Nothing -> (configModel global (configData lobby data.secret), Effects.none)

  JoinLobby lobbyId secret (Result lobbyAndHand) ->
    case lobbyAndHand.lobby.round of
      Just _ -> (model global { data | lobby = lobbyAndHand.lobby
                                     , hand = lobbyAndHand.hand
                                     }, eventEffects data.lobby lobbyAndHand.lobby)
      Nothing -> (configModel global (configData lobbyAndHand.lobby data.secret), Effects.none)

  Consider potentialWinner ->
    (model global { data | considering = Just potentialWinner } , Effects.none)

  Choose winner ->
    (model global data, (API.choose data.lobby.id data.secret winner)
      |> Request.toEffect (\error -> DisplayError (toString error)) UpdateLobbyAndHand)

  Skip players ->
    (model global data, (API.skip data.lobby.id data.secret players)
      |> Request.toEffect (\error -> DisplayError (toString error)) UpdateLobbyAndHand)

  UpdateLobbyAndHand lobbyAndHand ->
      (model global
        { data | lobby = lobbyAndHand.lobby
               , hand = lobbyAndHand.hand
               }, eventEffects data.lobby lobbyAndHand.lobby)

  NextRound ->
    (model global { data | lastFinishedRound = Nothing
                         , picked = []
                         , considering = Nothing
                         }, Effects.none)

  AnimatePlayedCards toAnimate ->
    let
      (shownPlayed, seed) = updatePositioning toAnimate data.shownPlayed global.seed
    in
      (model { global | seed = seed } { data | shownPlayed = shownPlayed }, Effects.none)

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
      (API.leave data.lobby.id data.secret) |> Request.toEffect (\_ -> NoAction) (\_ -> NoAction))

  GameEvent event ->
    case event of
      RoundPlayed amount ->
        let
          (shownPlayed, effects, seed) = addShownPlayed amount data.shownPlayed global.seed
        in
          (model { global | seed = seed } { data | shownPlayed = shownPlayed }, effects)

      RoundEnd call czar responses playedByAndWinner ->
        (model global { data | lastFinishedRound = Just (FinishedRound call czar responses playedByAndWinner)
                             , shownPlayed = []
                             } , Effects.none)

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
      DisplayError ("Got an action (" ++ (toString other) ++ ") that can't be handled in the current state (Playing).")
      |> Task.succeed
      |> Effects.task)


{-| Create a model for the playing state.
-}
model : Global -> PlayingData -> Model
model global data =
  { state = SPlaying data
  , subscription = Nothing
  , global = global
  }


{-| Create a model for the playing state that also subscribes to a notification websocket for the given lobby.
-}
modelSub : Global -> String -> Secret -> PlayingData -> Model
modelSub global lobbyId secret data =
  { state = SPlaying data
  , subscription = Just (Just { lobbyId = lobbyId, secret = secret })
  , global = global
  }


{-| Create a model for the config state.

We'd pull this in from `Config`, but then we'd have a circular import.
-}
configModel : Global -> ConfigData -> Model
configModel global data =
  { state = SConfig data
  , subscription = Nothing
  , global = global
  }


{-| Render the playing state.
-}
view : Signal.Address Action -> Global -> PlayingData -> Html
view address global playingData = UI.view address global playingData


{- Private -}


notificationChange : Global -> PlayingData -> Maybe Notification.Player -> (Model, Effects.Effects Action)
notificationChange global data notification =
  let
    newNotification = Maybe.oneOf
      [ notification
      , data.playerNotification
      ]
  in
    ( model global { data | playerNotification = newNotification}
    , Task.sleep (Time.second * 5) `Task.andThen` (\_ -> Task.succeed (DismissPlayerNotification newNotification)) |> Effects.task
    )


addShownPlayed : Int -> List Attribute -> Seed -> (List Attribute, Effects.Effects Action, Seed)
addShownPlayed amount existing seed =
  let
    existingLength = List.length existing
    (new, newSeed) = Random.generate (list (amount - existingLength) initialRandomPositioning) seed
  in
    ( List.concat [ existing, new ]
    , (Task.sleep (Time.millisecond * 250)
        `Task.andThen`
        \_ -> (Task.succeed (AnimatePlayedCards (Util.range existingLength (List.length new)))))
      |> Effects.task
    , newSeed
    )

updatePositioning : List Int -> List Attribute -> Seed -> (List Attribute, Seed)
updatePositioning toAnimate existing seed =
  let
    generator = (\index val -> if (List.member index toAnimate) then randomPositioning else Random.map (\_ -> val) bool)
    generators = List.indexedMap generator existing
  in
    Random.generate (Util.inOrder generators) seed


randomPositioning : Generator Attribute
randomPositioning = Random.map4 positioning (int -75 75) (int 0 50) bool (int -5 1)


initialRandomPositioning : Generator Attribute
initialRandomPositioning = Random.map3 (\r h l -> positioning r h l -100) (int -75 75) (int 0 50) bool


positioning : Int -> Int -> Bool -> Int -> Attribute
positioning rotation horizontalPos left verticalPos =
  let
    horizontalDirection = if left then "left" else "right"
  in
    style
      [ ("transform", "rotate(" ++ (toString rotation) ++ "deg)")
      , (horizontalDirection, (toString horizontalPos) ++ "%")
      , ("top", (toString verticalPos) ++ "%")
      ]
