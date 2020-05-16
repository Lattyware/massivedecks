module MassiveDecks.Pages.Lobby.Configure.Privacy.Model exposing (Config, Id(..))


type Id
    = All
    | Password
    | Public
    | AudienceMode


type alias Config =
    { password : Maybe String
    , public : Bool
    , audienceMode : Bool
    }
