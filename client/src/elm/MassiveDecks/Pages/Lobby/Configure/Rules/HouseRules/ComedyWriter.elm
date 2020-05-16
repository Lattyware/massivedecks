module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.ComedyWriter exposing (all)

import MassiveDecks.Components.Form.Message as Message
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Pages.Lobby.Configure.Configurable as Configurable
import MassiveDecks.Pages.Lobby.Configure.Configurable.Editor as Editor
import MassiveDecks.Pages.Lobby.Configure.Configurable.Model exposing (Configurable)
import MassiveDecks.Pages.Lobby.Configure.Configurable.Validator as Validator
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.ComedyWriter.Model exposing (..)
import MassiveDecks.Strings as Strings


all : Configurable Id (Maybe Rules.ComedyWriter) model msg
all =
    Configurable.group
        { id = All
        , editor = Editor.group Nothing False False
        , children =
            [ enabled |> Configurable.wrapAsToggle default
            , children |> Configurable.wrapMaybe
            ]
        }


default : Rules.ComedyWriter
default =
    { exclusive = False
    , number = 3
    }


enabled : Configurable Id Bool model msg
enabled =
    Configurable.value
        { id = Enabled
        , editor = Editor.bool Strings.HouseRuleComedyWriter
        , validator = Validator.none
        , messages = always [ Message.info Strings.HouseRuleComedyWriterDescription ]
        }


children : Configurable Id Rules.ComedyWriter model msg
children =
    Configurable.group
        { id = Child Children
        , editor = Editor.group Nothing True True
        , children =
            [ exclusive |> Configurable.wrap Child (.exclusive >> Just) (\v p -> { p | exclusive = v })
            , number |> Configurable.wrap Child (.number >> Just) (\v p -> { p | number = v })
            ]
        }


exclusive : Configurable ChildId Bool model msg
exclusive =
    Configurable.value
        { id = Exclusive
        , editor = Editor.bool Strings.HouseRuleComedyWriterExclusive
        , validator = Validator.none
        , messages = always [ Message.info Strings.HouseRuleComedyWriterExclusiveDescription ]
        }


number : Configurable ChildId Int model msg
number =
    Configurable.value
        { id = Number
        , editor = Editor.int Strings.HouseRuleComedyWriterNumber
        , validator = Validator.between 0 9999
        , messages = always [ Message.info Strings.HouseRuleComedyWriterNumberDescription ]
        }
