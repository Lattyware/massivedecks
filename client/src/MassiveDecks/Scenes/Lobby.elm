module MassiveDecks.Scenes.Lobby exposing (update, view, init, subscriptions)

import String
import Json.Decode as Json
import Json.Encode exposing (encode)
import Task
import Time

import WebSocket

import AnimationFrame

import Html exposing (Html)

import MassiveDecks.API as API
import MassiveDecks.API.Request as Request
import MassiveDecks.Components.QR as QR
import MassiveDecks.Components.BrowserNotifications as BrowserNotifications
import MassiveDecks.Components.Overlay as Overlay exposing (Overlay)
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
import MassiveDecks.Util as Util exposing ((:>))


{-| Create the initial model for the lobby.
-}
init : Init -> Game.LobbyAndHand -> Player.Secret -> (Model, Cmd ConsumerMessage)
init init lobbyAndHand secret =
  { lobby = lobbyAndHand.lobby
  , hand = lobbyAndHand.hand
  , config = Config.init
  , playing = Playing.init init
  , browserNotifications = BrowserNotifications.init init.browserNotificationsSupported False
  , secret = secret
  , init = init
  , notification = Nothing
  , qrNeedsRendering = False
  } ! []


{-| Subscriptions for the lobby.
-}
subscriptions : Model -> Sub ConsumerMessage
subscriptions model =
  let
    delegated = case model.lobby.round of
      Nothing -> Config.subscriptions model.config |> Sub.map ConfigMessage
      Just round -> Playing.subscriptions model.playing |> Sub.map PlayingMessage

    websocket = WebSocket.listen (webSocketUrl model.init.url model.lobby.gameCode) webSocketResponseDecoder

    browserNotifications = BrowserNotifications.subscriptions model.browserNotifications |> Sub.map BrowserNotificationsMessage

    render = if model.qrNeedsRendering then [ AnimationFrame.diffs (\_ -> LocalMessage RenderQr) ] else []
  in
    Sub.batch ([ delegated |> Sub.map LocalMessage
               , websocket
               , browserNotifications |> Sub.map LocalMessage
               ] ++ render)


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


webSocketResponseDecoder : String -> ConsumerMessage
webSocketResponseDecoder response =
  if (response == "identify") then
    Identify |> LocalMessage
  else
    case Json.decodeString lobbyDecoder response of
      Ok lobby ->
        UpdateLobby lobby |> LocalMessage

      Err message ->
        let
          _ = Debug.log "Error from websocket" message
        in
          NoOp |> LocalMessage


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

    BrowserNotificationsMessage notificationMessage ->
      let
        (browserNotifications, localCmd, cmd) = BrowserNotifications.update notificationMessage model.browserNotifications
      in
        { model | browserNotifications = browserNotifications } !
          [ Cmd.map (LocalMessage << BrowserNotificationsMessage) localCmd
          , Cmd.map overlayAlert cmd
          ]

    UpdateLobby lobby ->
      model |> updateLobbyAndHand { lobby = lobby, hand = model.hand }
            :> updateHandIfRoundStarted

    UpdateHand hand ->
      model |> updateLobbyAndHand { lobby = model.lobby, hand = hand }

    Identify ->
      (model, Cmd.map LocalMessage (WebSocket.send (webSocketUrl model.init.url model.lobby.gameCode) (encodePlayerSecret model.secret |> encode 0)))

    DisplayInviteOverlay ->
      { model | qrNeedsRendering = True } ! [ Util.cmd (UI.inviteOverlay model.init.url model.lobby.gameCode |> OverlayMessage) ]

    RenderQr ->
      { model | qrNeedsRendering = False } ! [ QR.encodeAndRender "invite-qr-code" (Util.lobbyUrl model.init.url model.lobby.gameCode) ]

    DismissNotification notification ->
      let
        newModel =
          if model.notification == Just notification then
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
              newPlayingModel = { playingModel | finishedRound = Just (Game.FinishedRound czar call responses playedByAndWinner) }
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

          Event.RoundJudging _ ->
            case model.lobby.round of
              Nothing ->
                (model, Cmd.none)

              Just round ->
                let
                  cmd = if (round.czar == model.secret.id) then
                    Util.cmd (BrowserNotifications.notify { title = "You need to pick a winner for the round.", icon = icon model "gavel" } |> BrowserNotificationsMessage |> LocalMessage)
                  else
                    Cmd.none
                in
                  (model, cmd)

          Event.PlayerStatus id status ->
            let
              cmd = if (id == model.secret.id) then
                case status of
                  Player.NotPlayed ->
                    Util.cmd (BrowserNotifications.notify { title = "You need to play a card for the round.", icon = icon model "hourglass" } |> BrowserNotificationsMessage |> LocalMessage)
                  Player.Skipping ->
                    Util.cmd (BrowserNotifications.notify { title = "You are being skipped due to inactivity.", icon = icon model "fast-forward"} |> BrowserNotificationsMessage |> LocalMessage)
                  _ ->
                    Cmd.none
              else
                Cmd.none
            in
              (model, cmd)

          _ ->
            (model, Cmd.none)

    NoOp ->
      (model, Cmd.none)


overlayAlert : BrowserNotifications.ConsumerMessage -> ConsumerMessage
overlayAlert message =
  case message of
    BrowserNotifications.PermissionChanged permission ->
      case permission of
        BrowserNotifications.Denied ->
          (Overlay.Show (Overlay "times-circle" "Can't enable desktop notifications."
            [ Html.text "You did not give Massive Decks permission to give you desktop notifications." ])
          ) |> OverlayMessage

        _ ->
          NoOp |> LocalMessage


icon : Model -> String -> Maybe String
icon model name = Just (model.init.url ++ "assets/images/icons/" ++ name ++ ".png")


type alias Update = Model -> (Model, Cmd ConsumerMessage)


updateLobbyAndHand : Game.LobbyAndHand -> Update
updateLobbyAndHand lobbyAndHand model =
  let
    events
      = Event.events model.lobby lobbyAndHand.lobby
      |> List.map (GameEvent >> LocalMessage >> Util.cmd)
    commands = [ Util.cmd (Playing.LobbyAndHandUpdated |> Playing.LocalMessage |> PlayingMessage |> LocalMessage) ] ++ events
  in
    { model | lobby = lobbyAndHand.lobby
            , hand = lobbyAndHand.hand} ! commands


{-| If the player didn't make the call the start the game, they will only recieve a notification about it, which won't
give them their hand. We check if we have started a new round, and don't have a hand - if so we go get it.
-}
updateHandIfRoundStarted : Update
updateHandIfRoundStarted model =
  let
    cmd = case model.lobby.round of
      Just value ->
        if (List.isEmpty model.hand.hand) then
          Request.send' (API.getHand model.lobby.gameCode model.secret) ErrorMessage (LocalMessage << UpdateHand)
        else
          Cmd.none

      Nothing ->
        Cmd.none
  in
    (model, cmd)


{-| Handles a change to the displayed notification.
-}
notificationChange : Model -> Maybe Notification -> (Model, Cmd ConsumerMessage)
notificationChange model notification =
  let
    newNotification = Maybe.oneOf
      [ notification
      , model.notification
      ]
    cmd = case newNotification of
      Just nn ->
        let
          dismiss = Util.after (Time.second * 5) (Task.succeed nn)
        in
          Task.perform Util.impossible (LocalMessage << DismissNotification) dismiss

      Nothing ->
        Cmd.none
  in
    ({ model | notification = newNotification }, cmd)
