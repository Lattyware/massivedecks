module MassiveDecks.Components.Icon exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


{-| A FointAwesome icon by name.
-}
icon : String -> Html a
icon name =
    i [ class ("fa fa-" ++ name) ] []


{-| A full width FointAwesome icon by name.
-}
fwIcon : String -> Html a
fwIcon name =
    i [ class ("fa fa-fw fa-" ++ name) ] []


{-| A loading spinner.
-}
spinner : Html a
spinner =
    i [ class "fa fa-circle-o-notch fa-spin" ] []
