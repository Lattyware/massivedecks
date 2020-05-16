module MassiveDecks.Util.Html.Events exposing (..)

import Html
import Html.Events as HtmlE
import Json.Decode


{-| Same as onClick, but without propagating to other elements.
-}
onClickNoPropagation : msg -> Html.Attribute msg
onClickNoPropagation msg =
    HtmlE.stopPropagationOn "click" (Json.Decode.succeed ( msg, True ))
