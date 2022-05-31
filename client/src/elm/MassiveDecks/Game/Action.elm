module MassiveDecks.Game.Action exposing (view)

import FontAwesome as Icon exposing (Icon)
import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Game.Action.Model exposing (..)
import MassiveDecks.Game.Messages as Game exposing (Msg)
import MassiveDecks.Icon as Icon
import MassiveDecks.Model exposing (..)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import Material.Fab as Fab


actions : List Action
actions =
    [ PickCall, EditCall, Submit, TakeBack, Judge, Like, Advance ]


{-| Style for actions that are blocking the game from continuing until they are performed.
-}
blocking : List (Html.Attribute msg)
blocking =
    [ HtmlA.class "blocking" ]


{-| Style for an action that doesn't block the game.
-}
normal : List (Html.Attribute msg)
normal =
    [ HtmlA.class "normal" ]


view : (Msg -> msg) -> Shared -> Maybe Action -> Html msg
view wrap shared visible =
    Html.div [] (actions |> List.map (viewSingle wrap shared visible))


viewSingle : (Msg -> msg) -> Shared -> Maybe Action -> Action -> Html msg
viewSingle wrap shared visible action =
    let
        { icon, attrs, type_, title, onClick } =
            case action of
                PickCall ->
                    IconView Icon.accept blocking Fab.Normal Strings.PickCall Game.Submit

                EditCall ->
                    IconView Icon.edit blocking Fab.Normal Strings.WriteCall Game.WriteCall

                Submit ->
                    IconView Icon.accept blocking Fab.Normal Strings.SubmitPlay Game.Submit

                TakeBack ->
                    IconView Icon.undo normal Fab.Normal Strings.TakeBackPlay Game.TakeBack

                Judge ->
                    IconView Icon.win blocking Fab.Normal Strings.JudgePlay Game.Judge

                Like ->
                    IconView Icon.like normal Fab.Normal Strings.LikePlay Game.Like

                Advance ->
                    IconView Icon.skip blocking Fab.Normal Strings.AdvanceRound Game.AdvanceRound

                Discard ->
                    IconView Icon.discard normal Fab.Mini Strings.HouseRuleNeverHaveIEver Game.Discard
    in
    Fab.view
        type_
        (title |> Lang.string shared)
        (icon |> Icon.view)
        (onClick |> wrap |> Just)
        (HtmlA.classList [ ( "action", True ), ( "exited", visible /= Just action ) ] :: attrs)


type alias IconView msg =
    { icon : Icon Icon.WithoutId
    , attrs : List (Html.Attribute msg)
    , type_ : Fab.Type
    , title : MdString
    , onClick : Game.Msg
    }
