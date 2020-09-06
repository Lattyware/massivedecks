module MassiveDecks.Game.Round.Plays exposing
    ( ByLine
    , Details
    , SpecialRole(..)
    , view
    , viewByLine
    )

import Dict exposing (Dict)
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
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
import Set exposing (Set)


{-| The details needed to render a specific play.
-}
type alias Details msg =
    { id : Play.Id
    , responses : List (Html msg)
    , action : Maybe msg
    , byLine : Maybe ByLine
    }


{-| The details needed for a by line.
-}
type alias ByLine =
    { by : User.Id
    , specialRole : Maybe SpecialRole
    , likes : Maybe Int
    }


{-| If the user had a special role in the game, then this defines it.
-}
type SpecialRole
    = Winner
    | Czar


{-| View a collection of plays.
-}
view : Shared -> Dict User.Id User -> List ( String, Bool ) -> Set Play.Id -> Maybe Play.Id -> List (Details msg) -> Html msg
view shared users classes liked picked details =
    HtmlK.ul [ HtmlA.classList (classes ++ [ ( "cards", True ), ( "plays", True ) ]) ]
        (details |> List.map (viewPlay shared users liked picked))


{-| Create a byline.
-}
viewByLine : Shared -> Dict User.Id User -> ByLine -> Html msg
viewByLine shared users { by, specialRole, likes } =
    let
        roleIcon role =
            let
                ( cls, icon ) =
                    case role of
                        Winner ->
                            ( "trophy", Icon.trophy )

                        Czar ->
                            ( "czar", Icon.gavel )
            in
            Html.span [ HtmlA.class cls ] [ Icon.viewIcon icon ]

        name =
            users |> Dict.get by |> Maybe.map .name |> Maybe.withDefault (Strings.UnknownUser |> Lang.string shared)

        contents =
            [ specialRole |> Maybe.map roleIcon
            , Html.span [ HtmlA.class "name" ] [ Html.text name ] |> Just
            , likes
                |> Maybe.map (\l -> Html.span [ HtmlA.class "likes" ] [ Strings.Likes { total = l } |> Lang.html shared ])
            ]
    in
    Html.span [ HtmlA.class "byline", HtmlA.title name ] (contents |> List.filterMap identity)



{- Private -}


viewPlay : Shared -> Dict User.Id User -> Set Play.Id -> Maybe Play.Id -> Details msg -> ( String, Html msg )
viewPlay shared users liked picked { id, responses, action, byLine } =
    ( id
    , Html.li [ HtmlA.classList [ ( "with-byline", byLine /= Nothing ) ] ]
        [ byLine |> Maybe.map (viewByLine shared users) |> Maybe.withDefault Html.nothing
        , Html.ol
            [ HtmlA.classList
                [ ( "play", True )
                , ( "card-set", True )
                , ( "active", action /= Nothing )
                , ( "picked", picked == Just id )
                , ( "liked", Set.member id liked )
                ]
            , action |> Maybe.map HtmlE.onClick |> Maybe.withDefault HtmlA.nothing
            ]
            (responses |> List.map (\card -> Html.li [] [ card ]))
        ]
    )
