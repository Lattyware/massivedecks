module MassiveDecks.Scenes.Lobby.UI exposing (view, inviteOverlay)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import MassiveDecks.Components.About as About
import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Components.QR as QR
import MassiveDecks.Components.Icon as Icon
import MassiveDecks.Components.Overlay as Overlay
import MassiveDecks.Components.BrowserNotifications as BrowserNotifications
import MassiveDecks.Components.TTS as TTS
import MassiveDecks.Scenes.Config as Config
import MassiveDecks.Scenes.Playing as Playing
import MassiveDecks.Scenes.Lobby.Models exposing (Model)
import MassiveDecks.Scenes.Lobby.Messages exposing (ConsumerMessage(..), Message(..))
import MassiveDecks.Scenes.Lobby.Sidebar as Sidebar
import MassiveDecks.Models.Player as Player exposing (Player, Status(..))
import MassiveDecks.Models.Game as Game
import MassiveDecks.Models.Notification as Notification exposing (Notification)
import MassiveDecks.Util as Util


view : Model -> Html ConsumerMessage
view model =
    let
        lobby =
            model.lobby

        url =
            model.init.url

        gameCode =
            lobby.gameCode

        players =
            lobby.players

        ( header, contents ) =
            case lobby.game of
                Game.Configuring ->
                    ( [], [ Config.view model |> Html.map (ConfigMessage >> LocalMessage) ] )

                Game.Playing round ->
                    let
                        ( h, c ) =
                            Playing.view model round
                    in
                        ( h |> List.map (Html.map (PlayingMessage >> LocalMessage)), c |> List.map (Html.map (PlayingMessage >> LocalMessage)) )

                Game.Finished ->
                    ( [], [] )
    in
        root model.sidebar.hidden
            [ appHeader header model
            , spacer
            , scores model.secret.id model.lobby.owner model.sidebar.shownAsOverlay players
            , contentWrapper contents
            ]


root : Bool -> List (Html msg) -> Html msg
root hideScores contents =
    div [ classList [ ( "content", True ), ( "hide-scores", hideScores ) ] ] contents


contentWrapper : List (Html msg) -> Html msg
contentWrapper contents =
    div [ id "content-wrapper" ] contents


spacer : Html msg
spacer =
    div [ class "mui--appbar-height" ] []


scores : Player.Id -> Player.Id -> Bool -> List Player -> Html ConsumerMessage
scores client owner shownAsOverlay players =
    let
        hideMessage =
            LocalMessage (SidebarMessage Sidebar.Hide)

        closeLink =
            if shownAsOverlay then
                [ a
                    [ class "link close-link"
                    , title "Hide."
                    , attribute "tabindex" "0"
                    , attribute "role" "button"
                    , onClick hideMessage
                    ]
                    [ Icon.icon "times" ]
                ]
            else
                []

        sidebar =
            div [ id "scores", classList [ ( "shownAsOverlay", shownAsOverlay ), ( "mui--z1", True ) ] ]
                [ div [ id "scores-title", class "mui--appbar-line-height mui--text-headline" ] ([ text "Players" ] ++ closeLink)
                , div [ class "mui-divider" ] []
                , table [ class "mui-table" ]
                    [ thead []
                        [ tr []
                            [ th [ class "state", title "State" ] [ Icon.icon "tasks" ]
                            , th [ class "name" ] [ text "Player" ]
                            , th [ class "score", title "Score" ] [ Icon.icon "trophy" ]
                            ]
                        ]
                    , tbody [] (List.map (score client owner) players)
                    ]
                ]
    in
        if shownAsOverlay then
            div
                [ id "mui-overlay"
                , Util.onClickIfId "mui-overlay" hideMessage (LocalMessage NoOp)
                , Util.onKeyDown "Escape" hideMessage (LocalMessage NoOp)
                , tabindex 0
                ]
                [ sidebar ]
        else
            sidebar


