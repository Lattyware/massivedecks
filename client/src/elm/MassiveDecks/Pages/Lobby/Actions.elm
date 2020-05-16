module MassiveDecks.Pages.Lobby.Actions exposing
    ( configure
    , discard
    , endGame
    , enforceTimeLimit
    , fill
    , judge
    , kick
    , leave
    , like
    , redraw
    , reveal
    , setPlayerAway
    , setPresence
    , setPrivilege
    , setUserRole
    , startGame
    , submit
    , takeBack
    )

import Json.Encode as Json
import Json.Patch exposing (Patch)
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Play as Play
import MassiveDecks.Game.Player as Player
import MassiveDecks.Game.Round as Round
import MassiveDecks.Models.Encoders as Encoders
import MassiveDecks.ServerConnection as ServerConnection
import MassiveDecks.User as User


configure : Json.Patch.Patch -> Cmd msg
configure patch =
    action "Configure" [ ( "change", patch |> Json.Patch.encoder ) ]


startGame : Cmd msg
startGame =
    action "StartGame" []


discard : Card.Id -> Cmd msg
discard card =
    action "Discard" [ ( "card", card |> Json.string ) ]


fill : Card.Id -> String -> Cmd msg
fill card text =
    action "Fill" [ ( "card", card |> Json.string ), ( "text", text |> Json.string ) ]


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


setUserRole : Maybe User.Id -> User.Role -> Cmd msg
setUserRole id role =
    [ id |> Maybe.map (\i -> ( "id", i |> Json.string ))
    , Just ( "role", role |> Encoders.userRole )
    ]
        |> List.filterMap identity
        |> action "SetUserRole"


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



{- Private -}


action : String -> List ( String, Json.Value ) -> Cmd msg
action name data =
    ( "action", name |> Json.string ) :: data |> Json.object |> ServerConnection.message
