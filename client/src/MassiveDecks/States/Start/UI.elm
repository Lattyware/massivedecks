module MassiveDecks.States.Start.UI where

import String

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import MassiveDecks.Models.State exposing (StartData, Global, Error)
import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.States.SharedUI.General exposing (..)


view : Signal.Address Action -> Global -> StartData -> Html
view address global data =
  let
    errors = global.errors
    nameEntered = not (String.isEmpty data.name)
    lobbyIdEntered = not (String.isEmpty data.lobbyId)
    active = ([ class "mui--is-active" ],  " mui--is-active")
    inactive = ([], "")
    ((createLiClass, createDivClass), (joinLiClass, joinDivClass)) = case global.initialState.gameCode of
      Just val -> (inactive, active)
      Nothing -> (active, inactive)
  in
    div [ id "start-screen" ]
      [ div [ id "start-screen-content", class "mui-panel" ]
        [ h1 [ class "mui--divider-bottom" ] [ text "Massive Decks" ]
        , nameEntry address data.nameError
        , ul [ class "mui-tabs__bar mui-tabs__bar--justified" ]
          [ li createLiClass
              [ a [ attribute "data-mui-toggle" "tab", attribute "data-mui-controls" "pane-new" ] [ text "Create" ] ]
          , li joinLiClass [ a [ attribute "data-mui-toggle" "tab", attribute "data-mui-controls" "pane-existing" ] [ text "Join" ] ]
          ]
        , div [ class ("mui-tabs__pane" ++ createDivClass), id "pane-new" ] [ newGame address nameEntered ]
        , div [ class ("mui-tabs__pane" ++ joinDivClass), id "pane-existing" ]
          [ lobbyIdEntry address data.lobbyId data.lobbyIdError
          , joinGame address (nameEntered && lobbyIdEntered)
          ]
        , a [ class "about-link mui--divider-top link"
            , attribute "tabindex" "0"
            , attribute "role" "button"
            , attribute "onClick" "aboutOverlay()"
            ]
            [ icon "question-circle" , text " About" ]
        , errorMessages address errors
        , aboutOverlay
        , span [ id "forkongithub" ] [ a [ href "https://github.com/lattyware/massivedecks", target "_blank" ]
                                         [ icon "github", text " Fork me on GitHub" ] ]
        ]
      ]


nameEntry : Signal.Address Action -> Maybe String -> Html
nameEntry address error =
  div [] (List.append
    [ div [ class "nickname-entry mui-textfield" ]
        [ input [ type' "text"
                , placeholder "Nickname"
                , on "input" targetValue (\name -> Signal.message address (UpdateInputValue "name" name))
                ]
                []
        , label [] [ icon "info-circle", text " Your name in the game." ]
        ]
    ] (inputError error))

lobbyIdEntry : Signal.Address Action -> String -> Maybe String -> Html
lobbyIdEntry address val error =
  div [] (List.append
    [ div [ class "lobby-id-entry mui-textfield" ]
        [ input
          [ type' "text"
          , placeholder "Game Code"
          , on "input" targetValue (\name -> Signal.message address (UpdateInputValue "lobbyId" name))
          , value val
          ]
          []
        , label [] [ icon "info-circle", text " The code for the game to join." ]
        ]
    ] (inputError error))


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
