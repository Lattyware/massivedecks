module MassiveDecks.Pages.Unknown exposing
    ( changeRoute
    , init
    , route
    , view
    )

import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Messages exposing (..)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Route as Route
import MassiveDecks.Pages.Start.Route as Start
import MassiveDecks.Pages.Unknown.Model exposing (..)
import MassiveDecks.Pages.Unknown.Route exposing (..)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import Material.Card as Card


changeRoute : Route -> Model -> ( Model, Cmd Msg )
changeRoute r model =
    ( { model | route = r }, Cmd.none )


init : Route -> ( Model, Cmd Msg )
init r =
    ( { route = r }, Cmd.none )


route : Model -> Route
route model =
    model.route


view : Shared -> Model -> List (Html Msg)
view shared _ =
    [ Html.div [ HtmlA.class "page unknown-page" ]
        [ Card.view []
            [ Html.h1 [] [ Icon.viewIcon Icon.exclamationCircle, Lang.html shared Strings.UnknownPageTitle ]
            , Html.p []
                [ Html.a [ Route.url (Route.Start { section = Start.New }) |> HtmlA.href ]
                    [ Lang.html shared Strings.GoBackHome
                    ]
                ]
            ]
        ]
    ]
