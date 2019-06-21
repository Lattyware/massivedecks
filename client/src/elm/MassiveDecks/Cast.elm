module MassiveDecks.Cast exposing (main)

{-| An alternative main module used when acting as a cast server.
-}

import Browser
import Browser.Navigation as Navigation
import Html exposing (Html)
import Html.Attributes as HtmlA
import Json.Decode as Json
import MassiveDecks.Cast.Model as Cast
import MassiveDecks.Messages exposing (..)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Models.Decoders as Decoders
import MassiveDecks.Pages.Lobby.Token as Token
import MassiveDecks.Pages.Spectate as Spectate
import MassiveDecks.Pages.Spectate.Model as Spectate
import MassiveDecks.Settings as Settings
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util as Util
import MassiveDecks.Util.Url as Url
import Url exposing (Url)


type alias Model =
    { shared : Shared
    , spectate : Maybe Spectate.Model
    }


main : Program Json.Value Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }



{- Private -}


init : Json.Value -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        castFlags =
            flags
                |> Json.decodeValue Decoders.castFlags
                |> Result.toMaybe

        auth =
            castFlags
                |> Maybe.map (.token >> Token.decode)
                |> Maybe.andThen Result.toMaybe

        ( spectate, cmd ) =
            case auth of
                Just a ->
                    Spectate.init { lobby = { gameCode = a.claims.gc } } |> Util.modelLift Just

                Nothing ->
                    ( Nothing, Cmd.none )

        ( settings, _ ) =
            Settings.init Settings.defaults

        shared =
            { language = castFlags |> Maybe.map .language |> Maybe.withDefault Lang.defaultLanguage
            , key = key
            , origin = Url.origin url
            , settings = settings
            , browserLanguage = Nothing
            , castStatus = Cast.NoDevicesAvailable
            }
    in
    ( { shared = shared, spectate = spectate }, cmd )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest _ =
    NoOp


onUrlChange : Url -> Msg
onUrlChange _ =
    NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = Strings.MassiveDecks |> Lang.string model.shared
    , body = model.spectate |> Maybe.map (Spectate.view model.shared) |> Maybe.withDefault (errorView model.shared)
    }


errorView : Shared -> List (Html msg)
errorView shared =
    -- TODO: Real impl
    [ Html.div [ HtmlA.class "spectate" ] [ Strings.CastError |> Lang.html shared ] ]
