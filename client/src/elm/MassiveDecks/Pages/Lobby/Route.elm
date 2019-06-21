module MassiveDecks.Pages.Lobby.Route exposing
    ( Route
    , partsAndFragment
    , route
    )

import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)
import MassiveDecks.Util.Maybe as Maybe


{-| A route for a lobby page.
-}
type alias Route =
    { gameCode : GameCode
    }


route : List String -> Maybe String -> Maybe Route
route parts _ =
    case parts of
        [ name, gameCode ] ->
            gameCode
                |> Maybe.justIf (name == lobbiesName)
                |> Maybe.andThen GameCode.fromString
                |> Maybe.map (\gc -> { gameCode = gc })

        _ ->
            Nothing


{-| Get the parts and fragment for a URL based on the given route.
-}
partsAndFragment : Route -> ( List String, Maybe String )
partsAndFragment r =
    ( [ lobbiesName, r.gameCode |> GameCode.toString ], Nothing )



{- Private -}


lobbiesName =
    "games"
