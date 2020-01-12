module MassiveDecks.Game.Round.Playing exposing
    ( init
    , view
    )

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Html.Keyed as HtmlK
import MassiveDecks.Card.Call as Call
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Response as Response
import MassiveDecks.Game.Action.Model as Action
import MassiveDecks.Game.Messages as Game
import MassiveDecks.Game.Model exposing (..)
import MassiveDecks.Game.Player as Player
import MassiveDecks.Game.Round as Round
import MassiveDecks.Messages as Global
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Pages.Lobby.Messages as Lobby
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Strings as Strings
import MassiveDecks.User as User
import MassiveDecks.Util.List as List
import MassiveDecks.Util.Random as Random
import Random
import Set exposing (Set)


init : Round.Playing -> Round.Pick -> ( Round.Playing, Cmd Global.Msg )
init round pick =
    let
        cmd =
            round.players
                |> playStylesGenerator (Call.slotCount round.call)
                |> Random.generate (Game.SetPlayStyles >> lift)
    in
    ( { round | pick = pick }
    , cmd
    )


view : Lobby.Auth -> Config -> Model -> Round.Playing -> RoundView Global.Msg
view auth config model round =
    let
        slots =
            Call.slotCount round.call

        missingFromPick =
            slots - (round.pick.cards |> List.length)

        self =
            auth.claims.uid

        ( action, instruction, notPlaying ) =
            if round.players |> Set.member self then
                case round.pick.state of
                    Round.Selected ->
                        if missingFromPick > 0 then
                            ( Nothing, Strings.PlayInstruction { numberOfCards = missingFromPick }, False )

                        else
                            ( Just Action.Submit, Strings.SubmitInstruction, False )

                    Round.Submitted ->
                        ( Just Action.TakeBack, Strings.WaitingForPlaysInstruction, True )

            else if Player.isCzar (Round.P round) self then
                ( Nothing, Strings.CzarsDontPlayInstruction, True )

            else
                ( Nothing, Strings.NotInRoundInstruction, True )

        hand =
            HtmlK.ul [ HtmlA.classList [ ( "hand", True ), ( "cards", True ), ( "not-playing", notPlaying ) ] ]
                (model.hand |> List.map (round.pick.cards |> viewHandCard config))

        backgroundPlays =
            Html.div [ HtmlA.class "background-plays" ]
                (round.players |> Set.toList |> List.map (viewBackgroundPlay model.playStyles slots round.played))

        picked =
            round.pick.cards
                |> List.map (\id -> List.find (\c -> c.details.id == id) model.hand)
                |> List.filterMap identity
    in
    { instruction = Just instruction
    , action = action
    , content =
        Html.div []
            [ hand
            , backgroundPlays
            ]
    , fillCallWith = picked
    }



{- Private -}


viewHandCard : Config -> List Card.Id -> Card.Response -> ( String, Html Global.Msg )
viewHandCard config picked response =
    ( response.details.id
    , Response.view
        config
        Card.Front
        [ HtmlA.classList [ ( "picked", List.member response.details.id picked ) ]
        , response.details.id |> Game.Pick |> lift |> HtmlE.onClick
        ]
        response
    )


viewBackgroundPlay : PlayStyles -> Int -> Set User.Id -> User.Id -> Html msg
viewBackgroundPlay playStyles slots played for =
    let
        -- TODO: Move to css variable --rotation when possible.
        cards =
            playStyles
                |> Dict.get for
                |> Maybe.withDefault (List.repeat slots { rotation = 0 })
                |> List.map viewBackgroundPlayCard
    in
    Html.div [ HtmlA.classList [ ( "play", True ), ( "played", Set.member for played ) ] ] cards


viewBackgroundPlayCard : CardStyle -> Html msg
viewBackgroundPlayCard playStyle =
    Response.viewUnknown
        [ "rotate(" ++ String.fromFloat playStyle.rotation ++ "turn)" |> HtmlA.style "transform" ]


lift : Game.Msg -> Global.Msg
lift msg =
    msg |> Lobby.GameMsg |> Global.LobbyMsg


playStylesGenerator : Int -> Set User.Id -> Random.Generator PlayStyles
playStylesGenerator cards players =
    Random.map Dict.fromList
        (players |> Set.toList |> List.map (playStylesEntryGenerator cards) |> Random.disparateList)


playStylesEntryGenerator : Int -> User.Id -> Random.Generator ( User.Id, List CardStyle )
playStylesEntryGenerator cards userId =
    Random.map (\playStyles -> ( userId, playStyles ))
        (Random.list cards playStyleGenerator)


playStyleGenerator : Random.Generator CardStyle
playStyleGenerator =
    Random.map CardStyle
        (Random.float 0 1)
