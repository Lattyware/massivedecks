module MassiveDecks.Card.Source exposing
    ( default
    , defaultDetails
    , editor
    , empty
    , emptyMatching
    , equals
    , externalAndEquals
    , generalEditor
    , logo
    , name
    , problems
    , tooltip
    )

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Card.Source.Cardcast as Cardcast
import MassiveDecks.Card.Source.Fake as Fake
import MassiveDecks.Card.Source.Methods exposing (..)
import MassiveDecks.Card.Source.Model exposing (..)
import MassiveDecks.Card.Source.Player as Player
import MassiveDecks.Components.Form.Message exposing (Message)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User exposing (User)
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
name : Shared -> Source -> String
name shared source =
    (methods source |> .name) shared


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
generalEditor : Shared -> External -> (External -> msg) -> List (Html msg)
generalEditor shared currentValue update =
    [ Wl.select
        [ HtmlA.id "source-selector"
        , WlA.outlined
        , HtmlE.onInput (empty >> Maybe.withDefault default >> update)
        ]
        [ Html.option [ HtmlA.value "Cardcast" ]
            [ Strings.Cardcast |> Lang.html shared
            ]
        ]
    , editor shared currentValue update
    ]


{-| An editor for the given source value.
-}
editor : Shared -> External -> (External -> msg) -> Html msg
editor shared source =
    shared |> (externalMethods source |> .editor)



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

        Player ->
            Player.methods

        Fake ->
            Fake.methods


externalMethods : External -> ExternalMethods msg
externalMethods external =
    case external of
        Cardcast playCode ->
            Cardcast.methods playCode
