module MassiveDecks.Models.JSON.Encode exposing (..)

import Json.Encode as Json
import MassiveDecks.Models.Player as Player


encodeCommand : String -> Player.Secret -> List ( String, Json.Value ) -> Json.Value
encodeCommand action playerSecret rest =
    Json.object
        (List.append
            [ ( "command", Json.string action )
            , ( "secret", encodePlayerSecret playerSecret )
            ]
            rest
        )


encodeDeckId : String -> ( String, Json.Value )
encodeDeckId id =
    ( "deckId", Json.string id )


encodePlayerSecret : Player.Secret -> Json.Value
encodePlayerSecret playerSecret =
    Json.object
        [ ( "id", encodePlayerId playerSecret.id )
        , ( "secret", Json.string playerSecret.secret )
        ]


encodePlayerId : Player.Id -> Json.Value
encodePlayerId playerId =
    Json.int playerId


encodeName : String -> Json.Value
encodeName name =
    Json.object [ ( "name", Json.string name ) ]


encodeNameAndPassword : String -> String -> Json.Value
encodeNameAndPassword name password =
    Json.object
        [ ( "name", Json.string name )
        , ( "password", Json.string password )
        ]
