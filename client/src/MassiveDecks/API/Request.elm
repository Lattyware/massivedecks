module MassiveDecks.API.Request where

import Http
import Task exposing (Task)
import Json.Decode exposing (Decoder, decodeValue, decodeString, keyValuePairs, value)
import Json.Encode as Json
import Effects exposing (Effects)

import MassiveDecks.Actions.Action exposing (Action(..))
import MassiveDecks.Util as Util


type alias Request specificErrors successfulResponse =
  Task (Error specificErrors) successfulResponse


type alias SpecificErrorDecoder specificErrors =
  Http.Response -> Maybe (Error specificErrors)


type Error a
  = Communication Http.RawError
  | Unknown Int String
  | Malformed String
  | Known a


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


extractValues : List String -> List (String, Json.Value) -> List Json.Value
extractValues keys values =
  List.filterMap (\key -> Util.find (\(potentialKey, value) -> potentialKey == key) values) keys
    |> List.map snd


toArgument : Decoder a -> (a -> b) -> Json.Value -> Maybe b
toArgument decoder f value = Result.toMaybe (decodeValue decoder value) |> Maybe.map f


oneArgument : Decoder a -> (a -> b) -> List Json.Value -> Maybe b
oneArgument decoder f values = (List.head values) `Maybe.andThen` (toArgument decoder f)


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


toEffectsWithOnError : (a -> Action) -> (b -> Action) -> (Error a -> Action) -> Request a b -> Effects Action
toEffectsWithOnError errorHandler successHandler onError task
  = Task.map successHandler task
  |> handleErrors errorHandler (Just onError)
  |> Effects.task


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


toEffect : (a -> Action) -> (b -> Action) -> Request a b -> Effects Action
toEffect errorHandler successHandler task
  = Task.map successHandler task
  |> handleErrors errorHandler Nothing
  |> Effects.task


jsonBody : Json.Value -> Http.Body
jsonBody value = Json.encode 0 value |> Http.string
