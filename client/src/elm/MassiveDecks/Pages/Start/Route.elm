module MassiveDecks.Pages.Start.Route exposing
    ( Route
    , Section(..)
    , partsAndFragment
    , route
    )

import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)


{-| A route for the start page.
-}
type alias Route =
    { section : Section
    }


{-| A section of the start page.
-}
type Section
    = New
    | Join (Maybe GameCode)
    | Find
    | About


route : List String -> Maybe String -> Maybe Route
route givenParts fragment =
    let
        section =
            if givenParts == parts then
                Just
                    (case fragment of
                        Just frag ->
                            if frag == newFragment then
                                New

                            else if frag == findFragment then
                                Find

                            else if frag == aboutFragment then
                                About

                            else if frag == joinFragment then
                                Join Nothing

                            else
                                frag |> GameCode.fromString |> Join

                        Nothing ->
                            New
                    )

            else
                Nothing
    in
    section |> Maybe.map (\s -> { section = s })


{-| Get the parts and fragment for a URL based on the given route.
-}
partsAndFragment : Route -> ( List String, Maybe String )
partsAndFragment r =
    ( parts
    , case r.section of
        New ->
            Just newFragment

        Join gameCode ->
            Just (gameCode |> Maybe.map GameCode.toString |> Maybe.withDefault joinFragment)

        Find ->
            Just findFragment

        About ->
            Just aboutFragment
    )



{- Private -}


parts : List String
parts =
    []


newFragment : String
newFragment =
    "new"


joinFragment : String
joinFragment =
    "join"


findFragment : String
findFragment =
    "find"


aboutFragment : String
aboutFragment =
    "about"
