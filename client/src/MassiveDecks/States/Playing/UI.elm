module MassiveDecks.States.Playing.UI (view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import MassiveDecks.Models.State exposing (PlayingData, Error, Global)
import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.Player exposing (Player, Id, Status(..))
import MassiveDecks.Models.Game exposing (Round, FinishedRound)
import MassiveDecks.Models.Card exposing (Response, Responses(..), PlayedCards)
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.States.SharedUI.Lobby as LobbyUI
import MassiveDecks.States.SharedUI.General exposing (..)
import MassiveDecks.Util as Util


view : Signal.Address Action -> Global -> PlayingData -> Html
view address global data =
  let
    errors = global.errors
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
    LobbyUI.view address global.initialState.url data.lobby.id header lobby.players data.playerNotification
                 (List.concat [ infoBar data
                              , content
                              , [ warningDrawer address
                                    (List.concat [ skippingNotice address lobby.players data.secret.id
                                                 , disconnectedNotice address lobby.players
                                                 ])
                                ]
                              , [ errorMessages address errors ]
                              ])


roundContents : Signal.Address Action -> PlayingData -> Round -> List Html
roundContents address data round =
  let
    hand = data.hand.hand
    pickedWithIndex = Util.getAllWithIndex hand data.picked
    picked = List.map snd pickedWithIndex
    id = data.secret.id
    isCzar = round.czar == id
    hasPlayed = List.filter (\player -> player.id == id) data.lobby.players
      |> List.any (\player -> player.status == Played)
    callFill = case round.responses of
      Revealed responses ->
        Maybe.withDefault [] (data.considering `Maybe.andThen` (Util.get responses.cards))
      Hidden _ ->
        picked
    pickedOrChosen = case round.responses of
      Revealed responses ->
        case data.considering of
          Just considering ->
            case Util.get responses.cards considering of
              Just consideringCards -> [ consideringView address considering consideringCards isCzar ]
              Nothing -> []
          Nothing -> []
      Hidden _ -> pickedView address pickedWithIndex (Card.slots round.call) data.shownPlayed
    playedOrHand = case round.responses of
      Revealed responses -> playedView address isCzar responses
      Hidden _ -> handView address data.picked (isCzar || hasPlayed) hand
  in
    [ playArea
      [ div [ class "round-area" ] (List.concat [ [ call round.call callFill ], pickedOrChosen ])
      , playedOrHand
      ]
    ]


consideringView : Signal.Address Action -> Int -> List Response -> Bool -> Html
consideringView address considering consideringCards isCzar =
  let
    extra = if isCzar then [ chooseButton address considering ] else []
  in
    ol [ class "considering" ]
      (List.append (List.map (\card -> li [] [ (playedResponse card) ]) consideringCards) extra)


winnerContentsAndHeader : Signal.Address Action -> FinishedRound -> List Player -> (List Html, List Html)
winnerContentsAndHeader address round players =
  let
    cards = round.responses
    winning = Card.winningCards cards round.playedByAndWinner |> Maybe.withDefault []
    winner = Maybe.map .name (Util.get players round.playedByAndWinner.winner) |> Maybe.withDefault ""
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
call contents picked =
  let
    responseFirst = contents |> List.head |> Maybe.map ((==) "") |> Maybe.withDefault False
    (contents, picked) = if responseFirst then
        (contents, Util.mapFirst Util.firstLetterToUpper picked)
      else
        (Util.mapFirst Util.firstLetterToUpper contents, picked)
    spanned = List.map (\part -> span [] [ text part ]) contents
    withSlots = Util.interleave (slots (Card.slots contents) "" picked) spanned
    callContents = if responseFirst then List.tail withSlots |> Maybe.withDefault withSlots else withSlots
  in
    div [ class "card call mui-panel" ] [ div [ class "call-text" ] callContents ]


slot : String -> Html
slot value = (span [ class "slot" ] [ text value ])


slots : Int -> String -> List Response -> List Html
slots count placeholder picked =
  let
    extra = count - List.length picked
  in
    List.concat [picked, List.repeat extra placeholder] |> List.map slot


response : Signal.Address Action -> List Int -> Bool -> Int -> String -> Html
response address picked disabled responseId contents =
  let
    isPicked = List.member responseId picked
    pickedClass = if isPicked then " picked" else ""
    classes = [ class ("card response mui-panel" ++ pickedClass) ]
    clickHandler = if isPicked || disabled then [] else [ onClick address (Pick responseId) ]
  in
    div (List.concat [ classes, clickHandler ])
      [ div [ class "response-text" ] [ text (Util.firstLetterToUpper contents), text "." ] ]


blankResponse : Attribute -> Html
blankResponse positioning = div [ class "card mui-panel", positioning ] []


handRender : Bool -> List Html -> Html
handRender disabled contents =
  let
    classes = "hand mui--divider-top" ++ if disabled then " disabled" else ""
  in
    ul [ class classes ] (List.map (\item -> li [] [ item ]) contents)


handView : Signal.Address Action -> List Int -> Bool -> List Response -> Html
handView address picked disabled responses =
  handRender disabled (List.indexedMap (response address picked disabled) responses)


pickedResponse : Signal.Address Action -> (Int, String) -> Html
pickedResponse address (index, contents) =
  li [ onClick address (Withdraw index) ]
     [ div [ class "card response mui-panel" ] [ div [ class "response-text" ]
                                                     [ text (Util.firstLetterToUpper contents), text "." ] ] ]


pickedView : Signal.Address Action -> List (Int, Response) -> Int -> List Attribute -> List Html
pickedView address picked slots shownPlayed =
  let
    numberPicked = List.length picked
    pb = if (numberPicked < slots) then [] else [ playButton address ]
    pickedResponses = List.map (pickedResponse address) picked
  in
    [ ol [ class "picked" ] (List.concat [ pickedResponses, pb ])
    , div [ class "others-picked" ] (List.map blankResponse shownPlayed)
    ]


playButton : Signal.Address Action -> Html
playButton address = li [ class "play-button" ] [ button
  [ class "mui-btn mui-btn--small mui-btn--accent mui-btn--fab", onClick address Play ]
  [ icon "check" ] ]


playedView : Signal.Address Action -> Bool -> Card.RevealedResponses -> Html
playedView address isCzar responses =
  ol [ class "played mui--divider-top" ]
     (List.indexedMap (\index pc -> li [] [ (playedCards address isCzar index pc) ]) responses.cards)


playedCards : Signal.Address Action -> Bool -> Int -> PlayedCards -> Html
playedCards address isCzar playedId cards =
    ol
    [ onClick address (Consider playedId) ]
    (List.map (\card -> li [] [ (playedResponse card) ]) cards)


playedResponse : Response -> Html
playedResponse contents =
  div [ class "card response mui-panel" ]
    [ div [ class "response-text" ]
          [ text (Util.firstLetterToUpper contents), text "." ] ]


chooseButton : Signal.Address Action -> Int -> Html
chooseButton address playedId = li [ class "choose-button" ] [ button
  [ class "mui-btn mui-btn--small mui-btn--accent mui-btn--fab", onClick address (Choose playedId) ]
  [ icon "trophy" ] ]


infoBar : PlayingData -> List Html
infoBar data =
  let
    content = Maybe.oneOf [ statusInfo data.lobby.players data.secret.id, stateInfo data.lobby.round ]
  in
    case content of
      Just message ->
        [ div [ id "info-bar" ]
           [ icon "info-circle"
           , text " "
           , text message
           ]
        ]
      Nothing ->
        []


statusInfo : List Player -> Id -> Maybe String
statusInfo players id =
  case players |> Util.find (\player -> player.id == id) |> Maybe.map .status of
    Just status ->
      case status of
        Skipping ->
          Nothing {- There is a warning for this instead. -}
        Neutral ->
          Just "You joined while this round was already in play, you will be able to play next round."
        Czar ->
          Just "As card czar for this round - you don't play into the round, you pick the winner."
        _ ->
          Nothing
    Nothing ->
      Nothing


stateInfo : Maybe Round -> Maybe String
stateInfo round =
  round `Maybe.andThen` (\round ->
    case round.responses of
      Hidden _ ->
        Nothing
      Revealed _ ->
        Just "The card czar is now picking a winner.")


warningDrawer : Signal.Address Action -> List Html -> Html
warningDrawer address contents =
  let
    hidden = List.isEmpty contents
    classes =
      [ ("hidden", hidden)
      ]
  in
  div [ id "warning-drawer", classList classes ]
      [ button [ attribute "onClick" "toggleWarningDrawer()"
               , class "toggle mui-btn mui-btn--small mui-btn--fab"
               , title "Warning notices."
               ] [ icon "exclamation-triangle" ]
      , div [ class "top" ] []
      , div [ class "contents" ] contents
      ]


skippingNotice : Signal.Address Action -> List Player -> Id -> List Html
skippingNotice address players id =
  let
    status = players |> Util.find (\player -> player.id == id) |> Maybe.map .status
    renderSkippingNoticeIfSkipping = (\status ->
      case status of
        Skipping ->
          renderSkippingNotice address
        _ ->
          [])
  in
    Maybe.map renderSkippingNoticeIfSkipping status |> Maybe.withDefault []


renderSkippingNotice : Signal.Address Action -> List Html
renderSkippingNotice address =
  [ div [ class "notice" ]
    [ h3 [] [ icon "fast-forward" ]
    , span [] [ text "You are currently being skipped because you took too long to play."
              ]
    , div [ class "actions" ]
          [ button [ class "mui-btn mui-btn--small"
                   , onClick address Back
                   , title "Rejoin the game."
                   ]
                   [ icon "sign-in", text " Rejoin" ]
          ]
    ]
 ]


timeoutNotice : Signal.Address Action -> List Player -> Bool -> List Html
timeoutNotice address players timeout =
  let
    timedOutPlayers = List.filter (\player -> player.status == NotPlayed) players
    timedOutNames = Util.joinWithAnd (List.map .name timedOutPlayers)
    timedOutIds = List.map .id timedOutPlayers
  in
    if timeout then
      Maybe.map (renderTimeoutNotice address timedOutIds (Util.pluralHas timedOutPlayers)) timedOutNames
      |> Maybe.map (\item -> [ item ])
      |> Maybe.withDefault []
    else
      []


renderTimeoutNotice : Signal.Address Action -> List Id -> String -> String -> Html
renderTimeoutNotice address ids has names =
  div [ class "notice" ]
      [ h3 [] [ icon "minus-circle" ]
      , span [] [ text names
                , text " "
                , text has
                , text " not played into the round before the round timer ran out."
                ]
      , div [ class "actions" ]
            [ button [ class "mui-btn mui-btn--small"
                     , onClick address (Skip ids)
                     , title "They will be removed from this round, and won't be in future rounds until they come back."
                     ]
                     [ icon "fast-forward", text " Skip" ]
            ]
      ]


disconnectedNotice : Signal.Address Action -> List Player -> List Html
disconnectedNotice address players =
  let
    disconnected = List.filter (\player -> player.disconnected && (not (player.status == Skipping))) players
    disconnectedNames = Util.joinWithAnd (List.map .name disconnected)
    disconnectedIds = List.map .id disconnected
  in
    Maybe.map (renderDisconnectedNotice address disconnectedIds (Util.pluralHas disconnected)) disconnectedNames
    |> Maybe.map (\item -> [ item ])
    |> Maybe.withDefault []


renderDisconnectedNotice : Signal.Address Action -> List Id -> String -> String -> Html
renderDisconnectedNotice address ids has disconnectedNames =
  div [ class "notice" ]
      [ h3 [] [ icon "minus-circle" ]
      , span [] [ text disconnectedNames
                , text " "
                , text has
                , text " disconnected from the game."
                ]
      , div [ class "actions" ]
            [ button [ class "mui-btn mui-btn--small"
                     , onClick address (Skip ids)
                     , title "They will be removed from this round, and won't be in future rounds until they reconnect."
                     ]
                     [ icon "fast-forward", text " Skip" ]
            ]
      ]
