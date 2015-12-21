module MassiveDecks.States.SharedUI.General where

import Http exposing (url)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import MassiveDecks.Models.State exposing (Error)
import MassiveDecks.Actions.Action exposing (Action(..))


icon : String -> Html
icon name = i [ class ("fa fa-" ++ name) ] []


fwIcon : String -> Html
fwIcon name = i [ class ("fa fa-fw fa-" ++ name) ] []


spinner : Html
spinner = i [ class "fa fa-circle-o-notch fa-spin" ] []


reportText : String -> String
reportText message =
  ("I was [a short explanation of what you were doing] when I got the following error: \n\n"
    ++ message)


errorMessage : Signal.Address Action -> Int -> Error -> Html
errorMessage address index error =
  let
    reportUrl = (url "https://github.com/Lattyware/massivedecks/issues/new" [( "body", reportText error.message ) ])
  in
    li
      [ class "error" ]
      [ div
        []
        [ a [ class "link"
            , attribute "tabindex" "0"
            , attribute "role" "button"
            , onClick address (RemoveErrorPanel index)
            ] [ icon "times" ]
        , h5 [] [ icon "exclamation-triangle"
                , text " Error"
                ]
        , divider
        , p [] [ text error.message ]
        , p [] [ a [ href reportUrl, target "_blank" ] [ icon "bug", text " Report this as a bug." ] ]
        ]
      ]


errorMessages : Signal.Address Action -> List Error -> Html
errorMessages address errors =
    ol [ id "errorPanel"] (List.indexedMap (errorMessage address) errors)


divider : Html
divider = div [ class "mui-divider" ] []


root : List Html -> Html
root contents = div [ class "content" ] contents


gameMenu : Signal.Address Action -> Html
gameMenu address = div [ class "menu mui-dropdown" ]
  [ button [ class "mui-btn mui-btn--small mui-btn--primary"
           , attribute "data-mui-toggle" "dropdown"
           , title "Game menu."
           ] [ fwIcon "ellipsis-h" ]
  , ul [ class "mui-dropdown__menu mui-dropdown__menu--right" ]
     [ li [] [ a [ class "link"
                 , attribute "tabindex" "0"
                 , attribute "role" "button"
                 , attribute "onClick" "inviteOverlay()"
                 ] [ fwIcon "bullhorn", text " Invite Players" ] ]
     , li [] [ a [ class "link"
                 , attribute "tabindex" "0"
                 , attribute "role" "button"
                 , onClick address LeaveLobby
                 ] [ fwIcon "sign-out", text " Leave Game" ] ]
     , li [ class "mui-divider" ] []
     , li [] [ a [ class "link"
                 , attribute "tabindex" "0"
                 , attribute "role" "button"
                 , attribute "onClick" "aboutOverlay()"
                 ] [ fwIcon "info-circle", text " About" ] ]
     , li [] [ a [ href "https://github.com/Lattyware/massivedecks/issues/new", target "_blank" ]
                 [ fwIcon "bug", text " Report a bug" ] ]
     ]
  ]


inviteOverlay : String -> String -> Html
inviteOverlay appUrl lobbyId =
  let
    url = lobbyUrl appUrl lobbyId
  in
    div [ id "invite" ]
      [ div [ class "mui-panel" ]
        [ h1 [] [ icon "bullhorn", text " Invite Players" ]
        , p [] [ text "To invite other players, simply send them this link: " ]
        , p [] [ a [ href url ] [ text url ] ]
        , p [] [ text "Or give them this game code to enter on the start page: " ]
        , p [] [ input [ readonly True, value lobbyId ] [] ]
        , p [ class "close-link" ]
            [ a [ class "link"
                , attribute "tabindex" "0"
                , attribute "role" "button"
                , attribute "onClick" "closeOverlay()"
                ] [ icon "times", text " Close" ] ]
        ]
      ]


lobbyUrl : String -> String -> String
lobbyUrl url lobbyId = url ++ "#" ++ lobbyId


aboutOverlay : Html
aboutOverlay =
  div [ id "about" ]
    [ div [ class "mui-panel" ]
      [ h1 [] [ icon "info-circle", text " About" ]
      , p [] [ text "Massive Decks is a web game based on the excellent "
             , a [ href "https://cardsagainsthumanity.com/", target "_blank" ] [ text "Cards against Humanity" ]
             , text " - a party game where you play white cards to try and produce the most amusing outcome when "
             , text "combined with the given black card."
             ]
      , p [] [ text "Massive Decks is also inspired by: "
             , ul [] [ li [] [ a [ href "https://www.cardcastgame.com/", target "_blank" ] [ text "Cardcast" ]
                             , text " - an app that allows you to play on a ChromeCast."
                             ]
                     , li [] [ a [ href "http://pretendyoure.xyz/zy/", target "_blank" ] [ text "Pretend You're Xyzzy" ]
                             , text " - a web game where you can jump in with people you don't know."
                             ]
                     ]
             ]
      , p [] [ text "This is an open source game developed in "
             , a [ href "http://elm-lang.org/", target "_blank" ] [ text "Elm" ]
             , text " for the client and "
             , a [ href "http://www.scala-lang.org/", target "_blank" ] [ text "Scala" ]
             , text " for the server."
             ]
      , p [] [ text "We also use: "
             , ul [] [ li [] [ a [ href "https://www.cardcastgame.com/", target "_blank" ] [ text "Cardcast" ]
                             , text "'s APIs for getting decks of cards (you can go there to make your own!)."
                             ]
                     , li [] [ text "The "
                             , a [ href "https://www.playframework.com/", target "_blank" ] [ text "Play framework" ]
                             ]
                     , li [] [ a [ href "http://lesscss.org/", target "_blank" ] [ text "Less" ] ]
                     , li [] [ a [ href "https://fortawesome.github.io/Font-Awesome/", target "_blank" ] [ text "Font Awesome" ] ]
                     , li [] [ a [ href "https://www.muicss.com", target "_blank" ] [ text "MUI" ] ]
                     ]
             ]
      , p [] [ text "Bug reports and contributions are welcome on the "
             , a [ href "https://github.com/Lattyware/massivedecks", target "_blank" ] [ text "GitHub repository" ]
             , text ", where you can find the complete source to the game, under the GPLv3 license."
             ]
      , p [ class "close-link" ]
          [ a [ class "link"
              , attribute "tabindex" "0"
              , attribute "role" "button"
              , attribute "onClick" "closeOverlay()"
              ] [ icon "times", text " Close" ] ]
      ]
    ]


inputError : Maybe String -> List Html
inputError error =
  (Maybe.map (\error -> [ span [ class "input-error" ] [ icon "exclamation", text " ", text error ] ]) error
    |> Maybe.withDefault [])
