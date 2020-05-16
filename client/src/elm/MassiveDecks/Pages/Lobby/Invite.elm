module MassiveDecks.Pages.Lobby.Invite exposing (button, dialog, overlay)

import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Components.Form as Form
import MassiveDecks.Components.Form.Message as Message
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Messages as Lobby exposing (Msg(..))
import MassiveDecks.Pages.Route as Route
import MassiveDecks.Pages.Start.Route as Start
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Html.Events as HtmlE
import MassiveDecks.Util.NeList as NeList exposing (NeList(..))
import Material.Card as Card
import Material.IconButton as IconButton
import QRCode
import Url exposing (Url)


{-| A button to show the dialog.
-}
button : (Msg -> msg) -> Shared -> Html msg
button wrap shared =
    IconButton.view shared Strings.Invite (Icon.bullhorn |> Icon.present |> NeList.just) (ToggleInviteDialog |> wrap |> Just)


{-| A dialog overlay that displays information on how to invite people to the game.
-}
dialog : (Msg -> msg) -> Shared -> GameCode -> Maybe String -> Bool -> Html msg
dialog wrap shared gameCode password open =
    let
        lobbyUrl =
            url shared gameCode
    in
    Html.div
        [ HtmlA.id "invite-dialog"
        , HtmlA.classList [ ( "open", open ) ]
        , Lobby.ToggleInviteDialog |> wrap |> HtmlE.onClick
        ]
        [ IconButton.viewNoPropagation shared
            Strings.Close
            (Icon.times |> Icon.present |> NeList.just)
            (Lobby.ToggleInviteDialog |> wrap |> Just)
        , Card.view [ HtmlE.onClickNoPropagation (wrap NoOp) ]
            [ Strings.InviteExplanation { gameCode = GameCode.toString gameCode, password = password } |> Lang.html shared
            , Form.section shared
                "invite-link"
                (Html.div [ HtmlA.class "multipart" ]
                    [ Html.input
                        [ HtmlA.readonly True
                        , HtmlA.value lobbyUrl
                        , HtmlA.class "primary"
                        , HtmlA.id "invite-link-field"
                        ]
                        []
                    , IconButton.view shared
                        Strings.Copy
                        (Icon.copy |> Icon.present |> NeList.just)
                        ("invite-link-field" |> Copy |> wrap |> Just)
                    ]
                )
                [ Message.info Strings.InviteLinkHelp ]
            , lobbyUrl |> qr
            ]
        ]


{-| A widget that displays information on how to join the game.
-}
overlay : Shared -> GameCode -> Html msg
overlay shared gameCode =
    Html.div [ HtmlA.class "invite" ]
        [ Html.div [ HtmlA.class "join-info" ]
            [ Html.p [] [ Strings.JoinTheGame |> Lang.html shared ]
            , Html.p [] [ Strings.GameCode { code = GameCode.toString gameCode } |> Lang.html shared ]
            , Html.p [] [ Html.text (stripProtocol shared.origin) ]
            ]
        , Html.div [ HtmlA.class "qr-code" ] [ url shared gameCode |> qr ]
        ]



{- Private -}


qr : String -> Html msg
qr lobbyUrl =
    lobbyUrl
        |> QRCode.encodeWith QRCode.Low
        |> Result.map QRCode.toSvg
        |> Result.withDefault Html.nothing


{-| Get the url for a lobby.
-}
url : Shared -> GameCode -> String
url shared gameCode =
    Route.externalUrl shared.origin (Route.Start { section = Start.Join (Just gameCode) })


{-| We assume that the protocol and root path don't matter, to simplify the shown URL.
This should be fine as long as http redirects to https, which is good practice.
If the origin doesn't parse we probably have bigger problems, but we just return it unaltered.
-}
stripProtocol : String -> String
stripProtocol stringUrl =
    Url.fromString stringUrl
        |> Maybe.map fromUrl
        |> Maybe.withDefault stringUrl


fromUrl : Url -> String
fromUrl nonStringUrl =
    let
        portPart =
            case nonStringUrl.port_ of
                Nothing ->
                    ""

                Just port_ ->
                    ":" ++ String.fromInt port_

        pathPart =
            if nonStringUrl.path == "/" then
                ""

            else
                nonStringUrl.path
    in
    nonStringUrl.host ++ portPart ++ pathPart
