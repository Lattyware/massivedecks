module MassiveDecks.Scenes.History.UI exposing (view)

import Dict

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import MassiveDecks.Scenes.History.Models exposing (Model)
import MassiveDecks.Scenes.History.Messages exposing (ConsumerMessage(..))
import MassiveDecks.Scenes.Playing.UI.Cards as CardsUI
import MassiveDecks.Models.Game as Game
import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.Player as Player exposing (Player)
import MassiveDecks.Components.Icon as Icon


view : Model -> List Player -> Html ConsumerMessage
view model players =
  let
    content = case model.rounds of
      Just rounds ->
        ul [] (List.map (finishedRound players) rounds)

      Nothing ->
        Icon.spinner
  in
    div
      [ id "history" ]
      [ h1 [ class "mui--divider-bottom" ] [ text "Previous Rounds" ]
      , closeButton
      , content
      ]


finishedRound : List Player -> Game.FinishedRound -> Html msg
finishedRound players round =
  let
    czar =
      Maybe.map
        (\player -> [ Icon.icon "gavel", text " ", text player.name ])
        (Player.byId round.czar players) |> Maybe.withDefault []
    playedCardsByPlayer = Card.playedCardsByPlayer round.playedByAndWinner.playedBy round.responses |> Dict.toList
  in
    li
      [ class "round" ]
      [ div [] [ div [ class "who" ] czar, CardsUI.call round.call [] ]
      , ul [ class "plays" ] (List.map (responses players round.playedByAndWinner.winner) playedCardsByPlayer)
      ]


responses : List Player -> Player.Id -> (Player.Id, List Card.Response) -> Html msg
responses players winnerId idAndResponses =
  let
    (playerId, responses) = idAndResponses
    winner = playerId == winnerId
    winnerPrefix = if (winner) then [ Icon.icon "trophy", text " " ] else []
    player =
      Maybe.map
        (\player -> winnerPrefix ++ [ text player.name ])
        (Player.byId playerId players) |> Maybe.withDefault []
  in
    li []
       [ div [ class "responses" ]
             [ div [ classList [ ("who", True), ("won", winner) ] ] player
             , ul [] (List.map (\r -> li [] [ CardsUI.response False [] r ]) responses)
             ]
       ]


closeButton : Html ConsumerMessage
closeButton =
  button
    [ class "mui-btn mui-btn--small mui-btn--fab"
    , onClick Close
    ]
    [ Icon.icon "times" ]
