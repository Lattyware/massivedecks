module MassiveDecks.UI.Lobby where

import Html exposing (..)
import Html.Attributes exposing (..)

import MassiveDecks.Models.Player exposing (Player, Status(..), statusName)
import MassiveDecks.UI.General exposing (..)

view : String -> List Html -> List Player -> List Html -> Html
view lobbyId header players contents =
  root [ appHeader header
       , spacer
       , scores players
       , contentWrapper contents
       , inviteOverlay lobbyId
       , aboutOverlay
       ]


contentWrapper : List Html -> Html
contentWrapper contents = div [ id "content-wrapper" ] contents


spacer : Html
spacer = div [ class "mui--appbar-height" ] []


scores : List Player -> Html
scores players = div [ id "scores" ]
           [ div [ id "scores-title", class "mui--appbar-line-height mui--text-title" ] [ text "Scores" ]
           , div [ class "mui-divider" ] []
           , table [ class "mui-table" ]
             (List.concat [ [ thead [] [ tr [] [ th [ class "state", title "State" ] [ icon "tasks" ]
                                , th [ class "name" ] [ text "Player" ]
                                , th [ class "score", title "Score" ] [ icon "star" ]
                                ] ]
             ], List.map score players])
           ]


score : Player -> Html
score player = tr [ class (statusName player.status), title (statusDescription player.status) ]
  [ td [ class "state" ] [ (statusIcon player.status) ]
  , td [ class "name" ] [ text player.name ]
  , td [ class "score" ] [ text (toString player.score) ]
  ]


appHeader : List Html -> Html
appHeader contents = (header [] [ div [ class "mui-appbar mui--appbar-line-height" ]
  [ div [ class "mui--appbar-line-height" ]
    [ button [ class "scores-toggle mui-btn mui-btn--small mui-btn--primary mui--visible-xs-inline-block js-show-scores" ] [ icon "users" ]
    , button [ class "scores-toggle mui-btn mui-btn--small mui-btn--primary mui--hidden-xs js-hide-scores" ] [ icon "users" ]
    , span [ id "title", class "mui--text-title mui--visible-xs-inline-block" ] contents
    , gameMenu ] ] ])


statusDescription : Status -> String
statusDescription status = case status of
  NotPlayed -> "Choosing"
  Played -> "Played"
  Czar -> "Round Czar"
  Disconnected -> "Disconnected"
  Left -> "Left Game"
  Neutral -> ""


statusIcon : Status -> Html
statusIcon status =  (case status of
  NotPlayed -> icon "hourglass"
  Played -> icon "check"
  Czar -> icon "gavel"
  Disconnected -> icon "minus-circle"
  Left -> icon "sign-out"
  Neutral -> text "")
