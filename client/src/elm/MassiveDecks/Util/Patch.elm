module MassiveDecks.Util.Patch exposing (..)

import Json.Encode as Json
import Json.Patch as Json
import Json.Pointer as Json


{-| Add, remove or replace a value in a patch based on old and new maybe values.
-}
addRemoveReplace : (value -> Json.Value) -> Json.Pointer -> Maybe value -> Maybe value -> Json.Patch
addRemoveReplace encode pointer old new =
    case old of
        Just _ ->
            case new of
                Just newValue ->
                    [ Json.Replace pointer (encode newValue) ]

                Nothing ->
                    [ Json.Remove pointer ]

        Nothing ->
            case new of
                Just newValue ->
                    [ Json.Add pointer (encode newValue) ]

                Nothing ->
                    []
