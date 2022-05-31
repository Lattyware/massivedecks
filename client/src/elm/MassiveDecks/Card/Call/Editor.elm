module MassiveDecks.Card.Call.Editor exposing
    ( init
    , toParts
    , update
    , view
    )

import FontAwesome as Icon
import FontAwesome.Layering as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Html5.DragDrop as DragDrop
import List.Extra as List
import MassiveDecks.Card.Call.Editor.Model exposing (..)
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Parts as Parts exposing (Parts)
import MassiveDecks.Card.Parts.Part as Part
import MassiveDecks.Components.Form as Form
import MassiveDecks.Components.Form.Message as Message
import MassiveDecks.Icon as Icon
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Maybe as Maybe
import Material.Button as Button
import Material.IconButton as IconButton
import Material.TextArea as TextArea
import Material.TextField as TextField


init : Card.Call -> Model
init source =
    { source = source
    , parts = source.body |> Parts.toList |> List.intersperse [ Parts.Text "\n" Part.NoStyle ] |> List.concat
    , selected = Nothing
    , error = Nothing
    , dragDrop = DragDrop.init
    }


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        Select index ->
            ( { model | selected = index }, Cmd.none )

        Add index part ->
            ( model |> changeParts (Just index) (model.parts |> insertAt index part), Cmd.none )

        Set index part ->
            case part of
                Parts.Text "" _ ->
                    ( model |> changeParts Nothing (model.parts |> List.removeAt index), Cmd.none )

                _ ->
                    ( model |> changeParts model.selected (model.parts |> List.setAt index part), Cmd.none )

        Move index by ->
            let
                from =
                    index

                to =
                    index + by
            in
            ( model |> changeParts (Just to) (model.parts |> List.swapAt from to), Cmd.none )

        Remove index ->
            ( model |> changeParts Nothing (model.parts |> List.removeAt index), Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        DragDropMsg dragDropMsg ->
            let
                ( newDragDrop, drag ) =
                    DragDrop.update dragDropMsg model.dragDrop

                newModel =
                    case drag of
                        Just ( from, to, _ ) ->
                            model |> changeParts (Just to) (model.parts |> List.swapAt from to)

                        Nothing ->
                            model
            in
            ( { newModel | dragDrop = newDragDrop }, Cmd.none )


view : (Msg -> msg) -> Shared -> Model -> Html msg
view wrap shared { parts, selected, error } =
    let
        partFor index =
            parts |> List.getAt index |> Maybe.map (\p -> ( index, p ))

        interactions index =
            List.concat
                [ [ HtmlE.onClick (index |> Just |> Select |> wrap) ]
                , DragDrop.draggable (DragDropMsg >> wrap) index
                , DragDrop.droppable (DragDropMsg >> wrap) index
                ]

        renderPart index part =
            case part of
                Parts.Text text style ->
                    Part.styledElement
                        style
                        (HtmlA.classList [ ( "text", True ), ( "selected", Just index == selected ) ] :: interactions index)
                        [ Html.text text ]

                Parts.Slot slot transform style ->
                    Part.transformedStyledElement
                        transform
                        style
                        (HtmlA.classList [ ( "slot", True ), ( "selected", Just index == selected ) ] :: interactions index)
                        [ Html.span [] [ Strings.Blank |> Lang.string shared |> String.toLower |> Html.text ]
                        , Html.span [ HtmlA.class "index" ] [ slot + 1 |> String.fromInt |> Html.text ]
                        ]

        renderedParts =
            parts |> List.indexedMap renderPart

        addAction part =
            Add (parts |> List.length) part |> wrap

        nextSlotIndex =
            parts |> Parts.nextSlotIndex

        addSlot =
            addAction (Parts.Slot nextSlotIndex Part.NoTransform Part.NoStyle)

        inlineButton string icon action =
            Button.view Button.Outlined Button.Padded (string |> Lang.string shared) (Just icon) action

        inlineControls =
            Html.p []
                [ inlineButton Strings.AddText (Icon.add |> Icon.view) (Parts.Text "..." Part.NoStyle |> addAction |> Just)
                , inlineButton Strings.AddSlot (Icon.add |> Icon.view) (Just addSlot)
                ]

        selectedPart =
            selected |> Maybe.andThen partFor

        editor =
            case selectedPart of
                Just ( index, Parts.Text text style ) ->
                    Form.section shared
                        "part-editor"
                        (TextArea.view
                            [ (\t -> Set index (Parts.Text t style) |> wrap) |> HtmlE.onInput
                            , HtmlA.class "text part-editor"
                            , HtmlA.value text
                            ]
                            []
                        )
                        []

                Just ( index, Parts.Slot slotIndex transform style ) ->
                    let
                        setSlotIndex str =
                            str
                                |> String.toInt
                                |> Maybe.map (\i -> Set index (Parts.Slot (i - 1) transform style))
                                |> Maybe.withDefault NoOp
                                |> wrap
                    in
                    Form.section shared
                        "part-editor"
                        (TextField.viewWithAttrs
                            (Strings.Blank |> Lang.string shared)
                            TextField.Number
                            (slotIndex + 1 |> String.fromInt)
                            (setSlotIndex |> Just)
                            [ HtmlA.min "1" ]
                        )
                        [ Message.info Strings.SlotIndexExplanation ]

                Nothing ->
                    Html.nothing

        viewError e =
            Message.errorWithFix e [ { description = Strings.AddSlot, icon = Icon.add, action = addSlot } ]
                |> Message.view shared
    in
    Html.div [ HtmlA.class "call-editor" ]
        [ Html.div [ HtmlA.class "parts" ] [ Html.p [] renderedParts, inlineControls ]
        , controls wrap shared (List.length parts - 1) selectedPart
        , editor
        , error |> Maybe.andThen viewError |> Maybe.withDefault Html.nothing
        ]


toParts : List Parts.Part -> Result MdString Parts
toParts parts =
    let
        splitOnNewLines part =
            case part of
                Parts.Slot _ _ _ ->
                    Just part

                Parts.Text text _ ->
                    if text == "\n" then
                        Nothing

                    else
                        Just part
    in
    parts |> List.concatMap separateNewLines |> splitMap splitOnNewLines |> Parts.fromList



{- Private -}


changeParts : Maybe Index -> List Parts.Part -> Model -> Model
changeParts selected newParts model =
    let
        source =
            model.source

        ( newSource, error ) =
            case newParts |> toParts of
                Ok body ->
                    ( { source | body = body }, Nothing )

                Err e ->
                    ( source, Just e )
    in
    { model | parts = newParts, selected = selected, source = newSource, error = error }


controls : (Msg -> msg) -> Shared -> Int -> Maybe ( Index, Parts.Part ) -> Html msg
controls wrap shared max selected =
    let
        sep =
            Html.div [ HtmlA.class "separator" ] []

        index =
            selected |> Maybe.map Tuple.first

        move by test =
            index |> Maybe.andThen (\i -> Move i by |> wrap |> Maybe.justIf (test i))

        iconButton string icon action =
            IconButton.view icon (string |> Lang.string shared) action

        generalControls =
            [ iconButton Strings.Remove (Icon.remove |> Icon.view) (index |> Maybe.map (Remove >> wrap))
            , iconButton Strings.MoveLeft (Icon.left |> Icon.view) (move -1 ((<) 0))
            , iconButton Strings.MoveRight (Icon.right |> Icon.view) (move 1 ((>) max))
            ]

        setIfDifferent old updated new =
            index |> Maybe.andThen (\i -> Set i (updated new) |> wrap |> Maybe.justIf (old /= new))

        styleControls setStyle =
            [ iconButton Strings.Normal (Icon.normalText |> Icon.view) (setStyle Part.NoStyle)
            , iconButton Strings.Emphasise (Icon.italicText |> Icon.view) (setStyle Part.Em)
            ]

        transformControls setTransform =
            let
                textIcon text =
                    Icon.layers [] [ Icon.text [] text ]
            in
            [ iconButton Strings.Normal (textIcon "aa") (setTransform Part.NoTransform)
            , iconButton Strings.Capitalise (textIcon "Aa") (setTransform Part.Capitalize)
            , iconButton Strings.UpperCase (textIcon "AA") (setTransform Part.UpperCase)
            ]

        ( replaceStyle, replaceTransform ) =
            case selected of
                Just ( _, Parts.Slot slot transform style ) ->
                    ( setIfDifferent style (Parts.Slot slot transform)
                    , setIfDifferent transform (\t -> Parts.Slot slot t style)
                    )

                Just ( _, Parts.Text text style ) ->
                    ( setIfDifferent style (Parts.Text text), always Nothing )

                _ ->
                    ( always Nothing, always Nothing )

        collected =
            List.concat
                [ generalControls
                , [ sep ]
                , styleControls replaceStyle
                , [ sep ]
                , transformControls replaceTransform
                ]
    in
    Html.div [ HtmlA.class "controls" ] collected


splitMap : (x -> Maybe y) -> List x -> List (List y)
splitMap map values =
    let
        internal vs =
            case vs of
                first :: rest ->
                    let
                        ( current, lines ) =
                            internal rest
                    in
                    case map first of
                        Just value ->
                            ( value :: current, lines )

                        Nothing ->
                            ( [], current :: lines )

                [] ->
                    ( [], [] )

        ( a, b ) =
            values |> internal
    in
    a :: b


separateNewLines : Parts.Part -> List Parts.Part
separateNewLines part =
    case part of
        Parts.Text string style ->
            String.split "\n" string |> List.map (\t -> Parts.Text t style) |> List.intersperse (Parts.Text "\n" style)

        Parts.Slot _ _ _ ->
            [ part ]


insertAt : Int -> a -> List a -> List a
insertAt index item items =
    let
        ( start, end ) =
            List.splitAt index items
    in
    start ++ item :: end
