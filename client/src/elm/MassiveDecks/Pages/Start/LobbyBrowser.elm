module MassiveDecks.Pages.Start.LobbyBrowser exposing
    ( init
    , refresh
    , update
    , view
    )

import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Keyed as HtmlK
import Http
import MassiveDecks.Messages as Global
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.GameCode as GameCode
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Pages.Route as Route exposing (Route)
import MassiveDecks.Pages.Start.LobbyBrowser.Messages exposing (..)
import MassiveDecks.Pages.Start.LobbyBrowser.Model exposing (..)
import MassiveDecks.Pages.Start.Messages as Start
import MassiveDecks.Pages.Start.Route as Start
import MassiveDecks.Requests.Api as Api
import MassiveDecks.Requests.HttpData as HttpData
import MassiveDecks.Requests.HttpData.Messages as HttpData
import MassiveDecks.Requests.HttpData.Model as HttpData exposing (HttpData)
import MassiveDecks.Strings as Strings exposing (MdString(..))
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.List as List
import MassiveDecks.Util.Maybe as Maybe
import Material.ListView as ListView


{-| Set up the lobby browser.
-}
init : ( Model, Cmd Global.Msg )
init =
    HttpData.init requestLobbySummaries


{-| An html view of the lobby browser.
-}
view : Shared -> Route -> Model -> Html Global.Msg
view shared route summaries =
    Html.div [ HtmlA.class "lobby-browser" ]
        [ Html.div [ HtmlA.class "top" ]
            [ Html.h2 [] [ LobbyBrowserTitle |> Lang.html shared ]
            , HttpData.refreshButton shared summaries |> Html.map (SummaryUpdate >> lift)
            ]
        , HttpData.view shared route [ emptyContent shared ] (lobbyList shared) summaries
        ]


{-| Update the state of the lobby browser.
-}
update : Msg -> Model -> ( Model, Cmd Global.Msg )
update msg model =
    case msg of
        SummaryUpdate summaries ->
            HttpData.update requestLobbySummaries summaries model


{-| Try to refresh the lobbies.
-}
refresh : Model -> ( Model, Cmd Global.Msg )
refresh model =
    update (HttpData.Pull |> SummaryUpdate) model



{- Private -}


requestLobbySummaries : HttpData.Pull Global.Msg
requestLobbySummaries =
    Api.lobbySummaries (HttpData.Response >> SummaryUpdate >> lift) |> Http.request


lift : Msg -> Global.Msg
lift =
    Start.LobbyBrowserMsg >> Global.StartMsg


lobbyList : Shared -> List Summary -> Html Global.Msg
lobbyList shared summaries =
    if List.isEmpty summaries then
        emptyContent shared

    else
        HtmlK.ul []
            (summaries
                |> byState
                |> List.filter (\( _, lobbies ) -> not (List.isEmpty lobbies))
                |> List.map (stateGroup shared)
                |> List.mappedIntersperse sep
            )


emptyContent : Shared -> Html Global.Msg
emptyContent shared =
    Html.div [ HtmlA.class "empty-info" ]
        [ Icon.viewIcon Icon.ghost
        , NoPublicGames |> Lang.html shared
        , Html.text " "
        , Html.a [ Route.Start { section = Start.New } |> Route.href ] [ StartYourOwn |> Lang.html shared ]
        ]


states : List Lobby.State
states =
    [ Lobby.SettingUp
    , Lobby.Playing
    ]


stateId : Lobby.State -> String
stateId state =
    case state of
        Lobby.Playing ->
            "playing"

        Lobby.SettingUp ->
            "setting-up"


stateDescription : Lobby.State -> MdString
stateDescription state =
    case state of
        Lobby.Playing ->
            PlayingGame

        Lobby.SettingUp ->
            SettingUpGame


sep : ( String, Html msg ) -> ( String, Html msg ) -> ( String, Html msg )
sep ( before, _ ) ( after, _ ) =
    ( "Sep" ++ before ++ after
    , Html.hr [] []
    )


byState : List Summary -> List ( Lobby.State, List Summary )
byState lobbies =
    states |> List.map (\state -> ( state, lobbies |> List.filter (.state >> (==) state) ))


stateGroup : Shared -> ( Lobby.State, List Summary ) -> ( String, Html Global.Msg )
stateGroup shared ( state, lobbies ) =
    ( state |> stateId
    , Html.li []
        [ Html.div []
            [ Html.h3 [] [ state |> stateDescription |> Lang.html shared ]
            , HtmlK.ul [] (lobbies |> List.map (lobby shared))
            ]
        ]
    )


lobby : Shared -> Summary -> ( String, Html Global.Msg )
lobby shared data =
    ( data.gameCode |> GameCode.toString
    , ListView.viewItem
        (ListView.Enabled (Route.Start { section = Start.Join (Just data.gameCode) } |> Global.ChangePage))
        Nothing
        ([ Html.span [ HtmlA.class "lobby-game-code" ]
            [ Strings.GameCode { code = GameCode.toString data.gameCode } |> Lang.html shared ]
         ]
            |> Just
        )
        ([ Icon.viewStyled [ HtmlA.title "Join Game" ] Icon.signInAlt ] |> Just)
        [ Html.span [ HtmlA.class "lobby-name", Strings.LobbyRequiresPassword |> Lang.title shared ]
            [ Html.text data.name
            , Html.text " "
            , Icon.lock
                |> Icon.viewStyled []
                |> Maybe.justIf data.password
                |> Maybe.withDefault Html.nothing
            ]
        ]
    )
