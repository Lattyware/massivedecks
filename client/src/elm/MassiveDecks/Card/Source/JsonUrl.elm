module MassiveDecks.Card.Source.JsonUrl exposing
    ( generalMethods
    , methods
    )

import Html as Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Json.Decode as Json
import MassiveDecks.Card.Source.Methods as Source
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Components.Form.Message as Message exposing (Message)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Decks.Model exposing (DeckOrError)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Maybe as Maybe
import Material.TextField as TextField


methods : String -> Source.ExternalMethods msg
methods url =
    { name = name
    , logo = logo
    , empty = empty
    , id = id
    , problems = problems url
    , defaultDetails = details url
    , tooltip = tooltip url
    , editor = editor url
    , equals = equals url
    }


generalMethods : Source.ExternalGeneralMethods msg
generalMethods =
    { name = name
    , logo = logo
    , empty = empty
    , id = id
    }



{- Private -}


id : () -> Source.General
id () =
    Source.GJsonUrl


name : () -> MdString
name () =
    Strings.JsonUrl


empty : Shared -> Source.External
empty _ =
    "" |> Source.JsonUrl


equals : String -> Source.External -> Bool
equals url source =
    case source of
        Source.JsonUrl other ->
            url == other

        _ ->
            False


problems : String -> () -> List (Message msg)
problems url () =
    if String.isEmpty url then
        [ Strings.CantBeEmpty |> Message.info ]

    else
        []


editor : String -> Shared -> List DeckOrError -> (Source.External -> msg) -> Maybe msg -> msg -> Html msg
editor url shared existing update submit noOp =
    let
        notAlreadyInGame potential =
            case potential of
                Source.JsonUrl otherUrl ->
                    let
                        notSameDeck { source } =
                            equals otherUrl source |> not
                    in
                    otherUrl |> Maybe.justIf (existing |> List.all notSameDeck)

                _ ->
                    Nothing

        recentDeck otherUrl =
            Html.option [ HtmlA.value otherUrl ] []
    in
    Html.div [ HtmlA.class "primary" ]
        [ Html.datalist [ HtmlA.id "recent-decks" ]
            (shared.settings.settings.recentDecks |> List.filterMap notAlreadyInGame |> List.map recentDeck)
        , TextField.view shared
            Strings.JsonUrl
            TextField.Text
            url
            [ HtmlA.list "recent-decks"
            , HtmlE.onInput (Source.JsonUrl >> update)
            , HtmlE.keyCode
                |> Json.map (\k -> submit |> Maybe.andThen (Maybe.justIf (k == 13)) |> Maybe.withDefault noOp)
                |> HtmlE.on "keydown"
            ]
        ]


details : String -> Shared -> Source.Details
details url shared =
    { name = (() |> name |> Lang.string shared) ++ " " ++ url
    , url = Nothing
    , author = Nothing
    , translator = Nothing
    , language = Nothing
    }


tooltip : String -> (String -> List (Html msg) -> Html msg) -> Maybe ( String, Html msg )
tooltip url tooltipRender =
    let
        forId =
            "json-url-" ++ url
    in
    ( forId, [ Html.p [ HtmlA.class "json-url" ] [ Html.text url ] ] |> tooltipRender forId ) |> Just


logo : () -> Maybe (Html msg)
logo () =
    Nothing
