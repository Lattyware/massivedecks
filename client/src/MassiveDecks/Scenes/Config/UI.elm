module MassiveDecks.Scenes.Config.UI exposing (view, deckIdInputLabel, passwordInputLabel, addDeckButton, setPasswordButton)

import String
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import MassiveDecks.Components.Icon as Icon
import MassiveDecks.Components.Input as Input
import MassiveDecks.Models.Game as Game
import MassiveDecks.Scenes.Lobby.Models as Lobby
import MassiveDecks.Scenes.Playing.HouseRule as HouseRule exposing (HouseRule)
import MassiveDecks.Scenes.Playing.HouseRule.Id as HouseRule
import MassiveDecks.Scenes.Playing.HouseRule.Available exposing (houseRules)
import MassiveDecks.Scenes.Config.Messages exposing (Message(..), InputId(..), Deck(..))
import MassiveDecks.Util as Util


view : Lobby.Model -> Html Message
view lobbyModel =
    let
        model =
            lobbyModel.config

        lobby =
            lobbyModel.lobby

        decks =
            lobby.config.decks

        enoughPlayers =
            ((List.length lobby.players) > 1)

        enoughCards =
            not (List.isEmpty decks)

        canNotChangeConfig =
            lobbyModel.lobby.owner /= lobbyModel.secret.id
    in
        div [ id "config" ]
            ((if canNotChangeConfig then
                infoBar
              else
                []
             )
                ++ [ div [ id "config-content", class "mui-panel" ]
                        [ invite lobbyModel.init.url lobby.gameCode
                        , div [ class "mui-divider" ] []
                        , h1 [] [ text "Game Setup" ]
                        , ul [ class "mui-tabs__bar" ]
                            [ li [ class "mui--is-active" ]
                                [ a
                                    [ attribute "data-mui-toggle" "tab"
                                    , attribute "data-mui-controls" "decks"
                                    ]
                                    [ text "Decks" ]
                                ]
                            , li []
                                [ a
                                    [ attribute "data-mui-toggle" "tab"
                                    , attribute "data-mui-controls" "house-rules"
                                    ]
                                    [ text "House Rules" ]
                                ]
                            , li []
                                [ a
                                    [ attribute "data-mui-toggle" "tab"
                                    , attribute "data-mui-controls" "lobby-settings"
                                    ]
                                    [ text "Lobby Settings" ]
                                ]
                            ]
                        , div [ id "decks", class "mui-tabs__pane mui--is-active" ]
                            [ deckList canNotChangeConfig decks model.loadingDecks model.deckIdInput ]
                        , div [ id "house-rules", class "mui-tabs__pane" ]
                            ([ rando canNotChangeConfig ] ++ (List.map (\rule -> houseRule canNotChangeConfig (List.member rule.id lobbyModel.lobby.config.houseRules) rule) houseRules))
                        , div [ id "lobby-settings", class "mui-tabs__pane" ]
                            [ password model.passwordInput ]
                        , div [ class "mui-divider" ] []
                        , startGameButton canNotChangeConfig enoughPlayers enoughCards
                        ]
                   ]
            )


infoBar : List (Html msg)
infoBar =
    [ div [ id "info-bar", class "mui--z1" ]
        [ Icon.icon "info-circle"
        , text " "
        , text "You can't change the configuration of the game, as you are not the owner."
        ]
    ]


passwordInputLabel : List (Html msg)
passwordInputLabel =
    [ text "If blank, anyone with the game code can join." ]


password : Input.Model InputId Message -> Html Message
password passwordInputModel =
    div []
        [ h3 [] [ Icon.icon "key", text " Privacy" ]
        , p [] [ text "A password that players will need to enter to get in the game. People already in the game will not need to enter it, and anyone in the game will be able to see it." ]
        , Input.view passwordInputModel
        ]


setPasswordButton : String -> List (Html Message)
setPasswordButton password =
    [ button
        [ class "mui-btn mui-btn--small mui-btn--primary"
        , onClick SetPassword
        , title "Set the password."
        ]
        [ Icon.icon "lock" ]
    ]


invite : String -> String -> Html msg
invite appUrl lobbyId =
    let
        url =
            Util.lobbyUrl appUrl lobbyId
    in
        div []
            [ p []
                [ text "Invite others to the game with the code '"
                , strong [ class "game-code" ] [ text lobbyId ]
                , text "' to enter on the main page, or give them this link: "
                ]
            , p [] [ a [ href url ] [ text url ] ]
            ]


deckIdInputLabel : List (Html msg)
deckIdInputLabel =
    [ text " A "
    , a [ href "https://www.cardcastgame.com/browse", target "_blank", rel "noopener" ] [ text "Cardcast" ]
    , text " Play Code"
    ]


addDeckButton : String -> List (Html Message)
addDeckButton deckId =
    [ button
        [ class "mui-btn mui-btn--small mui-btn--primary mui-btn--fab"
        , disabled (String.isEmpty deckId)
        , onClick (ConfigureDecks (Request deckId))
        , title "Add deck to game."
        ]
        [ Icon.icon "plus" ]
    ]


