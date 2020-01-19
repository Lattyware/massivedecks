module MassiveDecks.Animated exposing
    ( Animated
    , Msg(..)
    , State
    , animate
    , defaultDuration
    , enterAfter
    , exitAfter
    , subscriptions
    , update
    , view
    )

import Browser.Events as BrowserEvents
import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Util.Cmd as Cmd


{-| If given, removeDone will return a model with items that are done removed. The value given is the duration of the
exiting animation.
-}
type alias Settings =
    { removeDone : Maybe Int
    }


{-| The state of the animated item.
-}
type State
    = New
    | Entering
    | Exiting


{-| An animated item.
-}
type alias Animated item =
    { item : item
    , state : State
    }


type Msg item
    = Enter item
    | Exit item
    | Remove item


type alias Model item =
    List (Animated item)


subscriptions : (Msg item -> msg) -> Model item -> Sub msg
subscriptions wrap model =
    model |> List.filterMap (subscription wrap) |> Sub.batch


view : (Html.Attribute msg -> item -> Html msg) -> Animated item -> Html msg
view render item =
    render (class item.state) item.item


update : (Msg item -> msg) -> Settings -> Msg item -> Model item -> ( Model item, Cmd msg )
update wrap settings msg model =
    case msg of
        Enter item ->
            ( model |> List.map (setState Entering item), Cmd.none )

        Exit item ->
            ( model |> List.map (setState Exiting item)
            , settings.removeDone
                |> Maybe.map (\after -> Remove item |> wrap |> Cmd.after after)
                |> Maybe.withDefault Cmd.none
            )

        Remove item ->
            ( model |> List.filter (\i -> item /= i.item), Cmd.none )


animate : item -> Animated item
animate item =
    { state = New
    , item = item
    }


enterAfter : (Msg item -> msg) -> Int -> item -> Cmd msg
enterAfter wrap milliseconds item =
    Enter item |> wrap |> Cmd.after milliseconds


exitAfter : (Msg item -> msg) -> Int -> item -> Cmd msg
exitAfter wrap milliseconds item =
    Exit item |> wrap |> Cmd.after milliseconds


{-| If changed, sync to CSS.
-}
defaultDuration : Int
defaultDuration =
    200



{- Private -}


subscription : (Msg item -> msg) -> Animated item -> Maybe (Sub msg)
subscription wrap item =
    if item.state == New then
        BrowserEvents.onAnimationFrame (always (Enter item.item |> wrap)) |> Just

    else
        Nothing


setState : State -> item -> Animated item -> Animated item
setState state target item =
    if item.item == target then
        { item | state = state }

    else
        item


class : State -> Html.Attribute msg
class state =
    case state of
        New ->
            HtmlA.classList [ ( "animation", True ) ]

        Entering ->
            HtmlA.classList [ ( "animation", True ), ( "entering", True ) ]

        Exiting ->
            HtmlA.classList [ ( "animation", True ), ( "exiting", True ) ]
