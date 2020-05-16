module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Rando exposing (all)

import MassiveDecks.Components.Form.Message as Message
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Pages.Lobby.Configure.Configurable as Configurable
import MassiveDecks.Pages.Lobby.Configure.Configurable.Editor as Editor
import MassiveDecks.Pages.Lobby.Configure.Configurable.Model exposing (Configurable)
import MassiveDecks.Pages.Lobby.Configure.Configurable.Validator as Validator
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Rando.Model exposing (..)
import MassiveDecks.Strings as Strings


all : Configurable Id (Maybe Rules.Rando) model msg
all =
    Configurable.group
        { id = All
        , editor = Editor.group Nothing False False
        , children =
            [ enabled |> Configurable.wrapAsToggle default
            , children |> Configurable.wrapMaybe
            ]
        }


default : Rules.Rando
default =
    { number = 1 }


enabled : Configurable Id Bool model msg
enabled =
    Configurable.value
        { id = Enabled
        , editor = Editor.bool Strings.HouseRuleRandoCardrissian
        , validator = Validator.none
        , messages = always [ Message.info Strings.HouseRuleRandoCardrissianDescription ]
        }


children : Configurable Id Rules.Rando model msg
children =
    Configurable.group
        { id = Child Children
        , editor = Editor.group Nothing True True
        , children =
            [ number |> Configurable.wrap Child (.number >> Just) (\v p -> { p | number = v })
            ]
        }


number : Configurable ChildId Int model msg
number =
    Configurable.value
        { id = Number
        , editor = Editor.int Strings.HouseRuleRandoCardrissianNumber
        , validator = Validator.between 1 10
        , messages = always [ Message.info Strings.HouseRuleRandoCardrissianNumberDescription ]
        }
