module MassiveDecks.Pages.Lobby.Configure.Configurable exposing
    ( apply
    , equals
    , getById
    , group
    , id
    , isValid
    , set
    , value
    , viewDiff
    , viewEditor
    , wrap
    , wrapAsToggle
    , wrapMaybe
    )

import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Components.Form.Message as Message
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Configurable.Editor exposing (Editor)
import MassiveDecks.Pages.Lobby.Configure.Configurable.Model exposing (..)
import MassiveDecks.Util.Maybe as Maybe


wrapMaybe : Configurable id value model msg -> Configurable id (Maybe value) model msg
wrapMaybe =
    wrap identity identity (\v _ -> Just v)


wrapAsToggle : value -> Configurable id Bool model msg -> Configurable id (Maybe value) model msg
wrapAsToggle default =
    wrap identity (\v -> Just (v /= Nothing)) (\v p -> p |> Maybe.withDefault default |> Maybe.justIf v)


wrap : (id -> pId) -> (pV -> Maybe value) -> (value -> pV -> pV) -> Configurable id value model msg -> Configurable pId pV model msg
wrap wrapId getter setter node =
    apply (Wrap wrapId getter setter) node


apply : Wrap pId pV id value -> Configurable id value model msg -> Configurable pId pV model msg
apply w node globalWrap =
    let
        { update, config, noOp } =
            globalWrap

        wrappedUpdate i v =
            config |> Maybe.map (\c -> update (w.id i) (w.set v c)) |> Maybe.withDefault noOp
    in
    case node { noOp = noOp, config = config |> Maybe.andThen w.get, update = wrappedUpdate } of
        C c ->
            let
                wrappedId =
                    w.id c.id

                internalSetTarget target new old =
                    if wrappedId == target then
                        new |> w.get |> Maybe.map (\n -> w.set n old) |> Maybe.withDefault old

                    else
                        old

                internalEquals a b =
                    let
                        x =
                            w.get a

                        y =
                            w.get b
                    in
                    (x == Nothing && y == Nothing) || (Maybe.map2 c.equals x y |> Maybe.withDefault False)
            in
            C
                { id = wrappedId
                , editor = \m -> \v -> c.editor m (v |> Maybe.andThen w.get)
                , validator = \pv -> pv |> w.get |> Maybe.map c.validator |> Maybe.withDefault []
                , equals = internalEquals
                , setTarget = internalSetTarget
                , children = c.children |> List.map (\child -> apply w (\_ -> child) globalWrap)
                , messages = \pv -> pv |> Maybe.andThen w.get |> c.messages
                , isOption = c.isOption
                }


value : Value id value model msg -> Configurable id value model msg
value v globalWrap =
    let
        updateWithId =
            globalWrap.update v.id

        internalSetTarget i n o =
            if i == v.id then
                n

            else
                o
    in
    C
        { id = v.id
        , editor = \m val -> v.editor globalWrap.noOp updateWithId m val
        , validator = v.validator updateWithId
        , equals = (==)
        , setTarget = internalSetTarget
        , children = []
        , messages = v.messages
        , isOption = True
        }


group : Group id value model msg -> Configurable id value model msg
group g globalWrap =
    let
        updateWithId =
            globalWrap.update g.id

        components =
            g.children |> List.map (\c -> c globalWrap)

        editorWithChildren m v args =
            let
                { shared, readOnly } =
                    args

                child (C { editor, validator, messages, isOption }) =
                    let
                        e =
                            editor m v args
                    in
                    if isOption then
                        [ configOption shared e ((v |> Maybe.map validator |> Maybe.withDefault []) ++ messages v) ]

                    else
                        e

                childEditors =
                    components |> List.concatMap child
            in
            g.editor childEditors globalWrap.noOp updateWithId m v args

        setChildTarget target new base =
            components |> List.foldl (\(C c) -> \cfg -> c.setTarget target new cfg) base
    in
    C
        { id = g.id
        , editor = editorWithChildren
        , validator = \v -> components |> List.concatMap (\(C c) -> c.validator v)
        , equals = \a b -> components |> List.all (\(C c) -> c.equals a b)
        , setTarget = setChildTarget
        , children = components
        , messages = always []
        , isOption = False
        }


getById : Component id value model msg -> id -> Maybe (Component id value model msg)
getById component target =
    case component of
        C c ->
            if c.id == target then
                Just component

            else
                let
                    find components =
                        case components of
                            first :: rest ->
                                case getById first target of
                                    Just found ->
                                        Just found

                                    Nothing ->
                                        find rest

                            [] ->
                                Nothing
                in
                find c.children


isValid : Component id value model msg -> value -> Bool
isValid (C { validator }) =
    validator >> List.isEmpty


set : Component id value model msg -> value -> value -> value
set (C c) =
    c.setTarget c.id


viewEditor : Component id config model msg -> Shared -> model -> config -> Bool -> List (Html msg)
viewEditor (C { editor, validator, messages, isOption }) shared model local canEdit =
    let
        e =
            editor model (Just local) { shared = shared, readOnly = not canEdit }
    in
    if isOption then
        [ configOption shared e (validator local ++ messages (Just local)) ]

    else
        e


viewDiff : Component id config model msg -> Shared -> model -> config -> config -> Html msg
viewDiff (C { editor, messages, validator, isOption }) shared model local remote =
    configOption shared
        [ Html.div [ HtmlA.class "local" ]
            (editor model (Just local) { shared = shared, readOnly = False })
        , Html.div [ HtmlA.class "remote" ]
            (editor model (Just remote) { shared = shared, readOnly = True })
        ]
        (validator local ++ messages (Just local))


id : Component id value model msg -> id
id (C c) =
    c.id


equals : Component id value model msg -> value -> value -> Bool
equals (C c) =
    c.equals



{- Private -}


configOption : Shared -> List (Html msg) -> List (Message.Message msg) -> Html msg
configOption shared control messages =
    Html.div [ HtmlA.class "config-option" ]
        (Html.div [ HtmlA.class "control" ] control :: (messages |> List.filterMap (Message.view shared)))
