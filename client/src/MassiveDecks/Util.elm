module MassiveDecks.Util exposing (..)

import Json.Decode as Json
import Task exposing (Task)
import String
import Process
import Time exposing (Time)
import Html exposing (..)
import Html.Keyed as Keyed
import Html.Events exposing (..)


{-| Since a value of `Never` can never exist, this can't ever actually happen. Used to fill gaps where the type system
requires a method, but it'll never get called.
-}
impossible : Never -> a
impossible n =
    impossible n


{-| Add an item to a list if the value is not nothing.
-}
andMaybe : Maybe a -> List a -> List a
andMaybe maybeExtra values =
    List.append values (Maybe.map (\value -> [ value ]) maybeExtra |> Maybe.withDefault [])


or : Maybe a -> Maybe a -> Maybe a
or a b =
    case a of
        Just _ ->
            a

        Nothing ->
            b


{-| Give the first value from the list that matches the given condition. If none do, return `Nothing`.
-}
find : (a -> Bool) -> List a -> Maybe a
find check items =
    List.filter check items
        |> List.head


{-| Take two lists and inteleave them into each other. The first element will come from the second list.
-}
interleave : List a -> List a -> List a
interleave list1 list2 =
    case list1 of
        [] ->
            list2

        x :: xs ->
            case list2 of
                [] ->
                    list1

                y :: ys ->
                    y :: x :: interleave xs ys


{-| An url to a lobby from the base url and the lobby id.
-}
lobbyUrl : String -> String -> String
lobbyUrl url lobbyId =
    url ++ "#" ++ lobbyId


{-| Create a command that just sends the given message instantly.
-}
cmd : msg -> Cmd msg
cmd message =
    Task.perform identity (Task.succeed message)


{-| Chains two updates together to produce a single update.
-}
(:>) : (model -> ( model, Cmd msg )) -> (model -> ( model, Cmd msg )) -> model -> ( model, Cmd msg )
(:>) a b model =
    let
        ( aModel, aMsg ) =
            a model

        ( bModel, bMsg ) =
            b aModel
    in
        bModel ! [ aMsg, bMsg ]


{-| Reduce the list to the given indices, and give those indicies with the elements.
-}
getAllWithIndex : List a -> List Int -> List ( Int, a )
getAllWithIndex list indices =
    getAll (List.indexedMap (,) list) indices


{-| Reduce the list to the given indices.
-}
getAll : List a -> List Int -> List a
getAll list indices =
    List.filterMap (get list) indices


{-| Get the element at the given index, or nothing.
-}
get : List a -> Int -> Maybe a
get list index =
    case List.drop index list of
        [] ->
            Nothing

        item :: _ ->
            Just item


{-| Make the first character of the string uppercase.
-}
firstLetterToUpper : String -> String
firstLetterToUpper str =
    (String.toUpper (String.left 1 str)) ++ (String.dropLeft 1 str)


{-| map over the first element of a list only, returning the rest as-is.
-}
mapFirst : (a -> a) -> List a -> List a
mapFirst f xs =
    List.indexedMap
        (\index x ->
            if index == 0 then
                f x
            else
                x
        )
        xs


{-| Get "has" or "have" as appropriate for the given number of items.
-}
pluralHas : List a -> String
pluralHas items =
    case List.length items of
        1 ->
            "has"

        _ ->
            "have"


{-| Join the given strings together with commas and spacing, as in a list, adding an 'and' between the last two
elements.
-}
joinWithAnd : List String -> Maybe String
joinWithAnd items =
    case items of
        [] ->
            Nothing

        head :: [] ->
            Just head

        first :: second :: [] ->
            Just (first ++ " and " ++ second)

        head :: rest ->
            Just (head ++ ", " ++ (joinWithAnd rest |> Maybe.withDefault ""))


{-| Apply every function in the list to the given element.
-}
apply : List (a -> b) -> a -> List b
apply fs value =
    List.map (\f -> f value) fs


{-| Perform a task after a given period of time.
-}
after : Time -> Task x a -> Task x a
after waitFor task =
    Process.sleep waitFor |> Task.andThen (\_ -> task)


{-| Check if a Maybe is Nothing.
-}
isNothing : Maybe a -> Bool
isNothing m =
    case m of
        Just _ ->
            False

        Nothing ->
            True


{-| Add an event handler for keyboard key presses.
-}
onKeyDown : String -> msg -> msg -> Attribute msg
onKeyDown key message noOp =
    on "keydown"
        (Json.at [ "key" ] Json.string
            |> Json.map
                (\pressed ->
                    if pressed == key then
                        message
                    else
                        noOp
                )
        )


{-| Perform an action on click, only if the id of the clicked element matches (i.e: only on click for a given element
in the tree).
-}
onClickIfId : String -> msg -> msg -> Attribute msg
onClickIfId targetId message noOp =
    on "click"
        (ifIdDecoder
            |> Json.map
                (\clickedId ->
                    if clickedId == targetId then
                        message
                    else
                        noOp
                )
        )


ifIdDecoder : Json.Decoder String
ifIdDecoder =
    Json.at [ "target", "id" ] Json.string


{-| Create a tbody where each row is keyed.
-}
tbody : List (Attribute msg) -> List ( String, Html msg ) -> Html msg
tbody =
    Keyed.node "tbody"
