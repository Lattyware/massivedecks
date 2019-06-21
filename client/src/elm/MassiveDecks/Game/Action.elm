module MassiveDecks.Game.Action exposing (actions, view)

import FontAwesome.Icon exposing (Icon)
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Components as Components
import MassiveDecks.Game.Action.Model exposing (..)
import MassiveDecks.Game.Messages as Game
import MassiveDecks.Messages as Global
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Messages as Lobby
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html.Attributes as HtmlA
import Weightless.Attributes as WlA


actions : List Action
actions =
    [ Submit, TakeBack, Judge, Like ]


view : Shared -> Maybe Action -> Action -> Html Global.Msg
view shared visible action =
    let
        { icon, attrs, title, onClick } =
            case action of
                Submit ->
                    IconView Icon.check [ HtmlA.class "important" ] Strings.SubmitPlay Game.Submit

                TakeBack ->
                    IconView Icon.undo [ WlA.inverted, WlA.outlined ] Strings.TakeBackPlay Game.TakeBack

                Judge ->
                    IconView Icon.trophy [ HtmlA.class "important" ] Strings.JudgePlay Game.Judge

                Like ->
                    IconView Icon.thumbsUp [ WlA.inverted, WlA.outlined ] Strings.LikePlay Game.Like
    in
    Components.floatingActionButton
        (List.concat
            [ [ title |> Lang.title shared
              , onClick |> Lobby.GameMsg |> Global.LobbyMsg |> HtmlE.onClick
              , HtmlA.classList [ ( "action", True ), ( "exited", visible /= Just action ) ]
              ]
            , attrs
            ]
        )
        icon


type alias IconView =
    { icon : Icon
    , attrs : List (Html.Attribute Global.Msg)
    , title : MdString
    , onClick : Game.Msg
    }
