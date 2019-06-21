module MassiveDecks.Requests.HttpData exposing
    ( autoRefresh
    , init
    , initLazy
    , interceptedRequest
    , loadingOrLoaded
    , mappedRequest
    , refreshButton
    , request
    , update
    , view
    )

import FontAwesome.Attributes as Icon
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Http
import MassiveDecks.Error as Error
import MassiveDecks.Error.Model as Error exposing (Error)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Route exposing (Route)
import MassiveDecks.Requests.HttpData.Messages exposing (..)
import MassiveDecks.Requests.HttpData.Model exposing (..)
import MassiveDecks.Requests.Request exposing (Request)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Result as Result
import Time
import Weightless as Wl
import Weightless.Attributes as WlA


{-| Set up the empty HttpData and send a request to load the data.
-}
init : Pull msg -> ( HttpData result, Cmd msg )
init req =
    ( initLazy, req )


{-| Set up the empty HttpData with no initial request, the request can be made later.
-}
initLazy : HttpData result
initLazy =
    { loading = False, data = Nothing, error = Nothing }


{-| Tries to refresh the data every X milliseconds.
-}
autoRefresh : Float -> Sub (Msg result)
autoRefresh every =
    Time.every every (\_ -> Pull)


{-| If the data has been loaded, or is currently loading.
-}
loadingOrLoaded : HttpData result -> Bool
loadingOrLoaded model =
    model.loading || model.data /= Nothing


{-| Update the data with the response from the request.
-}
update : Pull msg -> Msg result -> HttpData result -> ( HttpData result, Cmd msg )
update req msg model =
    case msg of
        Pull ->
            if not model.loading then
                ( { model | loading = True }, req )

            else
                ( model, Cmd.none )

        Response result ->
            let
                loadingStoppedModel =
                    { model | loading = False }
            in
            case result of
                Ok response ->
                    ( { loadingStoppedModel
                        | data = Just response
                        , error = Nothing
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { loadingStoppedModel | error = Just error }, Cmd.none )


{-| A view over the data with any error received trying to load (or refresh) if it isn't there (or prefixed if during a
refresh).
-}
view : Shared -> Route -> (Msg result -> msg) -> (result -> Html msg) -> HttpData result -> Html msg
view shared route wrap viewResult model =
    let
        error =
            model.error |> Maybe.map (Error.view shared route)

        result =
            model.data |> Maybe.map viewResult

        content =
            List.filterMap identity [ error, result ]

        contentOrSpinner =
            if List.isEmpty content then
                [ Html.div [ HtmlA.class "info" ] [ refreshButton shared model |> Html.map wrap ] ]

            else
                content
    in
    Html.div [ HtmlA.class "loaded-data" ] contentOrSpinner


{-| Show a refresh button for the data.
-}
refreshButton : Shared -> HttpData result -> Html (Msg result)
refreshButton shared model =
    let
        title =
            [ Strings.Refresh |> Lang.title shared ]

        onClick =
            if not model.loading then
                [ HtmlE.onClick Pull ]

            else
                []

        style =
            [ WlA.flat
            , WlA.fab
            , WlA.inverted
            ]

        spin =
            if model.loading then
                [ Icon.spin ]

            else
                []
    in
    Wl.button
        (List.concat [ style, title, onClick ])
        [ Icon.viewStyled spin Icon.sync ]


{-| A request that just stores the result in the `HttpData`.
-}
request : Request result -> Cmd (Msg result)
request req =
    mappedRequest req Ok


{-| A request that just maps the result before storage in the `HttpData`.
-}
mappedRequest : Request response -> (response -> Result Error result) -> Pull (Msg result)
mappedRequest req f =
    interceptedRequest req f identity (Ok >> Response)


{-| A request that just maps the result before storage in the `HttpData`, as well as intercepting successes to perform
an action (note that this means the value will never get filled!
-}
interceptedRequest :
    Request response
    -> (response -> Result Error result)
    -> (Msg result -> msg)
    -> (result -> msg)
    -> Pull msg
interceptedRequest req f wrap intercept =
    req |> Http.request |> Cmd.map (mapResponse f wrap intercept)



{- Private -}


mapResponse :
    (response -> Result Error result)
    -> (Msg result -> msg)
    -> (result -> msg)
    -> Result Http.Error response
    -> msg
mapResponse f wrap intercept result =
    result
        |> Result.mapError Error.Http
        |> Result.andThen f
        |> Result.map intercept
        |> Result.mapError (Err >> Response >> wrap)
        |> Result.unify
