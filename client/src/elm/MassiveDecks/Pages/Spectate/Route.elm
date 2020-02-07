module MassiveDecks.Pages.Spectate.Route exposing
    ( Route
    , partsAndFragment
    , route
    )

import MassiveDecks.Pages.Lobby.GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Route as Lobby


{-| A route for a lobby page.
-}
type alias Route =
    { gameCode : GameCode
    }


route : List String -> Maybe String -> Maybe Route
route parts fragment =
    let
        oneLess =
            List.length parts - 1

        allButLast =
            parts |> List.take oneLess

        last =
            parts |> List.drop oneLess |> List.head
    in
    if last == Just spectateName then
        Lobby.route allButLast fragment |> Maybe.map (\lobby -> { gameCode = lobby.gameCode })

    else
        Nothing


{-| Get the parts and fragment for a URL based on the given route.
-}
partsAndFragment : Route -> ( List String, Maybe String )
partsAndFragment r =
    let
        ( parts, fragment ) =
            Lobby.partsAndFragment { gameCode = r.gameCode, section = Nothing }
    in
    ( parts ++ [ spectateName ], fragment )



{- Private -}


spectateName =
    "spectate"
