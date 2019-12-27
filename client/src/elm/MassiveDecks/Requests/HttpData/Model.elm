module MassiveDecks.Requests.HttpData.Model exposing
    ( HttpData
    , Pull
    )

import MassiveDecks.Error.Model exposing (Error)


{-| Some data that is requested and received via an HTTP request.
-}
type alias HttpData error result =
    { loading : Bool
    , data : Maybe result
    , error : Maybe error
    , generalError : Maybe Error
    }


{-| The command used to request data.
-}
type alias Pull msg =
    Cmd msg
