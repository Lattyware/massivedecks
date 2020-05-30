module MassiveDecks.Game.Round.Playing exposing
    ( init
    , view
    )

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Html.Keyed as HtmlK
import List.Extra as List
import MassiveDecks.Card as Card
import MassiveDecks.Card.Call as Call
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Response as Response
import MassiveDecks.Game.Action.Model as Action
import MassiveDecks.Game.Messages as Game exposing (Msg)
import MassiveDecks.Game.Model exposing (..)
import MassiveDecks.Game.Player as Player
import MassiveDecks.Game.Round as Round
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Strings as Strings
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Random as Random
import Random
import Set exposing (Set)


init : (Msg -> msg) -> Round.Playing -> Round.Pick -> ( Round.Playing, Cmd msg )
init wrap round pick =
    let
        cmd =
            round.players
                |> playStylesGenerator (Call.slotCount round.call)
                |> Random.generate (Game.SetPlayStyles >> wrap)
    in
    ( { round | pick = pick }
    , cmd
    )


view : (Msg -> msg) -> Lobby.Auth -> Shared -> Config -> Dict User.Id User -> Model -> Round.Playing -> RoundView msg
view wrap auth shared config _ model round =
    let
        slots =
            Call.slotCount round.call

        missingFromPick =
            slots - (round.pick.cards |> Dict.size)

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
                (model.hand |> List.map (round.pick.cards |> viewHandCard wrap shared config model.filledCards))

        backgroundPlays =
            Html.div [ HtmlA.class "background-plays" ]
                (round.players |> Set.toList |> List.map (viewBackgroundPlay shared model.playStyles slots round.played))

        fillCustom _ p =
            List.find (\c -> c.details.id == p) model.hand
                |> Maybe.map (Card.fillFromDict model.filledCards >> .body)
                |> Maybe.withDefault ""

        picked =
            round.pick.cards |> Dict.map fillCustom
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


viewHandCard : (Msg -> msg) -> Shared -> Config -> Dict Card.Id String -> Dict Int Card.Id -> Card.Response -> ( String, Html msg )
viewHandCard wrap shared config filled picked response =
    let
        details =
            response.details
    in
    ( details.id
    , Response.viewPotentiallyCustom
        shared
        config
        Card.Front
        (\v -> Game.EditBlank details.id v |> wrap)
        (\v -> Game.Fill details.id v |> wrap)
        [ HtmlA.classList [ ( "picked", picked |> Dict.values |> List.member details.id ) ]
        , details.id |> Game.Pick Nothing |> wrap |> HtmlE.onClick
        ]
        filled
        response
    )


viewBackgroundPlay : Shared -> PlayStyles -> Int -> Set User.Id -> User.Id -> Html msg
viewBackgroundPlay shared playStyles slots played for =
    let
        cards =
            playStyles
                |> Dict.get for
                |> Maybe.withDefault (List.repeat slots { rotation = 0 })
                |> List.map (viewBackgroundPlayCard shared)
    in
    Html.div
        [ HtmlA.classList [ ( "play", True ), ( "played", Set.member for played ) ] ]
        cards


viewBackgroundPlayCard : Shared -> CardStyle -> Html msg
viewBackgroundPlayCard shared playStyle =
    Response.viewUnknown shared
        [ "--rotation: " ++ String.fromFloat playStyle.rotation ++ "turn" |> HtmlA.attribute "style"
        , HtmlA.class "ignore-minimal-card-size"
        ]


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
