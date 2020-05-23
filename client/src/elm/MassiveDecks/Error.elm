module MassiveDecks.Error exposing
    ( view
    , viewSpecific
    )

import Html exposing (Html)
import Html.Attributes as HtmlA
import Json.Decode as Json
import MassiveDecks.Error.Model exposing (..)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Models.MdError as MdError exposing (MdError)
import MassiveDecks.Pages.Route as Route exposing (Route)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Strings.Languages.Model as Lang exposing (Language)
import MassiveDecks.Util.Html as Html
import MassiveDecks.Version exposing (version)
import Url.Builder


{-| A view of an error.
-}
view : Shared -> Route -> Error -> Html msg
view shared route error =
    let
        model =
            render error

        rawReport =
            model.details |> Maybe.map (body shared route model.description)

        ( report, link ) =
            rawReport |> Maybe.map (viewReport shared) |> Maybe.withDefault ( Html.nothing, Html.nothing )
    in
    Html.div
        [ HtmlA.class "error" ]
        [ Html.div [ HtmlA.class "header" ]
            [ Html.span [ HtmlA.class "title" ] [ Strings.Error |> Lang.html shared ]
            , Html.span [ HtmlA.class "description" ] [ model.description |> Lang.html shared ]
            , link
            ]
        , report
        ]


{-| A view of an MdError.
-}
viewSpecific : Shared -> MdError -> Html msg
viewSpecific shared error =
    Html.div
        [ HtmlA.class "error" ]
        [ Html.span [ HtmlA.class "title" ] [ Strings.Error |> Lang.html shared ]
        , Html.span [] [ error |> MdError.shortDescribe |> Lang.html shared ]
        , Html.p [] [ error |> MdError.describe |> Lang.html shared ]
        ]



{- Private -}


viewReport : Shared -> String -> ( Html msg, Html msg )
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
            Url.Builder.crossOrigin github path [ reportBody |> String.left 1950 |> Url.Builder.string "body" ]
    in
    ( Html.textarea [ HtmlA.class "report", HtmlA.readonly True, HtmlA.value report ] []
    , Html.span [ HtmlA.class "link" ]
        [ Html.blankA [ HtmlA.href url ] [ Strings.ReportError |> Lang.html shared ]
        ]
    )


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
                ++ Lang.givenLanguageString shared Lang.En description
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
                NetworkError ->
                    Model Strings.NetworkError Nothing

                BadStatus code ->
                    case code of
                        504 ->
                            Model Strings.ServerDownError Nothing

                        _ ->
                            Model Strings.BadStatusError (code |> String.fromInt |> Just)

                Timeout ->
                    Model Strings.TimeoutError Nothing

                BadUrl url ->
                    Model Strings.BadUrlError (Just ("Url: " ++ url))

        Token tokenError ->
            case tokenError of
                InvalidTokenStructure token ->
                    Model Strings.BadPayloadError ("Token didn't have expected structure: " ++ token |> Just)

                TokenBase64Error msg ->
                    Model Strings.BadPayloadError ("Base 64 decode error on token: " ++ msg |> Just)

                TokenJsonError jsonError ->
                    let
                        err =
                            jsonError |> Json |> render
                    in
                    { err | details = Just ("JSON decode error on token: " ++ (err.details |> Maybe.withDefault "")) }

        Json jsonError ->
            Model Strings.BadPayloadError (jsonError |> Json.errorToString |> Just)

        Config configError ->
            case configError of
                PatchError reason ->
                    Model Strings.PatchError (Just reason)

                VersionMismatch ->
                    Model Strings.VersionMismatch (Just "")
