module Weightless exposing
    ( button
    , card
    , expansion
    , listItem
    , navigationBar
    , popover
    , popoverCard
    , select
    , slider
    , switch
    , tab
    , tabGroup
    , textArea
    , textField
    , tooltip
    )

import Html exposing (Html)
import Weightless.Attributes as WlA


button : List (Html.Attribute msg) -> List (Html msg) -> Html msg
button =
    Html.node "wl-button"


card : List (Html.Attribute msg) -> List (Html msg) -> Html msg
card =
    Html.node "wl-card"


expansion : List (Html.Attribute msg) -> List (Html msg) -> Html msg
expansion attrs =
    Html.node "wl-expansion" (WlA.icon "" :: attrs)


listItem : List (Html.Attribute msg) -> List (Html msg) -> Html msg
listItem =
    Html.node "wl-list-item"


navigationBar : List (Html.Attribute msg) -> List (Html msg) -> Html msg
navigationBar =
    Html.node "wl-nav"


popover : List (Html.Attribute msg) -> List (Html msg) -> Html msg
popover =
    Html.node "wl-popover"


popoverCard : List (Html.Attribute msg) -> List (Html msg) -> Html msg
popoverCard =
    Html.node "wl-popover-card"


select : List (Html.Attribute msg) -> List (Html msg) -> Html msg
select =
    Html.node "wl-select"


slider : List (Html.Attribute msg) -> List (Html msg) -> Html msg
slider =
    Html.node "wl-slider"


switch : List (Html.Attribute msg) -> Html msg
switch attrs =
    Html.node "wl-switch" attrs []


tab : List (Html.Attribute msg) -> List (Html msg) -> Html msg
tab =
    Html.node "wl-tab"


tabGroup : List (Html.Attribute msg) -> List (Html msg) -> Html msg
tabGroup =
    Html.node "wl-tab-group"


textArea : List (Html.Attribute msg) -> List (Html msg) -> Html msg
textArea =
    Html.node "wl-textarea"


textField : List (Html.Attribute msg) -> List (Html msg) -> Html msg
textField =
    Html.node "wl-textfield"


tooltip : List (Html.Attribute msg) -> List (Html msg) -> Html msg
tooltip =
    Html.node "wl-tooltip"
