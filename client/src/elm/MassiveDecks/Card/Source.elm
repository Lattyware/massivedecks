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
import Weightless as Wl
import Weightless.Attributes as WlA


{-| The default source for an editor.
-}
default : External
default =
    Cardcast.generalMethods.empty ()


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


{-| Get an empty source of the given type.
-}
empty : String -> Maybe External
empty n =
    case n of
        "Cardcast" ->
            () |> Cardcast.generalMethods.empty |> Just

        _ ->
            Nothing


{-| An empty source of the same general type as the given one.
-}
emptyMatching : External -> External
emptyMatching source =
    () |> (externalMethods source |> .empty)


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
tooltip : Source -> Maybe ( String, Html msg )
tooltip source =
    case () |> (methods source |> .tooltip) of
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
    [ Wl.select
        [ HtmlA.id "source-selector"
        , WlA.outlined
        , HtmlE.onInput (empty >> Maybe.withDefault default >> update)
        ]
        [ Html.option [ HtmlA.value "Cardcast" ]
            [ Strings.Cardcast |> Lang.html shared
            ]
        ]
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

        Fake ->
            Fake.methods


externalMethods : External -> ExternalMethods msg
externalMethods external =
    case external of
        Cardcast playCode ->
            Cardcast.methods playCode
