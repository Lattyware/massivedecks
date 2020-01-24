module MassiveDecks.Card.Call exposing (slotCount, view, viewFilled, viewUnknown)

import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Card as Card
import MassiveDecks.Card.Model exposing (..)
import MassiveDecks.Card.Parts as Parts exposing (Parts)
import MassiveDecks.Game.Rules exposing (Rules)
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Strings exposing (MdString(..))
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
viewFilled : Shared -> Config -> Side -> List (Html.Attribute msg) -> List String -> Call -> Html msg
viewFilled shared config side attributes fillWith call =
    viewInternal shared config side attributes (Parts.viewFilled fillWith) call


{-| Render an unknown response to HTML, face-down.
-}
viewUnknown : List (Html.Attribute msg) -> Html msg
viewUnknown attributes =
    Card.viewUnknown "call" attributes



{- Private -}


viewInternal : Shared -> Config -> Side -> List (Html.Attribute msg) -> (Parts -> List (Html msg)) -> Call -> Html msg
viewInternal shared config side attributes viewParts call =
    Card.view
        "call"
        shared
        config.decks
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
            List.concat [ extraCardsInstruction shared rules slots, pickInstruction shared slots ]
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
        [ Html.li [] [ Draw { numberOfCards = extraCards } |> Lang.html shared ] ]
            |> Maybe.justIf (extraCards > 0)
            |> Maybe.withDefault []

    else
        []


pickInstruction : Shared -> Int -> List (Html msg)
pickInstruction shared slots =
    [ Html.li [] [ Pick { numberOfCards = slots } |> Lang.html shared ] ]
        |> Maybe.justIf (slots > 1)
        |> Maybe.withDefault []
