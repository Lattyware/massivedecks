module MassiveDecks.Speech exposing
    ( Model
    , Msg(..)
    , Settings
    , Voice
    , default
    , init
    , selectVoice
    , speak
    , subscriptions
    , toggle
    , update
    )

import Json.Decode
import Json.Encode as Json
import MassiveDecks.Ports as Ports


{-| A voice that can be used to speak phrases.
-}
type alias Voice =
    { name : String
    , lang : String
    , default : Bool
    }


{-| The configurable settings for speech.
-}
type alias Settings =
    { enabled : Bool
    , selectedVoice : Maybe String
    }


{-| Runtime data used for speech.
-}
type alias Model =
    { voices : List Voice
    }


{-| Messages used for speech.
-}
type Msg
    = UpdateVoices (List Voice)


{-| Initialize the model.
-}
init : ( Model, Cmd msg )
init =
    ( { voices = [] }, requestVoices )


{-| The default settings for speech.
-}
default : Settings
default =
    { enabled = False
    , selectedVoice = Nothing
    }


{-| Speak the given phrase.
-}
speak : Settings -> String -> Cmd msg
speak settings phrase =
    if settings.enabled then
        case settings.selectedVoice of
            Just voice ->
                Json.object [ ( "voice", Json.string voice ), ( "phrase", Json.string phrase ) ] |> Ports.speechCommands

            Nothing ->
                Cmd.none

    else
        Cmd.none


{-| Enable or disable speech.
-}
toggle : Bool -> Settings -> Settings
toggle enabled settings =
    { settings | enabled = enabled }


{-| Select a new voice for speech.
-}
selectVoice : String -> Settings -> Settings
selectVoice voice settings =
    { settings | selectedVoice = Just voice }


{-| Subscriptions for speech.
-}
subscriptions : (Json.Decode.Error -> msg) -> (Msg -> msg) -> Sub msg
subscriptions wrapError wrapMsg =
    Ports.speechVoices (Json.Decode.decodeValue (Json.Decode.list decodeVoice) >> toMsg wrapError wrapMsg)


{-| Update the model based on messages.
-}
update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateVoices voices ->
            { model | voices = voices }



{- Internal -}


requestVoices : Cmd msg
requestVoices =
    Json.object [ ( "name", Json.null ) ] |> Ports.speechCommands


decodeVoice : Json.Decode.Decoder Voice
decodeVoice =
    Json.Decode.map3 Voice
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "lang" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "default" Json.Decode.bool)
            |> Json.Decode.map (Maybe.withDefault False)
        )


toMsg : (Json.Decode.Error -> msg) -> (Msg -> msg) -> Result Json.Decode.Error (List Voice) -> msg
toMsg wrapError wrapMsg result =
    case result of
        Ok value ->
            UpdateVoices value |> wrapMsg

        Err error ->
            error |> wrapError
