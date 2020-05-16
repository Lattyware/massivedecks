module MassiveDecks.Pages.Lobby.Configure.Rules exposing (all)

import MassiveDecks.Components.Form.Message as Message
import MassiveDecks.Game.Rules exposing (Rules)
import MassiveDecks.Pages.Lobby.Configure.Configurable as Configurable
import MassiveDecks.Pages.Lobby.Configure.Configurable.Editor as Editor
import MassiveDecks.Pages.Lobby.Configure.Configurable.Model exposing (Configurable)
import MassiveDecks.Pages.Lobby.Configure.Configurable.Validator as Validator
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules as HouseRules
import MassiveDecks.Pages.Lobby.Configure.Rules.Model exposing (..)
import MassiveDecks.Strings as Strings


all : Configurable Id Rules model msg
all =
    Configurable.group
        { id = All
        , editor = Editor.group Nothing False False
        , children =
            [ gameRules
            , HouseRules.all |> Configurable.wrap HouseRulesId (.houseRules >> Just) (\v p -> { p | houseRules = v })
            ]
        }


gameRules : Configurable Id Rules model msg
gameRules =
    Configurable.group
        { id = GameRules
        , editor = Editor.group (Just Strings.ConfigureRules) False False
        , children =
            [ handSize |> Configurable.wrap identity (.handSize >> Just) (\v p -> { p | handSize = v })
            , scoreLimit |> Configurable.wrap identity (.scoreLimit >> Just) (\v p -> { p | scoreLimit = v })
            ]
        }


handSize : Configurable Id Int model msg
handSize =
    Configurable.value
        { id = HandSize
        , editor = Editor.int Strings.HandSize
        , validator = Validator.between 3 50
        , messages = always [ Message.info Strings.HandSizeDescription ]
        }


scoreLimit : Configurable Id (Maybe Int) model msg
scoreLimit =
    Configurable.value
        { id = ScoreLimit
        , editor = Editor.int Strings.ScoreLimit |> Editor.maybe 25
        , validator = Validator.between 0 9999 |> Validator.whenJust
        , messages = always [ Message.info Strings.ScoreLimitDescription ]
        }
