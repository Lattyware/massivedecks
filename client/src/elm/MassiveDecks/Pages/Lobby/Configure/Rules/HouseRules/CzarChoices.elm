module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.CzarChoices exposing (all)

import MassiveDecks.Components.Form.Message as Message
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Icon as Icon
import MassiveDecks.Pages.Lobby.Configure.Configurable as Configurable
import MassiveDecks.Pages.Lobby.Configure.Configurable.Editor as Editor
import MassiveDecks.Pages.Lobby.Configure.Configurable.Model exposing (Configurable)
import MassiveDecks.Pages.Lobby.Configure.Configurable.Validator as Validator
import MassiveDecks.Pages.Lobby.Configure.Messages exposing (Msg(..))
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Tab(..))
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.CzarChoices.Model exposing (..)
import MassiveDecks.Strings as Strings


all : (Msg -> msg) -> Configurable Id (Maybe Rules.CzarChoices) model msg
all wrap =
    Configurable.group
        { id = All
        , editor = Editor.group "czar-choices" Nothing False False
        , children =
            [ enabled wrap |> Configurable.wrapAsToggle default
            , children |> Configurable.wrapMaybe
            ]
        }


default : Rules.CzarChoices
default =
    { numberOfChoices = 3
    , custom = False
    }


enabled : (Msg -> msg) -> Configurable Id Bool model msg
enabled wrap =
    Configurable.value
        { id = Enabled
        , editor = Editor.bool Strings.HouseRuleCzarChoices
        , validator = Validator.none
        , messages =
            always
                [ Message.info Strings.HouseRuleCzarChoicesDescription
                , Message.infoWithFix (Strings.SeeAlso { rule = Strings.DuringTitle })
                    [ { description = Strings.ConfigureTimeLimits
                      , icon = Icon.show
                      , action = Stages |> Just |> ChangeTab |> wrap
                      }
                    ]
                ]
        }


children : Configurable Id Rules.CzarChoices model msg
children =
    Configurable.group
        { id = Child Children
        , editor = Editor.group "czar-choices-children" Nothing True True
        , children =
            [ number |> Configurable.wrap Child (.numberOfChoices >> Just) (\v p -> { p | numberOfChoices = v })
            , exclusive |> Configurable.wrap Child (.custom >> Just) (\v p -> { p | custom = v })
            ]
        }


exclusive : Configurable ChildId Bool model msg
exclusive =
    Configurable.value
        { id = Custom
        , editor = Editor.bool Strings.HouseRuleCzarChoicesCustom
        , validator = Validator.none
        , messages = always [ Message.info Strings.HouseRuleCzarChoicesCustomDescription ]
        }


number : Configurable ChildId Int model msg
number =
    Configurable.value
        { id = NumberOfChoices
        , editor = Editor.int Strings.HouseRuleCzarChoicesNumber
        , validator = Validator.between 1 10
        , messages = always [ Message.info Strings.HouseRuleCzarChoicesNumberDescription ]
        }
