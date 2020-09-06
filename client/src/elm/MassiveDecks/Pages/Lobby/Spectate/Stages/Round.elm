module MassiveDecks.Pages.Lobby.Spectate.Stages.Round exposing (view)

import Dict exposing (Dict)
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Card.Call as Call
import MassiveDecks.Card.Model as Card exposing (Call)
import MassiveDecks.Card.Parts as Parts
import MassiveDecks.Card.Play as Play exposing (Play)
import MassiveDecks.Card.Response as Response
import MassiveDecks.Game.Action as Action
import MassiveDecks.Game.Action.Model as Action
import MassiveDecks.Game.Messages as Game
import MassiveDecks.Game.Model as Game
import MassiveDecks.Game.Round as Round exposing (Round)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Dict as Dict
import MassiveDecks.Util.Maybe as Maybe
import Round
import Set exposing (Set)


view : (Game.Msg -> msg) -> Shared -> Config -> Dict User.Id User -> Game.Model -> List (Html msg)
view wrapGame shared config users game =
    let
        round =
            game.game.round
    in
    case round.stage of
        Round.P playing ->
            viewPlaying shared config game.playStyles round playing

        Round.R revealing ->
            viewRevealing wrapGame shared config users round revealing

        Round.J judging ->
            viewJudging wrapGame shared config users round judging

        Round.C complete ->
            viewComplete wrapGame shared config users round complete



{- Private -}


viewPlaying : Shared -> Config -> Game.PlayStyles -> Round -> Round.Playing -> List (Html msg)
viewPlaying shared config playStyles round stage =
    let
        slots =
            round.call |> Call.slotCount
    in
    [ viewCall shared config Nothing round.call
    , viewUnknownPlays shared slots playStyles round.players stage.played
    ]


viewRevealing : (Game.Msg -> msg) -> Shared -> Config -> Dict User.Id User -> Round -> Round.Revealing -> List (Html msg)
viewRevealing wrapGame shared config users round stage =
    let
        fillWith =
            case stage.plays |> List.filter (\p -> Just p.id == stage.lastRevealed) of
                play :: [] ->
                    play.responses |> Maybe.map Parts.fillsFromPlay

                _ ->
                    Nothing

        potential { id, responses } =
            ( id
            , { play = responses
              , playedBy = Nothing
              , likes = Nothing
              }
            )

        plays =
            stage.plays |> List.map potential
    in
    [ viewCall shared config fillWith round.call
    , viewPlays wrapGame shared config (round.call |> Call.slotCount) users Nothing stage.pick stage.likeDetail plays
    , Action.view wrapGame shared (Action.Like |> Maybe.justIf (stage.pick /= Nothing))
    ]


viewJudging : (Game.Msg -> msg) -> Shared -> Config -> Dict User.Id User -> Round -> Round.Judging -> List (Html msg)
viewJudging wrapGame shared config users round stage =
    let
        potential { id, responses } =
            ( id
            , { play = Just responses
              , playedBy = Nothing
              , likes = Nothing
              }
            )

        plays =
            stage.plays |> List.map potential
    in
    [ viewCall shared config Nothing round.call
    , viewPlays wrapGame shared config (round.call |> Call.slotCount) users Nothing stage.pick stage.likeDetail plays
    , Action.view wrapGame shared (Action.Like |> Maybe.justIf (stage.pick /= Nothing))
    ]


viewComplete : (Game.Msg -> msg) -> Shared -> Config -> Dict User.Id User -> Round -> Round.Complete -> List (Html msg)
viewComplete wrapGame shared config users round stage =
    let
        potential id { play, playedBy, likes } =
            ( id
            , { play = Just play
              , playedBy = Just playedBy
              , likes = likes
              }
            )

        plays =
            stage.playOrder |> List.filterMap (\id -> id |> Dict.getFrom stage.plays |> Maybe.map (potential id))

        winner =
            Dict.get stage.winner stage.plays |> Maybe.map (.play >> Parts.fillsFromPlay)
    in
    [ viewCall shared config winner round.call
    , viewPlays wrapGame shared config (round.call |> Call.slotCount) users (Just stage.winner) stage.pick stage.likeDetail plays
    , Action.view wrapGame shared (Action.Like |> Maybe.justIf (stage.pick /= Nothing))
    ]


viewCall : Shared -> Config -> Maybe Parts.Fills -> Call -> Html msg
viewCall shared config fillWith call =
    Html.div [ HtmlA.id "call-wrapper" ]
        [ Call.viewFilled shared config Card.Front [] (always []) (fillWith |> Maybe.withDefault Dict.empty) call
        ]


