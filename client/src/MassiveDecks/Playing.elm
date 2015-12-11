module MassiveDecks.Playing where

import Time
import Task
import Effects
import Html exposing (Html, Attribute)
import Html.Attributes exposing (style)
import Random exposing (Generator, Seed, list, bool, int)

import MassiveDecks.Models.Player exposing (Secret)
import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.Game exposing (Lobby)
import MassiveDecks.Models.State exposing (State(..), Model, ConfigData, PlayingData, Error, Global)
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.UI.Playing as UI
import MassiveDecks.API as API
import MassiveDecks.Util as Util


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

  Play Request ->
    (model global data, (API.play data.lobby.id data.secret data.picked) |> Task.map (Play << Result) |> API.toEffect)

  Play (Result lobbyAndHand) ->
    let
      (data, effect, seed) = (updateLobby data lobbyAndHand.lobby global.seed)
    in
      (model { global | seed = seed }
        { data | hand = lobbyAndHand.hand
               , picked = []
               }, effect)

  Notification lobby ->
    case lobby.round of
      Just _ ->
        let
          (data, effect, seed) = (updateLobby data lobby global.seed)
        in
          (model { global | seed = seed } data, effect)
      Nothing -> (configModel global (ConfigData lobby data.secret ""), Effects.none)

  JoinLobby lobbyId secret (Result lobbyAndHand) ->
    case lobbyAndHand.lobby.round of
      Just _ ->
        let
          (data, effect, seed) = (updateLobby data lobbyAndHand.lobby global.seed)
        in
          (model { global | seed = seed } data, effect)
      Nothing -> (configModel global (ConfigData lobbyAndHand.lobby data.secret ""), Effects.none)

  Choose winner Request ->
    (model global data, (API.choose data.lobby.id data.secret winner) |> Task.map (Choose winner << Result) |> API.toEffect)

  Choose winner (Result lobbyAndHand) ->
    let
      (data, effect, seed) = (updateLobby data lobbyAndHand.lobby global.seed)
    in
      (model { global | seed = seed }
        { data | hand = lobbyAndHand.hand
               , picked = []
               }, effect)

  NextRound ->
    (model global { data | lastFinishedRound = Nothing }, Effects.none)

  AnimatePlayedCards toAnimate ->
    let
      (shownPlayed, seed) = updatePositioning toAnimate data.shownPlayed global.seed
    in
      (model { global | seed = seed } { data | shownPlayed = (Debug.log "shownPlayed" shownPlayed) }, Effects.none)

  other ->
    (model global data,
      DisplayError ("Got an action (" ++ (toString other) ++ ") that can't be handled in the current state (Playing).")
      |> Task.succeed
      |> Effects.task)


updateLobby : PlayingData -> Lobby -> Seed -> (PlayingData, Effects.Effects Action, Seed)
updateLobby data lobby seed =
  let
    lastFinishedRound = if (Maybe.map .call data.lobby.round) == (Maybe.map .call lobby.round) then
      data.lastFinishedRound
    else
      data.lobby.round
    oldShownPlayed = data.shownPlayed
    oldShownPlayedLength = (List.length oldShownPlayed)
    (shownPlayed, effects, resultSeed) = case Maybe.map .responses data.lobby.round of
      Just (Card.Hidden amount) ->
        let
          (newShownPlayed, newSeed) =
            Random.generate (list (amount - oldShownPlayedLength) initialRandomPositioning) seed
        in
          (List.concat [ oldShownPlayed, newShownPlayed ]
          ,(Task.sleep (Time.millisecond * 250)
           `Task.andThen`
           \_ -> (Task.succeed (AnimatePlayedCards (Util.range oldShownPlayedLength (List.length newShownPlayed)))))
           |> Effects.task
          ,newSeed)
      _ -> ([], Effects.none, seed)
  in
    ({ data | lobby = lobby
            , lastFinishedRound = lastFinishedRound
            , shownPlayed = shownPlayed
            }, effects, resultSeed)


updatePositioning : List Int -> List Attribute -> Seed -> (List Attribute, Seed)
updatePositioning toAnimate existing seed =
  let
    generator = (\index val -> if (List.member index toAnimate) then randomPositioning else Random.map (\_ -> val) bool)
    generators = List.indexedMap generator (Debug.log "existing" existing)
  in
    Random.generate (Util.inOrder generators) seed


randomPositioning : Generator Attribute
randomPositioning = Random.map4 positioning (int -75 75) (int 0 50) bool (int -5 5)


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


model : Global -> PlayingData -> Model
model global data =
  { state = SPlaying data
  , jsAction = Nothing
  , global = global
  }


modelSub : Global -> String -> Secret -> PlayingData -> Model
modelSub global lobbyId secret data =
  { state = SPlaying data
  , jsAction = Just { lobbyId = lobbyId, secret = secret }
  , global = global
  }


configModel : Global -> ConfigData -> Model
configModel global data =
  { state = SConfig data
  , jsAction = Nothing
  , global = global
  }


view : Signal.Address Action -> Global -> PlayingData -> Html
view address global playingData = UI.view address global playingData
