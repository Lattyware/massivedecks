module MassiveDecks.Util.Cmd exposing (after)

{-| Utility methods for commands.
-}

import Process
import Task


{-| Trigger the given message after the given (in milliseconds) amount of time.
-}
after : Int -> msg -> Cmd msg
after delay message =
    delay |> toFloat |> Process.sleep |> Task.perform (always message)
