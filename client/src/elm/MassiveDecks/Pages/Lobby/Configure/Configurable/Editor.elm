module MassiveDecks.Pages.Lobby.Configure.Configurable.Editor exposing
    ( Def
    , Editor
    , EditorArgs
    , bool
    , group
    , int
    , map
    , maybe
    , password
    , string
    , toggle
    )

import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html.Events as HtmlE
import MassiveDecks.Util.Maybe as Maybe
import MassiveDecks.Util.NeList as NeList
import Material.IconButton as IconButton
import Material.Switch as Switch
import Material.TextField as TextField


type alias EditorArgs =
    { shared : Shared
    , readOnly : Bool
    }


type alias Def value model msg =
    msg -> (value -> msg) -> Editor value model msg


type alias Editor value model msg =
    model -> Maybe value -> EditorArgs -> List (Html msg)


maybe : value -> Def value model msg -> Def (Maybe value) model msg
maybe default base noOp update model value args =
    let
        { shared, readOnly } =
            args

        ( checked, disabled ) =
            case value of
                Just v ->
                    ( v /= Nothing, False )

                Nothing ->
                    ( False, True )
    in
    Switch.view
        [ checked |> HtmlA.checked
        , if readOnly || disabled then
            HtmlA.disabled True

          else
            HtmlE.onCheck (\c -> default |> Maybe.justIf c |> update)
        ]
        :: base noOp (Just >> update) model (value |> Maybe.andThen identity) args


bool : MdString -> Def Bool model msg
bool label _ update _ value { shared, readOnly } =
    let
        disabled =
            readOnly || value == Nothing

        labelClick =
            value |> Maybe.andThen (Maybe.justIf (not disabled)) |> Maybe.map (not >> update >> HtmlE.onClick)
    in
    [ Html.label
        (List.filterMap identity
            [ labelClick
            , HtmlA.class "primary" |> Just
            ]
        )
        [ Switch.view
            [ value |> Maybe.withDefault False |> HtmlA.checked
            , if disabled then
                HtmlA.disabled True

              else
                HtmlE.onCheckNoPropagation update
            ]
        , label |> Lang.html shared
        ]
    ]


toggle : MdString -> value -> Def (Maybe value) model msg
toggle label default =
    bool label |> map ((/=) Nothing) (\b -> default |> Maybe.justIf b)


map : (a -> b) -> (b -> a) -> Def b model msg -> Def a model msg
map f g base noOp update model value args =
    let
        mappedUpdate updated =
            update (g updated)

        mappedValue =
            value |> Maybe.map f
    in
    base noOp mappedUpdate model mappedValue args


string : MdString -> Def String model msg
string label _ update _ value { shared, readOnly } =
    [ TextField.view shared
        label
        TextField.Text
        (value |> Maybe.withDefault "")
        [ if readOnly || value == Nothing then
            HtmlA.disabled True

          else
            HtmlE.onInput update
        , HtmlA.class "primary"
        ]
    ]


int : MdString -> Def Int model msg
int label noOp update _ value { shared, readOnly } =
    [ TextField.view shared
        label
        TextField.Number
        (value |> Maybe.withDefault 0 |> String.fromInt)
        [ if readOnly || value == Nothing then
            HtmlA.disabled True

          else
            HtmlE.onInput (String.toInt >> Maybe.map update >> Maybe.withDefault noOp)
        , HtmlA.class "primary"
        ]
    ]


group : Maybe MdString -> Bool -> Bool -> List (Html msg) -> Def config model msg
group title indent shouldFold children _ _ _ value { shared, readOnly } =
    let
        node =
            case title of
                Just _ ->
                    Html.section

                Nothing ->
                    Html.div

        folded =
            shouldFold && value == Nothing
    in
    [ node
        [ HtmlA.classList [ ( "indent", indent ), ( "primary", True ), ( "folded", folded ) ] ]
        (List.filterMap identity
            [ title |> Maybe.map (\t -> Html.h3 [] [ t |> Lang.html shared ])
            , Html.div [ HtmlA.class "form-group" ] children |> Just
            ]
        )
    ]


password : (Bool -> msg) -> MdString -> Def String { model | passwordVisible : Bool } msg
password setPasswordVisibility label _ update model value { shared, readOnly } =
    let
        ( icon, type_ ) =
            if model.passwordVisible then
                ( Icon.eyeSlash, TextField.Text )

            else
                ( Icon.eye, TextField.Password )

        toggleVisibility =
            IconButton.view shared
                Strings.LobbyPassword
                (icon |> Icon.present |> NeList.just)
                (model.passwordVisible |> not |> setPasswordVisibility |> Just)
    in
    [ TextField.view shared
        label
        type_
        (value |> Maybe.withDefault "")
        [ if readOnly || (value == Nothing) then
            HtmlA.disabled True

          else
            HtmlE.onInput update
        , HtmlA.class "primary"
        ]
    , toggleVisibility
    ]
