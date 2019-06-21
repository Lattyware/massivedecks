module MassiveDecks.Pages exposing
    ( fromRoute
    , subscriptions
    , toRoute
    )

import MassiveDecks.Messages exposing (..)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby as Lobby
import MassiveDecks.Pages.Model as Model exposing (..)
import MassiveDecks.Pages.Route as Route exposing (Route)
import MassiveDecks.Pages.Spectate as Spectate
import MassiveDecks.Pages.Start as Start
import MassiveDecks.Pages.Unknown as Unknown
import MassiveDecks.Util as Util


subscriptions : Page -> Sub Msg
subscriptions model =
    case model of
        Lobby lobby ->
            Lobby.subscriptions lobby

        _ ->
            Sub.none


{-| Construct a page model from a route and an existing model.
If the existing model is of the same type, only the route will be changed.
-}
fromRoute : Shared -> Maybe Page -> Route -> ( Page, Cmd Msg )
fromRoute shared oldModel route =
    case route of
        Route.Start r ->
            (case oldModel of
                Just (Start old) ->
                    Start.changeRoute r old

                _ ->
                    Start.init shared r
            )
                |> Util.modelLift Start

        Route.Lobby r ->
            case oldModel of
                Just (Lobby old) ->
                    Lobby.changeRoute r old |> Util.modelLift Lobby

                _ ->
                    case Lobby.init shared r Nothing of
                        Route.Continue ( lobby, cmd ) ->
                            ( Lobby lobby, cmd )

                        Route.Redirect redirect ->
                            fromRoute shared oldModel redirect

        Route.Spectate r ->
            (case oldModel of
                Just (Spectate old) ->
                    Spectate.changeRoute r old

                _ ->
                    Spectate.init r
            )
                |> Util.modelLift Spectate

        Route.Unknown r ->
            (case oldModel of
                Just (Unknown old) ->
                    Unknown.changeRoute r old

                _ ->
                    Unknown.init r
            )
                |> Util.modelLift Unknown


{-| Extract a route from a page model.
-}
toRoute : Page -> Route
toRoute model =
    case model of
        Model.Start start ->
            Start.route start |> Route.Start

        Model.Lobby lobby ->
            Lobby.route lobby |> Route.Lobby

        Model.Spectate spectate ->
            Spectate.route spectate |> Route.Spectate

        Model.Unknown unknown ->
            Unknown.route unknown |> Route.Unknown
