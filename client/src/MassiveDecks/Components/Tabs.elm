port module MassiveDecks.Components.Tabs exposing (Message(..), Model, Tab, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


{-| Messages for the tab system.
-}
type Message tabId
    = SetTab tabId


{-| The model for the tabs.
-}
type alias Model tabId msg =
    { tabs : List (Tab tabId msg)
    , current : tabId
    , tagger : Message tabId -> msg
    }


{-| An individual tab.
-}
type alias Tab tabId msg =
    { id : tabId
    , title : List (Html msg)
    }


{-| Initialise the model.
-}
init : List (Tab tabId msg) -> tabId -> (Message tabId -> msg) -> Model tabId msg
init =
    Model


{-| Given a message, update the model to fit.
-}
update : Message tabId -> Model tabId msg -> Model tabId msg
update message model =
    case message of
        SetTab tabId ->
            { model | current = tabId }


{-| Given a model, render it.

The first argument is a rendering function for the content of the tab. This allows the caller of the view to control the
content easily.
-}
view : (tabId -> List (Html msg)) -> Model tabId msg -> List (Html msg)
view renderer model =
    [ ul [ class "mui-tabs__bar mui-tabs__bar--justified" ] (List.map (viewTab model.tagger model.current) model.tabs)
    ]
        ++ (List.map (viewPane model.current renderer) model.tabs)


viewTab : (Message tabId -> msg) -> tabId -> Tab tabId msg -> Html msg
viewTab tagger current model =
    li [ classList [ ( "mui--is-active", current == model.id ) ] ]
        [ a
            [ onClick (tagger <| SetTab model.id)
            ]
            model.title
        ]


viewPane : tabId -> (tabId -> List (Html msg)) -> Tab tabId msg -> Html msg
viewPane current renderer model =
    div [ classList [ ( "mui-tabs__pane", True ), ( "mui--is-active", current == model.id ) ] ] (renderer model.id)
