module MassiveDecks.Models.Encoders exposing
    ( checkAlive
    , houseRuleChange
    , language
    , lobbyCreation
    , lobbyToken
    , playerPresence
    , privilege
    , remoteControlCommand
    , roundId
    , settings
    , source
    , stage
    , timeLimitMode
    , userRegistration
    )

import Dict
import Json.Encode as Json
import MassiveDecks.Card.Source.Cardcast.Model as Cardcast
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Cast.Model as Cast
import MassiveDecks.Game.Player as Player
import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Notifications.Model as Notifications
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Pages.Start.Model as Start
import MassiveDecks.Settings.Model as Settings exposing (Settings)
import MassiveDecks.Speech as Speech
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Strings.Languages.Model as Lang exposing (Language)
import MassiveDecks.User as User


timeLimitMode : Rules.TimeLimitMode -> Json.Value
timeLimitMode mode =
    Json.string
        (case mode of
            Rules.Hard ->
                "Hard"

            Rules.Soft ->
                "Soft"
        )


roundId : Round.Id -> Json.Value
roundId =
    Round.idString >> Json.string


stage : Round.Stage -> Json.Value
stage =
    Round.stageToName >> Json.string


checkAlive : List Lobby.Token -> Json.Value
checkAlive tokens =
    [ ( "tokens", Json.list lobbyToken tokens ) ] |> Json.object


playerPresence : Player.Presence -> Json.Value
playerPresence presence =
    Json.string
        (case presence of
            Player.Active ->
                "Active"

            Player.Away ->
                "Away"
        )


privilege : User.Privilege -> Json.Value
privilege p =
    Json.string
        (case p of
            User.Privileged ->
                "Privileged"

            User.Unprivileged ->
                "Unprivileged"
        )


settings : Settings -> Json.Value
settings s =
    let
        lun =
            s.lastUsedName |> Maybe.map (\n -> [ ( "lastUsedName", Json.string n ) ]) |> Maybe.withDefault []

        cl =
            s.chosenLanguage |> Maybe.map (\l -> [ ( "chosenLanguage", language l ) ]) |> Maybe.withDefault []

        fields =
            List.concat
                [ [ ( "tokens", s.tokens |> Dict.toList |> List.map (\( gc, t ) -> ( gc, Json.string t )) |> Json.object )
                  , ( "openUserList", Json.bool s.openUserList )
                  , ( "recentDecks", Json.list source s.recentDecks )
                  , ( "compactCards", s.cardSize |> cardSize )
                  , ( "speech", s.speech |> speech )
                  , ( "notifications", s.notifications |> notifications )
                  ]
                , lun
                , cl
                ]
    in
    Json.object fields


notifications : Notifications.Settings -> Json.Value
notifications notificationSettings =
    Json.object
        [ ( "enabled", notificationSettings.enabled |> Json.bool )
        , ( "requireNotVisible", notificationSettings.requireNotVisible |> Json.bool )
        ]


speech : Speech.Settings -> Json.Value
speech speechSettings =
    let
        enabledField =
            [ ( "enabled", speechSettings.enabled |> Json.bool ) ]

        selectedVoiceField =
            speechSettings.selectedVoice
                |> Maybe.map (\sv -> [ ( "selectedVoice", Json.string sv ) ])
                |> Maybe.withDefault []
    in
    Json.object
        (List.concat [ enabledField, selectedVoiceField ])


cardSize : Settings.CardSize -> Json.Value
cardSize =
    Settings.cardSizeToValue >> Json.int


lobbyCreation : Start.LobbyCreation -> Json.Value
lobbyCreation c =
    Json.object
        [ ( "owner", c.owner |> userRegistration ) ]


remoteControlCommand : Cast.RemoteControlCommand -> Json.Value
remoteControlCommand command =
    case command of
        Cast.Spectate spectate ->
            Json.object
                [ ( "command", "Spectate" |> Json.string )
                , ( "token", spectate.token |> Json.string )
                , ( "language", spectate.language |> language )
                ]


lobbyToken : Lobby.Token -> Json.Value
lobbyToken =
    Json.string


source : Source.External -> Json.Value
source s =
    case s of
        Source.Cardcast (Cardcast.PlayCode playCode) ->
            Json.object [ ( "source", "Cardcast" |> Json.string ), ( "playCode", playCode |> Json.string ) ]


language : Language -> Json.Value
language l =
    Lang.code l |> Json.string


userRegistration : User.Registration -> Json.Value
userRegistration r =
    Json.object
        (( "name", r.name |> Json.string )
            :: (r.password |> Maybe.map (\p -> [ ( "password", p |> Json.string ) ]) |> Maybe.withDefault [])
        )


houseRuleChange : Rules.HouseRuleChange -> Json.Value
houseRuleChange change =
    let
        ( name, maybeSettings ) =
            case change of
                Rules.RandoChange maybe ->
                    ( "Rando", maybe |> Maybe.map (\rando -> Json.object [ ( "number", Json.int rando.number ) ]) )

                Rules.PackingHeatChange maybe ->
                    ( "PackingHeat", maybe |> Maybe.map (\_ -> Json.object []) )

                Rules.RebootChange maybe ->
                    ( "Reboot", maybe |> Maybe.map (\reboot -> Json.object [ ( "cost", Json.int reboot.cost ) ]) )

        ruleSettings =
            maybeSettings |> Maybe.map (\s -> [ ( "settings", s ) ]) |> Maybe.withDefault []
    in
    Json.object
        (( "houseRule", name |> Json.string ) :: ruleSettings)
