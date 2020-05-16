module MassiveDecks.Pages.Lobby.Spectate.Stages.Pregame exposing (view)

import Dict exposing (Dict)
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Keyed as HtmlK
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Model exposing (Lobby)
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User exposing (User)
import Svg.Attributes as SvgA


view : Shared -> Lobby -> List (Html msg)
view shared lobby =
    [ HtmlK.ul [ HtmlA.id "players" ] (players shared lobby.users)
    , Html.div [ HtmlA.id "spectators" ] (spectators shared lobby.users)
    ]



{- Private -}


players : Shared -> Dict User.Id User -> List ( String, Html msg )
players shared users =
    users |> Dict.toList |> List.filterMap (player shared)


player : Shared -> ( User.Id, User ) -> Maybe ( String, Html msg )
player _ ( id, user ) =
    case user.role of
        User.Player ->
            let
                icon =
                    case user.control of
                        User.Human ->
                            Icon.user

                        User.Computer ->
                            Icon.robot
            in
            Just
                ( id
                , Html.li [ HtmlA.class "player" ]
                    [ Icon.viewStyled [ SvgA.class "head" ] icon
                    , Html.span [ HtmlA.class "name" ] [ user.name |> Html.text ]
                    ]
                )

        User.Spectator ->
            Nothing


spectators : Shared -> Dict User.Id User -> List (Html msg)
spectators shared users =
    [ Html.span [ HtmlA.class "title" ]
        [ Strings.Spectators |> Lang.html shared
        , Html.text ": "
        ]
    , Html.span [ HtmlA.class "count" ]
        [ users |> Dict.values |> List.filter (.role >> (==) User.Spectator) |> List.length |> String.fromInt |> Html.text
        ]
    ]
