module MassiveDecks.Pages.Lobby.Configure.Privacy exposing (all)

import MassiveDecks.Components.Form.Message as Message
import MassiveDecks.Pages.Lobby.Configure.Configurable as Configurable
import MassiveDecks.Pages.Lobby.Configure.Configurable.Editor as Editor
import MassiveDecks.Pages.Lobby.Configure.Configurable.Model exposing (Configurable)
import MassiveDecks.Pages.Lobby.Configure.Configurable.Validator as Validator
import MassiveDecks.Pages.Lobby.Configure.Privacy.Model exposing (..)
import MassiveDecks.Strings as Strings


all : (Bool -> msg) -> Configurable Id Config { model | passwordVisible : Bool } msg
all setPasswordVisibility =
    Configurable.group
        { id = All
        , editor = Editor.group (Just Strings.ConfigurePrivacy) False False
        , children =
            [ public |> Configurable.wrap identity (.public >> Just) (\v p -> { p | public = v })
            , password setPasswordVisibility |> Configurable.wrap identity (.password >> Just) (\v p -> { p | password = v })
            , audienceMode |> Configurable.wrap identity (.audienceMode >> Just) (\v p -> { p | audienceMode = v })
            ]
        }


public : Configurable Id Bool model msg
public =
    Configurable.value
        { id = Public
        , editor = Editor.bool Strings.Public
        , validator = Validator.none
        , messages = always [ Message.info Strings.PublicDescription ]
        }


password : (Bool -> msg) -> Configurable Id (Maybe String) { model | passwordVisible : Bool } msg
password setPasswordVisibility =
    Configurable.value
        { id = Password
        , editor = Editor.password setPasswordVisibility Strings.LobbyPassword |> Editor.maybe ""
        , validator = Validator.nonEmpty |> Validator.whenJust
        , messages =
            always
                [ Message.info Strings.LobbyPasswordDescription
                , Message.warning Strings.PasswordShared
                , Message.warning Strings.PasswordNotSecured
                ]
        }


audienceMode : Configurable Id Bool model msg
audienceMode =
    Configurable.value
        { id = AudienceMode
        , editor = Editor.bool Strings.AudienceMode
        , validator = Validator.none
        , messages = always [ Message.info Strings.AudienceModeDescription ]
        }
