module MassiveDecks.Components.Errors exposing (Message(..), Model, view, update, init)

import Http exposing (url)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import MassiveDecks.Components.Icon as Icon
import MassiveDecks.Util as Util


type Message
  = New String Bool
  | Remove Int


type alias Model =
  { currentId : Int
  , errors : List Error
  }


{-| A generic error message to be displayed when something goes wrong. Should only be used where there isn't a good way
to avoid the error altogether or display the error closer to it's source.
-}
type alias Error =
  { id : Int
  , message : String
  , bugReport : Bool
  }


init : Model
init =
  { currentId = 0
  , errors = []
  }


view : Model -> Html Message
view model = ol [ id "error-panel"] (List.map errorMessage model.errors)


update : Message -> Model -> (Model, Cmd Message)
update message model =
  case message of
    New message bugReport ->
      let
        new = { id = model.currentId, message = message, bugReport = bugReport }
      in
        ( { model | errors = model.errors ++ [ new ]
                  , currentId = model.currentId + 1
                  }
        , Cmd.none
        )

    Remove id ->
      ({ model | errors = List.filter (\error -> error.id /= id) model.errors}, Cmd.none)


reportText : String -> String
reportText message =
  ("I was [a short explanation of what you were doing] when I got the following error: \n\n"
    ++ message)


errorMessage : Error -> Html Message
errorMessage error =
  let
    reportUrl = (url "https://github.com/Lattyware/massivedecks/issues/new" [( "body", reportText error.message ) ])
    bugReportLink =
      if error.bugReport then
        Just (p [] [ a [ href reportUrl, target "_blank" ] [ Icon.icon "bug", text " Report this as a bug." ] ])
      else
        Nothing
  in
    li
      [ class "error" ]
      [ div
        []
        ([ a [ class "link"
            , attribute "tabindex" "0"
            , attribute "role" "button"
            , onClick (Remove error.id)
            ] [ Icon.icon "times" ]
        , h5 [] [ Icon.icon "exclamation-triangle"
                , text " Error"
                ]
        , div [ class "mui-divider" ] []
        , p [] [ text error.message ]
        ] `Util.andMaybe` bugReportLink)
      ]
