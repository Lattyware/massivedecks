module MassiveDecks.Pages.Loading exposing (view)

import FontAwesome.Attributes as Icon
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA


view : List (Html msg)
view =
    [ Html.div [ HtmlA.id "loading" ]
        [ Icon.viewStyled [ Icon.spin ] Icon.sync
        ]
    ]
