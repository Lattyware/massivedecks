module MassiveDecks.Card.Source.BuiltIn exposing
    ( generalMethods
    , methods
    )

import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html as Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Card.Source.BuiltIn.Model exposing (..)
import MassiveDecks.Card.Source.Methods as Source
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Components.Form.Message exposing (Message)
import MassiveDecks.Icon as Icon
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Decks.Model exposing (DeckOrError)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Maybe as Maybe
import MassiveDecks.Util.NeList as NeList
import MassiveDecks.Util.Order as Order
import Material.Select as Select


methods : Id -> Source.ExternalMethods msg
methods given =
    { name = sourceName
    , logo = logo
    , empty = empty
    , id = sourceId
    , messages = \() -> []
    , problems = problems given
    , defaultDetails = details given
    , tooltip = tooltip given
    , editor = editor given
    , equals = equals given
    }


generalMethods : Source.ExternalGeneralMethods msg
generalMethods =
    { name = sourceName
    , logo = logo
    , empty = empty
    , id = sourceId
    , messages = \() -> []
    }



{- Private -}


sourceId : () -> Source.General
sourceId _ =
    Source.GBuiltIn


sourceName : () -> MdString
sourceName () =
    Strings.BuiltIn


empty : Shared -> Source.External
empty shared =
    shared.sources.builtIn
        |> Maybe.map (.decks >> NeList.head)
        |> Maybe.map .id
        |> Maybe.withDefault (hardcoded "")
        |> Source.BuiltIn


{-| See if the id is equal to the given source.
-}
equals : Id -> Source.External -> Bool
equals given source =
    case source of
        Source.BuiltIn other ->
            given == other

        _ ->
            False


problems : Id -> () -> List (Message msg)
problems _ () =
    []


editor : Id -> Shared -> List DeckOrError -> (Source.External -> msg) -> Maybe msg -> msg -> Html msg
editor selected shared existing update _ _ =
    case shared.sources.builtIn of
        Just { decks } ->
            let
                deck { id, name, language, author, translator } =
                    let
                        lang =
                            if language /= (Lang.currentLanguage shared |> Lang.code) then
                                language |> Lang.languageNameOrCode shared |> Just

                            else
                                Nothing

                        matches d =
                            case d.source of
                                Source.BuiltIn other ->
                                    other == id

                                _ ->
                                    False

                        secondary =
                            [ lang |> Maybe.map (\l -> Strings.DeckLanguage { language = l } |> Lang.html shared)
                            , Strings.DeckAuthor { author = author } |> Lang.html shared |> Just
                            , translator |> Maybe.map (\t -> Strings.DeckTranslator { translator = t } |> Lang.html shared)
                            ]
                                |> List.filterMap identity
                                |> List.intersperse (Html.text ", ")
                    in
                    { id = id
                    , icon = Nothing
                    , primary = [ Html.text name ]
                    , secondary = Just secondary
                    , meta = Icon.check |> Icon.viewIcon |> Maybe.justIf (existing |> List.any matches)
                    }
            in
            Html.div [ HtmlA.class "primary" ]
                [ Select.view shared
                    { label = Strings.Deck
                    , idToString = toString
                    , idFromString = fromString shared.sources.builtIn
                    , selected = Just selected
                    , wrap = Maybe.withDefault (hardcoded "") >> Source.BuiltIn >> update
                    }
                    [ HtmlA.id "built-in-selector" ]
                    (decks
                        |> NeList.toList
                        |> List.sortWith (sortClosestFirst (Lang.currentLanguage shared |> Lang.code) |> Order.map .language)
                        |> List.map deck
                    )
                ]

        Nothing ->
            Html.nothing


sortClosestFirst : String -> String -> String -> Order
sortClosestFirst target a b =
    if a == b then
        EQ

    else if a == target then
        LT

    else if b == target then
        GT

    else
        EQ


details : Id -> Shared -> Source.Details
details given shared =
    let
        isSame { id } =
            given == id

        info =
            shared.sources.builtIn
                |> Maybe.andThen (.decks >> NeList.toList >> List.filter isSame >> List.head)
    in
    { name = info |> Maybe.map .name |> Maybe.withDefault ""
    , url = Nothing
    , author = info |> Maybe.map .author
    , translator = info |> Maybe.andThen .translator
    , language = info |> Maybe.map .language
    }


tooltip : Id -> (String -> List (Html msg) -> Html msg) -> Maybe ( String, Html msg )
tooltip id renderTooltip =
    let
        forId =
            "builtin-" ++ (id |> toString)
    in
    ( forId, renderTooltip forId [] ) |> Just


logo : () -> Maybe (Html msg)
logo () =
    Icon.massiveDecks |> Icon.viewIcon |> Just
