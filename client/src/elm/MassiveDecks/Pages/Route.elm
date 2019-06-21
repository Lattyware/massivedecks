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
import MassiveDecks.Pages.Spectate.Route as Spectate
import MassiveDecks.Pages.Start.Route as Start
import MassiveDecks.Pages.Unknown.Route as Unknown
import MassiveDecks.Util.Maybe as Maybe
import Url exposing (Url)
import Url.Builder


{-| A route in the application represents a navigable subsection of it.
These can be transformed to and from URLs.
-}
type Route
    = Start Start.Route
    | Lobby Lobby.Route
    | Spectate Spectate.Route
    | Unknown Unknown.Route


{-| Either some data, or a redirect to a new route.
-}
type Fork a
    = Continue a
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
    , Spectate.route parts fragment |> Maybe.map Spectate
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

        Spectate spectateRoute ->
            Spectate.partsAndFragment spectateRoute

        Unknown unknownRoute ->
            Unknown.partsAndFragment unknownRoute
