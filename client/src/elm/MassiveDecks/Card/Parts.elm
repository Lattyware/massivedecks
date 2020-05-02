module MassiveDecks.Card.Parts exposing
    ( Part(..)
    , Parts
    , Style(..)
    , Transform(..)
    , coordinateMap
    , fromList
    , isSlot
    , slotCount
    , unsafeFromList
    , view
    , viewFilled
    , viewFilledString
    , viewLinesString
    , viewWithAttributes
    )

import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Util.String as String


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
    | Slot Transform Style


{-| Represents a line as a part of a part. Between each one the text will be forced to line break.
-}
type alias Line =
    List Part


{-| A collection of `Line`s. It is guaranteed to have at least one `Slot`.
-}
type Parts
    = Parts (List Line)


{-| Map through all the parts with coordinates.
-}
coordinateMap : Parts -> (Int -> Int -> Part -> a) -> List a
coordinateMap (Parts lines) f =
    lines |> List.indexedMap (\line -> List.indexedMap (f line)) |> List.concat


{-| A predicate checking if a part is a slot.
-}
isSlot : Part -> Bool
isSlot part =
    case part of
        Text _ _ ->
            False

        Slot _ _ ->
            True


{-| Construct a `Parts` from a `List` of `Line`s. This will fail if there is not at least one `Slot`.
-}
fromList : List Line -> Maybe Parts
fromList lines =
    if List.any (List.any isSlot) lines then
        Just (Parts lines)

    else
        Nothing


{-| Construct without checking for at least one `Slot`. This is designed for use with fake cards or the editor where
that guarantee isn't important.
-}
unsafeFromList : List Line -> Parts
unsafeFromList lines =
    Parts lines


{-| The number of `Slot`s in the `Parts`. This will be one or more.
-}
slotCount : Parts -> Int
slotCount (Parts lines) =
    lines |> List.concat |> List.filter isSlot |> List.length


{-| Render the `Parts` to HTML.
-}
view : Parts -> List (Html msg)
view parts =
    viewFilled [] parts


{-| Render the `Parts` to a string.
-}
viewFilledString : String -> List String -> Parts -> String
viewFilledString blankString play (Parts lines) =
    viewLinesString blankString play lines |> String.join "\n"


{-| Render the `Parts` with slots filled with the given values.
-}
viewFilled : List String -> Parts -> List (Html msg)
viewFilled play parts =
    viewWithAttributes (\_ -> \_ -> \_ -> []) play parts


{-| Render the parts with filled slots and attributes applied to each part.
-}
viewWithAttributes : (Int -> Int -> Part -> List (Html.Attribute msg)) -> List String -> Parts -> List (Html msg)
viewWithAttributes attributes play (Parts lines) =
    viewLinesHtml attributes play lines


{-| Render lines to a string without needing a complete parts.
-}
viewLinesString : String -> List String -> List Line -> List String
viewLinesString blankPhrase =
    viewLines (\_ -> \s -> \p -> viewPartsString blankPhrase s p |> String.concat) 0 (\_ -> \_ -> \_ -> [])



{- Private -}


viewLines : ((Int -> Part -> List (Html.Attribute msg)) -> List String -> List Part -> a) -> Int -> (Int -> Int -> Part -> List (Html.Attribute msg)) -> List String -> List Line -> List a
viewLines renderParts index attributes play lines =
    case lines of
        firstLine :: restLines ->
            let
                slots =
                    firstLine |> List.filter isSlot |> List.length
            in
            renderParts (attributes index) (List.take slots play) firstLine :: viewLines renderParts (index + 1) attributes (List.drop slots play) restLines

        [] ->
            []


viewLinesHtml : (Int -> Int -> Part -> List (Html.Attribute msg)) -> List String -> List Line -> List (Html msg)
viewLinesHtml attributes =
    viewLines (\a -> \s -> \p -> Html.p [] (viewPartsHtml a s p)) 0 attributes


viewParts : (List (Html.Attribute msg) -> Bool -> String -> Style -> List a) -> (List (Html.Attribute msg) -> a) -> Int -> (Int -> Part -> List (Html.Attribute msg)) -> List String -> List Part -> List a
viewParts viewText emptySlot index attributes play parts =
    case parts of
        firstPart :: restParts ->
            let
                recurse =
                    viewParts viewText emptySlot (index + 1) attributes

                attributesForThis =
                    attributes index firstPart
            in
            case firstPart of
                Text string style ->
                    viewText attributesForThis False string style ++ recurse play restParts

                Slot transform style ->
                    case play of
                        firstPlay :: restPlay ->
                            viewText attributesForThis True (applyTransform transform firstPlay) style ++ recurse restPlay restParts

                        [] ->
                            emptySlot attributesForThis :: recurse [] restParts

        [] ->
            []


viewPartsHtml : (Int -> Part -> List (Html.Attribute msg)) -> List String -> List Part -> List (Html msg)
viewPartsHtml =
    viewParts viewTextHtml (\attributes -> Html.span (HtmlA.class "slot" :: attributes) []) 0


viewPartsString : String -> List String -> List Part -> List String
viewPartsString blankPhrase =
    viewParts (\_ -> \_ -> \s -> \_ -> [ s ]) (always blankPhrase) 0 (\_ -> \_ -> [])


applyTransform : Transform -> String -> String
applyTransform transform value =
    case transform of
        NoTransform ->
            value

        UpperCase ->
            String.toUpper value

        Capitalize ->
            String.capitalise value


viewTextHtml : List (Html.Attribute msg) -> Bool -> String -> Style -> List (Html msg)
viewTextHtml attributes slot string style =
    let
        element =
            case style of
                NoStyle ->
                    Html.span

                Em ->
                    Html.em

        words =
            string |> splitWords |> List.map (\word -> Html.span [] [ Html.text word ])
    in
    if slot then
        [ element (HtmlA.class "slot" :: attributes) words ]

    else
        [ element (HtmlA.class "text" :: attributes) words ]


{-| Splits words by retains the whitespace.
-}
splitWords : String -> List String
splitWords string =
    case String.uncons string of
        Nothing ->
            []

        Just ( first, rest ) ->
            case first of
                ' ' ->
                    String.fromChar first :: splitWords rest

                other ->
                    case splitWords rest of
                        [] ->
                            [ String.fromChar other ]

                        head :: tail ->
                            String.cons other head :: tail
