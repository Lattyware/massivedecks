module MassiveDecks.Pages.Lobby.Configure.Privacy.Model exposing
    ( Config
    , Id(..)
    , Model
    , Msg(..)
    )


type Id
    = All
    | Password
    | Public


type alias Config =
    { password : Maybe String
    , public : Bool
    }


type alias Model =
    { passwordVisible : Bool
    }


type Msg
    = PasswordChange (Maybe String)
    | PublicChange Bool
    | TogglePasswordVisibility
