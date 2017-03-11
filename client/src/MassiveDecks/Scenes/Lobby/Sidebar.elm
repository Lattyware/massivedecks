port module MassiveDecks.Scenes.Lobby.Sidebar exposing (Model, Message(..), init, update)

import Task
import Window
import MassiveDecks.Util as Util


{-| This component handles the players sidebar for the lobby view. On a larger display, this bar is shown, but can be
hidden by the user. On small displays, it is hidden but can be popped out as a modal window over the top of the
lobby.

No rendering is done within this module - instead the model should be inspected and the sidebar rendered as required.
-}
type alias Model =
    { enhanceWidth : Int
    , hidden : Bool
    , shownAsOverlay : Bool
    }


type Message
    = Toggle
    | Show Int
    | Hide


init : Int -> Model
init enhanceWidth =
    { enhanceWidth = enhanceWidth
    , hidden = False
    , shownAsOverlay = False
    }


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        Toggle ->
            ( model, Task.perform Show Window.width )

        Show screenWidth ->
            if model.shownAsOverlay then
                ( { model | shownAsOverlay = False }, Cmd.none )
            else if screenWidth > model.enhanceWidth then
                ( { model | hidden = not model.hidden }, Cmd.none )
            else
                ( { model | shownAsOverlay = True }, Cmd.none )

        Hide ->
            ( { model | shownAsOverlay = False }, Cmd.none )
