module MassiveDecks.Pages.Lobby.Actions exposing
    ( addDeck
    , changeHouseRule
    , changeTimeLimitForStage
    , changeTimeLimitMode
    , endGame
    , enforceTimeLimit
    , judge
    , kick
    , leave
    , like
    , redraw
    , removeDeck
    , reveal
    , setHandSize
    , setPassword
    , setPlayerAway
    , setPresence
    , setPrivilege
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
import MassiveDecks.Game.Player as Player
import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Models.Encoders as Encoders
import MassiveDecks.ServerConnection as ServerConnection
import MassiveDecks.User as User


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


submit : List Card.Played -> Cmd msg
submit play =
    action "Submit" [ ( "play", play |> Json.list Encoders.playedCard ) ]


takeBack : Cmd msg
takeBack =
    action "TakeBack" []


reveal : Play.Id -> Cmd msg
reveal play =
    action "Reveal" [ ( "play", play |> Json.string ) ]


judge : Play.Id -> Cmd msg
judge play =
    action "Judge" [ ( "winner", play |> Json.string ) ]


like : Play.Id -> Cmd msg
like play =
    action "Like" [ ( "play", play |> Json.string ) ]


redraw : Cmd msg
redraw =
    action "Redraw" []


setPresence : Player.Presence -> Cmd msg
setPresence presence =
    action "SetPresence" [ ( "presence", presence |> Encoders.playerPresence ) ]


setPlayerAway : User.Id -> Cmd msg
setPlayerAway player =
    action "SetPlayerAway" [ ( "player", player |> Json.string ) ]


setPrivilege : User.Id -> User.Privilege -> Cmd msg
setPrivilege player privilege =
    action "SetPrivilege" [ ( "user", player |> Json.string ), ( "privilege", privilege |> Encoders.privilege ) ]


kick : User.Id -> Cmd msg
kick user =
    action "Kick" [ ( "user", user |> Json.string ) ]


leave : Cmd msg
leave =
    action "Leave" []


endGame : Cmd msg
endGame =
    action "EndGame" []


enforceTimeLimit : Round.Id -> Round.Stage -> Cmd msg
enforceTimeLimit round stage =
    action "EnforceTimeLimit"
        [ ( "round", Encoders.roundId round )
        , ( "stage", Encoders.stage stage )
        ]


changeTimeLimitMode : Rules.TimeLimitMode -> String -> Cmd msg
changeTimeLimitMode mode version =
    configAction "ChangeTimeLimit" [ ( "mode", Encoders.timeLimitMode mode ) ] version


changeTimeLimitForStage : Round.Stage -> Maybe Float -> String -> Cmd msg
changeTimeLimitForStage stage timeLimit version =
    let
        timeLimitField =
            case timeLimit of
                Just duration ->
                    [ ( "timeLimit", duration |> Json.float ) ]

                Nothing ->
                    []
    in
    configAction "ChangeTimeLimit" (( "stage", Encoders.stage stage ) :: timeLimitField) version



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
