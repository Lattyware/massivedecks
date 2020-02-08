module MassiveDecks.Pages.Lobby.Configure.Decks exposing
    ( componentById
    , default
    , getDecks
    , getSummary
    , init
    , update
    )

import FontAwesome.Attributes as Icon
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Json.Patch as Json
import MassiveDecks.Card.Source as Source
import MassiveDecks.Card.Source.Cardcast.Model as Cardcast
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Components as Components
import MassiveDecks.Components.Form as Form
import MassiveDecks.Components.Form.Message as Message exposing (Message)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Models.Encoders as Encoders
import MassiveDecks.Pages.Lobby.Actions as Actions
import MassiveDecks.Pages.Lobby.Configure.Component as Component exposing (Component(..))
import MassiveDecks.Pages.Lobby.Configure.Component.Validator as Validator exposing (Validator)
import MassiveDecks.Pages.Lobby.Configure.ConfigOption as ConfigOption
import MassiveDecks.Pages.Lobby.Configure.Decks.Model exposing (..)
import MassiveDecks.Settings as Settings
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Html.Attributes as HtmlA
import MassiveDecks.Util.Maybe as Maybe
import MassiveDecks.Util.Result as Result
import Svg.Attributes as SvgA


componentById : Id -> Component Config Model Id Msg msg
componentById id =
    case id of
        All ->
            all


init : Model
init =
    { toAdd = Source.default }


default : Config
default =
    []


{-| React to user input.
-}
update : Shared -> Msg -> Model -> ( Model, Shared, Cmd msg )
update shared msg model =
    case msg of
        Update source ->
            ( { model | toAdd = source }, shared, Cmd.none )

        Add source ->
            let
                ( settings, settingsCmd ) =
                    Settings.onAddDeck source shared.settings
            in
            ( { model | toAdd = Source.emptyMatching source }
            , { shared | settings = settings }
            , Cmd.batch [ Actions.configure (addDeck source), settingsCmd ]
            )

        Remove index ->
            ( model, shared, Actions.configure (removeDeck index) )


{-| View the editor/viewer for decks.
-}
view : Validator Config Msg msg -> ConfigOption.ViewArgs Model Config Msg msg -> Html msg
view _ { wrap, shared, model, remote, canEdit } =
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
            if List.isEmpty remote then
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
                    [ remote |> List.indexedMap (viewDeck wrap shared canEdit)
                    ]

        editor =
            if canEdit then
                addDeckWidget wrap shared remote model.toAdd

            else
                Html.nothing
    in
    Html.div [ HtmlA.id "decks-tab", HtmlA.class "compressed-terms" ]
        [ Html.table []
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
        , editor
        ]


addDeck : Source.External -> Json.Patch
addDeck source =
    [ Json.Add [ "decks", "-" ] (D (Deck source Nothing) |> Encoders.deckOrError) ]


removeDeck : Int -> Json.Patch
removeDeck index =
    [ Json.Remove [ "decks", index |> String.fromInt ] ]


getSummary : Config -> GetSummary
getSummary config s =
    config
        |> List.filterMap summaryFor
        |> List.filter (\( source, _ ) -> Source.externalAndEquals source s)
        |> List.head
        |> Maybe.map (\( _, summary ) -> summary)


getDecks : Config -> List Deck
getDecks config =
    config |> List.filterMap getDeck



{- Private -}


all : Component Config Model Id Msg msg
all =
    Component.group
        All
        Nothing
        [ Component.value All view (always False) Validator.none
        ]


getDeck : DeckOrError -> Maybe Deck
getDeck deckOrError =
    case deckOrError of
        D deck ->
            Just deck

        E _ ->
            Nothing


summaryFor : DeckOrError -> Maybe ( Source.External, Source.Summary )
summaryFor deckOrError =
    case deckOrError of
        D deck ->
            deck.summary |> Maybe.map (\s -> ( deck.source, s ))

        E _ ->
            Nothing


addDeckWidget : (Msg -> msg) -> Shared -> List DeckOrError -> Source.External -> Html msg
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
                    [ Source.generalEditor shared existing deckToAdd (Update >> wrap)
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


submitDeckAction : (Msg -> msg) -> List DeckOrError -> Source.External -> Result (List (Message msg)) msg
submitDeckAction wrap existing deckToAdd =
    let
        potentialProblems =
            if List.any (getSource >> Source.equals deckToAdd) existing then
                [ Strings.DeckAlreadyAdded |> Message.error ]

            else
                Source.problems deckToAdd
    in
    if List.isEmpty potentialProblems then
        deckToAdd |> Add |> wrap |> Result.Ok

    else
        potentialProblems |> Result.Err


getSource : DeckOrError -> Source.External
getSource deckOrError =
    case deckOrError of
        D deck ->
            deck.source

        E error ->
            error.source


viewDeck : (Msg -> msg) -> Shared -> Bool -> Int -> DeckOrError -> Html msg
viewDeck wrap shared canEdit index deckOrError =
    let
        ( deckSource, deckSummary, failureReason ) =
            case deckOrError of
                D { source, summary } ->
                    ( source, summary, Nothing )

                E { source, reason } ->
                    ( source, Nothing, Just reason )

        ( attr, columns ) =
            case deckSummary of
                Just s ->
                    ( [], viewSummary s )

                Nothing ->
                    ( [ HtmlA.colspan 3 ], [] )

        details =
            deckSummary |> Maybe.map .details |> Maybe.withDefault (deckSource |> Source.Ex |> Source.defaultDetails shared)

        loading =
            deckSummary == Nothing && failureReason == Nothing

        row =
            [ Html.td attr [ name wrap shared canEdit index deckSource loading failureReason details ] ] ++ columns
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
    -> Int
    -> Source.External
    -> Bool
    -> Maybe Source.LoadFailureReason
    -> Source.Details
    -> Html msg
name wrap shared canEdit index source loading maybeError details =
    let
        removeButton =
            Components.iconButton
                [ index |> Remove |> wrap |> HtmlE.onClick
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
