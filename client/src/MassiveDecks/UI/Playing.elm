module MassiveDecks.UI.Playing where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import MassiveDecks.Models.State exposing (PlayingData, Error)
import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.Player exposing (Player, Id)
import MassiveDecks.Models.Game exposing (Round)
import MassiveDecks.Models.Card exposing (Response, Responses(..), PlayedCards)
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.UI.Lobby as LobbyUI
import MassiveDecks.UI.General exposing (..)
import MassiveDecks.Util as Util


view : Signal.Address Action -> List Error -> PlayingData -> Html
view address errors data =
  let
    lobby = data.lobby
    (content, header) =
      case data.lastFinishedRound of
        Just round -> winnerContentsAndHeader address round lobby.players
        Nothing ->
          case lobby.round of
            Just round ->
              (roundContents address data round,
                [ icon "gavel", text (" " ++ (czarName lobby.players round.czar)) ])
            Nothing -> ([], [])
  in
    LobbyUI.view data.lobby.id header lobby.players (List.concat [ content, [ errorMessages address errors ] ])


roundContents : Signal.Address Action -> PlayingData -> Round -> List Html
roundContents address data round =
  let
    hand = data.hand.hand
    pickedWithIndex = (List.indexedMap (,) hand)
      |> List.filter (\item -> List.member (fst item) data.picked)
    picked = List.map snd pickedWithIndex
    isCzar = round.czar == data.secret.id
    pickedOrPlayed = case round.responses of
      Revealed responses -> playedView address isCzar responses
      Hidden others -> pickedView address pickedWithIndex (Card.slots round.call)
  in
    [ playArea [ call round.call picked, pickedOrPlayed]
               , handView address data.picked isCzar hand ]


winnerContentsAndHeader : Signal.Address Action -> Round -> List Player -> (List Html, List Html)
winnerContentsAndHeader address round players =
  let
    winning = case round.responses of
      Revealed revealed ->
          (Card.winningCards revealed.cards)
          |> Maybe.andThen revealed.playedByAndWinner
          |> Maybe.withDefault []
      Hidden _ -> []
    winner = case round.responses of
      Revealed revealed ->
          revealed.playedByAndWinner
          |> Maybe.map .winner
          |> Maybe.map (Util.get players)
          |> Maybe.map .name
          |> Maybe.withDefault ""
      Hidden _ -> ""
  in
    ([ div [ class "winner mui-panel" ]
       [ h1 [] [ icon "trophy" ]
       , h2 [] [ text (" " ++ Card.filled round.call winning) ]
       , h3 [] [ text ("- " ++ winner) ]
       ]
     , button [ id "next-round-button", class "mui-btn mui-btn--primary mui-btn--raised", onClick address NextRound ]
         [ text "Next Round" ]
     ], [ icon "trophy", text (" " ++ winner) ])


czarName : List Player -> Id -> String
czarName players czarId =
  (List.filter (\player -> player.id == czarId) players) |> List.head |> Maybe.map .name |> Maybe.withDefault ""


playArea : List Html -> Html
playArea contents = div [ class "play-area" ] contents


call : List String -> List Response -> Html
call contents picked = div [ class "card call mui-panel" ]
                    [ div [ class "call-text "] (Util.interleave (slots (Card.slots contents) "" picked) (List.map text contents)) ]


slot : String -> Html
slot value = (span [ class "slot" ] [ text value ])


slots : Int -> String -> List Response -> List Html
slots count placeholder picked =
  let
    extra = count - List.length picked
  in
    List.concat [picked, List.repeat extra placeholder] |> List.map slot


response : Signal.Address Action -> List Int -> Bool -> Int -> String -> Html
response address picked isCzar responseId contents =
  let
    isPicked = List.member responseId picked
    pickedClass = if isPicked then " picked" else ""
    classes = [ class ("card response mui-panel" ++ pickedClass) ]
    clickHandler = if isPicked || isCzar then [] else [ onClick address (Pick responseId) ]
  in
    div (List.concat [ classes, clickHandler ]) [ div [ class "response-text" ] [ text contents ] ]


handRender : Bool -> List Html -> Html
handRender isCzar contents =
  let
    classes = "hand mui--divider-top" ++ if isCzar then " disabled" else ""
  in
    ul [ class classes ] (List.map (\item -> li [] [ item ]) contents)


handView : Signal.Address Action -> List Int -> Bool -> List Response -> Html
handView address picked isCzar responses = handRender isCzar (List.indexedMap (response address picked isCzar) responses)


pickedResponse : Signal.Address Action -> (Int, String) -> Html
pickedResponse address (index, contents) =
  li [ onClick address (Withdraw index) ] [ div [ class "card response mui-panel" ] [ div [ class "response-text" ] [ text contents ] ] ]


pickedView : Signal.Address Action -> List (Int, Response) -> Int -> Html
pickedView address picked slots =
  let
    pb = if (List.length picked < slots) then [] else [ playButton address ]
  in
    ol [ class "picked" ] (List.concat [ (List.map (pickedResponse address) picked), pb ])


playButton : Signal.Address Action -> Html
playButton address = li [ class "play-button" ] [ button
  [ class "mui-btn mui-btn--small mui-btn--accent mui-btn--fab", onClick address (Play Request) ]
  [ icon "thumbs-up" ] ]


playedView : Signal.Address Action -> Bool -> Card.RevealedResponses -> Html
playedView address isCzar responses =
  ol [ class "played" ] (List.indexedMap (\index pc -> li [] [ (playedCards address isCzar index pc) ]) responses.cards)


playedCards : Signal.Address Action -> Bool -> Int -> PlayedCards -> Html
playedCards address isCzar playedId cards =
  let
    extra = if isCzar then [ chooseButton address playedId ] else []
  in
    ol [] (List.concat [ (List.map (\card -> li [] [ (playedResponse card) ]) cards), extra ])


playedResponse : Response -> Html
playedResponse contents =
  div [ class "card response mui-panel" ] [ div [ class "response-text" ] [ text contents ] ]


chooseButton : Signal.Address Action -> Int -> Html
chooseButton address playedId = li [ class "choose-button" ] [ button
  [ class "mui-btn mui-btn--small mui-btn--accent mui-btn--fab", onClick address (Choose playedId Request) ]
  [ icon "trophy" ] ]
