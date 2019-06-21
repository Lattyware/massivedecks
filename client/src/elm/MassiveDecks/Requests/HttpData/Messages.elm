module MassiveDecks.Requests.HttpData.Messages exposing (Msg(..))

import MassiveDecks.Error.Model as Error exposing (Error)


{-| A message for HttpData.
-}
type Msg result
    = Pull
    | Response (Result Error result)
