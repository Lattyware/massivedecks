module MassiveDecks.Pages.Lobby.Spectate.Stages.Postgame exposing (view)

import Dict exposing (Dict)
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Keyed as HtmlK
import MassiveDecks.Game.Model exposing (Game)
import MassiveDecks.Game.Player exposing (Player)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Model exposing (Lobby)
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Maybe as Maybe
import Set exposing (Set)


view : Shared -> Lobby -> Game -> Set User.Id -> List (Html msg)
view shared lobby game winner =
    [ viewPlayers shared lobby.users game.players winner
    ]



{- Private -}


viewPlayers : Shared -> Dict User.Id User -> Dict User.Id Player -> Set User.Id -> Html msg
viewPlayers shared users players winner =
    let
        playerDetails =
            users
                |> Dict.toList
                |> List.filterMap (extractPlayerDetails players)
                |> List.sortBy (\( _, _, p ) -> p.score)
                |> List.reverse
    in
    HtmlK.ol [ HtmlA.id "players" ] (playerDetails |> List.map (viewPlayer shared winner))


extractPlayerDetails : Dict User.Id Player -> ( User.Id, User ) -> Maybe ( User.Id, User, Player )
extractPlayerDetails players ( id, user ) =
    Dict.get id players |> Maybe.map (\p -> ( id, user, p ))


viewPlayer : Shared -> Set User.Id -> ( User.Id, User, Player ) -> ( String, Html msg )
viewPlayer shared winner ( id, user, player ) =
    let
        icon =
            case user.control of
                User.Human ->
                    Icon.user

                User.Computer ->
                    Icon.robot
    in
    ( id
    , Html.li [ HtmlA.class "player" ]
        [ Html.span [ HtmlA.class "head" ]
            [ Icon.viewIcon Icon.trophy |> Maybe.justIf (Set.member id winner) |> Maybe.withDefault Html.nothing
            , Icon.viewIcon icon
            ]
        , Html.span [ HtmlA.class "name" ]
            [ user.name |> Html.text
            , Html.text " ("
            , Strings.Score { total = player.score } |> Lang.html shared
            , Html.text ")"
            ]
        ]
    )
