module MassiveDecks.Scenes.History.UI exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import MassiveDecks.Scenes.History.Models exposing (Model)
import MassiveDecks.Scenes.History.Messages exposing (ConsumerMessage(..))
import MassiveDecks.Scenes.Playing.UI.Cards as CardsUI
import MassiveDecks.Models.Game.Round as Round exposing (Round)
import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.Player as Player exposing (Player)
import MassiveDecks.Components.Icon as Icon


view : Model -> List Player -> Html ConsumerMessage
view model players =
    let
        content =
            case model.rounds of
                Just rounds ->
                    Keyed.ul [] (List.map (\round -> ( round.call.id, finishedRound players round )) rounds)

                Nothing ->
                    Icon.spinner
    in
        div
            [ id "history" ]
            [ h1 [ class "mui--divider-bottom" ] [ text "Previous Rounds" ]
            , closeButton
            , content
            ]


finishedRound : List Player -> Round.FinishedRound -> Html msg
finishedRound players round =
    let
        state =
            round.state

        playedBy =
            state.playedByAndWinner.playedBy

        winner =
            state.playedByAndWinner.winner

        czar =
            Maybe.map
                (\player -> [ Icon.icon "gavel", text " ", text player.name ])
                (Player.byId round.czar players)
                |> Maybe.withDefault []

        playedCardsByPlayer =
            Card.playedCardsByPlayer playedBy state.responses |> Dict.toList
    in
        li
            [ class "round" ]
            [ div [] [ div [ class "who" ] czar, CardsUI.call round.call [] ]
            , Keyed.ul [ class "plays" ] (List.map (\( id, cards ) -> ( toString id, responses players winner id cards )) playedCardsByPlayer)
            ]


responses : List Player -> Player.Id -> Player.Id -> List Card.Response -> Html msg
responses players winnerId playerId responses =
    let
        winner =
            playerId == winnerId

        winnerPrefix =
            if (winner) then
                [ Icon.icon "trophy", text " " ]
            else
                []

        player =
            Maybe.map
                (\player -> winnerPrefix ++ [ text player.name ])
                (Player.byId playerId players)
                |> Maybe.withDefault []
    in
        li []
            [ div [ class "responses" ]
                [ div [ classList [ ( "who", True ), ( "won", winner ) ] ] player
                , Keyed.ul [] (List.map (\r -> ( r.id, li [] [ CardsUI.response False [] r ] )) responses)
                ]
            ]


closeButton : Html ConsumerMessage
closeButton =
    button
        [ class "mui-btn mui-btn--small mui-btn--fab"
        , onClick Close
        ]
        [ Icon.icon "times" ]
