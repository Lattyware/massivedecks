module MassiveDecks.Error exposing (view)

import Html exposing (Html)
import Html.Attributes as HtmlA
import Http
import Json.Decode as Json
import MassiveDecks.Error.Model exposing (..)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Pages.Route as Route exposing (Route)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Strings.Languages.Model as Lang exposing (Language)
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Maybe as Maybe
import MassiveDecks.Version exposing (version)
import Url.Builder
import Weightless as Wl
import Weightless.Attributes as WlA


{-| A view of an error.
-}
view : Shared -> Route -> Error -> Html msg
view shared route error =
    let
        model =
            render error

        report =
            model.details |> Maybe.map (body shared route model.description)

        reportView =
            report |> Maybe.map (viewReport shared) |> Maybe.withDefault []
    in
    Wl.expansion
        (List.concat
            [ [ WlA.name "errors", HtmlA.class "error" ]
            , [ WlA.disabled ] |> Maybe.justIf (report == Nothing) |> Maybe.withDefault []
            ]
        )
        (Html.span [ WlA.expansionSlot WlA.ETitle ] [ Strings.Error |> Lang.html shared ]
            :: Html.span [ WlA.expansionSlot WlA.EDescription ] [ model.description |> Lang.html shared ]
            :: reportView
        )



{- Private -}


viewReport : Shared -> String -> List (Html msg)
viewReport shared report =
    let
        github =
            "https://github.com"

        path =
            [ "Lattyware", "massivedecks", "issues", "new" ]

        reportBody =
            (Strings.ReportErrorBody |> Lang.string shared)
                ++ "\n\n"
                ++ report

        url =
            Url.Builder.crossOrigin github path [ Url.Builder.string "body" reportBody ]
    in
    [ Html.div [ HtmlA.class "report" ]
        [ Wl.textArea [ HtmlA.class "body", WlA.readonly, WlA.value report ] []
        , Html.span [ HtmlA.class "link" ]
            [ Html.blankA [ HtmlA.href url ] [ Strings.ReportError |> Lang.html shared ]
            ]
        ]
    ]


body : Shared -> Route -> MdString -> String -> String
body shared route description details =
    let
        developerInfo =
            -- Intentionally untranslated - this is for developer use, not users.
            "\n\nContext for developers:\n\tVersion: "
                ++ version
                ++ "\n\tPage: "
                ++ Route.externalUrl shared.origin route
                ++ "\n\tEnglish Error: "
                ++ Lang.givenLanguageString Lang.En description
                ++ "\n\tDetails: "
                ++ details
    in
    (description |> Lang.string shared)
        ++ developerInfo


type alias Model =
    { description : MdString
    , details : Maybe String
    }


render : Error -> Model
render error =
    case error of
        Http httpError ->
            case httpError of
                Http.NetworkError ->
                    Model Strings.NetworkError Nothing

                Http.BadBody message ->
                    Model Strings.BadPayloadError ("Decoding error: " ++ message |> Just)

                Http.BadStatus code ->
                    case code of
                        504 ->
                            Model Strings.ServerDownError Nothing

                        _ ->
                            Model Strings.BadStatusError (code |> String.fromInt |> Just)

                Http.Timeout ->
                    Model Strings.TimeoutError Nothing

                Http.BadUrl url ->
                    Model Strings.BadUrlError (Just ("Url: " ++ url))

        Token tokenError ->
            case tokenError of
                Lobby.InvalidTokenStructure token ->
                    Model Strings.BadPayloadError ("Token didn't have expected structure: " ++ token |> Just)

                Lobby.TokenBase64Error msg ->
                    Model Strings.BadPayloadError ("Base 64 decode error on token: " ++ msg |> Just)

                Lobby.TokenJsonError jsonError ->
                    let
                        err =
                            jsonError |> Json |> render
                    in
                    { err | details = Just ("JSON decode error on token: " ++ (err.details |> Maybe.withDefault "")) }

        Json jsonError ->
            Model Strings.BadPayloadError (jsonError |> Json.errorToString |> Just)

        Generic string ->
            Model string Nothing
