module MassiveDecks.Pages.Lobby.Configure.Decks exposing
    ( default
    , handleEvent
    , init
    , update
    , updateFromConfig
    , view
    )

import FontAwesome.Attributes as Icon
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Card.Source as Source
import MassiveDecks.Card.Source.Cardcast.Model as Cardcast
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Components as Components
import MassiveDecks.Components.Form as Form
import MassiveDecks.Components.Form.Message as Message exposing (Message)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Actions as Actions
import MassiveDecks.Pages.Lobby.Configure.Decks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Events as Events
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Html.Attributes as HtmlA
import MassiveDecks.Util.Maybe as Maybe
import MassiveDecks.Util.Result as Result
import Svg.Attributes as SvgA


init : Model
init =
    { toAdd = Source.default
    , errors = []
    }


default : Config
default =
    []


{-| Handle an event, updating the configuration and model as appropriate.
-}
handleEvent : Events.DeckEvent -> Config -> Model -> ( Config, Model )
handleEvent { change, deck } config model =
    let
        newConfig =
            case change of
                Events.Add ->
                    config ++ [ Deck deck Nothing ]

                Events.Remove ->
                    config |> List.filter (.source >> (/=) deck)

                Events.Load { summary } ->
                    config |> List.map (addSummary deck summary)

                Events.Fail _ ->
                    config |> List.filter (.source >> (/=) deck)

        newConfigure =
            case change of
                Events.Fail { reason } ->
                    { model | errors = { deck = deck, reason = reason } :: model.errors }

                _ ->
                    model
    in
    ( newConfig, newConfigure )


{-| Update the local model to reflect the configuration given.
-}
updateFromConfig : Config -> Model -> Model
updateFromConfig _ model =
    model


{-| React to user input.
-}
update : String -> Msg -> Model -> ( Model, Cmd msg )
update version msg model =
    case msg of
        Update source ->
            ( { model | toAdd = source }, Cmd.none )

        Add source ->
            ( { model | toAdd = Source.emptyMatching source }, Actions.addDeck version source )

        Remove source ->
            if model.errors |> List.any (\e -> e.deck == source) then
                ( { model | errors = model.errors |> List.filter (\e -> e.deck /= source) }, Cmd.none )

            else
                ( model, Actions.removeDeck version source )


{-| View the editor/viewer for decks.
-}
view : (Msg -> msg) -> Shared -> Bool -> Model -> Config -> Html msg
view wrap shared canEdit model config =
    let
        hint =
            if canEdit then
                Components.linkButton
                    [ "CAHBS" |> Cardcast.playCode |> Source.Cardcast |> Add |> wrap |> HtmlE.onClick
                    ]
                    [ Strings.NoDecksHint |> Lang.html shared ]

            else
                Html.nothing

        tableContent =
            if List.isEmpty config && List.isEmpty model.errors then
                [ Html.tr [ HtmlA.class "empty-info" ]
                    [ Html.td [ HtmlA.colspan 3 ]
                        [ Html.p []
                            [ Icon.viewIcon Icon.ghost
                            , Html.text " "
                            , Strings.NoDecks |> Lang.html shared
                            ]
                        , hint
                        ]
                    ]
                ]

            else
                List.concat
                    [ config |> List.map (D >> viewDeck wrap shared canEdit)
                    , if canEdit then
                        model.errors |> List.map (E >> viewDeck wrap shared canEdit)

                      else
                        []
                    ]

        editor =
            if canEdit then
                [ addDeckWidget wrap shared config model.toAdd
                ]

            else
                []
    in
    Html.div [ HtmlA.id "decks-tab", HtmlA.class "compressed-terms" ]
        (List.concat
            [ [ Html.h3 [] [ Strings.ConfigureDecks |> Lang.html shared ]
              , Html.table []
                    [ Html.colgroup []
                        [ Html.col [ HtmlA.class "deck-name" ] []
                        , Html.col [ HtmlA.class "count" ] []
                        , Html.col [ HtmlA.class "count" ] []
                        ]
                    , Html.thead []
                        [ Html.tr []
                            [ Html.th [ HtmlA.class "deck-name", HtmlA.scope "col" ] [ Strings.Deck |> Lang.html shared ]
                            , Html.th [ HtmlA.scope "col" ] [ Strings.Call |> Lang.html shared ]
                            , Html.th [ HtmlA.scope "col" ] [ Strings.Response |> Lang.html shared ]
                            ]
                        ]
                    , Html.tbody [] tableContent
                    ]
              ]
            , editor
            ]
        )



{- Private -}


type DeckOrError
    = D Deck
    | E Error


