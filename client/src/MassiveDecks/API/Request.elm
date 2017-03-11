module MassiveDecks.API.Request exposing (send, send_, request, Request, KnownError, Error(..))

import Json.Decode as Json
import Dict exposing (Dict)
import Http
import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Util as Util


{-| Send a request to the server.

request - The request to the server. See MassiveDecks.API.
onSpecificError - How to handle any errors specific to the request.
onGeneralError - How to handle any general errors.
onSuccess - How to handle success.

If the request has no specific errors, use `send_` instead.
-}
send : Request specificError result -> (specificError -> message) -> (Errors.Message -> message) -> (result -> message) -> Cmd message
send request onSpecificError onGeneralError onSuccess =
    let
        req =
            Http.request
                { method = request.method
                , headers = []
                , url = request.url
                , body =
                    case request.body of
                        Just json ->
                            Http.jsonBody json

                        Nothing ->
                            Http.emptyBody
                , expect = Http.expectStringResponse (handleResponse request.resultDecoder request.errors)
                , timeout = Nothing
                , withCredentials = False
                }
    in
        Http.send
            (\result ->
                case result of
                    Result.Ok errorOrResult ->
                        case errorOrResult of
                            Error error ->
                                handleErrors onSpecificError onGeneralError error

                            Result result ->
                                onSuccess result

                    Result.Err error ->
                        (case error of
                            Http.BadStatus response ->
                                (Json.decodeString
                                    (Json.maybe errorKeyDecoder
                                        |> Json.andThen
                                            (\n ->
                                                case n of
                                                    Just errorName ->
                                                        errorDecoder response errorName request.errors

                                                    Nothing ->
                                                        Json.succeed (General error)
                                            )
                                    )
                                    response.body
                                )
                                    |> Result.withDefault (General error)

                            _ ->
                                General error
                        )
                            |> handleErrors onSpecificError onGeneralError
            )
            req


handleErrors : (specificError -> message) -> (Errors.Message -> message) -> Error specificError -> message
handleErrors onSpecificError onGeneralError error =
    case error of
        Known specificError ->
            onSpecificError specificError

        _ ->
            onGeneralError (genericErrorHandler error)


handleResponse : Json.Decoder result -> KnownErrors specificError -> Http.Response String -> Result String (ErrorOrResult specificError result)
handleResponse resultDecoder knownErrors response =
    Json.decodeString (resultOrErrorDecoder response resultDecoder knownErrors) response.body


{-| Same as 'send', but for requests with no known errors.
-}
send_ : Request Never result -> (Errors.Message -> message) -> (result -> message) -> Cmd message
send_ request onGeneralError onSuccess =
    send request Util.impossible onGeneralError onSuccess


{-| A request to the API.
-}
type alias Request specificError result =
    { method : String
    , url : String
    , body : Maybe Json.Value
    , errors : KnownErrors specificError
    , resultDecoder : Json.Decoder result
    }


{-| A convinience method to make the errors dictionary from a list.
-}
request : String -> String -> Maybe Json.Value -> List (KnownError specificError) -> Json.Decoder result -> Request specificError result
request verb url body errors resultDecoder =
    Request verb url body (Dict.fromList errors) resultDecoder


{-| Specifies an error the client understands and can present to the user nicely.
-}
type alias KnownError specificError =
    ( ( Int, String ), Json.Decoder specificError )


{-| The dictionary of KnownErrors.
-}
type alias KnownErrors specificError =
    Dict ( Int, String ) (Json.Decoder specificError)


{-| The top level of potential errors from an API request.
-}
type Error specificError
    = General Http.Error
    | Known specificError
    | Unknown (Http.Response String)


type ErrorOrResult specificError result
    = Error (Error specificError)
    | Result result


{-| Convert errors to generic error messages for display in the errors component. Generally you want to use this as a
fallback after handling all known errors.
-}
genericErrorHandler : Error a -> Errors.Message
genericErrorHandler error =
    case error of
        Known specificError ->
            Errors.New ("An error was not correctly handled: " ++ (toString specificError)) True

        Unknown response ->
            Errors.New ("An error was not not recognised (status " ++ (toString response.status.code) ++ "): " ++ response.body) True

        General (Http.Timeout) ->
            Errors.New "Timed out trying to connect to the server." False

        General (Http.NetworkError) ->
            Errors.New "There was a network error trying to connect to the server." False

        General (Http.BadUrl url) ->
            Errors.New ("The URL '" ++ url ++ "' was invalid.") True

        General (Http.BadStatus response) ->
            Errors.New ("Recieved an unexpected response (" ++ (toString response.status.code) ++ ") from the server: " ++ response.status.message) True

        General (Http.BadPayload explanation response) ->
            Errors.New ("The response recieved from the server wasn't what we expected: " ++ explanation) True


{-| Decode the error key from
-}
errorKeyDecoder : Json.Decoder String
errorKeyDecoder =
    Json.at [ "error" ] Json.string


errorDecoder : Http.Response String -> String -> KnownErrors specificError -> Json.Decoder (Error specificError)
errorDecoder response errorName knownErrors =
    let
        decoder =
            Dict.get ( response.status.code, errorName ) knownErrors
    in
        case decoder of
            Just decoder ->
                Json.map Known decoder

            Nothing ->
                Json.succeed (Unknown response)


resultOrErrorDecoder : Http.Response String -> Json.Decoder result -> KnownErrors specificError -> Json.Decoder (ErrorOrResult specificError result)
resultOrErrorDecoder response resultDecoder knownErrors =
    Json.maybe errorKeyDecoder
        |> Json.andThen
            (\error ->
                case error of
                    Just errorName ->
                        Json.map (Error) (errorDecoder response errorName knownErrors)

                    Nothing ->
                        Json.map Result resultDecoder
            )
