module MassiveDecks.Components.About exposing (aboutOverlay)

import Html exposing (..)
import Html.Attributes exposing (..)

import MassiveDecks.Components.Icon exposing (..)


{-| The about overlay for telling players about the game.
-}
aboutOverlay : Html a
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
             , text ", where you can find the complete source to the game, under the GPLv3 license. The game concept "
             , text "'Cards against Humanity' is used under a "
             , a [ href "https://creativecommons.org/licenses/by-nc-sa/2.0/", target "_blank" ] [ text "Creative Commons BY-NC-SA 2.0 license" ]
             , text " granted by "
             , a [ href "https://cardsagainsthumanity.com/", target "_blank" ] [ text "Cards against Humanity" ]
             ]
      , p [ class "close-link" ]
          [ a [ class "link"
              , attribute "tabindex" "0"
              , attribute "role" "button"
              , attribute "onClick" "closeOverlay()"
              ] [ icon "times", text " Close" ] ]
      ]
    ]
