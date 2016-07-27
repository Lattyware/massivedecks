port module MassiveDecks.Components.Storage exposing (Model, Message(..), init, update)

import MassiveDecks.Models.Game as Game


type alias Model =
  { existingGames : List Game.GameCodeAndSecret
  }


type Message
  = Join Game.GameCodeAndSecret
  | Leave Game.GameCodeAndSecret


port store : List Game.GameCodeAndSecret -> Cmd msg


init : List Game.GameCodeAndSecret -> Model
init existingGames = Model existingGames


update : Message -> Model -> (Model, Cmd Message)
update message model =
  case message of
    Join gameCodeAndSecret ->
      let
        existingGames = gameCodeAndSecret :: List.filter (different gameCodeAndSecret) model.existingGames
      in
        ( { model | existingGames = existingGames }
        , store existingGames
        )

    Leave gameCodeAndSecret ->
      let
        existingGames = List.filter (different gameCodeAndSecret) model.existingGames
      in
        ( { model | existingGames = existingGames }
        , store existingGames
        )


different : Game.GameCodeAndSecret -> Game.GameCodeAndSecret -> Bool
different check existing = check.gameCode /= existing.gameCode
