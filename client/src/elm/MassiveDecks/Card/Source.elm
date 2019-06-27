module MassiveDecks.Card.Source exposing
    ( default
    , details
    , editor
    , empty
    , emptyMatching
    , equals
    , logo
    , name
    , tooltip
    , validate
    )

import Html exposing (Html)
import MassiveDecks.Card.Source.Cardcast as Cardcast
import MassiveDecks.Card.Source.Fake as Fake
import MassiveDecks.Card.Source.Methods exposing (..)
import MassiveDecks.Card.Source.Model exposing (..)
import MassiveDecks.Components.Form.Message exposing (Message)
import MassiveDecks.Model exposing (..)
import Weightless as Wl
import Weightless.Attributes as WlA


default : External
default =
    Cardcast.empty


equals : Source -> Source -> Bool
equals a b =
    (methods a |> .equals) b


empty : String -> Maybe External
empty n =
    case n of
        "Cardcast" ->
            Just Cardcast.empty

        _ ->
            Nothing


emptyMatching : External -> External
emptyMatching source =
    source |> Ex |> name |> empty |> Maybe.withDefault default


name : Source -> String
name source =
    () |> (methods source |> .name)


validate : Source -> Maybe (Message msg)
validate source =
    () |> (methods source |> .problem)


details : Source -> Details
details source =
    () |> (methods source |> .details)


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


logo : Source -> Maybe (Html msg)
logo source =
    () |> (methods source |> .logo)


editor : Shared -> Source -> (External -> msg) -> Html msg
editor shared source =
    shared |> (methods source |> .editor)



{- Private -}


methods : Source -> Methods msg
methods source =
    case source of
        Ex external ->
            case external of
                Cardcast playCode ->
                    Cardcast.methods playCode

        Fake ->
            Fake.methods
