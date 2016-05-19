module MassiveDecks.Scenes.Lobby.UI exposing (view)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import MassiveDecks.Components.Icon exposing (..)
import MassiveDecks.Components.About exposing (..)
import MassiveDecks.Scenes.Config as Config
import MassiveDecks.Scenes.Playing as Playing
import MassiveDecks.Scenes.Lobby.Models exposing (Model)
import MassiveDecks.Scenes.Lobby.Messages exposing (ConsumerMessage(..), Message(..))
import MassiveDecks.Models.Player as Player exposing (Player, Status(..))
import MassiveDecks.Models.Notification as Notification exposing (Notification)
import MassiveDecks.Util as Util


view : Model -> Html ConsumerMessage
view model =
  let
    lobby = model.lobby
    url = model.init.url
    gameCode = lobby.gameCode
    players = lobby.players
    notification = model.notification
    (header, contents) = case lobby.round of
      Nothing -> ([], [ Config.view model |> Html.map (ConfigMessage >> LocalMessage) ])
      Just round ->
        let
          (h, c) = Playing.view model
        in
          (h |> List.map (Html.map (PlayingMessage >> LocalMessage)), c |> List.map (Html.map (PlayingMessage >> LocalMessage)))
  in
    root [ appHeader header notification
         , spacer
         , scores players
         , contentWrapper contents
         , inviteOverlay url gameCode
         , aboutOverlay
         ]


root : List (Html msg) -> Html msg
root contents = div [ class "content" ] contents


contentWrapper : List (Html msg) -> Html msg
contentWrapper contents = div [ id "content-wrapper" ] contents


spacer : Html msg
spacer = div [ class "mui--appbar-height" ] []


scores : List Player -> Html msg
scores players = div [ id "scores" ]
           [ div [ id "scores-title", class "mui--appbar-line-height mui--text-title" ] [ text "Players" ]
           , div [ class "mui-divider" ] []
           , table [ class "mui-table" ]
             (List.concat [ [ thead [] [ tr [] [ th [ class "state", title "State" ] [ icon "tasks" ]
                                , th [ class "name" ] [ text "Player" ]
                                , th [ class "score", title "Score" ] [ icon "star" ]
                                ] ]
                            ], List.map score players])
           ]

score : Player -> Html msg
score player =
  let
    classes = classList
      [ (Player.statusName player.status, True)
      , ("disconnected", player.disconnected)
      , ("left", player.left)
      ]
    prename = if player.disconnected then [ icon "minus-circle", text " " ] else []
  in
    tr [ classes ]
      [ td [ class "state", title (statusDescription player) ] [ (playerIcon player) ]
      , td [ class "name", title player.name ] (List.append prename [ text player.name ])
      , td [ class "score" ] [ text (toString player.score) ]
      ]


appHeader : List (Html ConsumerMessage) -> Maybe Notification -> Html ConsumerMessage
appHeader contents notification = (header [] [ div [ class "mui-appbar mui--appbar-line-height" ]
  [ div [ class "mui--appbar-line-height" ]
    [ span [ class "score-buttons" ] (List.append [ scoresButton True, scoresButton False ] (notificationPopup notification))
    , span [ id "title", class "mui--text-title mui--visible-xs-inline-block" ] contents
    , gameMenu ] ] ])


scoresButton : Bool -> Html msg
scoresButton shown =
  let
    showHideClasses = if shown then " mui--hidden-xs js-hide-scores" else " mui--visible-xs-inline-block js-show-scores"
  in
    button [ class ("scores-toggle mui-btn mui-btn--small mui-btn--primary badged" ++ showHideClasses)
           , title "Players."
           ] [ fwIcon "users" ]


notificationPopup : Maybe Notification -> List (Html ConsumerMessage)
notificationPopup notification =
  case notification of
    Just notification ->
      let
        hidden = if notification.visible then "" else "hide"
      in
        [ div [ class ("badge mui--z2 " ++ hidden)
              , title notification.description
              , onClick (LocalMessage (DismissNotification (Just notification)))
              ]
              [ icon notification.icon, text (" " ++ notification.name) ]
        ]
    Nothing ->
      [ div [ class ("badge mui--z2 hide") ] [] ]


statusDescription : Player -> String
statusDescription player = (case player.status of
  NotPlayed -> "Choosing"
  Played -> "Played"
  Czar -> "Round Czar"
  Ai -> "A Computer"
  Neutral -> ""
  Skipping -> "Being Skipped") ++ if player.disconnected then " (Disconnected)" else ""


statusIcon : Status -> Html msg
statusIcon status = Maybe.map fwIcon (statusIconName status) |> Maybe.withDefault (text "")


statusIconName : Status -> Maybe String
statusIconName status = case status of
  NotPlayed -> Just "hourglass"
  Played -> Just "check"
  Czar -> Just "gavel"
  Ai -> Just "cogs"
  Neutral -> Nothing
  Skipping -> Just "fast-forward"


playerIcon : Player -> Html msg
playerIcon player =
  if player.left then
    icon "sign-out"
  else
    statusIcon player.status


{-| The overlay for inviting players to a lobby.
-}
inviteOverlay : String -> String -> Html msg
inviteOverlay appUrl lobbyId =
  let
    url = Util.lobbyUrl appUrl lobbyId
  in
    div [ id "invite" ]
      [ div [ class "mui-panel" ]
        [ h1 [] [ icon "bullhorn", text " Invite Players" ]
        , p [] [ text "To invite other players, simply send them this link: " ]
        , p [] [ a [ href url ] [ text url ] ]
        , p [] [ text "Or give them this game code to enter on the start page: " ]
        , p [] [ input [ readonly True, value lobbyId ] [] ]
        , p [ class "close-link" ]
            [ a [ class "link"
                , attribute "tabindex" "0"
                , attribute "role" "button"
                , attribute "onClick" "closeOverlay()"
                ] [ icon "times", text " Close" ] ]
        ]
      ]


{-| The menu for the game.
-}
gameMenu : Html ConsumerMessage
gameMenu = div [ class "menu mui-dropdown" ]
  [ button [ class "mui-btn mui-btn--small mui-btn--primary"
           , attribute "data-mui-toggle" "dropdown"
           , title "Game menu."
           ] [ fwIcon "ellipsis-h" ]
  , ul [ class "mui-dropdown__menu mui-dropdown__menu--right" ]
     [ li [] [ a [ class "link"
                 , attribute "tabindex" "0"
                 , attribute "role" "button"
                 , attribute "onClick" "inviteOverlay()"
                 ] [ fwIcon "bullhorn", text " Invite Players" ] ]
     , li [] [ a [ class "link"
                 , attribute "tabindex" "0"
                 , attribute "role" "button"
                 , onClick Leave
                 ] [ fwIcon "sign-out", text " Leave Game" ] ]
     , li [ class "mui-divider" ] []
     , li [] [ a [ class "link"
                 , attribute "tabindex" "0"
                 , attribute "role" "button"
                 , attribute "onClick" "aboutOverlay()"
                 ] [ fwIcon "info-circle", text " About" ] ]
     , li [] [ a [ href "https://github.com/Lattyware/massivedecks/issues/new", target "_blank" ]
                 [ fwIcon "bug", text " Report a bug" ] ]
     ]
  ]
