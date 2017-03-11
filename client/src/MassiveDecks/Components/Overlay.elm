port module MassiveDecks.Components.Overlay exposing (Overlay, Model, Message(..), init, view, update, map)

import Json.Decode as Json
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import MassiveDecks.Components.Icon as Icon
import MassiveDecks.Util as Util


type alias Model a =
    { overlay : Maybe (Overlay a)
    , wrap : Message a -> a
    }


type alias Overlay a =
    { icon : String
    , title : String
    , contents : List (Html a)
    }


type Message a
    = Show (Overlay a)
    | Hide
    | NoOp


init : (Message a -> a) -> Model a
init wrap =
    { overlay = Nothing
    , wrap = wrap
    }


map : (a -> b) -> Message a -> Message b
map mapper message =
    case message of
        Show overlay ->
            Show (Overlay overlay.icon overlay.title (List.map (Html.map mapper) overlay.contents))

        Hide ->
            Hide

        NoOp ->
            NoOp


update : Message a -> Model a -> Model a
update message model =
    case message of
        Show overlay ->
            { model | overlay = Just overlay }

        Hide ->
            { model | overlay = Nothing }

        NoOp ->
            model


view : Model a -> List (Html a)
view model =
    case model.overlay of
        Just overlay ->
            [ div
                [ id "mui-overlay"
                , Util.onClickIfId "mui-overlay" (model.wrap Hide) (model.wrap NoOp)
                , Util.onKeyDown "Escape" (model.wrap Hide) (model.wrap NoOp)
                , tabindex 0
                ]
                [ div [ class "overlay mui-panel" ]
                    ([ h1 [] [ Icon.icon overlay.icon, text " ", text overlay.title ] ]
                        ++ overlay.contents
                        ++ [ p [ class "close-link" ]
                                [ a
                                    [ class "link"
                                    , attribute "tabindex" "0"
                                    , attribute "role" "button"
                                    , onClick (model.wrap Hide)
                                    ]
                                    [ Icon.icon "times", text " Close" ]
                                ]
                           ]
                    )
                ]
            ]

        Nothing ->
            []
