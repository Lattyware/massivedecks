module MassiveDecks.API exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import MassiveDecks.API.Request exposing (..)
import MassiveDecks.Scenes.Playing.HouseRule.Id as HouseRule
import MassiveDecks.Models.Game as Game
import MassiveDecks.Models.Game.Round as Round
import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.Player as Player exposing (Player)
import MassiveDecks.Models.JSON.Decode exposing (..)
import MassiveDecks.Models.JSON.Encode exposing (..)


{-| Makes a request to create a new game lobby to the server. On success, returns that lobby.
-}
createLobby : String -> Request Never Game.GameCodeAndSecret
createLobby name =
    request "POST" "/api/lobbies" (Just (encodeName name)) [] gameCodeAndSecretDecoder


{-| Errors specific to new player requests.
* `NameInUse` - The request was to create a new player with a name already being uses in that lobby.
* `LobbyNotFound` - The given lobby does not exist.
-}
type NewPlayerError
    = NameInUse
    | PasswordWrong
    | NewPlayerLobbyNotFound


{-| Makes a request to add a new player to the given lobby. On success, returns a `Secret` for that player.
-}
newPlayer : String -> String -> String -> Request NewPlayerError Player.Secret
newPlayer gameCode name password =
    request
        "POST"
        ("/api/lobbies/" ++ gameCode ++ "/players")
        (Just (encodeNameAndPassword name password))
        [ ( ( 400, "name-in-use" ), Decode.succeed NameInUse )
        , ( ( 403, "password-wrong" ), Decode.succeed PasswordWrong )
        , ( ( 404, "lobby-not-found" ), Decode.succeed NewPlayerLobbyNotFound )
        ]
        playerSecretDecoder


{-| Errors specific to getting the lobby and hand.
* `LobbyNotFound` - The given lobby does not exist.
-}
type GetLobbyAndHandError
    = LobbyNotFound
    | SecretWrongOrNotAPlayer


{-| Get the lobby and the hand for the player with the given secret (using it to authenticate).
-}
getLobbyAndHand : String -> Player.Secret -> Request GetLobbyAndHandError Game.LobbyAndHand
getLobbyAndHand =
    commandRequest
        "getLobbyAndHand"
        []
        [ ( ( 404, "lobby-not-found" ), Decode.succeed LobbyNotFound )
        , ( ( 403, "secret-wrong-or-not-a-player" ), Decode.succeed SecretWrongOrNotAPlayer )
        ]
        lobbyAndHandDecoder


{-| Get the hand of the player with the given secret (using it to authenticate).
-}
getHand : String -> Player.Secret -> Request Never Card.Hand
getHand gameCode secret =
    request
        "POST"
        ("/api/lobbies/" ++ gameCode ++ "/players/" ++ (toString secret.id))
        (Just (encodePlayerSecret secret))
        []
        handDecoder


{-| Get the history of the given game.
-}
getHistory : String -> Request Never (List Round.FinishedRound)
getHistory gameCode =
    request
        "GET"
        ("/api/lobbies/" ++ gameCode ++ "/history")
        Nothing
        []
        (Decode.list finishedRoundDecoder)


{-| Errors specific to add deck requests.
* `CardcastTimeout` - The server timed out trying to retrieve the deck from Cardcast.
* `DeckNotFound` - The given play code does not resolve to a Cardcast deck.
-}
type AddDeckError
    = CardcastTimeout
    | DeckNotFound


{-| Makes a request to add the deck for the given play code to the game configuration, using the given secret to
authenticate.
-}
addDeck : String -> Player.Secret -> String -> Request AddDeckError ()
addDeck gameCode secret playCode =
    commandRequest
        "addDeck"
        [ ( "playCode", Encode.string playCode ) ]
        [ ( ( 502, "cardcast-timeout" ), Decode.succeed CardcastTimeout )
        , ( ( 400, "deck-not-found" ), Decode.succeed DeckNotFound )
        ]
        (Decode.succeed ())
        gameCode
        secret


{-| Makes a request to the server to add a new AI player to the game.
-}
newAi : String -> Player.Secret -> Request Never ()
newAi gameCode secret =
    request
        "POST"
        ("/api/lobbies/" ++ gameCode ++ "/players/newAi")
        (Just (encodePlayerSecret secret))
        []
        (Decode.succeed ())


{-| Errors specific to starting a new game.
* `NotEnoughPlayers` - There are not enough players in the lobby to start the game. The required number is given.
* `GameInProgress` - There is already a game in progress.
-}
type NewGameError
    = NotEnoughPlayers Int
    | GameInProgress


{-| Makes a request to the server to start a new game in the given lobby, using the given secret to authenticate.
-}
newGame : String -> Player.Secret -> Request NewGameError Card.Hand
newGame gameCode secret =
    commandRequest
        "newGame"
        []
        [ ( ( 400, "game-in-progress" ), Decode.succeed GameInProgress )
        , ( ( 400, "not-enough-players" ), Decode.map NotEnoughPlayers (Decode.field "required" Decode.int) )
        ]
        handDecoder
        gameCode
        secret


{-| Errors specific to choosing a winner for the round.
* `NotCzar` - The player is not the card czar.
-}
type ChooseError
    = NotCzar


