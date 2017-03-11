port module MassiveDecks.Components.QR exposing (view, encodeAndRender)

import Html exposing (Html)
import Html.Attributes as Html


port qr : { id : String, value : String } -> Cmd msg


view : String -> Html msg
view containerId =
    Html.div [ Html.id containerId ] []


encodeAndRender : String -> String -> Cmd msg
encodeAndRender containerId value =
    qr { id = containerId, value = value }
