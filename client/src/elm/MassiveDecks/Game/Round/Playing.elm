module MassiveDecks.Game.Round.Playing exposing
    ( init
    , view
    )

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Html.Keyed as HtmlK
import MassiveDecks.Card as Card
import MassiveDecks.Card.Call as Call
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Response as Response
import MassiveDecks.Card.Source.Model as Source
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
import MassiveDecks.Util.List as List
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
view wrap auth shared config users model round =
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
                (model.hand |> List.map (round.pick.cards |> viewHandCard wrap shared config model.filledCards))

        backgroundPlays =
            Html.div [ HtmlA.class "background-plays" ]
                (round.players |> Set.toList |> List.map (viewBackgroundPlay model.playStyles slots round.played))

        picked =
            round.pick.cards
                |> List.map (\p -> List.find (\c -> (Card.details c).id == p.id) model.hand)
                |> List.filterMap identity
                |> List.map (Card.asResponseFromDict model.filledCards)
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


viewHandCard : (Msg -> msg) -> Shared -> Config -> Dict Card.Id String -> List Card.Played -> Card.PotentiallyBlankResponse -> ( String, Html msg )
viewHandCard wrap shared config filled picked response =
    let
        details =
            Card.details response

        fill =
            case details.source of
                Source.Player ->
                    (filled |> Dict.get details.id) |> Maybe.withDefault "" |> Just

                _ ->
                    Nothing
    in
    ( details.id
    , Response.viewPotentiallyBlank
        shared
        config
        Card.Front
        (\v -> Game.EditBlank details.id v |> wrap)
        [ HtmlA.classList [ ( "picked", picked |> List.map .id |> List.member details.id ) ]
        , Card.Played details.id fill |> Game.Pick |> wrap |> HtmlE.onClick
        ]
        filled
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
    Html.div
        [ HtmlA.classList [ ( "play", True ), ( "played", Set.member for played ) ] ]
        cards


viewBackgroundPlayCard : CardStyle -> Html msg
viewBackgroundPlayCard playStyle =
    Response.viewUnknown
        [ "rotate(" ++ String.fromFloat playStyle.rotation ++ "turn)" |> HtmlA.style "transform"
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
