module MassiveDecks.UI.Start where

import String

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import MassiveDecks.Models.State exposing (StartData, Error)
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.UI.General exposing (..)


view : Signal.Address Action -> List Error -> StartData -> Html
view address errors data =
  let
    nameEntered = not (String.isEmpty data.name)
    lobbyIdEntered = not (String.isEmpty data.lobbyId)
  in
    div [ id "start-screen" ] (List.concat [
      [ div [ id "start-screen-content", class "mui-panel" ]
        [ h1 [] [ text "Massive Decks" ]
        , nameEntry address
        , ul [ class "mui-tabs__bar mui-tabs__bar--justified" ]
          [ li [ class "mui--is-active" ]
              [ a [ attribute "data-mui-toggle" "tab", attribute "data-mui-controls" "pane-new" ] [ text "Create" ] ]
          , li [] [ a [ attribute "data-mui-toggle" "tab", attribute "data-mui-controls" "pane-existing" ] [ text "Join" ] ]
          ]
        , div [ class "mui-tabs__pane mui--is-active", id "pane-new" ] [ newGame address nameEntered ]
        , div [ class "mui-tabs__pane", id "pane-existing" ]
          [ lobbyIdEntry address
          , joinGame address (nameEntered && lobbyIdEntered)
          ]
        ]
      ], [errorMessages address errors] ])


nameEntry : Signal.Address Action -> Html
nameEntry address = div [ class "nickname-entry mui-textfield" ]
  [ input [ type' "text"
          , placeholder "Nickname"
          , on "input" targetValue (\name -> Signal.message address (UpdateInputValue "name" name))
          ]
          []
  , label [] [ icon "info-circle", text " Your name in the game." ]
  ]


lobbyIdEntry : Signal.Address Action -> Html
lobbyIdEntry address = div [ class "lobby-id-entry mui-textfield" ]
  [ input [ type' "text"
          , placeholder "Game Code"
          , on "input" targetValue (\name -> Signal.message address (UpdateInputValue "lobbyId" name))
          ]
          []
  , label [] [ icon "info-circle", text " The code for the game to join." ]
  ]


joinGame : Signal.Address Action -> Bool -> Html
joinGame address canJoin =
  button
    [ class "mui-btn mui-btn--large mui-btn--primary"
    , onClick address JoinExistingLobby
    , disabled (not canJoin)
    ] [ text "Join Game" ]


newGame : Signal.Address Action -> Bool -> Html
newGame address canCreate =
  button
    [ class "mui-btn mui-btn--large mui-btn--primary"
    , onClick address (NewLobby Request)
    , disabled (not canCreate)
    ] [ text "Create Game" ]
