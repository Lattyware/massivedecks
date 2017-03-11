module MassiveDecks.Scenes.Playing.HouseRule.Reboot exposing (rule)

import MassiveDecks.Models.Player as Player
import MassiveDecks.Scenes.Playing.HouseRule as HouseRule exposing (HouseRule)
import MassiveDecks.Scenes.Playing.HouseRule.Id as HouseRule
import MassiveDecks.Scenes.Playing.Messages as Playing
import MassiveDecks.Scenes.Lobby.Models as Lobby


rule : HouseRule
rule =
    { id = HouseRule.Reboot
    , icon = "recycle"
    , name = "Rebooting the Universe"
    , description = "At any time, players may trade in a point to discard their hand and redraw."
    , actions = [ rebootAction ]
    }


rebootAction : HouseRule.Action
rebootAction =
    { icon = "recycle"
    , text = "Redraw"
    , description = "Lose one point to discard your hand and draw a new one."
    , onClick = Playing.Redraw
    , enabled = checkEnabled
    }


checkEnabled : Lobby.Model -> Bool
checkEnabled lobbyModel =
    Player.byId lobbyModel.secret.id lobbyModel.lobby.players
        |> Maybe.map (\player -> player.score > 0)
        |> Maybe.withDefault False
