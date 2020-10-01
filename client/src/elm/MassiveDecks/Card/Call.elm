module MassiveDecks.Card.Call exposing
    ( slotCount
    , view
    , viewFilled
    , viewUnknown
    )

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Card as Card
import MassiveDecks.Card.Model exposing (..)
import MassiveDecks.Card.Parts as Parts exposing (Parts)
import MassiveDecks.Game.Rules exposing (Rules)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Decks as Decks
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Maybe as Maybe


{-| How many slots there are on a call.
-}
slotCount : Call -> Int
slotCount call =
    call.body |> Parts.slotCount


{-| Render the call to HTML.
-}
view : Shared -> Config -> Side -> List (Html.Attribute msg) -> Call -> Html msg
view shared config side attributes call =
    viewInternal shared config side attributes Parts.view call


{-| Render the call to HTML, with the slots filled with the given values.
-}
viewFilled : Shared -> Config -> Side -> List (Html.Attribute msg) -> Parts.SlotAttrs msg -> Dict Int String -> Call -> Html msg
viewFilled shared config side attributes slotAttrs fillWith call =
    viewInternal shared config side attributes (Parts.viewFilled slotAttrs fillWith) call


{-| Render an unknown response to HTML, face-down.
-}
viewUnknown : Shared -> List (Html.Attribute msg) -> Html msg
viewUnknown shared attributes =
    Card.viewUnknown shared "call" attributes



{- Private -}


viewInternal : Shared -> Config -> Side -> List (Html.Attribute msg) -> (Parts -> List (Html msg)) -> Call -> Html msg
viewInternal shared config side attributes viewParts call =
    Card.view
        "call"
        shared
        (config.decks |> Decks.getSummary)
        side
        attributes
        (viewBody viewParts call)
        (viewInstructions shared config.rules call)
        call.details.source


viewBody : (Parts -> List (Html msg)) -> Call -> ViewBody msg
viewBody viewParts call =
    ViewBody (\() -> viewParts call.body)


viewInstructions : Shared -> Rules -> Call -> ViewInstructions msg
viewInstructions shared rules call =
    ViewInstructions (\() -> instructions shared rules call.body)


instructions : Shared -> Rules -> Parts -> List (Html msg)
instructions shared rules parts =
    let
        slots =
            Parts.slotCount parts

        instructionViews =
            List.concat
                [ extraCardsInstruction shared rules slots
                , pickInstruction shared slots (Parts.nonObviousSlotIndices parts)
                ]
    in
    [ Html.ol [ HtmlA.class "instructions" ] instructionViews ]
        |> Maybe.justIf (List.length instructionViews > 0)
        |> Maybe.withDefault []


extraCardsInstruction : Shared -> Rules -> Int -> List (Html msg)
extraCardsInstruction shared rules slots =
    if Maybe.isJust rules.houseRules.packingHeat || slots > 2 then
        let
            extraCards =
                slots - 1
        in
        [ Html.li [] [ Strings.Draw { numberOfCards = extraCards } |> Lang.html shared ] ]
            |> Maybe.justIf (extraCards > 0)
            |> Maybe.withDefault []

    else
        []


pickInstruction : Shared -> Int -> Bool -> List (Html msg)
pickInstruction shared slots nonObviousSlotIndices =
    [ Html.li [] [ Strings.Pick { numberOfCards = slots } |> Lang.html shared ] ]
        |> Maybe.justIf (slots > 1 || nonObviousSlotIndices)
        |> Maybe.withDefault []
