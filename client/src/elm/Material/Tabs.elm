module Material.Tabs exposing
    ( Model
    , TabModel
    , view
    )

import FontAwesome.Icon as Icon exposing (Icon)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Json.Decode
import Json.Encode
import List.Extra as List
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Html.Attributes as HtmlA
import MassiveDecks.Util.NeList as NonEmptyList exposing (NeList)


{-| A model for a bar of tabs.
-}
type alias Model id msg =
    { selected : id
    , change : id -> msg
    , ids : NeList id
    , tab : id -> TabModel
    , equals : id -> id -> Bool
    }


{-| A model for a tab.
-}
type alias TabModel =
    { label : MdString
    , icon : Maybe Icon
    }


{-| View a bar of tabs.
-}
view : Shared -> Model id msg -> Html msg
view shared { selected, change, ids, tab, equals } =
    let
        idsList =
            ids |> NonEmptyList.toList

        attrs =
            [ idsList |> List.findIndex (equals selected) |> Maybe.withDefault 0 |> activeIndex
            , ((\id -> List.getAt id idsList) >> (ids |> NonEmptyList.head |> Maybe.withDefault) >> change) |> onActivated
            ]

        viewTab { label, icon } =
            let
                ( iconAttr, iconNode ) =
                    case icon of
                        Just i ->
                            ( hasImageIcon, Icon.viewStyled [ HtmlA.slot "icon" ] i )

                        Nothing ->
                            ( HtmlA.nothing, Html.nothing )
            in
            Html.node "mwc-tab" [ label |> Lang.label shared, iconAttr ] [ iconNode ]

        tabs =
            idsList |> List.map (tab >> viewTab)
    in
    Html.node "mwc-tab-bar" attrs tabs



{- Private -}


activeIndex : Int -> Html.Attribute msg
activeIndex =
    Json.Encode.int >> HtmlA.property "activeIndex"


hasImageIcon : Html.Attribute msg
hasImageIcon =
    HtmlA.attribute "hasImageIcon" "hasImageIcon"


onActivated : (Int -> msg) -> Html.Attribute msg
onActivated wrap =
    Json.Decode.int |> Json.Decode.map wrap |> Json.Decode.at [ "target", "activeIndex" ] |> HtmlE.on "MDCTabBar:activated"
