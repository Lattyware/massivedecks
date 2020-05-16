module MassiveDecks.Pages.Lobby.Configure.Privacy exposing
    ( componentById
    , default
    , init
    , update
    )

import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import MassiveDecks.Components.Form.Message as Message
import MassiveDecks.Pages.Lobby.Configure.Component as Component exposing (Component)
import MassiveDecks.Pages.Lobby.Configure.Component.Validator as Validator
import MassiveDecks.Pages.Lobby.Configure.ConfigOption as ConfigOption exposing (ConfigOption)
import MassiveDecks.Pages.Lobby.Configure.ConfigOption.Toggleable as Toggleable
import MassiveDecks.Pages.Lobby.Configure.Privacy.Model exposing (..)
import MassiveDecks.Strings as Strings
import MassiveDecks.Util.NeList as NeList exposing (NeList(..))
import Material.IconButton as IconButton
import Material.TextField as TextField


init : Model
init =
    { passwordVisible = False
    }


default : Config
default =
    { public = False
    , password = Nothing
    }


componentById : Id -> Component Config Model Id Msg msg
componentById id =
    case id of
        All ->
            all

        Password ->
            password |> Component.liftConfig .password (\pw -> \c -> { c | password = pw })

        Public ->
            public |> Component.liftConfig .public (\p -> \c -> { c | public = p })


{-| React to user input.
-}
update : Msg -> Config -> Model -> ( Config, Model, Cmd msg )
update msg local model =
    case msg of
        PasswordChange pw ->
            ( { local | password = pw }, model, Cmd.none )

        PublicChange p ->
            ( { local | public = p }, model, Cmd.none )

        TogglePasswordVisibility ->
            ( local, { model | passwordVisible = not model.passwordVisible }, Cmd.none )



{- Private -}


all : Component Config Model Id Msg msg
all =
    Component.group All
        (Just Strings.ConfigurePrivacy)
        [ componentById Public
        , componentById Password
        ]


public : Component Bool Model Id Msg msg
public =
    Component.value
        Public
        (ConfigOption.view publicOption)
        (always False)
        Validator.none


publicOption : ConfigOption Model Bool Msg msg
publicOption =
    { id = "public-option"
    , toggleable = Toggleable.bool
    , primaryEditor = \_ -> ConfigOption.Label { text = Strings.Public }
    , extraEditor = ConfigOption.noExtraEditor
    , set = ConfigOption.wrappedSetter PublicChange
    , messages = \_ -> [ Message.info Strings.PublicDescription ]
    }


password : Component (Maybe String) Model Id Msg msg
password =
    Component.value
        Password
        (ConfigOption.view passwordOption)
        (always False)
        (Validator.optional Validator.nonEmpty)


passwordOption : ConfigOption Model (Maybe String) Msg msg
passwordOption =
    let
        visibility wrap shared model _ =
            let
                icon =
                    if model.passwordVisible then
                        Icon.eyeSlash

                    else
                        Icon.eye

                action =
                    TogglePasswordVisibility |> wrap |> Just
            in
            Just (IconButton.view shared Strings.LobbyPassword (icon |> Icon.present |> NeList.just) action)
    in
    { id = "game-password-option"
    , toggleable = Toggleable.maybe ""
    , primaryEditor =
        \model ->
            ConfigOption.TextField
                { placeholder = Strings.LobbyPassword
                , inputType =
                    if not model.passwordVisible then
                        TextField.Password

                    else
                        TextField.Text
                , toString = identity
                , fromString = Just >> Just
                , attrs = []
                }
    , extraEditor = visibility
    , set = ConfigOption.wrappedSetter PasswordChange
    , messages =
        \_ ->
            [ Message.info Strings.LobbyPasswordDescription
            , Message.warning Strings.PasswordShared
            , Message.warning Strings.PasswordNotSecured
            ]
    }
