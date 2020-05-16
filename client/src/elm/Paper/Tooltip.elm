module Paper.Tooltip exposing
    ( Position(..)
    , view
    )

import Html
import Html.Attributes as HtmlA


view : Position -> String -> List (Html.Html msg) -> Html.Html msg
view pos for =
    Html.node "paper-tooltip" [ position pos, HtmlA.attribute "for" for ]


type Position
    = Top
    | Right
    | Bottom
    | Left



{- Private -}


position : Position -> Html.Attribute msg
position pos =
    let
        positionString =
            case pos of
                Top ->
                    "top"

                Right ->
                    "right"

                Bottom ->
                    "bottom"

                Left ->
                    "left"
    in
    HtmlA.attribute "position" positionString
