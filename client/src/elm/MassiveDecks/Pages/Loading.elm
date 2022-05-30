module MassiveDecks.Pages.Loading exposing (view)

import FontAwesome as Icon
import FontAwesome.Attributes as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Icon as Icon


view : List (Html msg)
view =
    [ Html.div [ HtmlA.id "loading" ] [ Icon.loading |> Icon.view ] ]
