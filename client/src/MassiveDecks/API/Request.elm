module MassiveDecks.API.Request exposing (send, send', request, Request, KnownError, Error(..))

import Json.Encode exposing (encode)
import Json.Decode as Json
import Task
import Dict exposing (Dict)

import Http exposing (Value(..))

import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Util as Util


{-| Send a request to the server.

request - The request to the server. See MassiveDecks.API.
onSpecificError - How to handle any errors specific to the request.
onGeneralError - How to handle any general errors.
onSuccess - How to handle success.

If the request has no specific errors, use `send'` instead.
-}
send : Request specificError result -> (specificError -> message) -> (Errors.Message -> message) -> (result -> message) -> Cmd message
send request onSpecificError onGeneralError onSuccess =
  let
    errorToMessage = errorHandler onSpecificError onGeneralError
    task = Http.send Http.defaultSettings
      { verb = request.verb
      , url = request.url
      , headers = if request.body == Nothing then [] else jsonContentType
      , body = case request.body of
          Just json -> jsonBody json
          Nothing -> Http.empty
      } |> Task.map (handleResponse request.errors request.resultDecoder)
    errorMapped = (Task.mapError Communication task) `Task.andThen` Task.fromResult
  in
    Task.perform errorToMessage onSuccess errorMapped


{-| Same as 'send', but for requests with no known errors.
-}
send' : Request Never result -> (Errors.Message -> message) -> (result -> message) -> Cmd message
send' request onGeneralError onSuccess = send request Util.impossible onGeneralError onSuccess


{-| A request to the API.
-}
type alias Request specificError result =
  { verb : String
  , url : String
  , body : Maybe Json.Value
  , errors : KnownErrors specificError
  , resultDecoder : Json.Decoder result
  }


{-| A convinience method to make the errors dictionary from a list.
-}
request : String -> String -> Maybe Json.Value -> List (KnownError specificError) -> Json.Decoder result -> Request specificError result
request verb url body errors resultDecoder = Request verb url body (Dict.fromList errors) resultDecoder


{-| Specifies an error the client understands and can present to the user nicely.
-}
type alias KnownError specificError = ((Int, String), Json.Decoder specificError)

{-| The dictionary of KnownErrors.
-}
type alias KnownErrors specificError = Dict (Int, String) (Json.Decoder specificError)


{-| The top level of potential errors from an API request.
-}
type Error specificError
  = Communication Http.RawError
  | Malformed String
  | Known specificError
  | Unknown Int String


{-| Handle an error, turning it into a message.
-}
errorHandler : (specificErrors -> msg) -> (Errors.Message -> msg) -> Error specificErrors -> msg
errorHandler knownHandler errorMessageWrapper error =
  case error of
    Known specificError -> knownHandler specificError
    _ -> genericErrorHandler error |> errorMessageWrapper


{-| Convert errors to generic error messages for display in the errors component. Generally you want to use this as a
fallback after handling all known errors.
-}
genericErrorHandler : Error a -> Errors.Message
genericErrorHandler error =
  case error of
    Known specificError -> Errors.New ("An error was not correctly handled: " ++ (toString specificError)) True
    Communication Http.RawTimeout -> Errors.New "Timed out trying to connect to the server." False
    Communication Http.RawNetworkError -> Errors.New "There was a network error trying to connect to the server." False
    Malformed explanation -> Errors.New ("The response recieved from the server was incorrect: " ++ explanation) True
    Unknown code response -> Errors.New ("Recieved an unexpected response (" ++ (toString code) ++ ") from the server: " ++ response) True


handleResponse : KnownErrors specificError -> Json.Decoder message -> Http.Response -> Result (Error specificError) message
handleResponse errors resultDecoder response =
  if response.status >= 200 && response.status < 300 then
    handleSuccess resultDecoder response
  else
    handleFailure errors response |> Err


handleSuccess : Json.Decoder message -> Http.Response -> Result (Error specificError) message
handleSuccess resultDecoder response =
  case response.value of
    Text value -> Result.formatError Malformed (Json.decodeString resultDecoder value)
    Blob blob -> Err (Malformed "Recieved binary data instead of expected JSON.")


handleFailure : KnownErrors specificError -> Http.Response -> Error specificError
handleFailure errors response =
    case response.value of
      Text value ->
        case Json.decodeString errorKeyDecoder value of
          Ok errorName ->
            let
              decoder = Dict.get (response.status, errorName) errors
            in
              case decoder of
                Just decoder ->
                  case Json.decodeString decoder value of
                    Ok error ->
                      Known error

                    Err error ->
                      Malformed error

                Nothing ->
                  Unknown response.status value

          Err error ->
            Malformed error

      Blob blob -> Malformed "Recieved binary data instead of expected JSON in error."


{-| Specifies JSON encoded content.
-}
jsonContentType : List (String, String)
jsonContentType = [ ("Content-Type", "application/json") ]


{-| Turns JSON into an HTTP body for a request.
-}
jsonBody : Json.Value -> Http.Body
jsonBody value = encode 0 value |> Http.string


{-| Decode the error key from
-}
errorKeyDecoder : Json.Decoder String
errorKeyDecoder = Json.at [ "error" ] Json.string
