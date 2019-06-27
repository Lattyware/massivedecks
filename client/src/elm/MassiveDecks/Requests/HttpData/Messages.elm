module MassiveDecks.Requests.HttpData.Messages exposing (Msg(..))

import MassiveDecks.Requests.Request as Request


{-| A message for HttpData.
-}
type Msg error result
    = Pull
    | Response (Request.Response error result)
