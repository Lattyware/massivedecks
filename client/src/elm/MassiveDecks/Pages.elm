module MassiveDecks.Pages exposing
    ( fromRoute
    , subscriptions
    , toRoute
    )

import MassiveDecks.Error.Messages as Error
import MassiveDecks.Messages exposing (..)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby as Lobby
import MassiveDecks.Pages.Model as Model exposing (..)
import MassiveDecks.Pages.Route as Route exposing (Route)
import MassiveDecks.Pages.Start as Start
import MassiveDecks.Pages.Unknown as Unknown


subscriptions : Page -> Sub Msg
subscriptions model =
    case model of
        Lobby lobby ->
            Lobby.subscriptions LobbyMsg (Error.Add >> ErrorMsg) lobby

        _ ->
            Sub.none


{-| Construct a page model from a route and an existing model.
If the existing model is of the same type, only the route will be changed.
-}
fromRoute : Shared -> Maybe Page -> Route -> ( Page, Cmd Msg )
fromRoute shared oldModel route =
    case route of
        Route.Start r ->
            let
                ( start, cmd ) =
                    case oldModel of
                        Just (Start old) ->
                            Start.changeRoute r old

                        _ ->
                            Start.init shared r
            in
            ( Start start, cmd )

        Route.Lobby r ->
            let
                fork =
                    case oldModel of
                        Just (Lobby old) ->
                            Lobby.changeRoute shared r old

                        _ ->
                            Lobby.init shared r Nothing
            in
            case fork of
                Route.Continue ( lobby, cmd ) ->
                    ( Lobby lobby, cmd )

                Route.Redirect redirectRoute ->
                    fromRoute shared oldModel redirectRoute

        Route.Unknown r ->
            let
                ( unknown, cmd ) =
                    case oldModel of
                        Just (Unknown old) ->
                            Unknown.changeRoute r old

                        _ ->
                            Unknown.init r
            in
            ( Unknown unknown, cmd )

        Route.Loading ->
            ( Loading, Cmd.none )


{-| Extract a route from a page model.
-}
toRoute : Page -> Route
toRoute model =
    case model of
        Model.Start start ->
            Start.route start |> Route.Start

        Model.Lobby lobby ->
            Lobby.route lobby |> Route.Lobby

        Model.Unknown unknown ->
            Unknown.route unknown |> Route.Unknown

        Loading ->
            Route.Loading
