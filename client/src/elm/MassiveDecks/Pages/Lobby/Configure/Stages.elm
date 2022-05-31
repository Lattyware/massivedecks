module MassiveDecks.Pages.Lobby.Configure.Stages exposing (all)

import MassiveDecks.Components.Form.Message as Message
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Icon as Icon
import MassiveDecks.Pages.Lobby.Configure.Configurable as Configurable
import MassiveDecks.Pages.Lobby.Configure.Configurable.Editor as Editor
import MassiveDecks.Pages.Lobby.Configure.Configurable.Model exposing (Configurable)
import MassiveDecks.Pages.Lobby.Configure.Configurable.Validator as Validator
import MassiveDecks.Pages.Lobby.Configure.Messages exposing (Msg(..))
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Tab(..))
import MassiveDecks.Pages.Lobby.Configure.Stages.Model exposing (..)
import MassiveDecks.Strings as Strings exposing (MdString)


defaultStage : Rules.Stage
defaultStage =
    { duration = Nothing, after = 5 }


all : (Msg -> msg) -> Configurable Id Rules.Stages model msg
all wrap =
    Configurable.group
        { id = All
        , editor = Editor.group "time-limits" (Just Strings.ConfigureTimeLimits) False False
        , children =
            [ mode |> Configurable.wrap identity (.mode >> Just) (\v p -> { p | mode = v })
            , starting wrap |> Configurable.wrap identity (.starting >> Just) (\v p -> { p | starting = v })
            , alwaysStage "playing" Strings.Playing Strings.PlayingTimeLimitDescription Strings.PlayingAfterDescription Playing
                |> Configurable.wrap identity (.playing >> Just) (\v p -> { p | playing = v })
            , toggledStage "revealing" Strings.Revealing Strings.RevealingTimeLimitDescription Strings.RevealingAfterDescription Revealing
                |> Configurable.wrap identity (.revealing >> Just) (\v p -> { p | revealing = v })
            , alwaysStage "judging" Strings.Judging Strings.JudgingTimeLimitDescription Strings.CompleteTimeLimitDescription Judging
                |> Configurable.wrap identity (.judging >> Just) (\v p -> { p | judging = v })
            ]
        }


stage : String -> MdString -> MdString -> (StagePartId -> Id) -> Configurable Id Rules.Stage model msg
stage id duringDescription afterDescription s =
    Configurable.group
        { id = s Parts
        , editor = Editor.group (id ++ "-time-limits-children") Nothing True True
        , children =
            [ duration duringDescription |> Configurable.wrap s (.duration >> Just) (\v p -> { p | duration = v })
            , after afterDescription |> Configurable.wrap s (.after >> Just) (\v p -> { p | after = v })
            ]
        }


alwaysStage : String -> MdString -> MdString -> MdString -> (StagePartId -> Id) -> Configurable Id Rules.Stage model msg
alwaysStage id stageName duringDescription afterDescription s =
    Configurable.group
        { id = s Container
        , editor = Editor.group (id ++ "-time-limits") (Just stageName) False False
        , children =
            [ stage id duringDescription afterDescription s
            ]
        }


toggledStage : String -> MdString -> MdString -> MdString -> (StagePartId -> Id) -> Configurable Id (Maybe Rules.Stage) model msg
toggledStage id stageName duringDescription afterDescription s =
    Configurable.group
        { id = s Container
        , editor = Editor.group (id ++ "-time-limits") (Just stageName) False False
        , children =
            [ enabled |> Configurable.wrapAsToggle defaultStage
            , stage id duringDescription afterDescription s |> Configurable.wrapMaybe
            ]
        }


starting : (Msg -> msg) -> Configurable Id (Maybe Int) model msg
starting wrap =
    Configurable.group
        { id = StartingContainer
        , editor = Editor.group "starting-time-limits" (Just Strings.Starting) False False
        , children =
            [ Configurable.value
                { id = Starting
                , editor = Editor.int Strings.DuringTitle |> Editor.maybe 30
                , validator = Validator.between 0 900 |> Validator.whenJust
                , messages =
                    always
                        [ Message.info Strings.StartingTimeLimitDescription
                        , Message.infoWithFix (Strings.SeeAlso { rule = Strings.HouseRuleCzarChoices })
                            [ { description = Strings.ConfigureRules
                              , icon = Icon.show
                              , action = Rules |> Just |> ChangeTab |> wrap
                              }
                            ]
                        ]
                }
            ]
        }


enabled : Configurable Id Bool model msg
enabled =
    Configurable.value
        { id = RevealingEnabled
        , editor = Editor.bool Strings.RevealingEnabledTitle
        , validator = Validator.none
        , messages = always [ Message.info Strings.RevealingEnabled ]
        }


mode : Configurable Id Rules.TimeLimitMode model msg
mode =
    let
        there b =
            case b of
                Rules.Hard ->
                    True

                Rules.Soft ->
                    False

        back a =
            if a then
                Rules.Hard

            else
                Rules.Soft
    in
    Configurable.value
        { id = Mode
        , editor = Editor.bool Strings.Automatic |> Editor.map there back
        , validator = Validator.none
        , messages = always [ Message.info Strings.AutomaticDescription ]
        }


duration : MdString -> Configurable StagePartId (Maybe Int) model msg
duration description =
    Configurable.value
        { id = Duration
        , editor = Editor.int Strings.DuringTitle |> Editor.maybe 60
        , validator = Validator.between 0 900 |> Validator.whenJust
        , messages = always [ Message.info description ]
        }


after : MdString -> Configurable StagePartId Int model msg
after description =
    Configurable.value
        { id = After
        , editor = Editor.int Strings.AfterTitle
        , validator = Validator.between 0 900
        , messages = always [ Message.info description ]
        }
