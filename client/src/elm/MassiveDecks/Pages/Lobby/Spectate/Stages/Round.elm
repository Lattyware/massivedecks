module MassiveDecks.Pages.Lobby.Spectate.Stages.Round exposing (view)

import Dict exposing (Dict)
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Card.Call as Call
import MassiveDecks.Card.Model as Card exposing (Call)
import MassiveDecks.Card.Parts as Parts
import MassiveDecks.Card.Play as Play exposing (Play)
import MassiveDecks.Card.Response as Response
import MassiveDecks.Game.Model as Game
import MassiveDecks.Game.Round as Round exposing (Round)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Maybe as Maybe
import Round
import Set exposing (Set)


view : Shared -> Config -> Dict User.Id User -> Game.Model -> List (Html msg)
view shared config users game =
    case game.game.round of
        Round.P playing ->
            viewPlaying shared config game.playStyles playing

        Round.R revealing ->
            viewRevealing shared config users revealing

        Round.J judging ->
            viewJudging shared config users judging

        Round.C complete ->
            viewComplete shared config users complete



{- Private -}


viewPlaying : Shared -> Config -> Game.PlayStyles -> Round.Playing -> List (Html msg)
viewPlaying shared config playStyles round =
    let
        slots =
            round.call |> Call.slotCount
    in
    [ viewCall shared config Nothing round.call
    , viewUnknownPlays shared slots playStyles round.players round.played
    ]


viewRevealing : Shared -> Config -> Dict User.Id User -> Round.Revealing -> List (Html msg)
viewRevealing shared config users round =
    let
        fillWith =
            case round.plays |> List.filter (\p -> Just p.id == round.lastRevealed) of
                play :: [] ->
                    play.responses |> Maybe.map Parts.fillsFromPlay

                _ ->
                    Nothing

        plays =
            round.plays |> List.map (\p -> ( Nothing, p.responses |> Maybe.map (\r -> { play = r, likes = Nothing }) ))
    in
    [ viewCall shared config fillWith round.call
    , viewPlays shared config (round.call |> Call.slotCount) users Nothing plays
    ]


viewJudging : Shared -> Config -> Dict User.Id User -> Round.Judging -> List (Html msg)
viewJudging shared config users round =
    let
        plays =
            round.plays |> List.map (\p -> ( Nothing, Just { play = p.responses, likes = Nothing } ))
    in
    [ viewCall shared config Nothing round.call
    , viewPlays shared config (round.call |> Call.slotCount) users Nothing plays
    ]


viewComplete : Shared -> Config -> Dict User.Id User -> Round.Complete -> List (Html msg)
viewComplete shared config users round =
    let
        plays =
            round.playOrder |> List.map (\u -> ( Just u, Dict.get u round.plays ))

        winner =
            Dict.get round.winner round.plays |> Maybe.map (.play >> Parts.fillsFromPlay)
    in
    [ viewCall shared config winner round.call
    , viewPlays shared config (round.call |> Call.slotCount) users (Just round.winner) plays
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


viewPlays : Shared -> Config -> Int -> Dict User.Id User -> Maybe User.Id -> List ( Maybe User.Id, Maybe Play.WithLikes ) -> Html msg
viewPlays shared config slotCount users winner plays =
    let
        angle =
            plays |> List.length |> anglePerPlay
    in
    Html.ul [ HtmlA.id "plays" ] (plays |> List.indexedMap (viewPlayByIndex shared config slotCount users winner angle))


viewPlayByIndex : Shared -> Config -> Int -> Dict User.Id User -> Maybe User.Id -> Float -> Int -> ( Maybe User.Id, Maybe Play.WithLikes ) -> Html msg
viewPlayByIndex shared config slotCount users winner angle index ( user, play ) =
    let
        isWinner =
            case winner of
                Just w ->
                    user == Just w

                Nothing ->
                    False
    in
    viewPlay shared config slotCount (toFloat index * angle) (user |> Maybe.andThen (\u -> Dict.get u users)) isWinner play


anglePerPlay : Int -> Float
anglePerPlay total =
    turns 1 / toFloat total


closeDistance : number
closeDistance =
    35


farDistance : number
farDistance =
    150


viewPlay : Shared -> Config -> Int -> Float -> Maybe User -> Bool -> Maybe Play.WithLikes -> Html msg
viewPlay shared config slotCount angle playedBy isWinner play =
    Html.li
        (positionFromAngle angle closeDistance)
        [ Html.div [ HtmlA.class "with-byline" ]
            [ Html.span [ HtmlA.class "byline" ]
                (List.filterMap identity
                    [ Icon.viewIcon Icon.trophy |> Maybe.justIf isWinner
                    , playedBy |> Maybe.map (.name >> Html.text)
                    , play |> Maybe.andThen .likes |> Maybe.map (\l -> Strings.Likes { total = l } |> Lang.html shared)
                    ]
                )
            , Html.ol
                [ HtmlA.classList [ ( "play", True ), ( "card-set", True ) ]
                ]
                (play
                    |> Maybe.map (.play >> List.map (\response -> Html.li [] [ Response.view shared config Card.Front [] response ]))
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
