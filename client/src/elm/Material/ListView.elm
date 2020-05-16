module Material.ListView exposing
    ( Action(..)
    , action
    , interactive
    , view
    , viewItem
    )

import FontAwesome.Icon as Icon exposing (Icon)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Json.Encode as Json
import MassiveDecks.Util.Html.Attributes as HtmlA


{-| A list.
-}
view : List (Html.Attribute msg) -> List (Html msg) -> Html msg
view attributes children =
    Html.node "mwc-list" attributes children


{-| What happens when you interact with the item.
-}
type Action msg
    = None
    | Link
    | Enabled msg
    | Disabled


{-| A list item that is only sometimes enabled.
-}
interactive : msg -> Bool -> Action msg
interactive msg enabled =
    if enabled then
        Enabled msg

    else
        Disabled


{-| An action from a maybe, if it is enabled.
-}
action : Maybe msg -> Action msg
action a =
    case a of
        Just msg ->
            Enabled msg

        Nothing ->
            Disabled


{-| An item within a list.
-}
viewItem : Action msg -> Maybe Icon -> Maybe (List (Html msg)) -> Maybe (List (Html msg)) -> List (Html msg) -> Html msg
viewItem action_ icon secondary meta children =
    let
        ( optionalAttrs, optionalSlots ) =
            [ icon |> Maybe.map (\i -> ( HtmlA.attribute "graphic" "large", Icon.viewStyled [ HtmlA.slot "graphic" ] i ))
            , meta |> Maybe.map (\m -> ( True |> Json.bool |> HtmlA.property "hasMeta", Html.span [ HtmlA.slot "meta" ] m ))
            , secondary |> Maybe.map (\s -> ( True |> Json.bool |> HtmlA.property "twoline", Html.span [ HtmlA.slot "secondary" ] s ))
            ]
                |> List.filterMap identity
                |> List.unzip

        actionAttr =
            case action_ of
                Enabled msg ->
                    msg |> HtmlE.onClick

                Disabled ->
                    HtmlA.disabled True

                Link ->
                    HtmlA.nothing

                None ->
                    True |> Json.bool |> HtmlA.property "noninteractive"

        attrs =
            List.concat [ optionalAttrs, [ actionAttr ] ]

        slots =
            List.concat [ optionalSlots, [ Html.span [] children ] ]
    in
    Html.node "mwc-list-item" attrs slots
