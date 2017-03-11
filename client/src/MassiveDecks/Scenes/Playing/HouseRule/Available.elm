module MassiveDecks.Scenes.Playing.HouseRule.Available exposing (houseRules)

import MassiveDecks.Scenes.Playing.HouseRule as HouseRule exposing (HouseRule)
import MassiveDecks.Scenes.Playing.HouseRule.Reboot as Reboot


houseRules : List HouseRule
houseRules =
    [ Reboot.rule ]
