module Material.Select exposing
    ( ItemModel
    , Model
    , view
    )

import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Json.Decode as Json
import Json.Encode
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html.Attributes as HtmlA


{-| A combo box.
-}
view : Shared -> Model id msg -> List (Html.Attribute msg) -> List (ItemModel id msg) -> Html msg
view shared model attrs items =
    let
        allAttrs =
            List.concat
                [ [ model.label |> Lang.label shared
                  , model.idFromString >> model.wrap |> onChange
                  , HtmlA.fullWidth
                  ]
                , attrs
                ]
    in
    Html.node "mwc-select" allAttrs (items |> List.map (viewItem model))


{-| The things needed to render the select.
-}
type alias Model id msg =
    { label : MdString
    , idToString : id -> String
    , idFromString : String -> Maybe id
    , selected : Maybe id
    , wrap : Maybe id -> msg
    }


{-| The things needed to render a specific item in the select.
-}
type alias ItemModel id msg =
    { id : id
    , icon : Maybe (Html msg)
    , primary : List (Html msg)
    , secondary : Maybe (List (Html msg))
    , meta : Maybe (Html msg)
    }



{- Private -}


{-| An item within a list.
-}
viewItem : Model id msg -> ItemModel id msg -> Html msg
viewItem { idToString, selected } { id, icon, primary, secondary, meta } =
    let
        ( optionalAttrs, optionalSlots ) =
            [ icon |> Maybe.map (\i -> ( HtmlA.attribute "graphic" "large", Html.span [ HtmlA.slot "graphic" ] [ i ] ))
            , meta |> Maybe.map (\m -> ( True |> Json.Encode.bool |> HtmlA.property "hasMeta", Html.span [ HtmlA.slot "meta" ] [ m ] ))
            , secondary |> Maybe.map (\s -> ( True |> Json.Encode.bool |> HtmlA.property "twoline", Html.span [ HtmlA.slot "secondary" ] s ))
            ]
                |> List.filterMap identity
                |> List.unzip

        attrs =
            List.concat [ optionalAttrs, [ id |> idToString |> HtmlA.value, selected == Just id |> HtmlA.selected ] ]

        slots =
            List.concat [ primary, optionalSlots ] |> List.intersperse (Html.text " ")
    in
    Html.node "mwc-list-item" attrs slots


{-| An event for when the user changes the selection.
-}
onChange : (String -> msg) -> Html.Attribute msg
onChange wrap =
    Json.at [ "target", "value" ] Json.string |> Json.map wrap |> HtmlE.on "change"
