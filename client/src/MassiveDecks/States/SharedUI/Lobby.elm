module MassiveDecks.States.SharedUI.Lobby (view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import MassiveDecks.Actions.Action exposing (Action(..))
import MassiveDecks.Models.Notification as Notification
import MassiveDecks.Models.Player exposing (Player, Status(..), statusName)
import MassiveDecks.States.SharedUI.General exposing (..)

view : Signal.Address Action -> String -> String -> List Html -> List Player -> Maybe Notification.Player -> List Html -> Html
view address url lobbyId header players notification contents =
  root [ appHeader address header notification
       , spacer
       , scores players
       , contentWrapper contents
       , inviteOverlay url lobbyId
       , aboutOverlay
       ]


contentWrapper : List Html -> Html
contentWrapper contents = div [ id "content-wrapper" ] contents


spacer : Html
spacer = div [ class "mui--appbar-height" ] []


scores : List Player -> Html
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

score : Player -> Html
score player =
  let
    classes = classList
      [ (statusName player.status, True)
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


appHeader : Signal.Address Action -> List Html -> Maybe Notification.Player -> Html
appHeader address contents notification = (header [] [ div [ class "mui-appbar mui--appbar-line-height" ]
  [ div [ class "mui--appbar-line-height" ]
    [ span [ class "score-buttons" ] (List.append [ scoresButton True, scoresButton False ] (notificationPopup address notification))
    , span [ id "title", class "mui--text-title mui--visible-xs-inline-block" ] contents
    , gameMenu address ] ] ])


scoresButton : Bool -> Html
scoresButton shown =
  let
    showHideClasses = if shown then " mui--hidden-xs js-hide-scores" else " mui--visible-xs-inline-block js-show-scores"
  in
    button [ class ("scores-toggle mui-btn mui-btn--small mui-btn--primary badged" ++ showHideClasses)
           , title "Players."
           ] [ fwIcon "users" ]


notificationPopup : Signal.Address Action -> Maybe Notification.Player -> List Html
notificationPopup address notification =
  case notification of
    Just notification ->
      let
        hidden = if notification.visible then "" else "hide"
      in
        [ div [ class ("badge mui--z2 " ++ hidden)
              , title notification.description
              , onClick address (DismissPlayerNotification (Just notification))
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


statusIcon : Status -> Html
statusIcon status = Maybe.map fwIcon (statusIconName status) |> Maybe.withDefault (text "")


statusIconName : Status -> Maybe String
statusIconName status = case status of
  NotPlayed -> Just "hourglass"
  Played -> Just "check"
  Czar -> Just "gavel"
  Ai -> Just "cogs"
  Neutral -> Nothing
  Skipping -> Just "fast-forward"


playerIcon : Player -> Html
playerIcon player =
  if player.left then
    icon "sign-out"
  else
    statusIcon player.status
