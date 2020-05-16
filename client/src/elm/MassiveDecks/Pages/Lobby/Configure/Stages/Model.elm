module MassiveDecks.Pages.Lobby.Configure.Stages.Model exposing
    ( Id(..)
    , StagePartId(..)
    )


type Id
    = All
    | Mode
    | Playing StagePartId
    | RevealingEnabled
    | Revealing StagePartId
    | Judging StagePartId


type StagePartId
    = Container
    | Parts
    | Duration
    | After
