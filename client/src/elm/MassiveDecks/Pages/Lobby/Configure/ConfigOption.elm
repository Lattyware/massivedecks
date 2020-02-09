module MassiveDecks.Pages.Lobby.Configure.ConfigOption exposing
    ( ConfigOption
    , PrimaryEditor(..)
    , RenderMode(..)
    , ViewArgs
    , intEditor
    , maybeEditor
    , noExtraEditor
    , view
    , wrappedSetter
    )

import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Components.Form as Form
import MassiveDecks.Components.Form.Message exposing (Message)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Component.Validator exposing (Validator)
import MassiveDecks.Pages.Lobby.Configure.ConfigOption.Toggleable exposing (Toggleable)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html.Attributes as HtmlA
import MassiveDecks.Util.Maybe as Maybe
import Weightless as Wl
import Weightless.Attributes as WlA


type alias Model model config =
    { model | localConfig : config }


type alias ConfigOption model config iMsg msg =
    { id : String
    , toggleable : Toggleable config
    , primaryEditor : model -> PrimaryEditor config msg
    , extraEditor : (iMsg -> msg) -> model -> config -> Maybe (Html msg)
    , set : (iMsg -> msg) -> config -> msg
    , messages : (iMsg -> msg) -> List (Message msg)
    }


type PrimaryEditor value msg
    = TextField
        { placeholder : MdString
        , inputType : Maybe WlA.InputType
        , toString : value -> Maybe String
        , fromString : String -> Maybe value
        , attrs : List (Html.Attribute msg)
        }
    | Label { text : MdString }


intEditor : MdString -> List (Html.Attribute msg) -> PrimaryEditor Int msg
intEditor placeholder attrs =
    TextField
        { placeholder = placeholder
        , inputType = Just WlA.Number
        , toString = String.fromInt >> Just
        , fromString = String.toInt
        , attrs = attrs
        }


maybeEditor : PrimaryEditor value msg -> PrimaryEditor (Maybe value) msg
maybeEditor given =
    case given of
        TextField { placeholder, inputType, toString, fromString, attrs } ->
            TextField
                { placeholder = placeholder
                , inputType = inputType
                , toString = Maybe.andThen toString
                , fromString = fromString >> Just
                , attrs = attrs
                }

        Label { text } ->
            Label { text = text }


noExtraEditor : (iMsg -> msg) -> model -> config -> Maybe (Html msg)
noExtraEditor =
    \_ -> \_ -> \_ -> Nothing


wrappedSetter : (config -> iMsg) -> (iMsg -> msg) -> config -> msg
wrappedSetter set =
    \wrap -> set >> wrap


type RenderMode
    = Local
    | Remote
    | Diff


type alias ViewArgs model config optionMsg msg =
    { wrap : optionMsg -> msg
    , shared : Shared
    , model : model
    , local : config
    , remote : config
    , noOp : msg
    , canEdit : Bool
    , renderMode : RenderMode
    }


view : ConfigOption model config optionMsg msg -> Validator config optionMsg msg -> ViewArgs model config optionMsg msg -> Html msg
view opt validator { wrap, shared, model, local, remote, noOp, canEdit, renderMode } =
    let
        vc =
            viewContents opt wrap shared model noOp canEdit

        ( contents, saved ) =
            case renderMode of
                Local ->
                    ( vc False local, local == remote )

                Remote ->
                    ( vc True remote, True )

                Diff ->
                    ( List.concat [ vc False local, vc True remote ], local == remote )

        errors =
            validator wrap local

        validated =
            List.isEmpty errors
    in
    Form.section
        shared
        opt.id
        (Html.div
            [ HtmlA.classList
                [ ( "multipart", True )
                , ( "locally-changed", not saved && validated )
                , ( "validation-error", not saved && not validated )
                ]
            ]
            contents
        )
        (errors ++ opt.messages wrap)



{- Private -}


viewContents : ConfigOption model config optionMsg msg -> (optionMsg -> msg) -> Shared -> model -> msg -> Bool -> Bool -> config -> List (Html msg)
viewContents opt wrap shared model noOp canEdit readOnly config =
    let
        primaryEditor =
            case opt.primaryEditor model of
                TextField { placeholder, inputType, toString, fromString, attrs } ->
                    Wl.textField
                        ([ HtmlA.class "primary"
                         , placeholder |> Lang.label shared
                         , WlA.outlined
                         , inputType |> Maybe.map WlA.type_ |> Maybe.withDefault HtmlA.nothing
                         , config |> toString |> Maybe.map WlA.value |> Maybe.withDefault HtmlA.nothing
                         , if readOnly then
                            WlA.readonly

                           else
                            fromString
                                >> Maybe.map (opt.set wrap)
                                >> Maybe.withDefault noOp
                                |> HtmlE.onInput
                         , opt.toggleable
                            |> Maybe.andThen (\t -> Maybe.justIf (t.off == config) WlA.disabled)
                            |> Maybe.withDefault HtmlA.nothing
                         , WlA.disabled |> Maybe.justIf (not canEdit) |> Maybe.withDefault HtmlA.nothing
                         ]
                            ++ attrs
                        )
                        []

                Label { text } ->
                    Html.label [ HtmlA.class "primary" ] [ text |> Lang.html shared ]

        switch =
            case opt.toggleable of
                Just { off, on } ->
                    Wl.switch
                        [ WlA.checked |> Maybe.justIf (config /= off) |> Maybe.withDefault HtmlA.nothing
                        , if readOnly then
                            WlA.disabled

                          else
                            HtmlE.onCheck (\c -> Maybe.justIf c on |> Maybe.withDefault off |> opt.set wrap)
                        , WlA.disabled |> Maybe.justIf (not canEdit) |> Maybe.withDefault HtmlA.nothing
                        ]
                        |> Just

                Nothing ->
                    Nothing
    in
    [ switch
    , Just primaryEditor
    , opt.extraEditor wrap model config
    ]
        |> List.filterMap identity
