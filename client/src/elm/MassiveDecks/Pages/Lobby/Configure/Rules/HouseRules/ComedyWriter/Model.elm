module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.ComedyWriter.Model exposing
    ( ChildId(..)
    , Id(..)
    )


type Id
    = All
    | Enabled
    | Child ChildId


type ChildId
    = Children
    | Exclusive
    | Number
