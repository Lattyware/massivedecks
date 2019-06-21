module MassiveDecks.Pages.Unknown.Route exposing
    ( Route
    , partsAndFragment
    , route
    )

{-| A route for the unknown page page.
-}


type alias Route =
    { requestedPage : List String
    }


route : List String -> Maybe String -> Route
route parts _ =
    { requestedPage = parts }


{-| Get the parts and fragment for a URL based on the given route.
-}
partsAndFragment : Route -> ( List String, Maybe String )
partsAndFragment r =
    ( r.requestedPage, Nothing )
