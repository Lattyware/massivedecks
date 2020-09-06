module MassiveDecks.Game.Round.Playing exposing
    ( init
    , view
    )

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Html.Keyed as HtmlK
import Html5.DragDrop as DragDrop
import List.Extra as List
import MassiveDecks.Card as Card
import MassiveDecks.Card.Call as Call
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Parts as Parts
import MassiveDecks.Card.Response as Response
import MassiveDecks.Game.Action.Model as Action
import MassiveDecks.Game.Messages as Game exposing (Msg)
import MassiveDecks.Game.Model exposing (..)
import MassiveDecks.Game.Player as Player
import MassiveDecks.Game.Round as Round exposing (Round)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Strings as Strings
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Html.Attributes as HtmlA
import MassiveDecks.Util.Random as Random
import Random
import Set exposing (Set)


init : (Msg -> msg) -> Round.Specific Round.Playing -> Round.Pick -> ( Round, Cmd msg )
init wrap round pick =
    let
        cmd =
            round.players
                |> playStylesGenerator (Call.slotCount round.call)
                |> Random.generate (Game.SetPlayStyles >> wrap)

        stage =
            round.stage
    in
    ( round |> Round.withStage (Round.P { stage | pick = pick })
    , cmd
    )


view : (Msg -> msg) -> Lobby.Auth -> Shared -> Config -> Dict User.Id User -> Model -> Round.Specific Round.Playing -> RoundView msg
view wrap auth shared config _ model round =
    let
        slots =
            Call.slotCount round.call

        stage =
            round.stage

        missingFromPick =
            slots - (stage.pick.cards |> Dict.size)

        self =
            auth.claims.uid

        ( action, instruction, notPlaying ) =
            if round.players |> Set.member self then
                case stage.pick.state of
                    Round.Selected ->
                        if missingFromPick > 0 then
                            ( Nothing, Strings.PlayInstruction { numberOfCards = missingFromPick }, False )

                        else
                            ( Just Action.Submit, Strings.SubmitInstruction, False )

                    Round.Submitted ->
                        ( Just Action.TakeBack, Strings.WaitingForPlaysInstruction, True )

            else if Player.isCzar round self then
                ( Nothing, Strings.CzarsDontPlayInstruction, True )

            else
                ( Nothing, Strings.NotInRoundInstruction, True )

        hand =
            HtmlK.ul
                [ HtmlA.classList
                    [ ( "hand", True )
                    , ( "cards", True )
                    , ( "not-playing", notPlaying )
                    , ( "show-slot-indices", slots > 1 )
                    , ( "pick-full", missingFromPick < 1 )
                    ]
                ]
                (model.hand |> List.map (stage.pick.cards |> viewHandCard wrap shared config model.filledCards))

        backgroundPlays =
            Html.div [ HtmlA.class "background-plays" ]
                (round.players |> Set.toList |> List.map (viewBackgroundPlay shared model.playStyles slots stage.played))

        fillCustom _ p =
            List.find (\c -> c.details.id == p) model.hand
                |> Maybe.map (Card.fillFromDict model.filledCards >> .body)
                |> Maybe.withDefault ""

        picked =
            stage.pick.cards |> Dict.map fillCustom

        showNonObviousSlotIndices =
            if round.call.body |> Parts.nonObviousSlotIndices then
                [ HtmlA.class "show-slot-indices" ]

            else
                []

        slotAttrs i =
            List.concat
                [ [ Game.Unpick i |> wrap |> HtmlE.onClick ]
                , DragDrop.droppable (Game.Drag >> wrap) i
                , stage.pick.cards
                    |> Dict.get i
                    |> Maybe.map (DragDrop.draggable (Game.Drag >> wrap))
                    |> Maybe.withDefault []
                ]
    in
    { instruction = Just instruction
    , action = action
    , content =
        Html.div []
            [ hand
            , backgroundPlays
            ]
    , slotAttrs = slotAttrs
    , fillCallWith = picked
    , roundAttrs = List.concat [ [ HtmlA.class "playing" ], showNonObviousSlotIndices ]
    }



{- Private -}


viewHandCard : (Msg -> msg) -> Shared -> Config -> Dict Card.Id String -> Dict Int Card.Id -> Card.Response -> ( String, Html msg )
viewHandCard wrap shared config filled picked response =
    let
        details =
            response.details

        pick =
            picked |> Dict.filter (\_ v -> v == details.id) |> Dict.toList |> List.head

        pickedForSlot ( i, _ ) =
            HtmlA.attribute "data-picked-for-slot-index" (i + 1 |> String.fromInt)

        attrs =
            List.concat
                [ [ HtmlA.classList [ ( "picked", pick /= Nothing ) ]
                  , pick |> Maybe.map pickedForSlot |> Maybe.withDefault HtmlA.nothing
                  , details.id |> Game.Pick Nothing |> wrap |> HtmlE.onClick
                  ]
                , DragDrop.draggable (Game.Drag >> wrap) details.id
                ]
    in
    ( details.id
    , Response.viewPotentiallyCustom
        shared
        config
        Card.Front
        (\v -> Game.EditBlank details.id v |> wrap)
        (\v -> Game.Fill details.id v |> wrap)
        attrs
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
