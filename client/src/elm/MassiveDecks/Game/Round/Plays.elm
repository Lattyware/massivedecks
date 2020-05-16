module MassiveDecks.Game.Round.Plays exposing (Details, byLine, view)

import Dict exposing (Dict)
import FontAwesome.Icon as Icon exposing (Icon)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Html.Keyed as HtmlK
import MassiveDecks.Card.Play as Play
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Html.Attributes as HtmlA


{-| The details needed to render a specific play.
-}
type alias Details msg =
    { id : Play.Id
    , responses : List (Html msg)
    , action : Maybe msg
    , attrs : List (Html.Attribute msg)
    }


{-| View a collection of plays.
-}
view : List ( String, Bool ) -> Maybe Play.Id -> List (Details msg) -> Html msg
view classes picked details =
    HtmlK.ul [ HtmlA.classList (classes ++ [ ( "cards", True ), ( "plays", True ) ]) ]
        (details |> List.map (viewPlay picked))


{-| Create a byline.
-}
byLine : Shared -> Dict User.Id User -> User.Id -> Maybe ( String, Icon ) -> Maybe Int -> Html msg
byLine shared users id icon likes =
    let
        name =
            users |> Dict.get id |> Maybe.map .name |> Maybe.withDefault (Strings.UnknownUser |> Lang.string shared)
    in
    Html.span [ HtmlA.class "byline", HtmlA.title name ]
        [ icon
            |> Maybe.map (\( cls, i ) -> Html.span [ HtmlA.class cls ] [ Icon.viewIcon i ])
            |> Maybe.withDefault Html.nothing
        , Html.span [ HtmlA.class "name" ] [ Html.text name ]
        , likes
            |> Maybe.map (\l -> Html.span [ HtmlA.class "likes" ] [ Strings.Likes { total = l } |> Lang.html shared ])
            |> Maybe.withDefault Html.nothing
        ]



{- Private -}


viewPlay : Maybe Play.Id -> Details msg -> ( String, Html msg )
viewPlay picked { id, responses, action, attrs } =
    ( id
    , Html.li []
        [ Html.ol
            (HtmlA.classList [ ( "play", True ), ( "card-set", True ), ( "picked", picked == Just id ) ]
                :: (action |> Maybe.map HtmlE.onClick |> Maybe.withDefault HtmlA.nothing)
                :: attrs
            )
            (responses |> List.map (\card -> Html.li [] [ card ]))
        ]
    )
