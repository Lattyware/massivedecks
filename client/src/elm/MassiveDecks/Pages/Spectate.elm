module MassiveDecks.Pages.Spectate exposing
    ( changeRoute
    , init
    , route
    , update
    , view
    )

import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Card as Card
import MassiveDecks.Card.Call as Call
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Parts as Parts
import MassiveDecks.Card.Play as Play exposing (Play)
import MassiveDecks.Card.Response as Response
import MassiveDecks.Card.Source.Cardcast.Model as Cardcast
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Messages exposing (..)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.GameCode as GameCode
import MassiveDecks.Pages.Route as Route
import MassiveDecks.Pages.Spectate.Messages as Spectate
import MassiveDecks.Pages.Spectate.Model exposing (..)
import MassiveDecks.Pages.Spectate.Route exposing (..)
import MassiveDecks.Pages.Start.Route as Start
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Random as Random
import QRCode
import Random
import Random.Float as Random
import Round
import Url exposing (Url)


changeRoute : Route -> Model -> ( Model, Cmd Msg )
changeRoute r model =
    ( { model | route = r }, Cmd.none )


init : Route -> ( Model, Cmd Msg )
init r =
    let
        call =
            Card.call
                ([ [ Parts.Slot Parts.None ] ] |> Parts.unsafeFromList)
                "test"
                ("B80VA" |> Cardcast.playCode |> Source.Cardcast |> Source.Ex)

        slots =
            Parts.slotCount call.body

        testPlays =
            [ Just "1"
            , Just "2"
            , Just "3"
            , Just "4"
            , Just "5"
            , Just "6"
            ]
                |> List.map playingPlay
    in
    ( { route = r
      , call = call
      , plays = Playing testPlays
      }
    , askForRotations slots testPlays
    )


route : Model -> Route
route model =
    model.route


