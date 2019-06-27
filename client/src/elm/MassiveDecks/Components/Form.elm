module MassiveDecks.Components.Form exposing (section)

import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Components.Form.Message as Message exposing (Message)
import MassiveDecks.Model exposing (Shared)


{-| A section containing inputs and messages..
-}
section : Shared -> String -> Html msg -> List (Message msg) -> Html msg
section shared id component messages =
    Html.div [ HtmlA.id id, HtmlA.class "form-section" ]
        (component :: (messages |> List.filterMap (Message.view shared)))
