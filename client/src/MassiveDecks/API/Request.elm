module MassiveDecks.API.Request

  ( Request
  , toRequest
  , toEffect
  , toEffectsWithOnError
  , jsonBody

  , Error(..)
  , SpecificErrorDecoder
  , specificErrorDecoder
  , noArguments
  , oneArgument
  , twoArguments
  
  ) where

import Http
import Task exposing (Task)
import Json.Decode exposing (Decoder, decodeValue, decodeString, keyValuePairs, value)
import Json.Encode as Json
import Effects exposing (Effects)

import MassiveDecks.Actions.Action exposing (Action(..))
import MassiveDecks.Util as Util


{-| A request to the game server.

`specificErrors` is a type representing the possible errors (specific to this request) if it failes.
`successfulResponse` is a type representing the result of the API request if it succeeds.
-}
type alias Request specificErrors successfulResponse =
  Task (Error specificErrors) successfulResponse


{-| Construct a `Request` for the given HTTP request, using the given success and error decoders.

There should be a convinience method where this is done for every API call in `API`.
-}
toRequest : Decoder a -> SpecificErrorDecoder b -> Task Http.RawError Http.Response -> Request b a
toRequest successDecoder specificErrorDecoder task
  = (Task.mapError Communication task)
      `Task.andThen`
    (\response ->
      if (200 <= response.status && response.status < 300) then
        wrappedSuccessDecoder successDecoder response
      else
        Task.fail (specificErrorDecoder response |> Maybe.withDefault (genericErrorDecoder response))
    )


{-| Take a request, a handler to turn errors into actions, and a handler to turn successes into actions.
-}
toEffect : (a -> Action) -> (b -> Action) -> Request a b -> Effects Action
toEffect errorHandler successHandler task
  = Task.map successHandler task
  |> handleErrors errorHandler Nothing
  |> Effects.task


{-| The same as `toEffect`, but with a handler that produces an action on *any* errors (not just errors specific to this
request) in addition to the normal response.
This is mostly useful where you did something when the request started (e.g: disabled a button) and want to revert it
when the response completes, regardless of success.
-}
toEffectsWithOnError : (a -> Action) -> (b -> Action) -> (Error a -> Action) -> Request a b -> Effects Action
toEffectsWithOnError errorHandler successHandler onError task
  = Task.map successHandler task
  |> handleErrors errorHandler (Just onError)
  |> Effects.task


{-| Turns JSON into an HTTP body for a request.
-}
jsonBody : Json.Value -> Http.Body
jsonBody value = Json.encode 0 value |> Http.string


