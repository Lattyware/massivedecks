module MassiveDecks.Models.Encoders exposing
    ( checkAlive
    , comedyWriter
    , config
    , deckOrError
    , language
    , lobbyCreation
    , lobbyToken
    , packingHeat
    , playerPresence
    , privilege
    , rando
    , reboot
    , remoteControlCommand
    , roundId
    , settings
    , source
    , stage
    , timeLimitMode
    , userRegistration
    , userRole
    )

import Dict
import Json.Encode as Json
import MassiveDecks.Card.Source.BuiltIn.Model as BuiltIn
import MassiveDecks.Card.Source.JsonAgainstHumanity.Model as JsonAgainstHumanity
import MassiveDecks.Card.Source.ManyDecks.Model as ManyDecks
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Cast.Model as Cast
import MassiveDecks.Game.Player as Player
import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Rules as Rules exposing (Rules)
import MassiveDecks.Notifications.Model as Notifications
import MassiveDecks.Pages.Lobby.Configure.Decks.Model as Decks
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config, Tab(..))
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Pages.Start.Model as Start
import MassiveDecks.Settings.Model as Settings exposing (Settings)
import MassiveDecks.Speech as Speech
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Strings.Languages.Model as Lang exposing (Language)
import MassiveDecks.User as User
import MassiveDecks.Util.Maybe as Maybe


userRole : User.Role -> Json.Value
userRole role =
    let
        name =
            case role of
                User.Player ->
                    "Player"

                User.Spectator ->
                    "Spectator"
    in
    name |> Json.string


config : Config -> Json.Value
config c =
    Json.object
        (List.filterMap identity
            [ Just ( "name", c.name |> Json.string )
            , Just ( "rules", c.rules |> rules )
            , Just ( "decks", c.decks |> decks )
            , Just ( "version", c.version |> Json.string )
            , ( "public", True |> Json.bool ) |> Maybe.justIf c.privacy.public
            , ( "audienceMode", True |> Json.bool ) |> Maybe.justIf c.privacy.audienceMode
            , c.privacy.password |> Maybe.map (\p -> ( "password", p |> Json.string ))
            ]
        )


rules : Rules -> Json.Value
rules r =
    Json.object
        (List.concat
            [ [ ( "handSize", r.handSize |> Json.int )
              , ( "houseRules", r.houseRules |> houseRules )
              , ( "stages", r.stages |> stages )
              ]
            , r.scoreLimit |> Maybe.map (\sl -> [ ( "scoreLimit", sl |> Json.int ) ]) |> Maybe.withDefault []
            ]
        )


stages : Rules.Stages -> Json.Value
stages t =
    Json.object
        (List.filterMap identity
            [ Just ( "timeLimitMode", timeLimitMode t.mode )
            , Just ( "playing", t.playing |> stageRules )
            , t.revealing |> Maybe.map (\r -> ( "revealing", r |> stageRules ))
            , Just ( "judging", t.judging |> stageRules )
            ]
        )


stageRules : Rules.Stage -> Json.Value
stageRules s =
    Json.object
        (List.filterMap identity
            [ s.duration |> Maybe.map (\d -> ( "duration", d |> Json.int ))
            , Just ( "after", s.after |> Json.int )
            ]
        )


houseRules : Rules.HouseRules -> Json.Value
houseRules h =
    Json.object
        (List.filterMap identity
            [ h.rando |> Maybe.map (\r -> ( "rando", rando r ))
            , h.packingHeat |> Maybe.map (\p -> ( "packingHeat", packingHeat p ))
            , h.reboot |> Maybe.map (\r -> ( "reboot", reboot r ))
            , h.comedyWriter |> Maybe.map (\c -> ( "comedyWriter", comedyWriter c ))
            , h.neverHaveIEver |> Maybe.map (\n -> ( "neverHaveIEver", neverHaveIEver n ))
            , h.happyEnding |> Maybe.map (\e -> ( "happyEnding", happyEnding e ))
            ]
        )


rando : Rules.Rando -> Json.Value
rando { number } =
    Json.object [ ( "number", number |> Json.int ) ]


reboot : Rules.Reboot -> Json.Value
reboot { cost } =
    Json.object [ ( "cost", cost |> Json.int ) ]


packingHeat : Rules.PackingHeat -> Json.Value
packingHeat _ =
    Json.object []


neverHaveIEver : Rules.NeverHaveIEver -> Json.Value
neverHaveIEver _ =
    Json.object []


happyEnding : Rules.HappyEnding -> Json.Value
happyEnding _ =
    Json.object []


comedyWriter : Rules.ComedyWriter -> Json.Value
comedyWriter { number, exclusive } =
    Json.object [ ( "number", number |> Json.int ), ( "exclusive", exclusive |> Json.bool ) ]


decks : Decks.Config -> Json.Value
decks d =
    d |> Json.list deckOrError


deckOrError : Decks.DeckOrError -> Json.Value
deckOrError d =
    case d.result of
        Ok s ->
            deck { source = d.source, summary = s }

        Err r ->
            deckError { source = d.source, reason = r }


deck : Decks.Deck -> Json.Value
deck d =
    Json.object
        (List.filterMap identity
            [ Just ( "source", source d.source )
            , d.summary |> Maybe.map (\s -> ( "summary", summary s ))
            ]
        )


summary : Source.Summary -> Json.Value
summary s =
    Json.object
        [ ( "details", details s.details )
        , ( "calls", Json.int s.calls )
        , ( "responses", Json.int s.responses )
        ]


details : Source.Details -> Json.Value
details d =
    Json.object
        (List.filterMap identity
            [ Just ( "name", Json.string d.name )
            , d.url |> Maybe.map (\u -> ( "url", Json.string u ))
            ]
        )


deckError : Decks.Error -> Json.Value
deckError e =
    Json.object
        [ ( "source", source e.source )
        , ( "reason", failureReason e.reason )
        ]


failureReason : Source.LoadFailureReason -> Json.Value
failureReason reason =
    case reason of
        Source.SourceFailure ->
            Json.string "SourceFailure"

        Source.NotFound ->
            Json.string "NotFound"


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
    Round.stageToString >> Json.string


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

        aa =
            s.autoAdvance |> Maybe.map (\e -> [ ( "autoAdvance", Json.bool e ) ]) |> Maybe.withDefault []

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
                , aa
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
        [ ( "name", c.name |> Json.string ), ( "owner", c.owner |> userRegistration ) ]


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
        Source.ManyDecks deckCode ->
            Json.object
                [ ( "source", "ManyDecks" |> Json.string )
                , ( "deckCode", deckCode |> ManyDecks.encode )
                ]

        Source.BuiltIn id ->
            Json.object [ ( "source", "BuiltIn" |> Json.string ), ( "id", id |> BuiltIn.toString |> Json.string ) ]

        Source.JsonAgainstHumanity id ->
            Json.object
                [ ( "source", "JAH" |> Json.string )
                , ( "id", id |> JsonAgainstHumanity.toString |> Json.string )
                ]


language : Language -> Json.Value
language l =
    Lang.code l |> Json.string


userRegistration : User.Registration -> Json.Value
userRegistration r =
    Json.object
        (( "name", r.name |> Json.string )
            :: (r.password |> Maybe.map (\p -> [ ( "password", p |> Json.string ) ]) |> Maybe.withDefault [])
        )
