module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Reboot exposing (all)

import MassiveDecks.Components.Form.Message as Message
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Pages.Lobby.Configure.Configurable as Configurable
import MassiveDecks.Pages.Lobby.Configure.Configurable.Editor as Editor
import MassiveDecks.Pages.Lobby.Configure.Configurable.Model exposing (Configurable)
import MassiveDecks.Pages.Lobby.Configure.Configurable.Validator as Validator
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Reboot.Model exposing (..)
import MassiveDecks.Strings as Strings


all : Configurable Id (Maybe Rules.Reboot) model msg
all =
    Configurable.group
        { id = All
        , editor = Editor.group Nothing False False
        , children =
            [ enabled
            , children |> Configurable.wrapMaybe
            ]
        }


default : Rules.Reboot
default =
    { cost = 1 }


enabled : Configurable Id (Maybe Rules.Reboot) model msg
enabled =
    let
        messages r =
            { cost = r |> Maybe.andThen identity |> Maybe.map .cost }
                |> Strings.HouseRuleRebootDescription
                |> Message.info
    in
    Configurable.value
        { id = Enabled
        , editor = Editor.toggle Strings.HouseRuleReboot default
        , validator = Validator.none
        , messages = \r -> [ messages r ]
        }


children : Configurable Id Rules.Reboot model msg
children =
    Configurable.group
        { id = Child Children
        , editor = Editor.group Nothing True True
        , children =
            [ cost |> Configurable.wrap Child (.cost >> Just) (\v p -> { p | cost = v })
            ]
        }


cost : Configurable ChildId Int model msg
cost =
    Configurable.value
        { id = Cost
        , editor = Editor.int Strings.HouseRuleRebootCost
        , validator = Validator.between 1 10
        , messages = always [ Message.info Strings.HouseRuleRebootCostDescription ]
        }
