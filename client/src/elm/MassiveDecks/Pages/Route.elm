module MassiveDecks.Pages.Route exposing
    ( Fork(..)
    , Route(..)
    , externalUrl
    , fromUrl
    , href
    , url
    )

import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Pages.Lobby.Route as Lobby
import MassiveDecks.Pages.Start.Route as Start
import MassiveDecks.Pages.Unknown.Route as Unknown
import MassiveDecks.Util.Maybe as Maybe
import Url exposing (Url)
import Url.Builder


{-| A route in the application represents a navigable subsection of it.
These can be transformed to and from URLs losslessly.
-}
type Route
    = Start Start.Route
    | Lobby Lobby.Route
    | Unknown Unknown.Route
    | Loading


{-| A situation where either an operation continues as expected with some data, or the application is redirected to a
new route.
-}
type Fork continue
    = Continue continue
    | Redirect Route


{-| Get the URL for the given page.
-}
url : Route -> String
url route =
    urlRoot Url.Builder.Absolute route


{-| Get the URL for the given page, with the origin - useful for giving the user a link to copy/paste, etc...
-}
externalUrl : String -> Route -> String
externalUrl origin route =
    urlRoot (Url.Builder.CrossOrigin origin) route


{-| Get the page described by the given URL.
-}
fromUrl : Url -> Route
fromUrl given =
    let
        parts =
            given.path |> String.split "/" |> List.filter ((/=) "")

        fragment =
            given.fragment
    in
    [ Start.route parts fragment |> Maybe.map Start
    , Lobby.route parts fragment |> Maybe.map Lobby
    ]
        |> Maybe.first
        |> Maybe.withDefault (Unknown.route parts fragment |> Unknown)


{-| Convenience to construct an `href` attribute for a link to the given page.
-}
href : Route -> Html.Attribute msg
href =
    url >> HtmlA.href



{- Private -}


urlRoot : Url.Builder.Root -> Route -> String
urlRoot root route =
    let
        ( parts, fragment ) =
            partsAndFragment route
    in
    Url.Builder.custom root parts [] fragment


partsAndFragment : Route -> ( List String, Maybe String )
partsAndFragment route =
    case route of
        Start startRoute ->
            Start.partsAndFragment startRoute

        Lobby lobbyRoute ->
            Lobby.partsAndFragment lobbyRoute

        Unknown unknownRoute ->
            Unknown.partsAndFragment unknownRoute

        Loading ->
            ( [], Nothing )
