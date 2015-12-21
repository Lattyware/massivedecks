module MassiveDecks.States.Config.UI where

import String

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.Models.Game exposing (DeckInfo)
import MassiveDecks.Models.State exposing (ConfigData, Error, Global)
import MassiveDecks.States.SharedUI.Lobby as LobbyUI
import MassiveDecks.States.SharedUI.General exposing (..)


view : Signal.Address Action -> ConfigData -> Global -> Html
view address data global =
  let
    errors = global.errors
    lobby = data.lobby
    decks = lobby.config.decks
    enoughPlayers = ((List.length lobby.players) > 1)
    enoughCards = not (List.isEmpty decks)
  in
    LobbyUI.view address global.initialState.url lobby.id [] lobby.players data.playerNotification (List.concat [
      [ div [ id "config" ]
        [ div [ id "config-content", class "mui-panel" ]
          [ invite global.initialState.url lobby.id
          , divider
          , h1 [] [ text "Game Setup" ]
          , ul [ class "mui-tabs__bar" ]
               [ li [ class "mui--is-active" ] [ a [ attribute "data-mui-toggle" "tab"
                                                   , attribute "data-mui-controls" "decks" ] [ text "Decks" ]
                                                   ]
               , li [] [ a [ attribute "data-mui-toggle" "tab"
                           , attribute "data-mui-controls" "house-rules" ] [ text "House Rules" ] ]
               ]
          , div [ id "decks", class "mui-tabs__pane mui--is-active" ]
                [ deckList address decks data.loadingDecks data.deckId data.deckIdError ]
          , div [ id "house-rules", class "mui-tabs__pane" ] [ rando address ]
          , divider
          , startGameButton address enoughPlayers enoughCards
          ]
        ]
      ], [ errorMessages address errors ] ])

invite : String -> String -> Html
invite appUrl lobbyId =
  let
    url = lobbyUrl appUrl lobbyId
  in
    div []
      [ p [] [ text "Invite others to the game with the code '"
             , strong [ class "game-code" ] [ text lobbyId ]
             , text "' to enter on the main page, or give them this link: " ]
      , p [] [ a [ href url ] [ text url ] ]
      ]


deckIdInput : Signal.Address Action -> String -> Maybe String -> Html
deckIdInput address deckIdValue error =
  div [] (List.append
    [ div [ id "deck-id-input" ]
        [ div [ class "mui-textfield" ]
          [ input
            [ type' "text"
            , placeholder "Play Code"
            , on "input" targetValue (\deckId -> Signal.message address (UpdateInputValue "deckId" deckId))
            , onKeyUp address (\key -> case key of
                13 -> AddDeck {- Return key. -}
                _ -> NoAction)
            ] []
          , label [] [ icon "info-circle"
                     , text " A "
                     , a [ href "https://www.cardcastgame.com/browse", target "_blank" ] [ text "Cardcast" ]
                     , text " Play Code"
                     ]
          ]
        , addDeckButton address (not (String.isEmpty deckIdValue))
        ]
    ] (inputError error))


addDeckButton : Signal.Address Action -> Bool -> Html
addDeckButton address canAdd =
  button [ class "mui-btn mui-btn--small mui-btn--primary mui-btn--fab", disabled (not canAdd)
         , onClick address AddDeck ] [ icon "plus" ]


deckList : Signal.Address Action -> List DeckInfo -> List String -> String -> Maybe String -> Html
deckList address decks loadingDecks deckIdValue error =
  table [ class "decks mui-table" ]
    [ thead []
      [ tr []
        [ th [] [ text "Id" ]
        , th [] [ text "Name" ]
        , th [ title "Calls" ] [ icon "square" ]
        , th [ title "Responses" ] [ icon "square-o" ]
        ]
      ]
    , tbody [] (List.concat
      [ emptyDeckListInfo address ((List.isEmpty decks) && List.isEmpty loadingDecks)
      , List.map (\deck -> tr []
        [ td [] [ deckLink deck.id ]
        , td [ title deck.name ] [ text deck.name ]
        , td [] [ text (toString deck.calls) ]
        , td [] [ text (toString deck.responses) ]
        ]) decks
      , List.map (\deck -> tr [] [ td [] [ deckLink deck ], td [ colspan 3 ] [ spinner ] ]) loadingDecks
      , [ tr [] [ td [ colspan 4 ] [ deckIdInput address deckIdValue error ] ] ]
      ])
    ]


deckLink : String -> Html
deckLink id = a [ href ("https://www.cardcastgame.com/browse/deck/" ++ id), target "_blank" ] [ text id ]


emptyDeckListInfo : Signal.Address Action -> Bool -> List Html
emptyDeckListInfo address display =
  if display then
    [ tr [] [ td [ colspan 4 ]
        [ icon "info-circle"
        , text " You will need to add at least one "
        , a [ href "https://www.cardcastgame.com/browse", target "_blank" ] [ text "Cardcast deck" ]
        , text " to the game."
        , text " Not sure? Try "
        , a [ class "link"
            , attribute "tabindex" "0"
            , attribute "role" "button"
            , onClick address (AddGivenDeck "CAHBS" Request)
            ] [ text "the Cards Against Humanity base set." ]
        ]
      ]
    ]
  else
    []


rando : Signal.Address Action -> Html
rando address = div [ id "rando" ]
  [ h4 [] [ icon "random", text " Rando Cardrissian " ]
  , button [ class "mui-btn mui-btn--small mui-btn--primary mui-btn--fab", onClick address AddAi ]
           [ icon "check" ]
  , p [] [ text "Every round, one random card will be played for an imaginary player named Rando Cardrissian, if he "
         , text "wins, all players go home in a state of everlasting shame." ]
  ]


startGameWarning : Bool -> Html
startGameWarning canStart = if canStart then text "" else
  span [] [ icon "info-circle", text " You will need at least two players to start the game." ]


startGameButton : Signal.Address Action -> Bool -> Bool -> Html
startGameButton address enoughPlayers enoughCards = div [ id "start-game" ]
  [ startGameWarning enoughPlayers
  , button
    [ class "mui-btn mui-btn--primary mui-btn--raised"
    , onClick address StartGame
    , disabled (not (enoughPlayers && enoughCards))
    ] [ text "Start Game" ]
  ]
