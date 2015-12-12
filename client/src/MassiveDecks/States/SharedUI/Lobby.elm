module MassiveDecks.States.SharedUI.Lobby where

import Html exposing (..)
import Html.Attributes exposing (..)

import MassiveDecks.Models.Player exposing (Player, Status(..), statusName)
import MassiveDecks.States.SharedUI.General exposing (..)

view : String -> String -> List Html -> List Player -> List Html -> Html
view url lobbyId header players contents =
  root [ appHeader header
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
  , td [ class "name", title player.name ] [ text player.name ]
  , td [ class "score" ] [ text (toString player.score) ]
  ]


appHeader : List Html -> Html
appHeader contents = (header [] [ div [ class "mui-appbar mui--appbar-line-height" ]
  [ div [ class "mui--appbar-line-height" ]
    [ span [] (List.append [ scoresButton True, scoresButton False ] (scoresBadge 0))
    , span [ id "title", class "mui--text-title mui--visible-xs-inline-block" ] contents
    , gameMenu ] ] ])


scoresButton : Bool -> Html
scoresButton shown =
  let
    showHideClasses = if shown then " mui--hidden-xs js-hide-scores" else " mui--visible-xs-inline-block js-show-scores"
  in
    button [ class ("scores-toggle mui-btn mui-btn--small mui-btn--primary badged" ++ showHideClasses)] [ icon "users" ]


scoresBadge : Int -> List Html
scoresBadge events =
  if events > 0 then
    [ div [ class "badge" ] [ icon "exclamation" ] ]
  else
    []


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
