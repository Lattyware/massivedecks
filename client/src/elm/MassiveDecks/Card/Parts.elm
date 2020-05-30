module MassiveDecks.Card.Parts exposing
    ( Fills
    , Part(..)
    , Parts
    , Style(..)
    , Transform(..)
    , fillsFromPlay
    , fromList
    , isSlot
    , missingSlotIndices
    , slotCount
    , unsafeFromList
    , view
    , viewFilled
    , viewFilledString
    , viewLinesString
    )

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as HtmlA
import List.Extra as List
import Set exposing (Set)


{-| A transform to apply to the value in a slot.
-}
type Transform
    = NoTransform
    | UpperCase
    | Capitalize


{-| A style to be applied to some text.
-}
type Style
    = NoStyle
    | Em


{-| A part of a call's text. This is either just text or a position for a call to be inserted in-game.
-}
type Part
    = Text String Style
    | Slot Int Transform Style


{-| Represents a line as a part of a part. Between each one the text will be forced to line break.
-}
type alias Line =
    List Part


{-| A collection of strings to fill the slots in a card.
-}
type alias Fills =
    Dict Int String


{-| A collection of `Line`s. It is guaranteed to have at least one `Slot`.
-}
type Parts
    = Parts (List Line)


{-| A predicate checking if a part is a slot.
-}
isSlot : Part -> Bool
isSlot part =
    case part of
        Slot _ _ _ ->
            True

        _ ->
            False


{-| Construct a `Parts` from a `List` of `Line`s. This will fail if there is not at least one `Slot`.
-}
fromList : List Line -> Result String Parts
fromList lines =
    let
        indicesList =
            lines |> List.concat |> List.filterMap slotIndex

        indices =
            indicesList |> Set.fromList
    in
    if Set.isEmpty indices then
        Err "Must contain at least one slot."

    else
        let
            max =
                indicesList |> List.maximum |> Maybe.withDefault 0

            expect =
                List.range 0 max |> Set.fromList
        in
        if expect == indices then
            Ok (Parts lines)

        else
            let
                missing =
                    Set.diff expect indices

                missingStr =
                    missing |> Set.toList |> List.map String.fromInt |> String.join ", "
            in
            "Gap in given slot indexes, missing: " ++ missingStr |> Err


{-| Construct without checking for at least one `Slot`. This is designed for use with fake cards or the editor where
that guarantee isn't important.
-}
unsafeFromList : List Line -> Parts
unsafeFromList lines =
    Parts lines


{-| The number of `Slot`s with distinct indexes in the `Parts`. This will be one or more.
-}
slotCount : Parts -> Int
slotCount (Parts lines) =
    lines |> List.concat |> List.filterMap slotIndex |> Set.fromList |> Set.size


{-| Render the `Parts` to HTML.
-}
view : Parts -> List (Html msg)
view parts =
    viewFilled Dict.empty parts


{-| Render the `Parts` to a string.
-}
viewFilledString : String -> Fills -> Parts -> String
viewFilledString blankString play (Parts lines) =
    viewLinesString blankString play lines


{-| Render the `Parts` with slots filled with the given values.
-}
viewFilled : Fills -> Parts -> List (Html msg)
viewFilled play (Parts lines) =
    viewLines play lines


{-| Render lines to a string without needing a complete parts.
-}
viewLinesString : String -> Fills -> List (List Part) -> String
viewLinesString blankPhrase fills lines =
    let
        viewPartString part =
            case part of
                Slot index _ _ ->
                    fills |> Dict.get index |> Maybe.withDefault blankPhrase

                Text t _ ->
                    t

        viewLineString line =
            line |> List.map viewPartString |> String.concat
    in
    lines |> List.map viewLineString |> String.join "\n"


{-| Get fills from a given play.
-}
fillsFromPlay : List { a | body : String } -> Fills
fillsFromPlay play =
    play |> List.indexedMap (\i r -> ( i, r.body )) |> Dict.fromList


