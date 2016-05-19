port module MassiveDecks.Components.Storage exposing (storeInGame, storeLeftGame)

import MassiveDecks.Models.Game as Game


port existingGame : Maybe Game.GameCodeAndSecret -> Cmd msg


storeInGame : Game.GameCodeAndSecret -> Cmd msg
storeInGame gameCodeAndSecret = existingGame (Just gameCodeAndSecret)

storeLeftGame : Cmd msg
storeLeftGame = existingGame Nothing
