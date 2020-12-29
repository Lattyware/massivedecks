module MassiveDecks.Game.Round.Starting exposing (view)

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Html.Keyed as HtmlK
import MassiveDecks.Card.Call as Call
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Response as Response
import MassiveDecks.Game.Action.Model as Action exposing (Action)
import MassiveDecks.Game.Messages as Game exposing (Msg)
import MassiveDecks.Game.Model exposing (..)
import MassiveDecks.Game.Round as Round exposing (Round)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Maybe as Maybe


view : (Msg -> msg) -> Lobby.Auth -> Shared -> Config -> Dict User.Id User -> Model -> Round.Specific Round.Starting -> RoundView msg
view wrap _ shared config _ model round =
    let
        stage =
            round.stage

        { call, instruction, action, content } =
            case stage.calls of
                Just calls ->
                    let
                        findCallById id =
                            calls |> List.filter (.details >> .id >> (==) id) |> List.head
                    in
                    ViewSubset
                        (stage.pick |> Maybe.andThen findCallById)
                        Strings.PickCallInstruction
                        (Action.PickCall |> Maybe.justIf (stage.pick /= Nothing))
                        (calls |> viewOptions wrap shared config stage.pick)

                Nothing ->
                    ViewSubset
                        Nothing
                        Strings.WaitForCallInstruction
                        Nothing
                        (model.hand |> viewHand wrap shared config model.filledCards)
    in
    { call = call
    , instruction = Just instruction
    , action = action
    , content = content
    , slotAttrs = always []
    , fillCallWith = Dict.empty
    , roundAttrs = []
    }



{- Private -}


type alias ViewSubset msg =
    { call : Maybe Card.Call
    , instruction : MdString
    , action : Maybe Action
    , content : Html msg
    }


viewOptions : (Msg -> msg) -> Shared -> Config -> Maybe Card.Id -> List Card.Call -> Html msg
viewOptions wrap shared config pick calls =
    let
        viewOption call =
            let
                id =
                    call.details.id
            in
            ( id
            , Call.view
                shared
                config
                Card.Front
                [ HtmlA.classList [ ( "picked", pick == Just id ) ]
                , id |> Game.Pick Nothing |> wrap |> HtmlE.onClick
                ]
                call
            )
    in
    HtmlK.ul
        [ HtmlA.classList
            [ ( "options", True )
            , ( "cards", True )
            ]
        ]
        (calls |> List.map viewOption)


viewHand : (Msg -> msg) -> Shared -> Config -> Dict Card.Id String -> List Card.Response -> Html msg
viewHand wrap shared config fills hand =
    let
        viewHandCard response =
            let
                id =
                    response.details.id
            in
            ( id
            , Response.viewPotentiallyCustom
                shared
                config
                Card.Front
                (Game.EditBlank id >> wrap)
                (Game.Fill id >> wrap)
                []
                fills
                response
            )
    in
    HtmlK.ul
        [ HtmlA.classList
            [ ( "hand", True )
            , ( "cards", True )
            , ( "not-playing", True )
            ]
        ]
        (hand |> List.map viewHandCard)
