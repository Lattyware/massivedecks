module MassiveDecks.Scenes.Lobby exposing (update, view, init, subscriptions)

import String
import Json.Encode exposing (encode)
import Task
import Time

import WebSocket

import AnimationFrame

import Html exposing (Html)

import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Components.QR as QR
import MassiveDecks.Components.BrowserNotifications as BrowserNotifications
import MassiveDecks.Components.Overlay as Overlay exposing (Overlay)
import MassiveDecks.Components.TTS as TTS
import MassiveDecks.Models exposing (Init)
import MassiveDecks.Models.Event as Event exposing (Event)
import MassiveDecks.Models.JSON.Encode exposing (encodePlayerSecret)
import MassiveDecks.Models.Game as Game
import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.Notification as Notification exposing (Notification)
import MassiveDecks.Models.Player as Player exposing (Player)
import MassiveDecks.Scenes.Playing as Playing
import MassiveDecks.Scenes.Playing.Messages as Playing
import MassiveDecks.Scenes.Config as Config
import MassiveDecks.Scenes.Config.Messages as Config
import MassiveDecks.Scenes.Lobby.UI as UI
import MassiveDecks.Scenes.Lobby.Messages exposing (ConsumerMessage(..), Message(..))
import MassiveDecks.Scenes.Lobby.Models exposing (Model)
import MassiveDecks.Scenes.Lobby.Sidebar as Sidebar
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
  , sidebar = Sidebar.init 768 {- Should match the enhance-width in less. -}
  , tts = TTS.init
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
    baseUrl ++ "api/lobbies/" ++ gameCode ++ "/notifications"


webSocketResponseDecoder : String -> ConsumerMessage
webSocketResponseDecoder response =
  if (response == "identify") then
    Identify |> LocalMessage
  else
    case Event.fromJson response of
      Ok event ->
        LocalMessage <| Batch <| handleEvent event

      Err message ->
        ErrorMessage <| Errors.New ("Error handling notification: " ++ message) True


{-| Render the lobby.
-}
view : Model -> Html ConsumerMessage
view model = UI.view model


{-| Handles messages and alters the model as appropriate.
-}
update : Message -> Model -> (Model, Cmd ConsumerMessage)
update message model =
  let
    lobby = model.lobby
  in
    case message of
      ConfigMessage configMessage ->
        case configMessage of
          Config.ErrorMessage errorMessage ->
            (model, ErrorMessage errorMessage |> Util.cmd)

          Config.HandUpdate hand ->
            model |> updateLobbyAndHand (Game.LobbyAndHand model.lobby hand)

          Config.LocalMessage localMessage ->
            let
              (config, cmd) = Config.update localMessage model
            in
              ({ model | config = config }, Cmd.map (LocalMessage << ConfigMessage) cmd)

      PlayingMessage playingMessage ->
        case playingMessage of
          Playing.ErrorMessage errorMessage ->
            (model, ErrorMessage errorMessage |> Util.cmd)

          Playing.HandUpdate hand ->
            model |> updateLobbyAndHand (Game.LobbyAndHand model.lobby hand)

          Playing.TTSMessage ttsMessage ->
            (model, TTSMessage ttsMessage |> LocalMessage |> Util.cmd)

          Playing.LocalMessage localMessage ->
            let
              (playing, cmd) = Playing.update localMessage model
            in
              ({ model | playing = playing }, Cmd.map (LocalMessage << PlayingMessage) cmd)

      SidebarMessage sidebarMessage ->
        let
          (sidebarModel, cmd) = Sidebar.update sidebarMessage model.sidebar
        in
          ({ model | sidebar = sidebarModel }, Cmd.map (LocalMessage << SidebarMessage) cmd)

      TTSMessage ttsMessage ->
        let
          (ttsModel, cmd) = TTS.update ttsMessage model.tts
        in
          ({ model | tts = ttsModel }, Cmd.map (LocalMessage << TTSMessage) cmd)

      BrowserNotificationsMessage notificationMessage ->
        let
          (browserNotifications, localCmd, cmd) = BrowserNotifications.update notificationMessage model.browserNotifications
        in
          { model | browserNotifications = browserNotifications } !
            [ Cmd.map (LocalMessage << BrowserNotificationsMessage) localCmd
            , Cmd.map overlayAlert cmd
            ]

      BrowserNotificationForUser getUserId title iconName ->
        let
          cmd = case (getUserId lobby) of
            Just(id) ->
              if (id == model.secret.id) then
                Util.cmd (BrowserNotifications.notify { title = title, icon = icon model iconName } |> BrowserNotificationsMessage |> LocalMessage)
              else
                Cmd.none
            Nothing ->
              Cmd.none
        in
          (model, cmd)

      UpdateLobbyAndHand lobbyAndHand ->
        model |> updateLobbyAndHand lobbyAndHand

      UpdateLobby update ->
        model |> updateLobbyAndHand (Game.LobbyAndHand (update lobby) model.hand)

      UpdateHand hand ->
        model |> updateLobbyAndHand (Game.LobbyAndHand model.lobby hand)

      SetNotification notification ->
        notificationChange model (notification lobby.players)

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

      Batch messages ->
        model ! (List.map (Util.cmd << LocalMessage) messages)

      NoOp ->
        (model, Cmd.none)


