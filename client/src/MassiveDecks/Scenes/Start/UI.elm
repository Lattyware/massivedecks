module MassiveDecks.Scenes.Start.UI exposing (view)

import String

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import MassiveDecks.Components.Tabs as Tabs
import MassiveDecks.Components.Icon as Icon
import MassiveDecks.Components.About as About
import MassiveDecks.Components.Input as Input
import MassiveDecks.Scenes.Start.Models exposing (Model)
import MassiveDecks.Scenes.Start.Messages exposing (Message(..), Tab(..))


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
    versionInfo = if String.isEmpty model.init.version then [] else [ text " Version ", text model.init.version ]
  in
    div [ id "start-screen" ]
        [ div [ id "start-screen-content", class "mui-panel" ]
              ([ h1 [ class "mui--divider-bottom" ] [ text "Massive Decks" ]
               ] ++ (model.info |> Maybe.map (\message -> [ div [ class "info-message mui--divider-bottom" ] [ Icon.icon "info-circle", text " ", text message ] ]) |> Maybe.withDefault []) ++
               [ Input.view model.nameInput
               ] ++ (Tabs.view (renderTab nameEntered gameCodeEntered model) model.tabs) ++
               [ a [ class "about-link mui--divider-top link"
                   , attribute "tabindex" "0"
                   , attribute "role" "button"
                   , onClick (About.show model.init.version |> OverlayMessage)
                   ]
                   [ Icon.icon "question-circle" , text " About" ]
               , div [ id "forkongithub" ] [ div [] [ a [ href "https://github.com/lattyware/massivedecks", target "_blank" ]
                                                        [ Icon.icon "github", text " Fork me on GitHub" ] ] ]
               ])
        , footer []
                 [ a [ href "https://github.com/Lattyware/massivedecks" ]
                     [ img [ src "images/icon.svg", alt "The Massive Decks logo.", title "Massive Decks" ] [] ]
                 , p [] versionInfo
                 ]
        ]

renderTab : Bool -> Bool -> Model -> Tab -> List (Html Message)
renderTab nameEntered gameCodeEntered model tab =
  case tab of
    Create ->
      [ createLobbyButton (nameEntered && model.buttonsEnabled) ]

    Join ->
      [ Input.view model.gameCodeInput
      , joinLobbyButton (nameEntered && gameCodeEntered && model.buttonsEnabled)
      ]

{-| A button to join an existing lobby.
-}
joinLobbyButton : Bool -> Html Message
joinLobbyButton enabled =
  button [ class "mui-btn mui-btn--large mui-btn--primary"
         , onClick JoinLobbyAsNewPlayer
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
