module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Reboot.Model exposing
    ( ChildId(..)
    , Id(..)
    )


type Id
    = All
    | Enabled
    | Child ChildId


type ChildId
    = Children
    | Cost