handleEvent : Event -> List Message
handleEvent event =
  case event of
    Event.Sync lobbyAndHand ->
      [ UpdateLobbyAndHand lobbyAndHand ]

    Event.PlayerJoin player ->
      [ SetNotification (Notification.playerJoin player.id)
      , UpdateLobby (\lobby -> { lobby | players = lobby.players ++ [ player ] })
      ]
    Event.PlayerStatus player status ->
      let
        browserNotification = case status of
          Player.NotPlayed ->
            [ BrowserNotificationForUser (\_ -> Just player) "You need to play a card for the round." "hourglass" ]
          Player.Skipping ->
            [ BrowserNotificationForUser (\_ -> Just player) "You are being skipped due to inactivity." "fast-forward" ]
          _ ->
            []
      in
        [ updatePlayer player (\player -> { player | status = status })
        ] ++ browserNotification
    Event.PlayerLeft player ->
      [ SetNotification (Notification.playerLeft player)
      , updatePlayer player (\player -> { player | left = True })
      ]
    Event.PlayerDisconnect player ->
      [ SetNotification (Notification.playerDisconnect player)
      , updatePlayer player (\player -> { player | disconnected = True })
      ]
    Event.PlayerReconnect player ->
      [ SetNotification (Notification.playerReconnect player)
      , updatePlayer player (\player -> { player | disconnected = False })
      ]
    Event.PlayerScoreChange player score ->
      [ updatePlayer player (\player -> { player | score = score }) ]

    Event.HandChange hand ->
      [ UpdateHand hand ]

    Event.RoundStart czar call ->
      [ UpdateLobby (\lobby -> { lobby | round = Just (Game.Round czar call (Card.Hidden 0) False) }) ]
    Event.RoundPlayed playedCards ->
      [ updateRound (\round -> { round | responses = Card.Hidden playedCards }) ]
    Event.RoundJudging playedCards ->
        [ updateRound (\round -> { round | responses = Card.Revealed (Card.RevealedResponses playedCards Nothing)
                                         , afterTimeLimit = False })
        , BrowserNotificationForUser (\lobby -> lobby.round |> Maybe.map .czar) "You need to pick a winner for the round." "gavel"
        ]
    Event.RoundEnd finishedRound ->
      [ updateRound (\round -> { round | responses = Card.Revealed (Card.RevealedResponses finishedRound.responses (Just finishedRound.playedByAndWinner)) })
      , PlayingMessage <| Playing.LocalMessage <| Playing.FinishRound finishedRound
      ]

    Event.GameStart ->
      []
    Event.GameEnd ->
      [ UpdateLobby (\lobby -> { lobby | round = Nothing })
      , UpdateHand { hand = [] }
      ]

    Event.ConfigChange config ->
      [ UpdateLobby (\lobby -> { lobby | config = config }) ]

    Event.RoundTimeLimitHit ->
      [ updateRound (\round -> { round | afterTimeLimit = True }) ]


updatePlayer : Player.Id -> (Player -> Player) -> Message
updatePlayer playerId playerUpdate =
  UpdateLobby (\lobby -> { lobby | players = List.map (\player -> if player.id == playerId then playerUpdate player else player) lobby.players })


updateRound : (Game.Round -> Game.Round) -> Message
updateRound roundUpdate =
  UpdateLobby (\lobby -> { lobby | round = Maybe.map roundUpdate lobby.round })


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
  { model | lobby = lobbyAndHand.lobby
          , hand = lobbyAndHand.hand} !
    [ Util.cmd (Playing.LobbyAndHandUpdated |> Playing.LocalMessage |> PlayingMessage |> LocalMessage) ]


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
