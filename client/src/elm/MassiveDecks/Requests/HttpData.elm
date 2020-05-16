module MassiveDecks.Requests.HttpData exposing
    ( autoRefresh
    , init
    , initLazy
    , loadingOrLoaded
    , refreshButton
    , update
    , view
    )

import FontAwesome.Attributes as Icon
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Error as Error
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Route exposing (Route)
import MassiveDecks.Requests.HttpData.Messages exposing (..)
import MassiveDecks.Requests.HttpData.Model exposing (..)
import MassiveDecks.Requests.Request as Request exposing (Request)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Util.Maybe as Maybe
import MassiveDecks.Util.NeList exposing (NeList(..))
import Material.IconButton as IconButton
import Time


{-| Set up the empty HttpData and send a request to load the data.
-}
init : Pull msg -> ( HttpData error result, Cmd msg )
init req =
    ( initLazy, req )


{-| Set up the empty HttpData with no initial request, the request can be made later.
-}
initLazy : HttpData error result
initLazy =
    { loading = False, data = Nothing, error = Nothing, generalError = Nothing }


{-| Tries to refresh the data every X milliseconds.
-}
autoRefresh : Float -> Sub (Msg error result)
autoRefresh every =
    Time.every every (\_ -> Pull)


{-| If the data has been loaded, or is currently loading.
-}
loadingOrLoaded : HttpData error result -> Bool
loadingOrLoaded model =
    model.loading || model.data /= Nothing


{-| Update the data with the response from the request.
-}
update : Pull msg -> Msg error result -> HttpData error result -> ( HttpData error result, Cmd msg )
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
                Request.Value response ->
                    ( { loadingStoppedModel | data = Just response, generalError = Nothing }, Cmd.none )

                Request.SpecificError error ->
                    ( { loadingStoppedModel | error = Just error }, Cmd.none )

                Request.GeneralError generalError ->
                    ( { loadingStoppedModel | generalError = Just generalError }, Cmd.none )


{-| A view over the data with any error received trying to load (or refresh) if it isn't there (or prefixed if during a
refresh).
-}
view : Shared -> Route -> List (Html msg) -> (result -> Html msg) -> HttpData error result -> Html msg
view shared route emptyContent viewResult model =
    let
        generalError =
            model.generalError |> Maybe.map (Error.view shared route)

        result =
            model.data |> Maybe.map viewResult

        content =
            List.filterMap identity [ generalError, result ]

        contentOrSpinner =
            if List.isEmpty content then
                emptyContent

            else
                content
    in
    Html.div [ HtmlA.class "loaded-data" ] contentOrSpinner


{-| Show a refresh button for the data.
-}
refreshButton : Shared -> HttpData error result -> Html (Msg error result)
refreshButton shared { loading, data } =
    let
        applyStyle =
            if loading then
                Icon.styled [ Icon.spin ]

            else
                identity
    in
    IconButton.view shared
        Strings.Refresh
        (NeList (Icon.sync |> Icon.present |> applyStyle) [])
        (Pull |> Maybe.justIf (not loading))
