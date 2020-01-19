module MassiveDecks.Card.Play exposing
    ( Details
    , Id
    , Known
    , Play
    , WithLikes
    , asKnown
    , asPlay
    )

import MassiveDecks.Card.Model as Card
import MassiveDecks.User as User


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


{-| Details we find out about a play when the round is complete.
-}
type alias Details =
    { playedBy : User.Id
    , likes : Maybe Int
    }


{-| A play with the number of likes it received.
-}
type alias WithLikes =
    { play : List Card.Response
    , likes : Maybe Int
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


{-| Get a known play as a general play.
-}
asPlay : Known -> Play
asPlay known =
    Play known.id (Just known.responses)