{-| Make a request to choose the given (by index) winning response for round for the given lobby, using the given secret
to authenticate.
-}
choose : String -> Player.Secret -> Int -> Request ChooseError ()
choose gameCode secret winner =
    commandRequest
        "choose"
        [ ( "winner", Encode.int winner ) ]
        [ ( ( 400, "not-czar" ), Decode.succeed NotCzar ) ]
        (Decode.succeed ())
        gameCode
        secret


{-| Errors specific to playing responses into the round.
* `NotInRound` - The player is not in the round, and therefore can't play (i.e.: They are card czar, joined mid-round
*                or were skipped.)
* `AlreadyPlayed` - The player has already played into the round.
* `AlreadyJudging` - The round is in the judging phase, no more cards can be played.
* `WrongNumberOfCards` - The wrong number of cards were played, with the number got, and the number expected.
-}
type PlayError
    = NotInRound
    | AlreadyPlayed
    | AlreadyJudging
    | WrongNumberOfCards Int Int


{-| Make a request to play the given (by index) cards from the player's hand into the round for the given lobby, using
the given secret to authenticate.
-}
play : String -> Player.Secret -> List String -> Request PlayError Card.Hand
play gameCode secret ids =
    commandRequest
        "play"
        [ ( "ids", Encode.list (List.map Encode.string ids) ) ]
        [ ( ( 400, "not-in-round" ), Decode.succeed NotInRound )
        , ( ( 400, "already-played" ), Decode.succeed AlreadyPlayed )
        , ( ( 400, "already-judging" ), Decode.succeed AlreadyJudging )
        , ( ( 400, "wrong-number-of-cards-played" ), Decode.map2 WrongNumberOfCards (Decode.field "got" Decode.int) (Decode.field "expected" Decode.int) )
        ]
        handDecoder
        gameCode
        secret


{-| Errors specific to skipping a player in the lobby.
* `NotEnoughPlayers` - The number of active players would drop below the minimum if the given players were
*                      skipped.
* `PlayersNotSkippable` - One of the given players was not in a state where they could be skipped (i.e.: not
*                         disconnected or timed out).
-}
type SkipError
    = NotEnoughPlayersToSkip Int
    | PlayersNotSkippable


{-| Make a request to skip the given players in the given lobby using the given secret to authenticate.
-}
skip : String -> Player.Secret -> List Player.Id -> Request SkipError ()
skip gameCode secret players =
    commandRequest
        "skip"
        [ ( "players", Encode.list (List.map Encode.int players) ) ]
        [ ( ( 400, "not-enough-players" ), Decode.map NotEnoughPlayersToSkip (Decode.field "required" Decode.int) )
        , ( ( 400, "players-must-be-skippable" ), Decode.succeed PlayersNotSkippable )
        ]
        (Decode.succeed ())
        gameCode
        secret


{-| Make a request to stop being skipped.
-}
back : String -> Player.Secret -> Request Never ()
back =
    commandRequest "back" [] [] (Decode.succeed ())


{-| Make a request to leave the game.
-}
leave : String -> Player.Secret -> Request Never ()
leave gameCode secret =
    request
        "POST"
        ("/api/lobbies/" ++ gameCode ++ "/players/" ++ (toString secret.id) ++ "/leave")
        (Just (encodePlayerSecret secret))
        []
        (Decode.succeed ())


{-| Errors specific to redrawing.
* `NotEnoughPoints` - The player does not have enough points to redraw.
-}
type RedrawError
    = NotEnoughPoints


{-| Make a request to redraw the players hand, losing a point.
-}
redraw : String -> Player.Secret -> Request RedrawError Card.Hand
redraw =
    commandRequest
        "redraw"
        []
        [ ( ( 400, "not-enough-points" ), Decode.succeed NotEnoughPoints )
        ]
        handDecoder


{-| Make a request to enable a house rule.
-}
enableRule : HouseRule.Id -> String -> Player.Secret -> Request Never ()
enableRule rule gameCode secret =
    commandRequest "enableRule" [ ( "rule", rule |> HouseRule.toString |> Encode.string ) ] [] (Decode.succeed ()) gameCode secret


{-| Make a request to disable a house rule.
-}
disableRule : HouseRule.Id -> String -> Player.Secret -> Request Never ()
disableRule rule gameCode secret =
    commandRequest "disableRule" [ ( "rule", rule |> HouseRule.toString |> Encode.string ) ] [] (Decode.succeed ()) gameCode secret


{-| Make a request to set the lobby password
-}
setPassword : String -> Player.Secret -> String -> Request Never ()
setPassword gameCode secret password =
    commandRequest "setPassword" [ ( "password", password |> Encode.string ) ] [] (Decode.succeed ()) gameCode secret



{- Private -}


{-| Construct a request for a command.
-}
commandRequest : String -> List ( String, Encode.Value ) -> List (KnownError a) -> Decode.Decoder b -> String -> Player.Secret -> Request a b
commandRequest name args errors decoder gameCode secret =
    request "POST" ("/api/lobbies/" ++ gameCode) (Just (encodeCommand name secret args)) errors decoder
