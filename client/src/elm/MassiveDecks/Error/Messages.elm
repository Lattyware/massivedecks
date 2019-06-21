module MassiveDecks.Error.Messages exposing (Msg(..))

import MassiveDecks.Error.Model exposing (Error)


type Msg
    = Add Error
    | Clear
