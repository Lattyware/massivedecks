module MassiveDecks.Pages.Lobby.Configure.ConfigOption exposing
    ( ConfigOption
    , IntBounds
    , PrimaryEditor(..)
    , RenderMode(..)
    , ViewArgs
    , intEditor
    , maybeEditor
    , noExtraEditor
    , toMinMaxAttrs
    , toValidator
    , view
    , wrappedSetter
    )

import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Components.Form as Form
import MassiveDecks.Components.Form.Message exposing (Message)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Component.Validator as Validator exposing (Validator)
import MassiveDecks.Pages.Lobby.Configure.ConfigOption.Toggleable exposing (Toggleable)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Maybe as Maybe
import Material.Switch as Material
import Material.TextField as TextField


type alias Model model config =
    { model | localConfig : config }


type alias ConfigOption model config iMsg msg =
    { id : String
    , toggleable : Toggleable config
    , primaryEditor : model -> PrimaryEditor config msg
    , extraEditor : (iMsg -> msg) -> Shared -> model -> config -> Maybe (Html msg)
    , set : (iMsg -> msg) -> config -> msg
    , messages : (iMsg -> msg) -> List (Message msg)
    }


type PrimaryEditor value msg
    = TextField
        { placeholder : MdString
        , inputType : TextField.Type
        , toString : value -> Maybe String
        , fromString : String -> Maybe value
        , attrs : List (Html.Attribute msg)
        }
    | Label { text : MdString }


intEditor : MdString -> List (Html.Attribute msg) -> PrimaryEditor Int msg
intEditor placeholder attrs =
    TextField
        { placeholder = placeholder
        , inputType = TextField.Number
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


noExtraEditor : (iMsg -> msg) -> Shared -> model -> config -> Maybe (Html msg)
noExtraEditor _ _ _ _ =
    Nothing


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


{-| Boundaries for an integer value.
-}
type alias IntBounds =
    { min : Int
    , max : Int
    }


{-| Convert bounds to min/max HTML attributes.
-}
toMinMaxAttrs : IntBounds -> List (Html.Attribute msg)
toMinMaxAttrs { min, max } =
    [ min |> String.fromInt |> HtmlA.min
    , max |> String.fromInt |> HtmlA.max
    ]


{-| Convert bounds to a validator.
-}
toValidator : IntBounds -> (Int -> iMsg) -> Validator Int iMsg msg
toValidator { min, max } =
    Validator.between min max



{- Private -}


viewContents : ConfigOption model config optionMsg msg -> (optionMsg -> msg) -> Shared -> model -> msg -> Bool -> Bool -> config -> List (Html msg)
viewContents opt wrap shared model noOp canEdit readOnly config =
    let
        ( switch, toggle, id ) =
            case opt.toggleable of
                Just { off, on } ->
                    let
                        i =
                            opt.id ++ "-swtich"

                        t =
                            Maybe.justIf (config == off) on |> Maybe.withDefault off |> opt.set wrap

                        s =
                            Material.view
                                [ HtmlA.checked (config /= off)
                                , if readOnly || not canEdit then
                                    HtmlA.disabled True

                                  else
                                    HtmlE.onCheck (\c -> Maybe.justIf c on |> Maybe.withDefault off |> opt.set wrap)
                                , HtmlA.id i
                                ]
                    in
                    ( Just s, t |> Maybe.justIf (not readOnly && canEdit), Just i )

                Nothing ->
                    ( Nothing, Nothing, Nothing )

        primaryEditor =
            case opt.primaryEditor model of
                TextField { placeholder, inputType, toString, fromString, attrs } ->
                    let
                        toggleableAndOff =
                            opt.toggleable |> Maybe.map (.off >> (==) config) |> Maybe.withDefault False
                    in
                    TextField.view shared
                        placeholder
                        inputType
                        (config |> toString |> Maybe.withDefault "")
                        (List.filterMap identity
                            [ HtmlA.class "primary" |> Just
                            , if readOnly then
                                HtmlA.readonly True |> Just

                              else
                                fromString
                                    >> Maybe.map (opt.set wrap)
                                    >> Maybe.withDefault noOp
                                    |> HtmlE.onInput
                                    |> Just
                            , HtmlA.disabled True |> Maybe.justIf toggleableAndOff
                            , toggle |> Maybe.andThen (Maybe.justIf toggleableAndOff) |> Maybe.map HtmlE.onClick
                            , True |> HtmlA.disabled |> Maybe.justIf (not canEdit)
                            ]
                            ++ attrs
                        )

                Label { text } ->
                    Html.label
                        (List.filterMap identity
                            [ HtmlA.class "primary" |> Just
                            , toggle |> Maybe.map HtmlE.onClick
                            , id |> Maybe.map HtmlA.for
                            ]
                        )
                        [ text |> Lang.html shared ]
    in
    [ switch
    , Just primaryEditor
    , opt.extraEditor wrap shared model config
    ]
        |> List.filterMap identity
