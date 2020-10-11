module MassiveDecks.Card.Source exposing
    ( default
    , defaultDetails
    , editor
    , empty
    , emptyMatching
    , equals
    , externalAndEquals
    , generalEditor
    , generalMatching
    , loadFailureReasonMessage
    , logo
    , messages
    , name
    , problems
    , tooltip
    )

import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Card.Source.BuiltIn as BuiltIn
import MassiveDecks.Card.Source.Custom as Player
import MassiveDecks.Card.Source.Fake as Fake
import MassiveDecks.Card.Source.Generated as Generated
import MassiveDecks.Card.Source.JsonAgainstHumanity as JsonAgainstHumanity
import MassiveDecks.Card.Source.ManyDecks as ManyDecks
import MassiveDecks.Card.Source.Methods exposing (..)
import MassiveDecks.Card.Source.Model exposing (..)
import MassiveDecks.Components.Form.Message exposing (Message)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Decks.Model exposing (DeckOrError)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Maybe as Maybe
import Material.Select as Select
import Paper.Tooltip as Tooltip


{-| The default source for an editor.
-}
default : Shared -> External
default =
    BuiltIn.generalMethods.empty


{-| Check if two sources are equal.
-}
equals : External -> External -> Bool
equals a b =
    (externalMethods a |> .equals) b


{-| Check if the given source is external, and if it is, if it matches the given one.
-}
externalAndEquals : External -> Source -> Bool
externalAndEquals a b =
    case b of
        Ex external ->
            equals a external

        _ ->
            False


{-| Get an general methods of the given type.
-}
generalMethods : General -> ExternalGeneralMethods msg
generalMethods source =
    case source of
        GBuiltIn ->
            BuiltIn.generalMethods

        GManyDecks ->
            ManyDecks.generalMethods

        GJsonAgainstHumanity ->
            JsonAgainstHumanity.generalMethods


{-| Get an empty source of the given type.
-}
empty : Shared -> General -> External
empty shared =
    generalMethods >> (\m -> m.empty shared)


{-| Get the general source for the given specific source.
-}
generalMatching : External -> General
generalMatching source =
    (externalMethods source |> .id) ()


{-| An empty source of the same general type as the given one.
-}
emptyMatching : Shared -> External -> External
emptyMatching shared source =
    shared |> (externalMethods source |> .empty)


{-| The name of a source.
-}
name : Source -> MdString
name source =
    () |> (methods source |> .name)


{-| Any problems, if they exist, for a source. If none, it is valid.
-}
problems : External -> List (Message msg)
problems source =
    () |> (externalMethods source |> .problems)


{-| Any problems, if they exist, for a source. If none, it is valid.
-}
messages : General -> List (Message msg)
messages source =
    (generalMethods source |> .messages) ()


{-| The default details for a source.
-}
defaultDetails : Shared -> Source -> Details
defaultDetails shared source =
    (methods source |> .defaultDetails) shared


{-| A tooltip for a source.
-}
tooltip : Shared -> Tooltip.Position -> Details -> Source -> Maybe ( String, Html msg )
tooltip shared position details source =
    let
        ms =
            methods source
    in
    ms.tooltip (generalTooltip shared position details)


{-| A general tooltip for any source.
-}
generalTooltip : Shared -> Tooltip.Position -> Details -> String -> List (Html msg) -> Html msg
generalTooltip shared position details forId sourceSpecificContent =
    let
        lang l =
            Html.p [ HtmlA.class "language" ]
                [ Strings.DeckLanguage { language = l |> Lang.languageNameOrCode shared } |> Lang.html shared
                ]

        author a =
            Html.p [ HtmlA.class "author" ] [ Strings.DeckAuthor { author = a } |> Lang.html shared ]

        translator t =
            Html.p [ HtmlA.class "translator" ] [ Strings.DeckTranslator { translator = t } |> Lang.html shared ]

        generalContent =
            [ details.language |> Maybe.andThen (\l -> Maybe.justIf (l /= (Lang.currentLanguage shared |> Lang.code)) (lang l))
            , details.author |> Maybe.map author
            , details.translator |> Maybe.map translator
            ]
                |> List.filterMap identity
    in
    [ Html.div [ HtmlA.class "source-tooltip" ]
        ([ sourceSpecificContent
         , generalContent
         ]
            |> List.concat
        )
    ]
        |> Tooltip.view position forId


{-| The logo for a source.
-}
logo : Source -> Maybe (Html msg)
logo source =
    () |> (methods source |> .logo)


{-| An editor for any supported external source.
-}
generalEditor : Shared -> List DeckOrError -> External -> (External -> msg) -> Maybe msg -> msg -> ( Html msg, Html msg )
generalEditor shared existing currentValue update submit noOp =
    let
        enabledSources =
            [ shared.sources.builtIn |> Maybe.map (\_ -> BuiltIn.generalMethods)
            , shared.sources.manyDecks |> Maybe.map (\_ -> ManyDecks.generalMethods)
            , shared.sources.jsonAgainstHumanity |> Maybe.map (\_ -> JsonAgainstHumanity.generalMethods)
            ]

        toItem source =
            { id = source.id ()
            , icon = source.logo ()
            , primary = [ () |> source.name |> Lang.string shared |> Html.text ]
            , secondary = Nothing
            , meta = Nothing
            }
    in
    ( Select.view shared
        { label = Strings.DeckSource
        , idToString = generalToString
        , idFromString = generalFromString
        , selected = currentValue |> generalMatching |> Just
        , wrap = Maybe.map (empty shared) >> Maybe.withDefault (default shared) >> update
        }
        [ HtmlA.id "source-selector", HtmlA.class "primary" ]
        (enabledSources |> List.filterMap (Maybe.map toItem))
    , editor shared existing currentValue update submit noOp
    )


{-| An editor for the given source value.
-}
editor : Shared -> List DeckOrError -> External -> (External -> msg) -> Maybe msg -> msg -> Html msg
editor shared existing source =
    (externalMethods source |> .editor) shared existing


{-| Get a user message explaining the reason a source failed to load.
The first argument is the name of the source that failed to load.
-}
loadFailureReasonMessage : MdString -> LoadFailureReason -> MdString
loadFailureReasonMessage source loadFailureReason =
    case loadFailureReason of
        SourceFailure ->
            Strings.SourceServiceFailure { source = source }

        NotFound ->
            Strings.SourceNotFound { source = source }



{- Private -}


methods : Source -> Methods msg
methods source =
    case source of
        Ex external ->
            let
                ms =
                    externalMethods external
            in
            { name = ms.name
            , logo = ms.logo
            , tooltip = ms.tooltip
            , defaultDetails = ms.defaultDetails
            , messages = ms.messages
            }

        Custom ->
            Player.methods

        Generated generator ->
            Generated.methods generator

        Fake fakeName ->
            Fake.methods fakeName


externalMethods : External -> ExternalMethods msg
externalMethods external =
    case external of
        ManyDecks url ->
            ManyDecks.methods url

        BuiltIn id ->
            BuiltIn.methods id

        JsonAgainstHumanity id ->
            JsonAgainstHumanity.methods id