{-| Get the indices for slots that are not filled by the given fills.
-}
missingSlotIndices : Dict Int a -> Parts -> Set Int
missingSlotIndices fills (Parts lines) =
    let
        expect =
            lines |> List.concat |> List.filterMap slotIndex |> Set.fromList

        filled =
            fills |> Dict.keys |> Set.fromList
    in
    Set.diff expect filled



{- Private -}


slotIndex : Part -> Maybe Int
slotIndex part =
    case part of
        Slot i _ _ ->
            Just i

        _ ->
            Nothing


{-| Split down to minimal parts, so we can figure out where we should be breaking.
-}
explode : Part -> List Part
explode part =
    case part of
        Text string style ->
            string |> String.toList |> List.map (\c -> Text (String.fromChar c) style)

        Slot index transform style ->
            [ Slot index transform style ]


{-| Concentrate parts back down to the least possible separate parts.
-}
minimise : List Part -> List Part
minimise parts =
    let
        canBeCombined a b =
            case a of
                Text _ sa ->
                    case b of
                        Text _ sb ->
                            sa == sb

                        _ ->
                            False

                _ ->
                    False

        getText a =
            case a of
                Text t _ ->
                    Just t

                _ ->
                    Nothing

        combine ( first, rest ) =
            case first of
                Text t s ->
                    Text (t ++ (rest |> List.filterMap getText |> String.concat)) s

                _ ->
                    first
    in
    parts |> List.groupWhile canBeCombined |> List.map combine


{-| Group parts by if they should be tied into the same line where possible.
-}
cluster : List Part -> List (List Part)
cluster parts =
    let
        ifBroken c =
            if c == " " then
                False

            else
                True

        isCluster a b =
            case a of
                Text c _ ->
                    case b of
                        Text _ _ ->
                            ifBroken c

                        Slot _ _ _ ->
                            ifBroken c

                Slot _ _ _ ->
                    case b of
                        Text c _ ->
                            ifBroken c

                        _ ->
                            False
    in
    parts |> List.concatMap explode |> List.groupWhile isCluster |> List.map ((\( h, t ) -> h :: t) >> minimise)


viewPart : Fills -> Part -> Html msg
viewPart fills part =
    let
        styleToElement style =
            case style of
                NoStyle ->
                    Html.span

                Em ->
                    Html.em

        transformToAttrs transform =
            case transform of
                NoTransform ->
                    []

                UpperCase ->
                    [ HtmlA.class "upper-case" ]

                Capitalize ->
                    [ HtmlA.class "capitalize" ]
    in
    case part of
        Text text style ->
            styleToElement style [ HtmlA.class "text" ] [ Html.text text ]

        Slot index transform style ->
            let
                ( fillState, fill ) =
                    case fills |> Dict.get index of
                        Just text ->
                            ( HtmlA.class "filled", [ Text text NoStyle ] |> cluster |> List.concatMap (viewCluster fills) )

                        Nothing ->
                            ( HtmlA.class "empty", [] )

                attrs =
                    List.concat
                        [ [ HtmlA.class "slot", fillState, HtmlA.attribute "data-slot-index" (index + 1 |> String.fromInt) ]
                        , transformToAttrs transform
                        ]
            in
            styleToElement style attrs fill


viewCluster : Fills -> List Part -> List (Html msg)
viewCluster fills c =
    case c of
        [] ->
            []

        first :: [] ->
            [ viewPart fills first ]

        many ->
            let
                isEmptySlot part =
                    case part of
                        Slot index _ _ ->
                            fills |> Dict.member index |> not

                        _ ->
                            False

                growthAttrs =
                    if c |> List.any isEmptySlot then
                        [ HtmlA.class "grow" ]

                    else
                        []
            in
            [ Html.span (HtmlA.class "cluster" :: growthAttrs) (many |> List.map (viewPart fills)) ]


viewLine : Fills -> List Part -> Html msg
viewLine fills line =
    Html.p [] (line |> cluster |> List.concatMap (viewCluster fills))


viewLines : Fills -> List (List Part) -> List (Html msg)
viewLines fills =
    List.map (viewLine fills)
