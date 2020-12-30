module MassiveDecks.Card.Parts exposing
    ( Fills
    , Part(..)
    , Parts
    , SlotAttrs
    , fillsFromPlay
    , fromList
    , missingSlotIndices
    , nextSlotIndex
    , nonObviousSlotIndices
    , slotCount
    , toList
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
import MassiveDecks.Card.Parts.Part as Part exposing (Style(..), Transform(..))
import MassiveDecks.Strings as Strings exposing (MdString)
import Set exposing (Set)


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


{-| A function to get attributes for a given slot index.
-}
type alias SlotAttrs msg =
    Int -> List (Html.Attribute msg)


{-| A collection of `Line`s. It is guaranteed to have at least one `Slot`.
-}
type Parts
    = Parts (List Line)


{-| Construct a `Parts` from a `List` of `Line`s. This will fail if there is not at least one `Slot`.
-}
fromList : List Line -> Result MdString Parts
fromList lines =
    let
        indices =
            lines |> List.concat |> List.filterMap slotIndex |> Set.fromList
    in
    if Set.isEmpty indices then
        Err Strings.MustContainAtLeastOneSlot

    else
        let
            remapping =
                indices |> Set.toList |> List.sort |> List.indexedMap (\new old -> ( old, new )) |> Dict.fromList

            rewrite part =
                case part of
                    Slot index transform style ->
                        Slot (Dict.get index remapping |> Maybe.withDefault 0) transform style

                    _ ->
                        part
        in
        lines |> List.map (List.map rewrite) |> Parts |> Ok


{-| Construct without checking for at least one `Slot`. This is designed for use with fake cards or the editor where
that guarantee isn't important.
-}
unsafeFromList : List Line -> Parts
unsafeFromList lines =
    Parts lines


{-| Get a list of lines.
-}
toList : Parts -> List (List Part)
toList (Parts lines) =
    lines


{-| The number of `Slot`s with distinct indexes in the `Parts`. This will be one or more.
-}
slotCount : Parts -> Int
slotCount (Parts lines) =
    lines |> List.concat |> List.filterMap slotIndex |> Set.fromList |> Set.size


{-| Render the `Parts` to HTML.
-}
view : Parts -> List (Html msg)
view parts =
    viewFilled (always []) Dict.empty parts


{-| Render the `Parts` to a string.
-}
viewFilledString : String -> Fills -> Parts -> String
viewFilledString blankString play (Parts lines) =
    viewLinesString blankString play lines


{-| Render the `Parts` with slots filled with the given values.
-}
viewFilled : SlotAttrs msg -> Fills -> Parts -> List (Html msg)
viewFilled slotAttrs play (Parts lines) =
    viewLines slotAttrs play lines


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


{-| Returns true if slot indices aren't obvious (i.e: at least one is repeated).
-}
nonObviousSlotIndices : Parts -> Bool
nonObviousSlotIndices (Parts lines) =
    let
        indices =
            lines |> List.concat |> List.filterMap slotIndex
    in
    (indices |> List.length) /= (indices |> Set.fromList |> Set.size)


{-| Get the next slot index not in use.
-}
nextSlotIndex : List Part -> Int
nextSlotIndex parts =
    parts |> List.filterMap slotIndex |> List.maximum |> Maybe.map ((+) 1) |> Maybe.withDefault 0



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


viewPart : SlotAttrs msg -> Fills -> Part -> Html msg
viewPart slotAttrs fills part =
    case part of
        Text text style ->
            Part.styledElement style [ HtmlA.class "text" ] [ Html.text text ]

        Slot index transform style ->
            let
                ( fillState, fill ) =
                    case fills |> Dict.get index of
                        Just text ->
                            ( HtmlA.class "filled"
                            , [ Text text NoStyle ] |> cluster |> List.concatMap (viewCluster slotAttrs fills)
                            )

                        Nothing ->
                            ( HtmlA.class "empty", [] )

                attrs =
                    List.concat
                        [ [ HtmlA.class "slot"
                          , fillState
                          , HtmlA.attribute "data-slot-index" (index + 1 |> String.fromInt)
                          ]
                        , slotAttrs index
                        , Part.transformAttrs transform
                        ]
            in
            Part.styledElement style attrs fill


viewCluster : SlotAttrs msg -> Fills -> List Part -> List (Html msg)
viewCluster slotAttrs fills c =
    case c of
        [] ->
            []

        first :: [] ->
            [ viewPart slotAttrs fills first ]

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
            [ Html.span (HtmlA.class "cluster" :: growthAttrs) (many |> List.map (viewPart slotAttrs fills)) ]


viewLine : SlotAttrs msg -> Fills -> List Part -> Html msg
viewLine slotAttrs fills line =
    Html.p [] (line |> cluster |> List.concatMap (viewCluster slotAttrs fills))


viewLines : SlotAttrs msg -> Fills -> List (List Part) -> List (Html msg)
viewLines slotAttrs fills =
    List.map (viewLine slotAttrs fills)
