module Weightless.Attributes exposing
    ( Alignment(..)
    , ExpansionSlot(..)
    , InputType(..)
    , ListItemSlot(..)
    , NavSlot(..)
    , TextFieldSlot(..)
    , XOrigin(..)
    , YOrigin(..)
    , active
    , align
    , anchor
    , anchorCloseEvents
    , anchorOpenEvents
    , anchorOrigin
    , checked
    , clickable
    , disableFocusTrap
    , disabled
    , expansionSlot
    , fab
    , filled
    , fixed
    , flat
    , hoverable
    , icon
    , inverted
    , label
    , list
    , listItemSlot
    , max
    , maxLength
    , min
    , minLength
    , name
    , navSlot
    , outlined
    , readonly
    , selected
    , step
    , textFieldSlot
    , transformOrigin
    , type_
    , value
    , vertical
    )

import Html exposing (Html)
import Html.Attributes as HtmlA
import Json.Encode as Json


step : Int -> Html.Attribute msg
step =
    numberAttr "step"


min : Int -> Html.Attribute msg
min =
    numberAttr "min"


max : Int -> Html.Attribute msg
max =
    numberAttr "max"


maxLength : Int -> Html.Attribute msg
maxLength =
    numberAttr "maxLength"


minLength : Int -> Html.Attribute msg
minLength =
    numberAttr "minLength"


anchorOpenEvents : List String -> Html.Attribute msg
anchorOpenEvents =
    stringArrayProperty "anchorOpenEvents"


anchorCloseEvents : List String -> Html.Attribute msg
anchorCloseEvents =
    stringArrayProperty "anchorCloseEvents"


anchor : String -> Html.Attribute msg
anchor id =
    stringAttr "anchor" ("#" ++ id)


icon : String -> Html.Attribute msg
icon icon_name =
    stringAttr "icon" icon_name


name : String -> Html.Attribute msg
name group =
    stringAttr "name" group


type NavSlot
    = Title
    | Left
    | Right


navSlot : NavSlot -> Html.Attribute msg
navSlot slot =
    let
        textSlot =
            case slot of
                Title ->
                    "title"

                Left ->
                    "left"

                Right ->
                    "right"
    in
    stringAttr "slot" textSlot


type ExpansionSlot
    = ETitle
    | EDescription


expansionSlot : ExpansionSlot -> Html.Attribute msg
expansionSlot slot =
    let
        textSlot =
            case slot of
                ETitle ->
                    "title"

                EDescription ->
                    "description"
    in
    stringAttr "slot" textSlot


type ListItemSlot
    = BeforeItem
    | AfterItem


listItemSlot : ListItemSlot -> Html.Attribute msg
listItemSlot slot =
    let
        textSlot =
            case slot of
                BeforeItem ->
                    "before"

                AfterItem ->
                    "after"
    in
    stringAttr "slot" textSlot


type TextFieldSlot
    = BeforeText
    | AfterText


textFieldSlot : TextFieldSlot -> Html.Attribute msg
textFieldSlot slot =
    let
        textSlot =
            case slot of
                BeforeText ->
                    "before"

                AfterText ->
                    "after"
    in
    stringAttr "slot" textSlot


value : String -> Html.Attribute msg
value text =
    stringAttr "value" text


type Alignment
    = Start
    | Center
    | End


align : Alignment -> Html.Attribute msg
align alignment =
    let
        textAlignment =
            case alignment of
                Start ->
                    "start"

                Center ->
                    "center"

                End ->
                    "end"
    in
    stringAttr "align" textAlignment


list : String -> Html.Attribute msg
list datalistSelector =
    stringAttr "list" datalistSelector


type InputType
    = Password
    | Email
    | Number
    | Color
    | Date
    | Search
    | Tel
    | File


type_ : InputType -> Html.Attribute msg
type_ inputType =
    let
        textInputType =
            case inputType of
                Password ->
                    "password"

                Email ->
                    "email"

                Number ->
                    "number"

                Color ->
                    "color"

                Date ->
                    "date"

                Search ->
                    "search"

                Tel ->
                    "tel"

                File ->
                    "file"
    in
    stringAttr "type" textInputType


label : String -> Html.Attribute msg
label text =
    stringAttr "label" text


inverted : Html.Attribute msg
inverted =
    presentAttribute "inverted"


vertical : Html.Attribute msg
vertical =
    presentAttribute "vertical"


filled : Html.Attribute msg
filled =
    presentAttribute "filled"


outlined : Html.Attribute msg
outlined =
    presentAttribute "outlined"


flat : Html.Attribute msg
flat =
    presentAttribute "flat"


fab : Html.Attribute msg
fab =
    presentAttribute "fab"


hoverable : Html.Attribute msg
hoverable =
    presentAttribute "hoverable"


disabled : Html.Attribute msg
disabled =
    presentAttribute "disabled"


readonly : Html.Attribute msg
readonly =
    presentAttribute "readonly"


active : Html.Attribute msg
active =
    presentAttribute "active"


clickable : Html.Attribute msg
clickable =
    presentAttribute "clickable"


checked : Html.Attribute msg
checked =
    presentAttribute "checked"


fixed : Html.Attribute msg
fixed =
    presentAttribute "fixed"


selected : Html.Attribute msg
selected =
    presentAttribute "selected"


disableFocusTrap : Html.Attribute msg
disableFocusTrap =
    presentAttribute "disablefocustrap"


type XOrigin
    = XLeft
    | XCenter
    | XRight


type YOrigin
    = YTop
    | YCenter
    | YBottom


anchorOrigin : XOrigin -> YOrigin -> List (Html.Attribute msg)
anchorOrigin =
    origin "anchor"


transformOrigin : XOrigin -> YOrigin -> List (Html.Attribute msg)
transformOrigin =
    origin "transform"



{- Private -}


origin : String -> XOrigin -> YOrigin -> List (Html.Attribute msg)
origin prefix xOrigin yOrigin =
    let
        ( textXOrigin, textYOrigin ) =
            textOrigin xOrigin yOrigin
    in
    [ stringAttr (prefix ++ "originx") textXOrigin
    , stringAttr (prefix ++ "originy") textYOrigin
    ]


textOrigin : XOrigin -> YOrigin -> ( String, String )
textOrigin xOrigin yOrigin =
    let
        textXOrigin =
            case xOrigin of
                XLeft ->
                    "left"

                XCenter ->
                    "center"

                XRight ->
                    "right"

        textYOrigin =
            case yOrigin of
                YTop ->
                    "top"

                YCenter ->
                    "center"

                YBottom ->
                    "bottom"
    in
    ( textXOrigin, textYOrigin )


presentAttribute : String -> Html.Attribute msg
presentAttribute attribute =
    HtmlA.attribute attribute attribute


stringArrayProperty : String -> List String -> Html.Attribute msg
stringArrayProperty property values =
    HtmlA.property property (values |> Json.list Json.string)


stringAttr : String -> String -> Html.Attribute msg
stringAttr attribute stringValue =
    HtmlA.attribute attribute stringValue


numberAttr : String -> Int -> Html.Attribute msg
numberAttr attribute intValue =
    intValue |> String.fromInt |> HtmlA.attribute attribute


numberProp : String -> Int -> Html.Attribute msg
numberProp property intValue =
    intValue |> Json.int |> HtmlA.property property
