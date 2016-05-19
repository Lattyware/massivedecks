module MassiveDecks.Scenes.Config.UI exposing (view, deckIdInputLabel, addDeckButton)

import String

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import MassiveDecks.Components.Icon as Icon
import MassiveDecks.Components.Input as Input
import MassiveDecks.Models.Game as Game
import MassiveDecks.Scenes.Lobby.Models as Lobby
import MassiveDecks.Scenes.Config.Messages exposing (Message(..), InputId(..), Deck(..))
import MassiveDecks.Util as Util


view : Lobby.Model -> Html Message
view lobbyModel =
  let
    model = lobbyModel.config
    lobby = lobbyModel.lobby
    decks = lobby.config.decks
    enoughPlayers = ((List.length lobby.players) > 1)
    enoughCards = not (List.isEmpty decks)
  in
    div [ id "config" ]
        [ div [ id "config-content", class "mui-panel" ]
              [ invite lobbyModel.init.url lobby.gameCode
              , div [ class "mui-divider" ] []
              , h1 [] [ text "Game Setup" ]
              , ul [ class "mui-tabs__bar" ]
                   [ li [ class "mui--is-active" ] [ a [ attribute "data-mui-toggle" "tab"
                                                       , attribute "data-mui-controls" "decks" ]
                                                       [ text "Decks" ]
                                                   ]
                   , li [] [ a [ attribute "data-mui-toggle" "tab"
                               , attribute "data-mui-controls" "house-rules" ] [ text "House Rules" ] ]
                               ]
              , div [ id "decks", class "mui-tabs__pane mui--is-active" ]
                    [ deckList decks model.loadingDecks model.deckIdInput ]
              , div [ id "house-rules", class "mui-tabs__pane" ] [ rando ]
              , div [ class "mui-divider" ] []
              , startGameButton enoughPlayers enoughCards
              ]
        ]

invite : String -> String -> Html Message
invite appUrl lobbyId =
  let
    url = Util.lobbyUrl appUrl lobbyId
  in
    div []
      [ p [] [ text "Invite others to the game with the code '"
             , strong [ class "game-code" ] [ text lobbyId ]
             , text "' to enter on the main page, or give them this link: " ]
      , p [] [ a [ href url ] [ text url ] ]
      ]


deckIdInputLabel : List (Html msg)
deckIdInputLabel =
  [ text " A "
  , a [ href "https://www.cardcastgame.com/browse", target "_blank" ] [ text "Cardcast" ]
  , text " Play Code"
  ]


addDeckButton : String -> List (Html Message)
addDeckButton deckId =
  [ button [ class "mui-btn mui-btn--small mui-btn--primary mui-btn--fab", disabled (String.isEmpty deckId)
           , onClick (ConfigureDecks (Request deckId))
           , title "Add deck to game."
           ] [ Icon.icon "plus" ]
  ]


deckList : List Game.DeckInfo -> List String -> Input.Model InputId Message -> Html Message
deckList decks loadingDecks deckId =
  table [ class "decks mui-table" ]
    [ thead []
      [ tr []
        [ th [] [ text "Id" ]
        , th [] [ text "Name" ]
        , th [ title "Calls" ] [ Icon.icon "square" ]
        , th [ title "Responses" ] [ Icon.icon "square-o" ]
        ]
      ]
    , tbody [] (List.concat
      [ emptyDeckListInfo ((List.isEmpty decks) && List.isEmpty loadingDecks)
      , List.map (\deck -> tr []
        [ td [] [ deckLink deck.id ]
        , td [ title deck.name ] [ text deck.name ]
        , td [] [ text (toString deck.calls) ]
        , td [] [ text (toString deck.responses) ]
        ]) decks
      , List.map (\deck -> tr [] [ td [] [ deckLink deck ], td [ colspan 3 ] [ Icon.spinner ] ]) loadingDecks
      , [ tr [] [ td [ colspan 4 ] [ Input.view deckId ] ] ]
      ])
    ]


deckLink : String -> Html Message
deckLink id = a [ href ("https://www.cardcastgame.com/browse/deck/" ++ id), target "_blank" ] [ text id ]


emptyDeckListInfo : Bool -> List (Html Message)
emptyDeckListInfo display =
  if display then
    [ tr [] [ td [ colspan 4 ]
        [ Icon.icon "info-circle"
        , text " You will need to add at least one "
        , a [ href "https://www.cardcastgame.com/browse", target "_blank" ] [ text "Cardcast deck" ]
        , text " to the game."
        , text " Not sure? Try "
        , a [ class "link"
            , attribute "tabindex" "0"
            , attribute "role" "button"
            , onClick (ConfigureDecks (Request "CAHBS"))
            ] [ text "clicking here to add the Cards Against Humanity base set" ]
        , text "."
        ]
      ]
    ]
  else
    []


houseRule : String -> String -> String -> String -> String -> Message -> Html Message
houseRule id' title icon description buttonText message =
  div [ id id', class "house-rule" ]
      [ div [] [ h3 [] [ Icon.icon icon, text " ", text title ]
             , button [ class "mui-btn mui-btn--small mui-btn--primary", onClick message ]
                      [ text buttonText ]
             ]
    , p [] [ text description ]
    ]


rando : Html Message
rando = houseRule "rando" "Rando Cardrissian" "cogs"
  "Every round, one random card will be played for an imaginary player named Rando Cardrissian, if he wins, all players go home in a state of everlasting shame."
  "Add an AI player" AddAi


startGameWarning : Bool -> Html Message
startGameWarning canStart = if canStart then text "" else
  span [] [ Icon.icon "info-circle", text " You will need at least two players to start the game." ]


startGameButton : Bool -> Bool -> Html Message
startGameButton enoughPlayers enoughCards = div [ id "start-game" ]
  [ startGameWarning enoughPlayers
  , button
    [ class "mui-btn mui-btn--primary mui-btn--raised"
    , onClick StartGame
    , disabled (not (enoughPlayers && enoughCards))
    ] [ text "Start Game" ]
  ]
