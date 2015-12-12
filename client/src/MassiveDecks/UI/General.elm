module MassiveDecks.UI.General where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import MassiveDecks.Models.State exposing (Error)
import MassiveDecks.Actions.Action exposing (Action(..))


icon : String -> Html
icon name = i [ class ("fa fa-" ++ name) ] []


spinner : Html
spinner = i [ class "fa fa-circle-o-notch fa-spin" ] []


errorMessage : Signal.Address Action -> Int -> Error -> Html
errorMessage address index error =
    li [ class "error" ] [ div [] [
      a [ href "#", onClick address (RemoveErrorPanel index) ] [ icon "times" ]
        , h5 []
          [ icon "exclamation-triangle"
          , text " Error"
          ]
        , divider
        , p [] [ text error.message ] ] ]


errorMessages : Signal.Address Action -> List Error -> Html
errorMessages address errors =
    ol [ id "errorPanel"] (List.indexedMap (errorMessage address) errors)


divider : Html
divider = div [ class "mui-divider" ] []


root : List Html -> Html
root contents = div [ class "content" ] contents


gameMenu : Html
gameMenu = div [ class "menu mui-dropdown" ]
  [ button [ class "mui-btn mui-btn--small mui-btn--primary"
           , attribute "data-mui-toggle" "dropdown"
           ] [ icon "ellipsis-h" ]
  , ul [ class "mui-dropdown__menu mui-dropdown__menu--right" ]
     [ li [] [ a [ href "#", attribute "onClick" "inviteOverlay(event)" ] [ icon "bullhorn", text " Invite Players" ] ]
     , li [] [ a [ href "#" ] [ icon "sign-out", text " Leave Game" ] ]
     , li [ class "mui-divider" ] []
     , li [] [ a [ href "#", attribute "onClick" "aboutOverlay(event)" ] [ icon "info-circle", text " About" ] ]
     , li [] [ a [ href "https://github.com/Lattyware/massivedecks/issues/new", target "_blank" ]
                 [ icon "bug", text " Report a bug" ] ]
     ]
  ]


inviteOverlay : String -> String -> Html
inviteOverlay appUrl lobbyId =
  let
    url = lobbyUrl appUrl lobbyId
  in
    div [ id "invite" ]
      [ div [ class "mui-panel" ]
        [ p [] [ text "To invite other players, simply send them this link: " ]
        , p [] [ a [ href url ] [ text url ] ]
        , p [] [ text "Or give them this game code to enter on the start page: " ]
        , p [] [ input [ readonly True, value lobbyId ] [] ] ]
        ]


lobbyUrl : String -> String -> String
lobbyUrl url lobbyId = url ++ "#" ++ lobbyId


aboutOverlay : Html
aboutOverlay =
  div [ id "about" ]
    [ div [ class "mui-panel" ]
      [ p [] [ text "Massive Decks is a clone of the excellent "
             , a [ href "https://cardsagainsthumanity.com/", target "_blank" ] [ text "Cards against Humanity" ]
             , text " using the "
             , a [ href "https://www.cardcastgame.com/", target "_blank" ] [ text "CardCast" ]
             , text " APIs (try their app if you have a ChromeCast!) and is inspired by "
             , a [ href "http://pretendyoure.xyz/zy/", target "_blank" ] [ text "Pretend You're Xyzzy" ]
             , text " (where you should go if you want to play with people you don't know)."
             ]
      , p [] [ text "This is an open source game developed in "
             , a [ href "http://elm-lang.org/", target "_blank" ] [ text "Elm" ]
             , text " for the client and "
             , a [ href "http://www.scala-lang.org/", target "_blank" ] [ text "Scala" ]
             , text " for the server. We also use "
             , a [ href "https://www.playframework.com/", target "_blank" ] [ text "the Play framework" ]
             , text ", "
             , a [ href "http://lesscss.org/", target "_blank" ] [ text "less" ]
             , text ", and "
             , a [ href "https://fortawesome.github.io/Font-Awesome/", target "_blank" ] [ text "Font Awesome" ]
             , text ". Bug reports and contributions are welcome on our "
             , a [ href "https://github.com/Lattyware/massivedecks", target "_blank" ] [ text "GitHub repository" ]
             , text "."
             ]
      ]
    ]
