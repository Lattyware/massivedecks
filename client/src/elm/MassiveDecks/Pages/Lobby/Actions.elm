module MassiveDecks.Pages.Lobby.Actions exposing
    ( addDeck
    , changeHouseRule
    , judge
    , redraw
    , removeDeck
    , reveal
    , setHandSize
    , setPassword
    , setPublic
    , setScoreLimit
    , startGame
    , submit
    , takeBack
    )

import Json.Encode as Json
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Play as Play
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Models.Encoders as Encoders
import MassiveDecks.ServerConnection as ServerConnection


addDeck : String -> Source.External -> Cmd msg
addDeck =
    changeDecks "Add"


removeDeck : String -> Source.External -> Cmd msg
removeDeck =
    changeDecks "Remove"


startGame : Cmd msg
startGame =
    action "StartGame" []


setScoreLimit : Maybe Int -> String -> Cmd msg
setScoreLimit value =
    configAction "SetScoreLimit" (value |> Maybe.map (\v -> [ ( "scoreLimit", v |> Json.int ) ]) |> Maybe.withDefault [])


setHandSize : Int -> String -> Cmd msg
setHandSize value =
    configAction "SetHandSize" [ ( "handSize", value |> Json.int ) ]


setPassword : Maybe String -> String -> Cmd msg
setPassword value =
    configAction "SetPassword" (value |> Maybe.map (\v -> [ ( "password", v |> Json.string ) ]) |> Maybe.withDefault [])


changeHouseRule : Rules.HouseRuleChange -> String -> Cmd msg
changeHouseRule value =
    configAction "ChangeHouseRule" [ ( "change", value |> Encoders.houseRuleChange ) ]


setPublic : Bool -> String -> Cmd msg
setPublic value =
    configAction "SetPublic" [ ( "public", value |> Json.bool ) ]


submit : List Card.Id -> Cmd msg
submit play =
    action "Submit" [ ( "play", play |> Json.list Json.string ) ]


takeBack : Cmd msg
takeBack =
    action "TakeBack" []


reveal : Play.Id -> Cmd msg
reveal play =
    action "Reveal" [ ( "play", play |> Json.string ) ]


judge : Play.Id -> Cmd msg
judge play =
    action "Judge" [ ( "winner", play |> Json.string ) ]


redraw : Cmd msg
redraw =
    action "Redraw" []



{- Private -}


changeDecks : String -> String -> Source.External -> Cmd msg
changeDecks change version source =
    configAction "ChangeDecks" [ ( "deck", source |> Encoders.source ), ( "change", change |> Json.string ) ] version


configAction : String -> List ( String, Json.Value ) -> String -> Cmd msg
configAction name data version =
    action name (( "if", version |> Json.string ) :: data)


action : String -> List ( String, Json.Value ) -> Cmd msg
action name data =
    ( "action", name |> Json.string ) :: data |> Json.object |> ServerConnection.message
