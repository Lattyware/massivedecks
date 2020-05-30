module MassiveDecks.Card.Source.JsonAgainstHumanity exposing
    ( generalMethods
    , methods
    )

import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html as Html exposing (Html)
import Html.Attributes as HtmlA
import List.Extra as List
import MassiveDecks.Card.Source.JsonAgainstHumanity.Model exposing (..)
import MassiveDecks.Card.Source.Methods as Source
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Components.Form.Message as Message exposing (Message)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Decks.Model exposing (DeckOrError)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Maybe as Maybe
import Material.Select as Select


methods : Id -> Source.ExternalMethods msg
methods givenId =
    { name = name
    , logo = logo
    , empty = empty
    , id = id
    , messages = messages
    , problems = problems givenId
    , defaultDetails = details givenId
    , tooltip = tooltip givenId
    , editor = editor givenId
    , equals = equals givenId
    }


generalMethods : Source.ExternalGeneralMethods msg
generalMethods =
    { name = name
    , logo = logo
    , empty = empty
    , id = id
    , messages = messages
    }



{- Private -}


id : () -> Source.General
id () =
    Source.GJsonAgainstHumanity


name : () -> MdString
name () =
    Strings.JsonAgainstHumanity


empty : Shared -> Source.External
empty shared =
    shared.sources.jsonAgainstHumanity
        |> Maybe.andThen (.decks >> List.head)
        |> Maybe.map .id
        |> Maybe.withDefault (hardcoded "")
        |> Source.JsonAgainstHumanity


equals : Id -> Source.External -> Bool
equals givenId source =
    case source of
        Source.JsonAgainstHumanity other ->
            givenId == other

        _ ->
            False


messages : () -> List (Message msg)
messages () =
    [ Strings.JsonAgainstHumanityAbout |> Message.info ]


problems : Id -> () -> List (Message msg)
problems givenId () =
    []


editor : Id -> Shared -> List DeckOrError -> (Source.External -> msg) -> Maybe msg -> msg -> Html msg
editor selected shared existing update _ _ =
    case shared.sources.jsonAgainstHumanity of
        Just { decks } ->
            let
                deck d =
                    let
                        matches other =
                            case other.source of
                                Source.JsonAgainstHumanity o ->
                                    o == d.id

                                _ ->
                                    False
                    in
                    { id = d.id
                    , icon = Nothing
                    , primary = [ Html.text d.name ]
                    , secondary = Nothing
                    , meta = Icon.check |> Icon.viewIcon |> Maybe.justIf (existing |> List.any matches)
                    }
            in
            Html.span [ HtmlA.id "json-against-humanity-editor", HtmlA.class "primary" ]
                [ Select.view shared
                    { label = Strings.Deck
                    , idToString = toString
                    , idFromString = fromString shared.sources.jsonAgainstHumanity
                    , selected = Just selected
                    , wrap = Maybe.withDefault (hardcoded "") >> Source.JsonAgainstHumanity >> update
                    }
                    [ HtmlA.id "built-in-selector" ]
                    (decks |> List.map deck)
                ]

        Nothing ->
            Html.nothing


details : Id -> Shared -> Source.Details
details givenId shared =
    { name =
        shared.sources.jsonAgainstHumanity
            |> Maybe.andThen (.decks >> List.find (\d -> d.id == givenId))
            |> Maybe.map .name
            |> Maybe.withDefault (givenId |> toString)
    , url = Nothing
    , author = Nothing
    , translator = Nothing
    , language = Nothing
    }


tooltip : Id -> (String -> List (Html msg) -> Html msg) -> Maybe ( String, Html msg )
tooltip givenId tooltipRender =
    let
        forId =
            "json-against-humanity-" ++ toString givenId
    in
    ( forId, [] |> tooltipRender forId ) |> Just


logo : () -> Maybe (Html msg)
logo () =
    Icon.code |> Icon.viewIcon |> Just