score : Player.Id -> Player.Id -> Player -> Html msg
score client owner player =
    let
        classes =
            classList
                [ ( Player.statusName player.status, True )
                , ( "disconnected", player.disconnected )
                , ( "left", player.left )
                , ( "you", player.id == client )
                ]

        prename =
            List.concat
                [ if player.id == owner then
                    [ Icon.icon "star", text " " ]
                  else
                    []
                , if player.id == client then
                    [ Icon.icon "user-circle", text " " ]
                  else
                    []
                , if player.disconnected then
                    [ Icon.icon "minus-circle", text " " ]
                  else
                    []
                ]

        afterNameTitle =
            (if player.id == owner then
                " (Owner)"
             else
                ""
            )
                ++ (if player.id == client then
                        " (You)"
                    else
                        ""
                   )
                ++ (if player.disconnected then
                        " (Disconnected)"
                    else
                        ""
                   )
    in
        tr [ classes ]
            [ td [ class "state", title (statusDescription player) ] [ (playerIcon player) ]
            , td [ class "name", title (player.name ++ afterNameTitle) ] (List.append prename [ text player.name ])
            , td [ class "score" ] [ text (toString player.score) ]
            ]


appHeader : List (Html ConsumerMessage) -> Model -> Html ConsumerMessage
appHeader contents model =
    (header []
        [ div [ class "mui-appbar mui--z1 mui--appbar-line-height" ]
            [ div [ class "mui--appbar-line-height" ]
                [ span [ class "score-buttons" ] ([ scoresButton ] ++ (notificationPopup model.notification))
                , span [ id "title", class "mui--text-title mui--visible-xs-inline-block" ] contents
                , gameMenu model
                ]
            ]
        ]
    )


scoresButton : Html ConsumerMessage
scoresButton =
    button
        [ class ("scores-toggle mui-btn mui-btn--small mui-btn--primary badged")
        , title "Players."
        , onClick (LocalMessage (SidebarMessage Sidebar.Toggle))
        ]
        [ Icon.fwIcon "users" ]


notificationPopup : Maybe Notification -> List (Html ConsumerMessage)
notificationPopup notification =
    case notification of
        Just notification ->
            let
                hidden =
                    if notification.visible then
                        ""
                    else
                        "hide"
            in
                [ div
                    [ class ("badge mui--z2 " ++ hidden)
                    , title notification.description
                    , onClick (LocalMessage (DismissNotification notification))
                    ]
                    [ Icon.icon notification.icon, text (" " ++ notification.name) ]
                ]

        Nothing ->
            [ div [ class ("badge mui--z2 hide") ] [] ]


statusDescription : Player -> String
statusDescription player =
    case player.status of
        NotPlayed ->
            "Choosing"

        Played ->
            "Played"

        Czar ->
            "Round Czar"

        Ai ->
            "A Computer"

        Neutral ->
            ""

        Skipping ->
            "Being Skipped"


statusIcon : Status -> Html msg
statusIcon status =
    Maybe.map Icon.fwIcon (statusIconName status) |> Maybe.withDefault (text "")


statusIconName : Status -> Maybe String
statusIconName status =
    case status of
        NotPlayed ->
            Just "hourglass"

        Played ->
            Just "check"

        Czar ->
            Just "gavel"

        Ai ->
            Just "cogs"

        Neutral ->
            Nothing

        Skipping ->
            Just "fast-forward"


playerIcon : Player -> Html msg
playerIcon player =
    if player.left then
        Icon.icon "sign-out"
    else
        statusIcon player.status


{-| The overlay for inviting players to a lobby.
-}
inviteOverlay : String -> String -> Overlay.Message msg
inviteOverlay appUrl gameCode =
    let
        url =
            Util.lobbyUrl appUrl gameCode

        contents =
            [ p [] [ text "To invite other players, simply send them this link: " ]
            , p [] [ a [ href url ] [ text url ] ]
            , p [] [ text "Have them scan this QR code: " ]
            , QR.view "invite-qr-code"
            , p [] [ text "Or give them this game code to enter on the start page: " ]
            , p [] [ input [ readonly True, value gameCode ] [] ]
            ]
    in
        Overlay.Show
            { icon = "bullhorn"
            , title = "Invite Players"
            , contents = contents
            }


