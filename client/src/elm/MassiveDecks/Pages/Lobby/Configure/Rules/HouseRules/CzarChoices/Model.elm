module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.CzarChoices.Model exposing
    ( ChildId(..)
    , Id(..)
    )


type Id
    = All
    | Enabled
    | Child ChildId


type ChildId
    = Children
    | NumberOfChoices
    | Custom
