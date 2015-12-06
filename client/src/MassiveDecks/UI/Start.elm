module MassiveDecks.UI.Start where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import MassiveDecks.Models.State exposing (Error)
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.UI.General exposing (..)


view : Signal.Address Action -> List Error -> Html
view address errors = div [ id "start-screen" ] (List.concat [
  [ div [ id "start-screen-content", class "mui-panel" ]
    [ h1 [] [ text "Massive Decks" ]
    , nameEntry address
    , ul [ class "mui-tabs__bar mui-tabs__bar--justified" ]
      [ li [ class "mui--is-active" ]
          [ a [ attribute "data-mui-toggle" "tab", attribute "data-mui-controls" "pane-new" ] [ text "Create" ] ]
      , li [] [ a [ attribute "data-mui-toggle" "tab", attribute "data-mui-controls" "pane-existing" ] [ text "Join" ] ]
      ]
    , div [ class "mui-tabs__pane mui--is-active", id "pane-new" ] [ newGame address ]
    , div [ class "mui-tabs__pane", id "pane-existing" ]
      [ lobbyIdEntry address
      , joinGame address
      ]
    ]
  ], [errorMessages address errors] ])


nameEntry : Signal.Address Action -> Html
nameEntry address = div [ class "nickname-entry mui-textfield" ]
  [ input [ type' "text"
          , placeholder "Nickname"
          , on "change" targetValue (\name -> Signal.message address (UpdateInputValue "name" name))
          ]
          []
  , label [] [ icon "info-circle", text " Your name in the game." ]
  ]


lobbyIdEntry : Signal.Address Action -> Html
lobbyIdEntry address = div [ class "lobby-id-entry mui-textfield" ]
  [ input [ type' "text"
          , placeholder "Game Code"
          , on "change" targetValue (\name -> Signal.message address (UpdateInputValue "lobbyId" name))
          ]
          []
  , label [] [ icon "info-circle", text " The code for the game to join." ]
  ]


joinGame : Signal.Address Action -> Html
joinGame address =
  button [ class "mui-btn mui-btn--large mui-btn--primary", onClick address JoinExistingLobby ] [ text "Join Game" ]


newGame : Signal.Address Action -> Html
newGame address =
  button [ class "mui-btn mui-btn--large mui-btn--primary", onClick address (NewLobby Request) ] [ text "Create Game" ]
