module Material.TextField exposing
    ( Type(..)
    , view
    )

import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang


{-| The type of field.
-}
type Type
    = Text
    | Search
    | Tel
    | Url
    | Email
    | Password
    | Date
    | Month
    | Week
    | Time
    | DateTimeLocal
    | Number
    | Color


{-| A text field for the given type of data.
-}
view : Shared -> MdString -> Type -> String -> List (Html.Attribute msg) -> Html msg
view shared label t value attributes =
    let
        allAttrs =
            List.concat
                [ [ label |> Lang.label shared
                  , t |> type_
                  , value |> HtmlA.value
                  ]
                , attributes
                ]
    in
    Html.node "mwc-textfield" allAttrs []



{- Private -}


type_ : Type -> Html.Attribute msg
type_ t =
    let
        stringType =
            case t of
                Text ->
                    "text"

                Search ->
                    "search"

                Tel ->
                    "tel"

                Url ->
                    "url"

                Email ->
                    "email"

                Password ->
                    "password"

                Date ->
                    "date"

                Month ->
                    "month"

                Week ->
                    "week"

                Time ->
                    "time"

                DateTimeLocal ->
                    "datetime-local"

                Number ->
                    "number"

                Color ->
                    "color"
    in
    stringType |> HtmlA.attribute "type"
