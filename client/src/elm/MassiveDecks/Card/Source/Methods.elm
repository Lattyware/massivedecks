module MassiveDecks.Card.Source.Methods exposing (Methods)

import Html exposing (Html)
import MassiveDecks.Card.Source.Model exposing (..)
import MassiveDecks.Components.Form.Message exposing (Message)
import MassiveDecks.Model exposing (..)


{-| A collection of methods applied to the source data.
-}
type alias Methods msg =
    { problem : () -> Maybe (Message msg)
    , details : () -> Details
    , tooltip : () -> Maybe ( String, Html msg )
    , logo : () -> Maybe (Html msg)
    , name : () -> String
    , editor : Shared -> (External -> msg) -> Html msg
    , equals : Source -> Bool
    }
