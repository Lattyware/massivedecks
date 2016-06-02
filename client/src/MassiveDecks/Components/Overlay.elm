port module MassiveDecks.Components.Overlay exposing (Model, Message(..), init, view, update, map)

import Json.Decode as Json

import Html.App as Html
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import MassiveDecks.Components.Icon as Icon


type alias Model a =
  { icon : String
  , title : String
  , contents : List (Html a)
  , wrap : (Message a) -> a
  , shown : Bool
  }


type Message a
  = Show String String (List (Html a))
  | Hide
  | NoOp


init : ((Message a) -> a) -> Model a
init wrap =
  { icon = ""
  , title = ""
  , contents = []
  , wrap = wrap
  , shown = False
  }


map : (a -> b) -> Message a -> Message b
map mapper message =
  case message of
    Show icon title contents ->
      Show icon title (List.map (Html.map mapper) contents)

    Hide ->
      Hide

    NoOp ->
      NoOp


update : Message a -> Model a -> Model a
update message model =
  case message of
    Show icon title contents ->
      { model | icon = icon
              , title = title
              , contents = contents
              , shown = True
              }

    Hide ->
      { model | shown = False }

    NoOp ->
      model


view : Model a -> List (Html a)
view model =
  if model.shown then
    [ div [ id "mui-overlay", onClickIfId "mui-overlay" (model.wrap Hide) (model.wrap NoOp) ]
          [ div [ class "overlay mui-panel" ]
                ([ h1 [] [ Icon.icon model.icon, text " ", text model.title ] ] ++
                 model.contents ++
                 [ p [ class "close-link"]
                     [ a [ class "link"
                         , attribute "tabindex" "0"
                         , attribute "role" "button"
                         , onClick (model.wrap Hide)
                         ] [ Icon.icon "times", text " Close" ]
                     ]
                 ])
          ]
    ]
  else
    []


onClickIfId : String -> msg -> msg -> Attribute msg
onClickIfId targetId message noOp =
  on "click" (ifIdDecoder targetId |> Json.map (\match -> if match then message else noOp))


ifIdDecoder : String -> Json.Decoder Bool
ifIdDecoder targetId = Json.at [ "target", "id" ] Json.string |> Json.map ((==) targetId)
