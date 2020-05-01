module MassiveDecks.Card.Parts exposing
    ( Part(..)
    , Parts
    , Style(..)
    , Transform(..)
    , fromList
    , map
    , slotCount
    , unsafeFromList
    , view
    , viewFilled
    , viewFilledString
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
    | Strong


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


{-| TODO: Remove
-}
unsafeFromList : List Line -> Parts
unsafeFromList lines =
    Parts lines


{-| Apply the given function to each `Part`, returning the resulting `List`.
-}
map : (Line -> a) -> Parts -> List a
map f lines =
    lines |> extract |> List.map f


{-| The number of `Slot`s in the `Parts`. This will be one or more.
-}
slotCount : Parts -> Int
slotCount lines =
    lines |> extract |> List.concat |> List.filter isSlot |> List.length


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
viewFilled play (Parts lines) =
    viewLinesHtml play lines



{- Private -}


viewLines : (List String -> List Part -> a) -> List String -> List Line -> List a
viewLines renderParts play lines =
    case lines of
        firstLine :: restLines ->
            let
                slots =
                    firstLine |> List.filter isSlot |> List.length
            in
            renderParts (List.take slots play) firstLine :: viewLines renderParts (List.drop slots play) restLines

        [] ->
            []


viewLinesHtml : List String -> List Line -> List (Html msg)
viewLinesHtml =
    viewLines (\s -> \p -> viewPartsHtml s p |> Html.p [])


viewLinesString : String -> List String -> List Line -> List String
viewLinesString blankPhrase =
    viewLines (\s -> \p -> viewPartsString blankPhrase s p |> String.join "")


viewParts : (Bool -> String -> Style -> List a) -> a -> List String -> List Part -> List a
viewParts viewText emptySlot play parts =
    case parts of
        firstPart :: restParts ->
            case firstPart of
                Text string style ->
                    viewText False string style ++ viewParts viewText emptySlot play restParts

                Slot transform style ->
                    case play of
                        firstPlay :: restPlay ->
                            viewText True (applyTransform transform firstPlay) style ++ viewParts viewText emptySlot restPlay restParts

                        [] ->
                            emptySlot :: viewParts viewText emptySlot [] restParts

        [] ->
            []


viewPartsHtml : List String -> List Part -> List (Html msg)
viewPartsHtml =
    viewParts viewTextHtml (Html.span [ HtmlA.class "slot" ] [])


viewPartsString : String -> List String -> List Part -> List String
viewPartsString blankPhrase =
    viewParts (\_ -> \s -> \_ -> [ s ]) blankPhrase


applyTransform : Transform -> String -> String
applyTransform transform value =
    case transform of
        NoTransform ->
            value

        UpperCase ->
            String.toUpper value

        Capitalize ->
            String.capitalise value


viewTextHtml : Bool -> String -> Style -> List (Html msg)
viewTextHtml slot string style =
    let
        element =
            case style of
                NoStyle ->
                    Html.span

                Em ->
                    Html.em

                Strong ->
                    Html.strong

        words =
            string |> splitWords |> List.map (\word -> element [] [ Html.text word ])
    in
    if slot then
        [ Html.span [ HtmlA.class "slot" ] words ]

    else
        words


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


extract : Parts -> List Line
extract lines =
    case lines of
        Parts list ->
            list