addSummary : Source.External -> Source.Summary -> Deck -> Deck
addSummary target summary deckSource =
    if deckSource.source == target then
        Deck target (Just summary)

    else
        deckSource


addDeckWidget : (Msg -> msg) -> Shared -> List Deck -> Source.External -> Html msg
addDeckWidget wrap shared existing deckToAdd =
    let
        submit =
            deckToAdd |> submitDeckAction wrap existing
    in
    Html.form
        [ submit |> Result.map HtmlE.onSubmit |> Result.withDefault HtmlA.nothing ]
        [ Form.section
            shared
            "add-deck"
            (Html.div [ HtmlA.class "multipart" ]
                (List.concat
                    [ Source.generalEditor shared deckToAdd (Update >> wrap)
                    , [ Components.floatingActionButton
                            [ HtmlA.type_ "submit"
                            , Result.isError submit |> HtmlA.disabled
                            , Strings.AddDeck |> Lang.title shared
                            ]
                            Icon.plus
                      ]
                    ]
                )
            )
            (submit |> Result.error |> Maybe.withDefault [])
        ]


submitDeckAction : (Msg -> msg) -> List Deck -> Source.External -> Result (List (Message msg)) msg
submitDeckAction wrap existing deckToAdd =
    let
        potentialProblems =
            if List.any (.source >> Source.equals deckToAdd) existing then
                [ Strings.DeckAlreadyAdded |> Message.error ]

            else
                Source.problems deckToAdd
    in
    if List.isEmpty potentialProblems then
        deckToAdd |> Add |> wrap |> Result.Ok

    else
        potentialProblems |> Result.Err


viewDeck : (Msg -> msg) -> Shared -> Bool -> DeckOrError -> Html msg
viewDeck wrap shared canEdit deckOrError =
    let
        ( deckSource, deckSummary, failureReason ) =
            case deckOrError of
                D { source, summary } ->
                    ( source, summary, Nothing )

                E { deck, reason } ->
                    ( deck, Nothing, Just reason )

        ( attr, columns ) =
            case deckSummary of
                Just s ->
                    ( [], viewSummary s )

                Nothing ->
                    ( [ HtmlA.colspan 3 ], [] )

        details =
            deckSummary |> Maybe.map .details |> Maybe.withDefault (deckSource |> Source.Ex |> Source.defaultDetails shared)

        row =
            [ Html.td attr [ name wrap shared canEdit deckSource False failureReason details ] ] ++ columns
    in
    Html.tr [ HtmlA.class "deck-row" ] row


viewSummary : Source.Summary -> List (Html msg)
viewSummary summary =
    [ Html.td [] [ summary.calls |> String.fromInt |> Html.text ]
    , Html.td [] [ summary.responses |> String.fromInt |> Html.text ]
    ]


name :
    (Msg -> msg)
    -> Shared
    -> Bool
    -> Source.External
    -> Bool
    -> Maybe Source.LoadFailureReason
    -> Source.Details
    -> Html msg
name wrap shared canEdit source loading maybeError details =
    let
        removeButton =
            Components.iconButton
                [ source |> Remove |> wrap |> HtmlE.onClick
                , Strings.RemoveDeck |> Lang.title shared
                , HtmlA.class "remove-button"
                ]
                Icon.trash
                |> Maybe.justIf canEdit

        ( maybeId, tooltip ) =
            source |> Source.Ex |> Source.tooltip |> Maybe.decompose

        attrs =
            maybeId |> Maybe.map (\id -> [ HtmlA.id id ]) |> Maybe.withDefault []

        nameText =
            Html.text details.name

        linkOrText =
            Html.span attrs [ Maybe.transformWith nameText makeLink details.url ] |> Just

        spinner =
            Icon.viewStyled [ Icon.spin, SvgA.class "loading-deck-info" ] Icon.circleNotch |> Maybe.justIf loading

        content =
            List.filterMap identity [ linkOrText, removeButton, spinner, tooltip ]

        withError =
            maybeError
                |> Maybe.map (viewError shared source >> (\e -> [ Html.div [ HtmlA.class "with-error" ] [ Html.div [] content, e ] ]))
                |> Maybe.withDefault content
    in
    Html.td [ HtmlA.class "name" ] withError


viewError : Shared -> Source.External -> Source.LoadFailureReason -> Html msg
viewError shared source error =
    error
        |> Source.loadFailureReasonMessage (source |> Source.Ex |> Source.name)
        |> Message.error
        |> Message.view shared
        |> Maybe.withDefault Html.nothing


makeLink : Html msg -> String -> Html msg
makeLink text url =
    Html.blankA [ HtmlA.href url ] [ text ]