notificationsMenuItem : BrowserNotifications.Model -> List (Html ConsumerMessage)
notificationsMenuItem model =
    let
        ( notClickable, enabled ) =
            if not model.supported then
                ( Just "Your browser does not support desktop notifications.", False )
            else if model.permission == Just BrowserNotifications.Denied then
                ( Just "You have denied Massive Decks permission to display desktop notifications.", False )
            else
                ( Nothing, model.enabled )

        classes =
            classList
                [ ( "link", True )
                , ( "disabled", not (Util.isNothing notClickable) )
                ]

        extraAttrs =
            case notClickable of
                Nothing ->
                    [ onClick
                        (LocalMessage <|
                            BrowserNotificationsMessage <|
                                (if enabled then
                                    BrowserNotifications.disable
                                 else
                                    BrowserNotifications.enable
                                )
                        )
                    ]

                Just msg ->
                    [ title msg ]

        attributes =
            [ classes, attribute "tabindex" "0", attribute "role" "button" ] ++ extraAttrs

        description =
            " "
                ++ (if enabled then
                        "Disable"
                    else
                        "Enable"
                   )
                ++ " Notifications"
    in
        [ li []
            [ a attributes
                [ Icon.fwIcon
                    (if enabled then
                        "bell-slash"
                     else
                        "bell"
                    )
                , text description
                ]
            ]
        ]


{-| The menu for the game.
-}
gameMenu : Model -> Html ConsumerMessage
gameMenu model =
    let
        url =
            (Errors.reportUrl { url = model.init.url, version = model.init.version }
                "I was [a short explanation of what you were doing] when [a short explanation of the bug]."
            )
    in
        div [ class "menu mui-dropdown" ]
            [ button
                [ class "mui-btn mui-btn--small mui-btn--primary"
                , attribute "data-mui-toggle" "dropdown"
                , title "Game menu."
                ]
                [ Icon.fwIcon "ellipsis-h" ]
            , ul [ class "mui-dropdown__menu mui-dropdown__menu--right" ]
                ([ li []
                    [ a
                        [ class "link"
                        , attribute "tabindex" "0"
                        , attribute "role" "button"
                        , onClick (DisplayInviteOverlay |> LocalMessage)
                        ]
                        [ Icon.fwIcon "bullhorn", text " Invite Players" ]
                    ]
                 ]
                    ++ (notificationsMenuItem model.browserNotifications)
                    ++ [ li []
                            [ a
                                [ class "link"
                                , attribute "tabindex" "0"
                                , attribute "role" "button"
                                , onClick (TTS.Enabled (not model.tts.enabled) |> TTSMessage |> LocalMessage)
                                ]
                                (if model.tts.enabled then
                                    [ Icon.fwIcon "volume-off", text " Disable Speech" ]
                                 else
                                    [ Icon.fwIcon "volume-up", text " Enable Speech" ]
                                )
                            ]
                       , li []
                            [ a
                                [ class "link"
                                , attribute "tabindex" "0"
                                , attribute "role" "button"
                                , onClick Leave
                                ]
                                [ Icon.fwIcon "sign-out", text " Leave Game" ]
                            ]
                       , li [ class "mui-divider" ] []
                       , li []
                            [ a
                                [ class "link"
                                , attribute "tabindex" "0"
                                , attribute "role" "button"
                                , onClick (About.show model.init.version |> OverlayMessage)
                                ]
                                [ Icon.fwIcon "info-circle", text " About" ]
                            ]
                       , li []
                            [ a [ href url, target "_blank", rel "noopener" ]
                                [ Icon.fwIcon "bug", text " Report a bug" ]
                            ]
                       ]
                )
            ]
