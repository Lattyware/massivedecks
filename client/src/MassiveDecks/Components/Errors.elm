module MassiveDecks.Components.Errors exposing (Message(..), Model, ApplicationInfo, view, update, init, reportUrl)

import String
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


type alias ApplicationInfo =
    { url : String
    , version : String
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


view : ApplicationInfo -> Model -> Html Message
view applicationInfo model =
    ol [ id "error-panel" ] (List.map (errorMessage applicationInfo) model.errors)


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        New message bugReport ->
            let
                new =
                    { id = model.currentId, message = message, bugReport = bugReport }
            in
                ( { model
                    | errors = model.errors ++ [ new ]
                    , currentId = model.currentId + 1
                  }
                , Cmd.none
                )

        Remove id ->
            ( { model | errors = List.filter (\error -> error.id /= id) model.errors }, Cmd.none )


reportText : String -> String
reportText message =
    ("I was [a short explanation of what you were doing] when I got the following error: \n\n" ++ message)


reportUrl : ApplicationInfo -> String -> String
reportUrl applicationInfo message =
    let
        version =
            if String.isEmpty applicationInfo.version then
                "Not Specified"
            else
                applicationInfo.version

        full =
            message ++ "\n\nApplication Info:\n\tVersion: " ++ version ++ "\n\tURL: " ++ applicationInfo.url
    in
        "https://github.com/Lattyware/massivedecks/issues/new?body=" ++ full


errorMessage : ApplicationInfo -> Error -> Html Message
errorMessage applicationInfo error =
    let
        url =
            reportUrl applicationInfo (reportText error.message)

        bugReportLink =
            if error.bugReport then
                Just (p [] [ a [ href url, target "_blank", rel "noopener" ] [ Icon.icon "bug", text " Report this as a bug." ] ])
            else
                Nothing
    in
        li
            [ class "error" ]
            [ div
                []
                ([ a
                    [ class "link"
                    , attribute "tabindex" "0"
                    , attribute "role" "button"
                    , onClick (Remove error.id)
                    ]
                    [ Icon.icon "times" ]
                 , h5 []
                    [ Icon.icon "exclamation-triangle"
                    , text " Error"
                    ]
                 , div [ class "mui-divider" ] []
                 , p [] [ text error.message ]
                 ]
                    |> Util.andMaybe bugReportLink
                )
            ]
