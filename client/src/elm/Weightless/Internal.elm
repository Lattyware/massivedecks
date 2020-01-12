module Weightless.Internal exposing
    ( boolProp
    , floatProp
    , numberAttr
    , numberProp
    , presentAttribute
    , stringArrayProperty
    , stringAttr
    , stringProp
    )

import Html
import Html.Attributes as HtmlA
import Json.Encode as Json


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


floatProp : String -> Float -> Html.Attribute msg
floatProp property floatValue =
    floatValue |> Json.float |> HtmlA.property property


boolProp : String -> Bool -> Html.Attribute msg
boolProp property boolValue =
    boolValue |> Json.bool |> HtmlA.property property


stringProp : String -> String -> Html.Attribute msg
stringProp property stringValue =
    stringValue |> Json.string |> HtmlA.property property
