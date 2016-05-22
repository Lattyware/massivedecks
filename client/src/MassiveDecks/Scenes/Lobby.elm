module MassiveDecks.Scenes.Lobby exposing (update, view, init, subscriptions)

import String
import Json.Decode as Json
import Json.Encode exposing (encode)
import Process
import Task
import Time

import WebSocket

import Html exposing (Html)

import MassiveDecks.Components.QR as QR
import MassiveDecks.Models exposing (Init)
import MassiveDecks.Models.JSON.Decode exposing (lobbyDecoder)
import MassiveDecks.Models.JSON.Encode exposing (encodePlayerSecret)
import MassiveDecks.Models.Game as Game
import MassiveDecks.Models.Notification as Notification exposing (Notification)
import MassiveDecks.Models.Player as Player
import MassiveDecks.Scenes.Playing as Playing
import MassiveDecks.Scenes.Playing.Messages as Playing
import MassiveDecks.Scenes.Config as Config
import MassiveDecks.Scenes.Config.Messages as Config
import MassiveDecks.Scenes.Lobby.Event as Event
import MassiveDecks.Scenes.Lobby.UI as UI
import MassiveDecks.Scenes.Lobby.Messages exposing (ConsumerMessage(..), Message(..))
import MassiveDecks.Scenes.Lobby.Models exposing (Model)
import MassiveDecks.Util as Util


{-| Create the initial model for the lobby.
-}
init : Init -> Game.LobbyAndHand -> Player.Secret -> (Model, Cmd ConsumerMessage)
init init lobbyAndHand secret =
  { lobby = lobbyAndHand.lobby
  , hand = lobbyAndHand.hand
  , config = Config.init
  , playing = Playing.init init
  , secret = secret
  , init = init
  , notification = Nothing
  } ! [ Cmd.map LocalMessage (WebSocket.send (webSocketUrl init.url lobbyAndHand.lobby.gameCode) (encodePlayerSecret secret |> encode 0))
      , QR.encodeAndRender "invite-qr-code" (Util.lobbyUrl init.url lobbyAndHand.lobby.gameCode)
      ]


{-| Subscriptions for the lobby.
-}
subscriptions : Model -> Sub ConsumerMessage
subscriptions model =
  let
    delegated = case model.lobby.round of
      Nothing -> Config.subscriptions model.config |> Sub.map ConfigMessage
      Just round -> Sub.none

    websocket = WebSocket.listen (webSocketUrl model.init.url model.lobby.gameCode) webSocketResponseDecoder
  in
    Sub.batch [ delegated |> Sub.map LocalMessage
              , websocket |> Sub.map LocalMessage
              ]


webSocketUrl : String -> String -> String
webSocketUrl url gameCode =
  let
    (protocol, rest) = case String.split ":" url of
      [] -> ("No protocol.", [])
      protocol :: rest -> (protocol, rest)
    host = String.join ":" rest

    baseUrl = case protocol of
      "http" ->
        "ws:" ++ host
      "https" ->
        "wss:" ++ host
      unknown ->
        let
          _ = Debug.log "Assuming https due to unknown protocol for URL" unknown
        in
          "wss:" ++ host
  in
    baseUrl ++ "lobbies/" ++ gameCode ++ "/notifications"


webSocketResponseDecoder : String -> Message
webSocketResponseDecoder response =
  case Json.decodeString lobbyDecoder response of
    Ok lobby ->
      LobbyUpdated lobby

    Err message ->
      let
        _ = Debug.log "Error from websocket" message
      in
        NoOp


{-| Render the lobby.
-}
view : Model -> Html ConsumerMessage
view model = UI.view model


{-| Handles messages and alters the model as appropriate.
-}
update : Message -> Model -> (Model, Cmd ConsumerMessage)
update message model =
  case message of
    ConfigMessage configMessage ->
      case configMessage of
        Config.ErrorMessage errorMessage ->
          (model, ErrorMessage errorMessage |> Util.cmd)

        Config.LobbyUpdate lobbyAndHand ->
          model |> updateLobbyAndHand lobbyAndHand

        Config.LocalMessage localMessage ->
          let
            (config, cmd) = Config.update localMessage model
          in
            ({ model | config = config }, Cmd.map (LocalMessage << ConfigMessage) cmd)

    PlayingMessage playingMessage ->
      case playingMessage of
        Playing.ErrorMessage errorMessage ->
          (model, ErrorMessage errorMessage |> Util.cmd)

        Playing.LobbyUpdate lobbyAndHand ->
          model |> updateLobbyAndHand lobbyAndHand

        Playing.LocalMessage localMessage ->
          let
            (playing, cmd) = Playing.update localMessage model
          in
            ({ model | playing = playing }, Cmd.map (LocalMessage << PlayingMessage) cmd)

    LobbyUpdated lobby ->
      model |> updateLobbyAndHand { lobby = lobby, hand = model.hand }

    DismissNotification notification ->
      let
        newModel =
          if model.notification == notification then
            { model | notification = Maybe.map Notification.hide model.notification }
          else
            model
      in
        (newModel, Cmd.none)

    GameEvent event ->
      let
        players = model.lobby.players
      in
        case event of
          Event.RoundEnd call czar responses playedByAndWinner ->
            let
              playingModel = model.playing
              newPlayingModel = { playingModel | finishedRound = Just (Game.FinishedRound call czar responses playedByAndWinner) }
            in
              ({ model | playing = newPlayingModel }, Cmd.none)

          Event.PlayerJoin id ->
            notificationChange model (Notification.playerJoin id players)

          Event.PlayerReconnect id ->
            notificationChange model (Notification.playerReconnect id players)

          Event.PlayerDisconnect id ->
            notificationChange model (Notification.playerDisconnect id players)

          Event.PlayerLeft id ->
            notificationChange model (Notification.playerLeft id players)

          _ ->
            (model, Cmd.none)

    NoOp ->
      (model, Cmd.none)


type alias Update = Model -> (Model, Cmd ConsumerMessage)


updateLobbyAndHand : Game.LobbyAndHand -> Update
updateLobbyAndHand lobbyAndHand model =
  let
    events = Event.events model.lobby lobbyAndHand.lobby |> List.map (GameEvent >> LocalMessage >> Util.cmd)
  in
    { model | lobby = lobbyAndHand.lobby
            , hand = lobbyAndHand.hand} ! events


{-| Handles a change to the displayed notification.
-}
notificationChange : Model -> Maybe Notification -> (Model, Cmd ConsumerMessage)
notificationChange model notification =
  let
    newNotification = Maybe.oneOf
      [ notification
      , model.notification
      ]
    dismiss = Process.sleep (Time.second * 5) `Task.andThen` (\_ -> Task.succeed (LocalMessage (DismissNotification newNotification)))
  in
    ( { model | notification = newNotification}
    , Task.perform identity (\_ -> LocalMessage NoOp) dismiss
    )