{-| An error from a request.
* A `Communication` error is an error at the networking level.
* A `Malformed` error means either the content wasn't JSON or it wasn't in the expected form.
* A `Known` error means an error specific to the request being made (e.g: adding a deck can fail because the play code
  doesn't exist).
* An `Unknown` error is an error where the HTTP request succeeded, but the combination of error code and content didn't
resolve to a known error. i.e: anything else.
-}
type Error specificErrors
  = Communication Http.RawError
  | Malformed String
  | Known specificErrors
  | Unknown Int String


{-| A function that decodes an error that is specific to the request being made (i.e: an `Error.Known`)

`specificErrors` is a type representing the possible errors for the API request.

There is a helper function to generate these more easily - see `specificErrorDecoder`.
-}
type alias SpecificErrorDecoder specificErrors =
  Http.Response -> Maybe (Error specificErrors)


{-| Creates a `SpecificErrorDecoder` for the given list of possible errors. The errors are taken in the format:

  (Status code, Error name, [ Fields ], Error constructor)

Where
  * Status code is the status code of the HTTP response as an int (e.g: 400, 404, 500, etc...)
  * Error name is the value of the 'error' field of the object taken from the content of the body of the response.
  * Fields are a list of names of other fields in the error.
  * Error constructor is a function that takes the values of the given fields and produces an error.

The decoder will take the HTTP response, and will sequentially try to find an error which matches the request in both
status code and error name. Then it will try to produce an error using the fields taken from the body. If this fails,
it will fall back to producing no error.

For example:

  (400, "unexpected-value", [ "value" ], oneArgument Json.Decode.int UnexpectedValue)

Would take a response with a status code of 400 and a body of:

  {
    "error": "unexpected-value",
    "value": 1
  }

And produce an `UnexpectedValue 1`.

Note there are convinience methods to map the JSON values into normal values. See `noArguments`, `oneArgument` and
`twoArguments`.
-}
specificErrorDecoder : List (Int, String, List String, (List Json.Value -> Maybe a)) -> SpecificErrorDecoder a
specificErrorDecoder errorsFormats response =
    case response.value of
      Http.Text rawValues ->
        case decodeString (keyValuePairs value) rawValues of
          Ok values ->
            let
              error = Util.find (\(key, value) -> key == "error") values
            in
              error
                `Maybe.andThen`
              (\(_, raw) -> decodeValue Json.Decode.string raw |> Result.toMaybe)
                `Maybe.andThen`
              (\respErrorName ->
                Util.find (\(status, errorName, _, _) -> response.status == status && respErrorName == errorName) errorsFormats
                 `Maybe.andThen` (\(_, _, keys, errorConstructor) -> (errorConstructor (extractValues keys values)))
                 |> Maybe.map Known)
          Err _ ->
            Nothing
      Http.Blob _ ->
        Nothing


{-| Returns the given value.
-}
noArguments : a -> List Json.Value -> Maybe a
noArguments value _ = Just value


{-| Takes the first value from the list if it exists, decodes it if possible, and feeds it into the given function.
-}
oneArgument : Decoder a -> (a -> b) -> List Json.Value -> Maybe b
oneArgument decoder f values = (List.head values) `Maybe.andThen` (toArgument decoder f)


{-| Takes the two values from the list if they exists, decodes them with the respective decoders if possible, and feeds
them into the given function.
-}
twoArguments : (Decoder a, Decoder b) -> (a -> b -> c) -> List Json.Value -> Maybe c
twoArguments (decoder1, decoder2) f values =
  case values of
    first :: second :: [] ->
      let
        v1 = Result.toMaybe (decodeValue decoder1 first)
        v2 = Result.toMaybe (decodeValue decoder2 second)
      in
        Maybe.map2 f v1 v2
    _ ->
      Nothing


{- Private -}


extractValues : List String -> List (String, a) -> List a
extractValues keys values =
  List.filterMap (\key -> Util.find (\(potentialKey, value) -> potentialKey == key) values) keys
    |> List.map snd


toArgument : Decoder a -> (a -> b) -> Json.Value -> Maybe b
toArgument decoder f value = Result.toMaybe (decodeValue decoder value) |> Maybe.map f


wrappedSuccessDecoder : Decoder a -> Http.Response -> Request b a
wrappedSuccessDecoder decoder response =
  case response.value of
    Http.Text rawValue ->
      case decodeString decoder rawValue of
        Ok value -> Task.succeed value
        Err error -> Task.fail (Malformed error)
    Http.Blob _ -> Task.fail (Malformed "Recieved binary data instead of expected JSON.")


genericErrorDecoder : Http.Response -> Error a
genericErrorDecoder response = Unknown response.status response.statusText


handleErrors : (a -> Action) -> Maybe (Error a -> Action) -> Request a Action -> Task c Action
handleErrors knownErrorHandler onError request =
  let
    errorToAction error = case error of
      Communication (Http.RawTimeout) ->
        DisplayError "The server couldn't be reached after a long time, it may be down."
      Communication (Http.RawNetworkError) ->
        DisplayError "There was a network error trying to each the server."
      Malformed explanation ->
        DisplayError ("There was an error decoding the response the server gave: " ++ explanation)
      Unknown status statusText ->
        DisplayError ("Recieved an unexpected bad response from the server: " ++ (toString status) ++ " - " ++ statusText )
      Known knownError ->
        knownErrorHandler knownError
  in
    request `Task.onError` (\error -> Task.succeed (case onError of
      Just onError -> Batch [ errorToAction error, onError error ]
      Nothing -> errorToAction error))
