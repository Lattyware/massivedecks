module MassiveDecks.Pages.Lobby.Configure.Component exposing
    ( Component(..)
    , Value
    , equal
    , group
    , indentedGroup
    , isValid
    , lift
    , liftConfig
    , update
    , validate
    , value
    , view
    )

import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Components.Form.Message exposing (Message)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Component.Validator exposing (Validator)
import MassiveDecks.Pages.Lobby.Configure.ConfigOption as ConfigOption
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Maybe as Maybe


group : id -> Maybe MdString -> List (Component config model id iMsg msg) -> Component config model id iMsg msg
group id title children =
    G { id = id, title = title, indent = False, children = children }


indentedGroup : id -> List (Component config model id iMsg msg) -> Component config model id iMsg msg
indentedGroup id children =
    G { id = id, title = Nothing, indent = True, children = children }


value :
    id
    -> (Validator config iMsg msg -> ConfigOption.ViewArgs model config iMsg msg -> Html msg)
    -> (config -> Bool)
    -> Validator config iMsg msg
    -> Component config model id iMsg msg
value id v d val =
    V
        { id = id
        , view = v val
        , disabled = d
        , validate = val
        , equal = (==)
        , update = \new -> \_ -> new
        }


type Component config model id iMsg msg
    = V (Value config model id iMsg msg)
    | G (Group config model id iMsg msg)


view : Component config model id iMsg msg -> (iMsg -> msg) -> Shared -> model -> config -> config -> msg -> Bool -> ConfigOption.RenderMode -> Maybe (Html msg)
view component wrap shared model local remote noOp canEdit renderMode =
    case component of
        V v ->
            let
                disabled =
                    case renderMode of
                        ConfigOption.Local ->
                            v.disabled local

                        ConfigOption.Remote ->
                            v.disabled remote

                        ConfigOption.Diff ->
                            v.disabled local && v.disabled remote
            in
            v.view (ConfigOption.ViewArgs wrap shared model local remote noOp canEdit renderMode)
                |> Maybe.justIf (disabled |> not)

        G { title, indent, children } ->
            let
                content =
                    children |> List.filterMap (\c -> view c wrap shared model local remote noOp canEdit renderMode)
            in
            if List.isEmpty content then
                Nothing

            else
                Html.section
                    [ HtmlA.classList [ ( "indent", indent ) ] ]
                    (List.filterMap identity
                        [ title |> Maybe.map (\t -> Html.h3 [] [ t |> Lang.html shared ])
                        , Html.div [] content |> Just
                        ]
                    )
                    |> Just


equal : Component config model id iMsg msg -> config -> config -> Bool
equal component a b =
    case component of
        V v ->
            v.equal a b

        G { children } ->
            children |> List.all (\c -> equal c a b)


validate : (iMsg -> msg) -> Component config model id iMsg msg -> config -> List ( Component config model id iMsg msg, List (Message msg) )
validate wrap component config =
    case component of
        V v ->
            let
                problems =
                    v.validate wrap config
            in
            if problems |> List.isEmpty then
                []

            else
                [ ( component, problems ) ]

        G { children } ->
            children |> List.concatMap (\c -> validate wrap c config)


isValid : Component config model id iMsg iMsg -> config -> Bool
isValid c config =
    validate identity c config |> List.isEmpty


update : Component config model id iMsg msg -> config -> config -> config
update component new base =
    case component of
        V v ->
            v.update new base

        G { children } ->
            children |> List.foldl (\c -> \cfg -> update c new cfg) base


liftConfig : (pConfig -> cConfig) -> (cConfig -> pConfig -> pConfig) -> Component cConfig model id iMsg msg -> Component pConfig model id iMsg msg
liftConfig extract insert component =
    lift identity identity extract insert identity component


lift : (cId -> pId) -> (cMsg -> pMsg) -> (pConfig -> cConfig) -> (cConfig -> pConfig -> pConfig) -> (pModel -> cModel) -> Component cConfig cModel cId cMsg msg -> Component pConfig pModel pId pMsg msg
lift wrapId wrap extractConfig insertConfig extractModel component =
    case component of
        V v ->
            V
                { id = wrapId v.id
                , view = \args -> v.view (liftViewArgs wrap extractConfig extractModel args)
                , disabled = extractConfig >> v.disabled
                , validate = \w -> \c -> v.validate (wrap >> w) (extractConfig c)
                , equal = \old -> \new -> v.equal (extractConfig old) (extractConfig new)
                , update = \new -> \old -> insertConfig (v.update (extractConfig new) (extractConfig old)) old
                }

        G { id, title, indent, children } ->
            G
                { id = wrapId id
                , title = title
                , indent = indent
                , children = children |> List.map (lift wrapId wrap extractConfig insertConfig extractModel)
                }


liftViewArgs : (cMsg -> pMsg) -> (pConfig -> cConfig) -> (pModel -> cModel) -> ConfigOption.ViewArgs pModel pConfig pMsg msg -> ConfigOption.ViewArgs cModel cConfig cMsg msg
liftViewArgs w extractConfig extractModel { wrap, shared, model, local, remote, noOp, canEdit, renderMode } =
    { wrap = w >> wrap
    , shared = shared
    , model = extractModel model
    , local = extractConfig local
    , remote = extractConfig remote
    , renderMode = renderMode
    , noOp = noOp
    , canEdit = canEdit
    }



{- Private -}


type alias Value config model id iMsg msg =
    { id : id
    , view : ConfigOption.ViewArgs model config iMsg msg -> Html msg
    , disabled : config -> Bool
    , validate : Validator config iMsg msg
    , equal : config -> config -> Bool
    , update : config -> config -> config
    }


type alias Group config model id iMsg msg =
    { id : id
    , title : Maybe MdString
    , indent : Bool
    , children : List (Component config model id iMsg msg)
    }
