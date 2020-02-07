module MassiveDecks.Pages.Lobby.Configure.Privacy exposing
    ( componentById
    , default
    , init
    , update
    )

import FontAwesome.Solid as Icon
import Html.Events as HtmlE
import MassiveDecks.Components as Components
import MassiveDecks.Components.Form.Message as Message
import MassiveDecks.Pages.Lobby.Configure.Component as Component exposing (Component)
import MassiveDecks.Pages.Lobby.Configure.Component.Validator as Validator
import MassiveDecks.Pages.Lobby.Configure.ConfigOption as ConfigOption exposing (ConfigOption)
import MassiveDecks.Pages.Lobby.Configure.ConfigOption.Toggleable as Toggleable
import MassiveDecks.Pages.Lobby.Configure.Privacy.Model exposing (..)
import MassiveDecks.Strings as Strings
import MassiveDecks.Util.Html.Attributes as HtmlA
import MassiveDecks.Util.Maybe as Maybe
import Weightless.Attributes as WlA


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
    { id = "game-password-option"
    , toggleable = Toggleable.maybe ""
    , primaryEditor =
        \model ->
            ConfigOption.TextField
                { placeholder = Strings.LobbyPassword
                , inputType = WlA.Password |> Maybe.justIf (not model.passwordVisible)
                , toString = identity
                , fromString = Just >> Just
                , attrs = [ WlA.minLength 1 ]
                }
    , extraEditor =
        \wrap ->
            \model ->
                \value ->
                    Just
                        (Components.iconButton
                            [ TogglePasswordVisibility |> wrap |> HtmlE.onClick
                            , WlA.disabled |> Maybe.justIf (Maybe.isNothing value) |> Maybe.withDefault HtmlA.nothing
                            ]
                            (Icon.eyeSlash |> Maybe.justIf model.passwordVisible |> Maybe.withDefault Icon.eye)
                        )
    , set = ConfigOption.wrappedSetter PasswordChange
    , messages =
        \_ ->
            [ Message.info Strings.LobbyPasswordDescription
            , Message.warning Strings.PasswordShared
            , Message.warning Strings.PasswordNotSecured
            ]
    }
