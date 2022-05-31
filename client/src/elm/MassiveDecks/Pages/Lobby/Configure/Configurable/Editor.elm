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

import FontAwesome as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Icon as Icon
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Maybe as Maybe
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
        { readOnly } =
            args

        ( selected, disabled ) =
            case value of
                Just v ->
                    ( v /= Nothing, False )

                Nothing ->
                    ( False, True )

        updateWithNewValue v =
            if v then
                default |> Just |> update

            else
                Nothing |> update
    in
    Switch.view
        Html.nothing
        selected
        (updateWithNewValue |> Maybe.justIf (not (readOnly || disabled)))
        :: base noOp (Just >> update) model (value |> Maybe.andThen identity) args


bool : MdString -> Def Bool model msg
bool label _ update _ value { shared, readOnly } =
    let
        disabled =
            readOnly || value == Nothing

        selected =
            value |> Maybe.withDefault False
    in
    [ Switch.viewWithAttrs
        (label |> Lang.html shared)
        selected
        (update |> Maybe.justIf (not disabled))
        [ HtmlA.class "primary" ]
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
    [ TextField.viewWithAttrs
        (label |> Lang.string shared)
        TextField.Text
        (value |> Maybe.withDefault "")
        (update |> Maybe.justIf (not (readOnly || (value == Nothing))))
        [ HtmlA.class "primary" ]
    ]


int : MdString -> Def Int model msg
int label noOp update _ value { shared, readOnly } =
    [ TextField.viewWithAttrs
        (label |> Lang.string shared)
        TextField.Number
        (value |> Maybe.withDefault 0 |> String.fromInt)
        ((String.toInt >> Maybe.map update >> Maybe.withDefault noOp) |> Maybe.justIf (not (readOnly || (value == Nothing))))
        [ HtmlA.class "primary" ]
    ]


group : String -> Maybe MdString -> Bool -> Bool -> List (Html msg) -> Def config model msg
group id title indent shouldFold children _ _ _ value { shared } =
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
        [ HtmlA.id id, HtmlA.classList [ ( "indent", indent ), ( "primary", True ), ( "folded", folded ) ] ]
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
                ( Icon.hide, TextField.Text )

            else
                ( Icon.show, TextField.Password )

        toggleVisibility =
            IconButton.view
                (icon |> Icon.view)
                (Strings.LobbyPassword |> Lang.string shared)
                (model.passwordVisible |> not |> setPasswordVisibility |> Just)
    in
    [ TextField.viewWithAttrs
        (label |> Lang.string shared)
        type_
        (value |> Maybe.withDefault "")
        (update |> Maybe.justIf (not (readOnly || (value == Nothing))))
        [ HtmlA.class "primary" ]
    , toggleVisibility
    ]
