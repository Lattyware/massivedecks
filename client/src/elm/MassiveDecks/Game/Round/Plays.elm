module MassiveDecks.Game.Round.Plays exposing (Details, view)

import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Html.Keyed as HtmlK
import MassiveDecks.Card.Play as Play
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
view : String -> Maybe Play.Id -> List (Details msg) -> Html msg
view class picked details =
    HtmlK.ul [ HtmlA.classList [ ( class, True ), ( "plays", True ) ] ] (details |> List.map (viewPlay picked))



{- Private -}


viewPlay : Maybe Play.Id -> Details msg -> ( String, Html msg )
viewPlay picked { id, responses, action, attrs } =
    ( id
    , Html.li
        (List.concat
            [ [ HtmlA.classList [ ( "play", True ), ( "picked", picked == Just id ) ]
              , action |> Maybe.map HtmlE.onClick |> Maybe.withDefault HtmlA.nothing
              ]
            , attrs
            ]
        )
        (responses |> List.map (\card -> Html.div [ HtmlA.class "overlap" ] [ card ]))
    )
