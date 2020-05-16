module MassiveDecks.Util.Html.Events exposing (..)

import Html
import Html.Events as HtmlE
import Json.Decode as Json


{-| Same as onClick, but without propagating to other elements.
-}
onClickNoPropagation : msg -> Html.Attribute msg
onClickNoPropagation msg =
    HtmlE.stopPropagationOn "click" (Json.succeed ( msg, True ))


{-| Same as onCheck, but without propagating to other elements.
-}
onCheckNoPropagation : (Bool -> msg) -> Html.Attribute msg
onCheckNoPropagation msg =
    HtmlE.stopPropagationOn "check" (Json.at [ "target", "checked" ] Json.bool |> Json.map (\c -> ( msg c, True )))