update : Spectate.Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Spectate.Rotations animations ->
            case model.plays of
                Playing playing ->
                    let
                        newPlays =
                            animations
                                |> List.foldl updateMatchingPlays playing
                    in
                    ( { model | plays = Playing newPlays }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


view : Shared -> Model -> List (Html Msg)
view shared model =
    let
        playCount =
            model.plays |> getPlays |> List.length

        angle =
            turns 1 / toFloat playCount

        slots =
            Call.slotCount model.call

        qr =
            Route.externalUrl shared.origin (Route.Start { section = Start.Join (Just model.route.lobby.gameCode) })
                |> QRCode.encodeWith QRCode.Low
                |> Result.map (\encoded -> [ QRCode.toSvg encoded ])
                |> Result.withDefault []
    in
    [ Html.div
        [ HtmlA.class "spectate" ]
        [ Html.div [ HtmlA.class "middle" ]
            [ -- Call.view shared config Card.Front [] model.call
              --, HtmlA.style "--play-count" (model.plays |> List.length |> String.fromInt)
              Html.ul [ HtmlA.class "plays" ] (viewPlays shared slots angle model.plays)
            ]
        ]
    , Html.div [ HtmlA.class "join-info" ]
        [ Html.p [] [ Strings.JoinTheGame |> Lang.html shared ]
        , Html.p [] [ Strings.GameCode { code = GameCode.toString model.route.lobby.gameCode } |> Lang.html shared ]
        , Html.p [] [ Html.text (stripProtocol shared.origin) ]
        ]
    , Html.div [ HtmlA.class "qr-code" ] qr
    ]



{- Private -}


{-| We assume that the protocol and root path don't matter, to simplify the shown URL.
This should be fine as long as http redirects to https, which is good practice.
If the origin doesn't parse we probably have bigger problems, but we just return it unaltered.
-}
stripProtocol : String -> String
stripProtocol stringUrl =
    Url.fromString stringUrl
        |> Maybe.map fromUrl
        |> Maybe.withDefault stringUrl


fromUrl : Url -> String
fromUrl url =
    let
        portPart =
            case url.port_ of
                Nothing ->
                    ""

                Just port_ ->
                    ":" ++ String.fromInt port_

        pathPart =
            if url.path == "/" then
                ""

            else
                url.path
    in
    url.host ++ portPart ++ pathPart


updateMatchingPlays : { play : Play.Id, rotation : Rotations } -> List PlayingPlay -> List PlayingPlay
updateMatchingPlays animation plays =
    plays
        |> List.map
            (Maybe.map
                (\p ->
                    if p.play == animation.play then
                        { p | animation = Just animation.rotation }

                    else
                        p
                )
            )


getPlays : Plays -> List (Maybe Play)
getPlays round =
    case round of
        Playing plays ->
            plays |> List.map (Maybe.map (\pp -> Play pp.play Nothing))

        Judging plays ->
            plays |> List.map (\pp -> Just (Play pp.play.id (Just pp.play.responses)))

        Finished { plays } ->
            plays |> List.map (\pp -> Just (Play pp.play.id (Just pp.play.responses)))


askForRotations : Int -> List PlayingPlay -> Cmd Msg
askForRotations slots plays =
    plays
        |> List.filterMap (rotationForPlay slots)
        |> Random.disparateList
        |> Random.generate (SpectateMsg << Spectate.Rotations)


rotationForPlay : Int -> PlayingPlay -> Maybe (Random.Generator { play : Play.Id, rotation : Rotations })
rotationForPlay slots play =
    play
        |> Maybe.andThen
            (\p ->
                case p.animation of
                    Nothing ->
                        Random.map (\r -> { play = p.play, rotation = r })
                            (Random.list slots (Random.normal 0 0.25))
                            |> Just

                    _ ->
                        Nothing
            )


viewPlays : Shared -> Int -> Float -> Plays -> List (Html Msg)
viewPlays shared slots anglePerPlay plays =
    let
        renderedCards =
            case plays of
                Playing playingPlays ->
                    playingPlays
                        |> List.map
                            (\p ->
                                ( viewPlayingPlay slots p
                                , p
                                    |> Maybe.map (.animation >> (==) Nothing)
                                    |> Maybe.withDefault False
                                )
                            )

                Judging judgingPlays ->
                    judgingPlays |> List.map (\p -> ( viewKnownPlay shared p.play p.rotation, False ))

                Finished finishedPlays ->
                    finishedPlays.plays |> List.map (\p -> ( viewKnownPlay shared p.play p.rotation, False ))
    in
    List.indexedMap
        (\index ->
            \( play, offScreen ) ->
                let
                    angle =
                        toFloat index * anglePerPlay

                    distance =
                        if offScreen then
                            100

                        else
                            20
                in
                Html.li
                    ([ HtmlA.class "player", rotated (angle - turns 0.25) ]
                        ++ positionFromAngle angle distance
                    )
                    -- TODO: CSS custom variables can't be set right now.
                    [ Html.div [ HtmlA.class "play set", HtmlA.style "--cards-in-play" (String.fromInt slots) ] play
                    ]
        )
        renderedCards


positionFromAngle : Float -> Float -> List (Html.Attribute msg)
positionFromAngle angle distance =
    let
        left =
            cos angle * distance

        top =
            sin angle * distance
    in
    [ HtmlA.style "left" (Round.round 4 left ++ "em")
    , HtmlA.style "top" (Round.round 4 top ++ "em")
    ]


viewPlayingPlay : Int -> PlayingPlay -> List (Html msg)
viewPlayingPlay slots play =
    case play of
        Just p ->
            List.map
                (\a ->
                    Response.viewUnknown [ rotated a ]
                )
                (p.animation |> Maybe.withDefault (defaultedRotations slots p.animation))

        Nothing ->
            [ Icon.view Icon.clock ]


viewKnownPlay : Shared -> Play.Known -> Rotations -> List (Html msg)
viewKnownPlay shared play rotations =
    --List.map2 (\c -> \a -> Response.view config Card.Front [ rotated a ] c) play.responses rotations
    []


defaultedRotations : Int -> Maybe Rotations -> Rotations
defaultedRotations slots rotations =
    rotations |> Maybe.withDefault (List.repeat slots 0)


rotated : Float -> Html.Attribute msg
rotated angle =
    HtmlA.style "transform" ("rotateZ(" ++ Round.round 6 angle ++ "rad)")
