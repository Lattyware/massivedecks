module MassiveDecks.Pages.Lobby.Configure.Privacy.Model exposing (Config, Id(..))


type Id
    = All
    | Password
    | Public


type alias Config =
    { password : Maybe String
    , public : Bool
    }
