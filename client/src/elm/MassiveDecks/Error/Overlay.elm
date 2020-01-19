module MassiveDecks.Error.Overlay exposing (init, update, view)

import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Components as Components
import MassiveDecks.Error as Error
import MassiveDecks.Error.Messages exposing (..)
import MassiveDecks.Error.Model as Error exposing (Error)
import MassiveDecks.Messages as Global
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Route exposing (Route)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import Weightless as Wl


init : Error.Overlay
init =
    { errors = [] }


view : Shared -> Route -> Error.Overlay -> List (Html Global.Msg)
view shared route model =
    if List.isEmpty model.errors then
        []

    else
        [ Html.div [ HtmlA.class "error-overlay" ]
            [ Html.div [ HtmlA.class "actions" ]
                [ Components.iconButton
                    [ HtmlA.class "close"
                    , Clear |> Global.ErrorMsg |> HtmlE.onClick
                    , Strings.Close |> Lang.title shared
                    ]
                    Icon.times
                , Components.iconButton
                    [ HtmlA.class "refresh"
                    , Global.Refresh |> HtmlE.onClick
                    , Strings.Refresh |> Lang.title shared
                    ]
                    Icon.redo
                ]
            , Wl.card [ HtmlA.class "help" ]
                [ Html.h3 [] [ Lang.html shared Strings.ErrorHelpTitle ]
                , Html.p [] [ Lang.html shared Strings.ErrorHelp ]
                ]
            , Html.div [ HtmlA.class "errors" ] (List.map (Error.view shared route) model.errors)
            ]
        ]


update : Msg -> Error.Overlay -> Error.Overlay
update msg model =
    case msg of
        Add error ->
            { model | errors = error :: model.errors }

        Clear ->
            { model | errors = [] }
