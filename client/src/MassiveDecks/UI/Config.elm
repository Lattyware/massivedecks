module MassiveDecks.UI.Config where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.Models.Game exposing (DeckInfo)
import MassiveDecks.Models.State exposing (ConfigData, Error)
import MassiveDecks.UI.Lobby as LobbyUI
import MassiveDecks.UI.General exposing (..)


view : Signal.Address Action -> ConfigData -> List Error -> Html
view address data errors =
  let
    lobby = data.lobby
    decks = lobby.config.decks
    enoughPlayers = ((List.length lobby.players) > 1)
    enoughCards = not (List.isEmpty decks)
  in
    LobbyUI.view lobby.id [] lobby.players (List.concat [
      [ div [ id "config" ]
        [ div [ id "config-content", class "mui-panel" ]
          [ invite lobby.id
          , divider
          , h1 [] [ text "Game Setup" ]
          , deckList address decks
          , startGameButton address enoughPlayers enoughCards
          ]
        ]
      ], [ errorMessages address errors ] ])

invite : String -> Html
invite lobbyId =
  let
    url = lobbyUrl lobbyId
  in
    div []
      [ p [] [ text "Invite others to the game with the code '"
             , strong [ class "game-code" ] [ text lobbyId ]
             , text "' to enter on the main page, or give them this link: " ]
      , p [] [ a [ href url ] [ text url ] ]
      ]


deckIdInput : Signal.Address Action -> Html
deckIdInput address = div [ id "deck-id-input" ]
  [ div [ class "mui-textfield" ]
    [ input [ type' "text"
            , placeholder "Deck Id"
            , on "change" targetValue (\deckId -> Signal.message address (UpdateInputValue "deckId" deckId))
            , onKeyUp address (\key -> case key of
                13 -> AddDeck Request {- Return key. -}
                _ -> NoAction
             ) ] []
    , label [] [ icon "info-circle", text " A ", a [ href "https://www.cardcastgame.com/browse", target "_blank" ] [ text "CardCast" ], text " Deck Id" ]
    ]
  , addDeckButton address
  ]


addDeckButton : Signal.Address Action -> Html
addDeckButton address =
  button [ class "mui-btn mui-btn--small mui-btn--primary mui-btn--fab"
         , onClick address (AddDeck Request) ] [ icon "plus" ]


deckList : Signal.Address Action -> List DeckInfo -> Html
deckList address decks =
  table [ class "decks mui-table" ]
    [ thead []
      [ tr []
        [ th [] [ text "Id" ]
        , th [] [ text "Name" ]
        , th [] [ icon "square" ]
        , th [] [ icon "square-o" ]
        ]
      ]
    , tbody [] (List.concat
      [ emptyDeckListInfo (List.isEmpty decks)
      , List.map (\deck -> tr []
        [ td [] [ a [ href ("https://www.cardcastgame.com/browse/deck/" ++ deck.id), target "_blank" ] [ text deck.id ] ]
        , td [] [ text deck.name ]
        , td [] [ text (toString deck.calls) ]
        , td [] [ text (toString deck.responses) ]
        ]) decks
      , [ tr [] [ td [ colspan 4 ] [ deckIdInput address ] ] ]
      ])
    ]


emptyDeckListInfo : Bool -> List Html
emptyDeckListInfo display =
  if display then
    [ tr [] [ td [ colspan 4 ]
      [ icon "info-circle"
      , text " You will need to add at least one "
      , a [ href "https://www.cardcastgame.com/browse", target "_blank" ] [ text "CardCast deck" ], text " to the game." ]
      ]
    ]
  else
    []


startGameWarning : Bool -> Html
startGameWarning canStart = if canStart then text "" else
  span [] [ icon "info-circle", text "You will need at least two players to start the game." ]


startGameButton : Signal.Address Action -> Bool -> Bool -> Html
startGameButton address enoughPlayers enoughCards = div [ id "start-game" ]
  [ startGameWarning enoughPlayers
  , button
    [ class "mui-btn mui-btn--primary mui-btn--raised"
    , onClick address (StartGame Request)
    , disabled (not (enoughPlayers && enoughCards))
    ] [ text "Start Game" ]
  ]
