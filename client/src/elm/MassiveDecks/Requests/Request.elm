module MassiveDecks.Requests.Request exposing
    ( Interception
    , Request
    , Response(..)
    , expectResponse
    , intercept
    , map
    , maybeReplace
    , passthrough
    , replace
    )

import Http
import Json.Decode as Json
import MassiveDecks.Error.Model as Error exposing (Error)
import MassiveDecks.Util.Result as Result


type alias Request msg =
    { method : String
    , headers : List Http.Header
    , url : String
    , body : Http.Body
    , expect : Http.Expect msg
    , timeout : Maybe Float
    , tracker : Maybe String
    }


type Response error value
    = GeneralError Error
    | SpecificError error
    | Value value


type Interception intercepted msg
    = Intercept (intercepted -> Maybe msg)
    | Continue


replace : (intercepted -> msg) -> Interception intercepted msg
replace originally =
    Intercept (originally >> Just)


maybeReplace : (intercepted -> Maybe msg) -> Interception intercepted msg
maybeReplace =
    Intercept


passthrough : Interception intercepted msg
passthrough =
    Continue


expectResponse : (Response error value -> msg) -> Json.Decoder error -> Json.Decoder value -> Http.Expect msg
expectResponse mapMsg errorDecoder resultDecoder =
    expectJsonOrError mapMsg errorDecoder resultDecoder


intercept :
    Interception Error msg
    -> Interception error msg
    -> Interception value msg
    -> (Response error value -> msg)
    -> Response error value
    -> msg
intercept generalErrorInterception errorInterception resultInterception otherwise response =
    case response of
        GeneralError error ->
            case generalErrorInterception of
                Intercept f ->
                    f error |> Maybe.withDefault (otherwise response)

                Continue ->
                    otherwise response

        SpecificError error ->
            case errorInterception of
                Intercept f ->
                    f error |> Maybe.withDefault (otherwise response)

                Continue ->
                    otherwise response

        Value result ->
            case resultInterception of
                Intercept f ->
                    f result |> Maybe.withDefault (otherwise response)

                Continue ->
                    otherwise response


map : (Error -> msg) -> (error -> msg) -> (value -> msg) -> Response error value -> msg
map mapNetworkError mapError mapResult response =
    case response of
        GeneralError error ->
            mapNetworkError error

        SpecificError error ->
            mapError error

        Value result ->
            mapResult result



{- Private -}


responseMap : (Response error value -> msg) -> Result Never (Response error value) -> msg
responseMap mapMsg value =
    value |> Result.byDefinition |> mapMsg


expectJsonOrError : (Response error value -> msg) -> Json.Decoder error -> Json.Decoder value -> Http.Expect msg
expectJsonOrError toMsg errorDecoder valueDecoder =
    Http.expectStringResponse (responseMap toMsg) (manageResponse errorDecoder valueDecoder)


manageResponse : Json.Decoder error -> Json.Decoder value -> Http.Response String -> Result Never (Response error value)
manageResponse errorDecoder valueDecoder response =
    let
        r =
            case response of
                Http.BadUrl_ url ->
                    url |> Error.BadUrl |> Error.Http |> GeneralError

                Http.Timeout_ ->
                    Error.Timeout |> Error.Http |> GeneralError

                Http.NetworkError_ ->
                    Error.NetworkError |> Error.Http |> GeneralError

                Http.BadStatus_ metadata body ->
                    if metadata.statusCode >= 400 && metadata.statusCode < 500 then
                        case Json.decodeString errorDecoder body of
                            Ok error ->
                                error |> SpecificError

                            Err err ->
                                err |> Error.Json |> GeneralError

                    else
                        metadata.statusCode |> Error.BadStatus |> Error.Http |> GeneralError

                Http.GoodStatus_ _ body ->
                    case Json.decodeString valueDecoder body of
                        Ok value ->
                            value |> Value

                        Err err ->
                            err |> Error.Json |> GeneralError
    in
    Ok r
