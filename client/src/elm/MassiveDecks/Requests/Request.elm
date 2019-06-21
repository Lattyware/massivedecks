module MassiveDecks.Requests.Request exposing (Request)

import Http


type alias Request msg =
    { method : String
    , headers : List Http.Header
    , url : String
    , body : Http.Body
    , expect : Http.Expect (Result Http.Error msg)
    , timeout : Maybe Float
    , tracker : Maybe String
    }
