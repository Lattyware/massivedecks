module MassiveDecks.Pages.Lobby.Route exposing
    ( Route
    , Section(..)
    , partsAndFragment
    , route
    )

import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)
import MassiveDecks.Util.Maybe as Maybe


{-| A route for a lobby page.
-}
type alias Route =
    { gameCode : GameCode
    , section : Maybe Section
    }


type Section
    = Configure
    | Play
    | Spectate


route : List String -> Maybe String -> Maybe Route
route parts _ =
    case parts of
        name :: gameCode :: sectionName ->
            let
                section =
                    if sectionName == [ configName ] then
                        Just Configure

                    else if sectionName == [ playName ] then
                        Just Play

                    else if sectionName == [ spectateName ] then
                        Just Spectate

                    else
                        Nothing
            in
            gameCode
                |> Maybe.justIf (name == lobbiesName)
                |> Maybe.andThen GameCode.fromString
                |> Maybe.map (\gc -> { gameCode = gc, section = section })

        _ ->
            Nothing


{-| Get the parts and fragment for a URL based on the given route.
-}
partsAndFragment : Route -> ( List String, Maybe String )
partsAndFragment r =
    ( List.filterMap identity
        [ lobbiesName |> Just
        , r.gameCode |> GameCode.toString |> Just
        , r.section |> Maybe.map sectionToString
        ]
    , Nothing
    )



{- Private -}


lobbiesName : String
lobbiesName =
    "games"


configName : String
configName =
    "configure"


playName : String
playName =
    "play"


spectateName : String
spectateName =
    "spectate"


sectionToString : Section -> String
sectionToString section =
    case section of
        Configure ->
            configName

        Play ->
            playName

        Spectate ->
            spectateName
