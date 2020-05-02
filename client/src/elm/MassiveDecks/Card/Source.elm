module MassiveDecks.Card.Source exposing
    ( default
    , defaultDetails
    , editor
    , empty
    , emptyMatching
    , equals
    , externalAndEquals
    , generalEditor
    , loadFailureReasonMessage
    , logo
    , name
    , problems
    , tooltip
    )

import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Card.Source.BuiltIn as BuiltIn
import MassiveDecks.Card.Source.Cardcast as Cardcast
import MassiveDecks.Card.Source.Custom as Player
import MassiveDecks.Card.Source.Fake as Fake
import MassiveDecks.Card.Source.Methods exposing (..)
import MassiveDecks.Card.Source.Model exposing (..)
import MassiveDecks.Components.Form.Message exposing (Message)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Decks.Model exposing (DeckOrError)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Maybe as Maybe
import Weightless as Wl
import Weightless.Attributes as WlA


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
generalMethods : String -> Maybe (ExternalGeneralMethods msg)
generalMethods n =
    case n of
        "BuiltIn" ->
            BuiltIn.generalMethods |> Just

        "Cardcast" ->
            Cardcast.generalMethods |> Just

        _ ->
            Nothing


{-| Get an empty source of the given type.
-}
empty : Shared -> String -> Maybe External
empty shared n =
    generalMethods n |> Maybe.map (\m -> m.empty shared)


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


{-| The default details for a source.
-}
defaultDetails : Shared -> Source -> Details
defaultDetails shared source =
    (methods source |> .defaultDetails) shared


{-| A tooltip for a source.
-}
tooltip : Shared -> Source -> Maybe ( String, Html msg )
tooltip shared source =
    case shared |> (methods source |> .tooltip) of
        Just ( id, rendered ) ->
            Just
                ( id
                , Wl.tooltip
                    (List.concat
                        [ [ WlA.anchor id
                          , WlA.fixed
                          , WlA.anchorOpenEvents [ "mouseover" ]
                          , WlA.anchorCloseEvents [ "mouseout" ]
                          ]
                        , WlA.anchorOrigin WlA.XRight WlA.YCenter
                        , WlA.transformOrigin WlA.XLeft WlA.YCenter
                        ]
                    )
                    [ rendered ]
                )

        Nothing ->
            Nothing


{-| The logo for a source.
-}
logo : Source -> Maybe (Html msg)
logo source =
    () |> (methods source |> .logo)


{-| An editor for any supported external source.
-}
generalEditor : Shared -> List DeckOrError -> External -> (External -> msg) -> List (Html msg)
generalEditor shared existing currentValue update =
    let
        enabledSources =
            [ shared.sources.builtIn |> Maybe.map (\_ -> BuiltIn.generalMethods)
            , Cardcast.generalMethods |> Maybe.justIf shared.sources.cardcast
            ]

        toOption source =
            Html.option [ HtmlA.value (source.id ()) ]
                [ () |> source.name |> Lang.html shared
                ]
    in
    [ Wl.select
        [ HtmlA.id "source-selector"
        , WlA.outlined
        , HtmlE.onInput (empty shared >> Maybe.withDefault (default shared) >> update)
        ]
        (enabledSources |> List.filterMap (Maybe.map toOption))
    , editor shared existing currentValue update
    ]


{-| An editor for the given source value.
-}
editor : Shared -> List DeckOrError -> External -> (External -> msg) -> Html msg
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
            }

        Custom ->
            Player.methods

        Fake fakeName ->
            Fake.methods fakeName


externalMethods : External -> ExternalMethods msg
externalMethods external =
    case external of
        Cardcast playCode ->
            Cardcast.methods playCode

        BuiltIn id ->
            BuiltIn.methods id
