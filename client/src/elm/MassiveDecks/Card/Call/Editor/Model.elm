module MassiveDecks.Card.Call.Editor.Model exposing (Index, Model, Msg(..))

import Html5.DragDrop as DragDrop
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Parts as Parts
import MassiveDecks.Strings exposing (MdString)


type Msg
    = Select (Maybe Index)
    | Add Index Parts.Part
    | Set Index Parts.Part
    | Move Index Int
    | Remove Index
    | NoOp
    | DragDropMsg (DragDrop.Msg Index Index)


type alias Model =
    { source : Card.Call
    , selected : Maybe Index
    , parts : List Parts.Part
    , error : Maybe MdString
    , dragDrop : DragDrop.Model Index Index
    }


type alias Index =
    Int
