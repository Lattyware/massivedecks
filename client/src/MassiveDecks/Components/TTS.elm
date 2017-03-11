port module MassiveDecks.Components.TTS exposing (Model, Message(..), update, init)

import MassiveDecks.Util as Util


type alias Model =
    { enabled : Bool
    }


type Message
    = Say String
    | Enabled Bool


init : Model
init =
    { enabled = False }


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        Say text ->
            ( model
            , if model.enabled then
                say text
              else
                Cmd.none
            )

        Enabled enabled ->
            ( { model | enabled = enabled }
            , if enabled then
                Cmd.none
              else
                Say "" |> Util.cmd
            )


port say : String -> Cmd msg
