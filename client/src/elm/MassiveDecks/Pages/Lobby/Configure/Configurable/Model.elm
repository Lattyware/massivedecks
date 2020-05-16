module MassiveDecks.Pages.Lobby.Configure.Configurable.Model exposing
    ( Component(..)
    , Configurable
    , GlobalWrap
    , Group
    , Value
    , Wrap
    )

import Html exposing (Html)
import MassiveDecks.Components.Form.Message exposing (Message)
import MassiveDecks.Pages.Lobby.Configure.Configurable.Editor as Editor exposing (Editor)
import MassiveDecks.Pages.Lobby.Configure.Configurable.Validator as Validator exposing (Validator)


type alias Configurable id value model msg =
    GlobalWrap id value msg
    -> Component id value model msg


type alias GlobalWrap id value msg =
    { noOp : msg
    , config : Maybe value
    , update : id -> value -> msg
    }


type Component id value model msg
    = C
        { id : id
        , editor : Editor value model msg
        , validator : Validator value msg
        , equals : value -> value -> Bool
        , setTarget : id -> value -> value -> value
        , children : List (Component id value model msg)
        , messages : Maybe value -> List (Message msg)
        , isOption : Bool
        }


type alias Wrap pId pV id value =
    { id : id -> pId
    , get : pV -> Maybe value
    , set : value -> pV -> pV
    }


type alias Value id value model msg =
    { id : id
    , editor : Editor.Def value model msg
    , validator : Validator.Def value msg
    , messages : Maybe value -> List (Message msg)
    }


type alias Group id value model msg =
    { id : id
    , editor : List (Html msg) -> Editor.Def value model msg
    , children : List (Configurable id value model msg)
    }
