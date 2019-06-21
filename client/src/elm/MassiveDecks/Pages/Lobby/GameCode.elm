module MassiveDecks.Pages.Lobby.GameCode exposing
    ( GameCode
    , fromString
    , toString
    , trusted
    )

import Set exposing (Set)


{-| A code for the lobby to identify it for users.
-}
type GameCode
    = GameCode String


{-| If we get the game code from a trusted source, then we don't need to sanity check it.
-}
trusted : String -> GameCode
trusted =
    GameCode


{-| Get a game code from a string by sanitising it.
-}
fromString : String -> Maybe GameCode
fromString string =
    case string of
        "" ->
            Nothing

        _ ->
            string |> String.toUpper |> String.filter (\c -> Set.member c alphabet) |> GameCode |> Just


{-| Get a string from a game code.
-}
toString : GameCode -> String
toString (GameCode gameCode) =
    gameCode



{- Private -}


alphabet : Set Char
alphabet =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" |> String.toList |> Set.fromList