deckList : Bool -> List Game.DeckInfo -> List String -> Input.Model InputId Message -> Html Message
deckList canNotChangeConfig decks loadingDecks deckId =
    table [ class "decks mui-table" ]
        [ thead []
            [ tr []
                [ th [] [ text "Id" ]
                , th [] [ text "Name" ]
                , th [ title "Calls" ] [ Icon.icon "square" ]
                , th [ title "Responses" ] [ Icon.icon "square-o" ]
                ]
            ]
        , Util.tbody []
            (List.concat
                [ if (canNotChangeConfig && (List.isEmpty decks)) then
                    [ ( "!!emptyInfo", tr [] [ td [ colspan 4 ] [ text "No decks have been added yet." ] ] ) ]
                  else
                    []
                , emptyDeckListInfo ((not canNotChangeConfig) && (List.isEmpty decks) && List.isEmpty loadingDecks)
                , List.map loadedDeckEntry decks
                , List.map loadingDeckEntry loadingDecks
                , if (canNotChangeConfig) then
                    []
                  else
                    [ ( "!!input", tr [] [ td [ colspan 4 ] [ Input.view deckId ] ] ) ]
                ]
            )
        ]


loadedDeckEntry : Game.DeckInfo -> ( String, Html msg )
loadedDeckEntry deck =
    let
        row =
            tr []
                [ td [] [ deckLink deck.id ]
                , td [ title deck.name ] [ text deck.name ]
                , td [] [ text (toString deck.calls) ]
                , td [] [ text (toString deck.responses) ]
                ]
    in
        ( deck.id, row )


loadingDeckEntry : String -> ( String, Html msg )
loadingDeckEntry deckId =
    let
        row =
            tr [] [ td [] [ deckLink deckId ], td [ colspan 3 ] [ Icon.spinner ] ]
    in
        ( deckId, row )


deckLink : String -> Html msg
deckLink id =
    a [ href ("https://www.cardcastgame.com/browse/deck/" ++ id), target "_blank", rel "noopener" ] [ text id ]


emptyDeckListInfo : Bool -> List ( String, Html Message )
emptyDeckListInfo display =
    if display then
        [ ( "!!emptyInfo"
          , tr []
                [ td [ colspan 4 ]
                    [ Icon.icon "info-circle"
                    , text " You will need to add at least one "
                    , a [ href "https://www.cardcastgame.com/browse", target "_blank", rel "noopener" ] [ text "Cardcast deck" ]
                    , text " to the game."
                    , text " Not sure? Try "
                    , a
                        [ class "link"
                        , attribute "tabindex" "0"
                        , attribute "role" "button"
                        , onClick (ConfigureDecks (Request "CAHBS"))
                        ]
                        [ text "clicking here to add the Cards Against Humanity base set" ]
                    , text "."
                    ]
                ]
          )
        ]
    else
        []


houseRule : Bool -> Bool -> HouseRule -> Html Message
houseRule canNotChangeConfig enabled rule =
    let
        ( buttonText, command ) =
            if enabled then
                ( "Disable", DisableRule rule.id )
            else
                ( "Enable", EnableRule rule.id )
    in
        houseRuleTemplate canNotChangeConfig (HouseRule.toString rule.id) rule.name rule.icon rule.description buttonText command


houseRuleTemplate : Bool -> String -> String -> String -> String -> String -> msg -> Html msg
houseRuleTemplate canNotChangeConfig id_ title icon description buttonText message =
    div [ id id_, class "house-rule" ]
        [ div []
            [ h3 [] [ Icon.icon icon, text " ", text title ]
            , button [ class "mui-btn mui-btn--small mui-btn--primary", onClick message, disabled canNotChangeConfig ]
                [ text buttonText ]
            ]
        , p [] [ text description ]
        ]


rando : Bool -> Html Message
rando canNotChangeConfig =
    houseRuleTemplate canNotChangeConfig
        "rando"
        "Rando Cardrissian"
        "cogs"
        "Every round, one random card will be played for an imaginary player named Rando Cardrissian, if he wins, all players go home in a state of everlasting shame."
        "Add an AI player"
        AddAi


startGameWarning : Bool -> Html msg
startGameWarning canStart =
    if canStart then
        text ""
    else
        span [] [ Icon.icon "info-circle", text " You will need at least two players to start the game." ]


startGameButton : Bool -> Bool -> Bool -> Html Message
startGameButton notOwner enoughPlayers enoughCards =
    div [ id "start-game" ]
        [ startGameWarning enoughPlayers
        , button
            [ class "mui-btn mui-btn--primary mui-btn--raised"
            , onClick StartGame
            , disabled ((not (enoughPlayers && enoughCards)) || notOwner)
            ]
            [ text "Start Game" ]
        ]
