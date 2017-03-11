port module MassiveDecks.Components.Storage exposing (Model, Message(..), update, join, leave)

import MassiveDecks.Models.Game as Game


type alias Model =
    List Game.GameCodeAndSecret


type Message
    = Store
    | Clear


port store : Model -> Cmd msg


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        Store ->
            ( model, store model )

        Clear ->
            ( [], store [] )


join : Game.GameCodeAndSecret -> Model -> Model
join gameCodeAndSecret model =
    gameCodeAndSecret :: List.filter (different gameCodeAndSecret) model


leave : Game.GameCodeAndSecret -> Model -> Model
leave gameCodeAndSecret =
    List.filter (different gameCodeAndSecret)


different : Game.GameCodeAndSecret -> Game.GameCodeAndSecret -> Bool
different check existing =
    check.gameCode /= existing.gameCode
