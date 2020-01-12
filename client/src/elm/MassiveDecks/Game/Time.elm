module MassiveDecks.Game.Time exposing
    ( Anchor
    , PartialAnchor
    , Time
    , anchor
    , animate
    , every
    , millisecondsSince
    , now
    , partialAnchorDecoder
    , timeDecoder
    )

import Browser.Events as Browser
import Json.Decode as Json
import Task
import Time as LocalTime


{-| A time in the game.
-}
type Time
    = Local LocalTime.Posix
    | Remote Int


{-| Can be passed to anchor to make an Anchor.
-}
type PartialAnchor
    = PartialAnchor Int


{-| An anchor point which allows the application to map remote times to local times.
-}
type Anchor
    = Anchor AnchorInternal


{-| Get an anchor point using a partial anchor. This should be called immediately after receiving the partial anchor.
-}
anchor : (Anchor -> msg) -> PartialAnchor -> Cmd msg
anchor wrap (PartialAnchor remote) =
    LocalTime.now |> Task.perform (AnchorInternal remote >> Anchor >> wrap)


{-| Get the current time.
-}
now : (Time -> msg) -> Cmd msg
now wrap =
    LocalTime.now |> Task.perform (Local >> wrap)


{-| Get a game time every so many milliseconds.
-}
every : Float -> (Time -> msg) -> Sub msg
every milliseconds wrap =
    LocalTime.every milliseconds (Local >> wrap)


{-| Get a game time every animation frame.
-}
animate : (Time -> msg) -> Sub msg
animate wrap =
    Browser.onAnimationFrame (Local >> wrap)


{-| Work out how many milliseconds it has been since the given time.
The first time should be earlier for a positive result.
-}
millisecondsSince : Anchor -> Time -> Time -> Int
millisecondsSince (Anchor { remote, local }) start end =
    case start of
        Local localStart ->
            case end of
                Local localEnd ->
                    LocalTime.posixToMillis localEnd - LocalTime.posixToMillis localStart

                Remote remoteEnd ->
                    let
                        anchorToStart =
                            LocalTime.posixToMillis localStart - LocalTime.posixToMillis local

                        anchorToEnd =
                            remoteEnd - remote
                    in
                    anchorToEnd - anchorToStart

        Remote remoteStart ->
            case end of
                Local localEnd ->
                    let
                        anchorToStart =
                            remoteStart - remote

                        anchorToEnd =
                            LocalTime.posixToMillis localEnd - LocalTime.posixToMillis local
                    in
                    anchorToEnd - anchorToStart

                Remote remoteEnd ->
                    remoteEnd - remoteStart


{-| Decode a time from the server.
-}
timeDecoder : Json.Decoder Time
timeDecoder =
    Json.int |> Json.map Remote


{-| Decode a partial anchor.
-}
partialAnchorDecoder : Json.Decoder PartialAnchor
partialAnchorDecoder =
    Json.int |> Json.map PartialAnchor



{- Private -}


type alias AnchorInternal =
    { remote : Int
    , local : LocalTime.Posix
    }
