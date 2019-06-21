module MassiveDecks.Card.Play exposing
    ( Id
    , Known
    , Play
    , asKnown
    )

import MassiveDecks.Card.Model as Card


{-| The id for a play.
-}
type alias Id =
    String


{-| A known or unknown play.
-}
type alias Play =
    { id : Id
    , responses : Maybe (List Card.Response)
    }


{-| A known play.
-}
type alias Known =
    { id : Id
    , responses : List Card.Response
    }


{-| Get a play as a known play, if possible.
-}
asKnown : Play -> Maybe Known
asKnown play =
    play.responses |> Maybe.map (Known play.id)
