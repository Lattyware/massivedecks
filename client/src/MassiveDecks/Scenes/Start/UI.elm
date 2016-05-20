module MassiveDecks.Scenes.Start.UI exposing (view)

import String

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import MassiveDecks.Components.Icon as Icon
import MassiveDecks.Components.About as About
import MassiveDecks.Components.Input as Input
import MassiveDecks.Scenes.Start.Models exposing (Model)
import MassiveDecks.Scenes.Start.Messages exposing (Message(..))


{-| Render the start screen.
-}
view : Model -> Html Message
view model =
  let
    nameEntered = not (String.isEmpty model.nameInput.value)
    gameCodeEntered = not (String.isEmpty model.gameCodeInput.value)
    active = ([ class "mui--is-active" ],  " mui--is-active")
    inactive = ([], "")
    ((createLiClass, createDivClass), (joinLiClass, joinDivClass)) =
      if model.init.gameCode /= Nothing then (inactive, active) else (active, inactive)
  in
    div [ id "start-screen" ]
        [ div [ id "start-screen-content", class "mui-panel" ]
              ([ h1 [ class "mui--divider-bottom" ] [ text "Massive Decks" ]
               ] ++ (model.info |> Maybe.map (\message -> [ div [ class "info-message mui--divider-bottom" ] [ Icon.icon "info-circle", text " ", text message ] ]) |> Maybe.withDefault []) ++
               [ Input.view model.nameInput
               , ul [ class "mui-tabs__bar mui-tabs__bar--justified" ]
                    [ li createLiClass [ a [ attribute "data-mui-toggle" "tab", attribute "data-mui-controls" "pane-new" ] [ text "Create" ] ]
                    , li joinLiClass [ a [ attribute "data-mui-toggle" "tab", attribute "data-mui-controls" "pane-existing" ] [ text "Join" ] ]
                   ]
               , div [ class ("mui-tabs__pane" ++ createDivClass), id "pane-new" ] [ createLobbyButton nameEntered ]
               , div [ class ("mui-tabs__pane" ++ joinDivClass), id "pane-existing" ]
                     [ Input.view model.gameCodeInput
                     , joinLobbyButton model.gameCodeInput.value (nameEntered && gameCodeEntered)
                     ]
               , a [ class "about-link mui--divider-top link"
                   , attribute "tabindex" "0"
                   , attribute "role" "button"
                   , attribute "onClick" "aboutOverlay()"
                   ]
                   [ Icon.icon "question-circle" , text " About" ]
               , About.aboutOverlay
               , div [ id "forkongithub" ] [ div [] [ a [ href "https://github.com/lattyware/massivedecks", target "_blank" ]
                                                        [ Icon.icon "github", text " Fork me on GitHub" ] ] ]
               ])
        ]


{-| A button to join an existing lobby.
-}
joinLobbyButton : String -> Bool -> Html Message
joinLobbyButton lobbyId enabled =
  button [ class "mui-btn mui-btn--large mui-btn--primary"
         , onClick (JoinLobbyAsNewPlayer lobbyId)
         , disabled (not enabled)
         ]
         [ text "Join Game" ]


{-| A button to create a new lobby.
-}
createLobbyButton : Bool -> Html Message
createLobbyButton enabled =
  button [ class "mui-btn mui-btn--large mui-btn--primary"
         , onClick CreateLobby
         , disabled (not enabled)
         ]
         [ text "Create Game" ]