viewUnknownPlays : Shared -> Int -> Game.PlayStyles -> Set User.Id -> Set User.Id -> Html msg
viewUnknownPlays shared slotCount playStyles players played =
    let
        angle =
            players |> Set.size |> anglePerPlay

        getPlayStyle =
            (\u -> Dict.get u playStyles) >> Maybe.withDefault (List.repeat slotCount { rotation = 0 })
    in
    Html.ul [ HtmlA.id "plays" ]
        (players
            |> Set.toList
            |> List.indexedMap (\i -> \u -> viewUnknownPlay shared (toFloat i * angle) (getPlayStyle u) (Set.member u played))
        )


viewPlays : (Game.Msg -> msg) -> Shared -> Config -> Int -> Dict User.Id User -> Maybe User.Id -> Maybe Play.Id -> Round.LikeDetail -> List ( Play.Id, Play.Potential ) -> Html msg
viewPlays wrapGame shared config slotCount users winner picked likeDetail plays =
    let
        angle =
            plays |> List.length |> anglePerPlay
    in
    Html.ul [ HtmlA.id "plays" ] (plays |> List.indexedMap (viewPlayByIndex wrapGame shared config slotCount users winner picked likeDetail angle))


viewPlayByIndex : (Game.Msg -> msg) -> Shared -> Config -> Int -> Dict User.Id User -> Maybe User.Id -> Maybe Play.Id -> Round.LikeDetail -> Float -> Int -> ( Play.Id, Play.Potential ) -> Html msg
viewPlayByIndex wrapGame shared config slotCount users winner picked likeDetail angle index ( playId, play ) =
    let
        isWinner =
            case winner of
                Just w ->
                    play.playedBy == Just w

                Nothing ->
                    False
    in
    viewPlay wrapGame shared config slotCount (toFloat index * angle) (play.playedBy |> Maybe.andThen (Dict.getFrom users)) isWinner picked likeDetail playId play


anglePerPlay : Int -> Float
anglePerPlay total =
    turns 1 / toFloat total


closeDistance : number
closeDistance =
    35


farDistance : number
farDistance =
    150


viewPlay : (Game.Msg -> msg) -> Shared -> Config -> Int -> Float -> Maybe User -> Bool -> Maybe Play.Id -> Round.LikeDetail -> Play.Id -> Play.Potential -> Html msg
viewPlay wrapGame shared config slotCount angle playedByUser isWinner picked likeDetail playId { play, playedBy, likes } =
    let
        isLiked =
            likeDetail.liked |> Set.member playId

        action =
            if play /= Nothing && likeDetail.played /= Just playId && not isLiked then
                playId |> Game.PickPlay |> wrapGame |> HtmlE.onClick |> Just

            else
                Nothing
    in
    Html.li
        (positionFromAngle angle closeDistance)
        [ Html.div [ HtmlA.class "with-byline", action |> Maybe.withDefault (HtmlA.disabled True) ]
            [ Html.span [ HtmlA.class "byline" ]
                (List.filterMap identity
                    [ Icon.viewIcon Icon.trophy |> Maybe.justIf isWinner
                    , playedByUser |> Maybe.map (.name >> Html.text)
                    , likes |> Maybe.map (\l -> Strings.Likes { total = l } |> Lang.html shared)
                    ]
                )
            , Html.ol
                [ HtmlA.classList
                    [ ( "play", True )
                    , ( "card-set", True )
                    , ( "active", action /= Nothing )
                    , ( "picked", picked == Just playId )
                    , ( "liked", isLiked )
                    ]
                ]
                (play
                    |> Maybe.map (List.map (\response -> Html.li [] [ Response.view shared config Card.Front [] response ]))
                    |> Maybe.withDefault (List.repeat slotCount (Html.li [] [ Response.viewUnknown shared [] ]))
                )
            ]
        ]


viewUnknownPlay : Shared -> Float -> Game.PlayStyle -> Bool -> Html msg
viewUnknownPlay shared angle playStyle played =
    let
        distance =
            if played then
                closeDistance

            else
                farDistance
    in
    Html.li
        (positionFromAngle angle distance)
        [ Html.div [ HtmlA.class "with-byline" ]
            [ Html.span [ HtmlA.class "byline" ] []
            , Html.ol
                [ HtmlA.classList [ ( "play", True ), ( "card-set", True ) ]
                ]
                (playStyle |> List.map (\cardStyle -> Html.li [] [ Response.viewUnknown shared [ rotated cardStyle.rotation ] ]))
            ]
        ]


positionFromAngle : Float -> Float -> List (Html.Attribute msg)
positionFromAngle angle distance =
    let
        startFromLeft =
            turns 0.5 + angle

        left =
            cos startFromLeft * distance

        top =
            sin startFromLeft * distance
    in
    [ HtmlA.style "left" (Round.round 4 left ++ "em")
    , HtmlA.style "top" (Round.round 4 top ++ "em")
    ]


rotated : Float -> Html.Attribute msg
rotated angle =
    HtmlA.style "transform" ("rotateZ(" ++ Round.round 6 angle ++ "turn)")
