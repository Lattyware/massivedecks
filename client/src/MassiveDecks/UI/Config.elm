module MassiveDecks.UI.Config where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import MassiveDecks.Actions.Action exposing (Action(..), APICall(..))
import MassiveDecks.Models.State exposing (ConfigData, Error)
import MassiveDecks.UI.Lobby as LobbyUI
import MassiveDecks.UI.General exposing (..)


view : Signal.Address Action -> ConfigData -> List Error -> Html
view address data errors =
  let
    lobby = data.lobby
    url = lobbyUrl lobby.id
  in
    LobbyUI.view lobby.id [] lobby.players (List.concat [
      [ div [ id "start-screen" ]
        [ div [ id "start-screen-content" ] [ p [] [ text "Invite others to the game with the code '"
                                                   , strong [ class "game-code" ] [ text lobby.id ]
                                                   , text "' to enter on the main page, or give them this link: " ]
                                            , p [] [ a [ href url ] [ text url ] ]
                                            , h1 [] [ text "Game Setup" ]
                                            , deckManagement address lobby.config.deckIds
                                            ]
        ]
      ], [ errorMessages address errors ] ])


deckManagement : Signal.Address Action -> List String -> Html
deckManagement address deckIds = div []
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
  , button [ class "mui-btn mui-btn--raised", onClick address (AddDeck Request) ] [ text "Add Deck" ]
  , ul [] (List.map (\deckId -> li [] [ text deckId ]) deckIds)
  , button [ class "mui-btn mui-btn--raised", onClick address (StartGame Request) ] [ text "Start Game" ]
  ]
