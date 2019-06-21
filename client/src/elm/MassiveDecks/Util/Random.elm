module MassiveDecks.Util.Random exposing (disparateList)

{-| Utility methods for random generation.
-}

import Random


{-| Take a `List` of `Generator` and give a `Generator` of a `List` of the results.
-}
disparateList : List (Random.Generator a) -> Random.Generator (List a)
disparateList generators =
    case generators of
        head :: tail ->
            Random.map2 (\firstGen -> \restGen -> firstGen :: restGen) head (Random.lazy (\() -> disparateList tail))

        [] ->
            Random.constant []
