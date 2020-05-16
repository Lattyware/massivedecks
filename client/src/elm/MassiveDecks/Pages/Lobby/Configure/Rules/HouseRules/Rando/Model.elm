module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Rando.Model exposing
    ( ChildId(..)
    , Id(..)
    )


type Id
    = All
    | Enabled
    | Child ChildId


type ChildId
    = Children
    | Number
