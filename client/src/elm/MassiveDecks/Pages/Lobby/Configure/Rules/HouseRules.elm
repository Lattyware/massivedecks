module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules exposing (all)

import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Pages.Lobby.Configure.Configurable as Configurable
import MassiveDecks.Pages.Lobby.Configure.Configurable.Editor as Editor
import MassiveDecks.Pages.Lobby.Configure.Configurable.Model exposing (Configurable)
import MassiveDecks.Pages.Lobby.Configure.Messages exposing (Msg)
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.ComedyWriter as ComedyWriter
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.CzarChoices as CzarChoices
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.HappyEnding as HappyEnding
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.NeverHaveIEver as NeverHaveIEver
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.PackingHeat as PackingHeat
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Rando as Rando
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Reboot as Reboot
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.WinnersPick as WinnersPick
import MassiveDecks.Strings as Strings


all : (Msg -> msg) -> Configurable Id Rules.HouseRules model msg
all wrap =
    Configurable.group
        { id = All
        , editor = Editor.group "house-rules" (Just Strings.HouseRulesTitle) False False
        , children =
            [ Rando.all |> Configurable.wrap RandoId (.rando >> Just) (\v p -> { p | rando = v })
            , PackingHeat.all |> Configurable.wrap PackingHeatId (.packingHeat >> Just) (\v p -> { p | packingHeat = v })
            , Reboot.all |> Configurable.wrap RebootId (.reboot >> Just) (\v p -> { p | reboot = v })
            , ComedyWriter.all |> Configurable.wrap ComedyWriterId (.comedyWriter >> Just) (\v p -> { p | comedyWriter = v })
            , NeverHaveIEver.all |> Configurable.wrap NeverHaveIEverId (.neverHaveIEver >> Just) (\v p -> { p | neverHaveIEver = v })
            , HappyEnding.all |> Configurable.wrap HappyEndingId (.happyEnding >> Just) (\v p -> { p | happyEnding = v })
            , CzarChoices.all wrap |> Configurable.wrap CzarChoicesId (.czarChoices >> Just) (\v p -> { p | czarChoices = v })
            , WinnersPick.all |> Configurable.wrap WinnersPickId (.winnersPick >> Just) (\v p -> { p | winnersPick = v })
            ]
        }
