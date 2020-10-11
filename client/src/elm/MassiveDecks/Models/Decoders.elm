module MassiveDecks.Models.Decoders exposing
    ( castStatus
    , config
    , event
    , eventOrMdError
    , externalSource
    , flags
    , gameCode
    , gameStateError
    , language
    , lobbyState
    , lobbySummary
    , lobbyToken
    , mdError
    , part
    , privilege
    , remoteControlCommand
    , revealingRound
    , settings
    , sourceInfo
    , specificRound
    , tokenValidity
    , userId
    , userSummary
    )

import Dict exposing (Dict)
import Json.Decode as Json
import Json.Decode.Pipeline as Json
import Json.Patch
import MassiveDecks.Card.Model as Card exposing (Call, Response)
import MassiveDecks.Card.Parts as Parts exposing (Part, Parts)
import MassiveDecks.Card.Play as Play exposing (Play)
import MassiveDecks.Card.Source.BuiltIn.Model as BuiltIn
import MassiveDecks.Card.Source.Generated.Model as Generated
import MassiveDecks.Card.Source.JsonAgainstHumanity.Model as JsonAgianstHumanity
import MassiveDecks.Card.Source.ManyDecks.Model as ManyDecks
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Cast.Model as Cast
import MassiveDecks.Game.Model as Game exposing (Game)
import MassiveDecks.Game.Player as Player exposing (Player)
import MassiveDecks.Game.Round as Round exposing (LikeDetail, Round)
import MassiveDecks.Game.Rules as Rules exposing (Rules)
import MassiveDecks.Game.Time as Time
import MassiveDecks.Model exposing (..)
import MassiveDecks.Models.MdError as MdError exposing (MdError)
import MassiveDecks.Notifications.Model as Notifications
import MassiveDecks.Pages.Lobby.Configure.Decks.Model as DeckConfig
import MassiveDecks.Pages.Lobby.Configure.Model as Configure
import MassiveDecks.Pages.Lobby.Configure.Privacy.Model as PrivacyConfig
import MassiveDecks.Pages.Lobby.Events as Events exposing (Event)
import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)
import MassiveDecks.Pages.Lobby.Model as Lobby exposing (Lobby)
import MassiveDecks.Pages.Start.LobbyBrowser.Model as LobbyBrowser
import MassiveDecks.Settings.Model as Settings exposing (Settings)
import MassiveDecks.Speech as Speech
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Strings.Languages.Model as Lang exposing (Language)
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.NeList as NonEmptyList
import Set exposing (Set)


sourceInfo : Json.Decoder Source.Info
sourceInfo =
    let
        atLeastOne info =
            if [ info.builtIn /= Nothing, info.manyDecks /= Nothing ] |> List.any identity then
                info |> Json.succeed

            else
                Json.fail "Must have at least one source enabled."
    in
    Json.succeed Source.Info
        |> Json.optional "builtIn" (builtInInfo |> Json.map Just) Nothing
        |> Json.optional "manyDecks" (manyDecksInfo |> Json.map Just) Nothing
        |> Json.optional "jsonAgainstHumanity" (jsonAgainstHumanityInfo |> Json.map Just) Nothing
        |> Json.andThen atLeastOne


builtInInfo : Json.Decoder BuiltIn.Info
builtInInfo =
    Json.succeed BuiltIn.Info
        |> Json.required "decks" (NonEmptyList.decoder builtInDeck)


manyDecksInfo : Json.Decoder ManyDecks.Info
manyDecksInfo =
    Json.succeed ManyDecks.Info
        |> Json.required "baseUrl" Json.string


jsonAgainstHumanityInfo : Json.Decoder JsonAgianstHumanity.Info
jsonAgainstHumanityInfo =
    let
        jsonAgainstHumanityDeck =
            Json.succeed JsonAgianstHumanity.Deck
                |> Json.required "id" JsonAgianstHumanity.idDecoder
                |> Json.required "name" Json.string
    in
    Json.succeed JsonAgianstHumanity.Info
        |> Json.required "aboutUrl" Json.string
        |> Json.required "decks" (Json.list jsonAgainstHumanityDeck)


builtInDeck : Json.Decoder BuiltIn.Deck
builtInDeck =
    Json.succeed BuiltIn.Deck
        |> Json.required "name" Json.string
        |> Json.required "id" BuiltIn.idDecoder
        |> Json.required "language" Json.string
        |> Json.required "author" Json.string
        |> Json.optional "translator" (Json.string |> Json.map Just) Nothing


unknownValue : String -> String -> Json.Decoder a
unknownValue name value =
    ("Unknown " ++ name ++ ": \"" ++ value ++ "\".") |> Json.fail


castStatus : Json.Decoder Cast.Status
castStatus =
    Json.field "status" Json.string |> Json.andThen castStatusByName


castStatusByName : String -> Json.Decoder Cast.Status
castStatusByName name =
    case name of
        "NoDevicesAvailable" ->
            Json.succeed Cast.NoDevicesAvailable

        "NotConnected" ->
            Json.succeed Cast.NotConnected

        "Connecting" ->
            Json.succeed Cast.Connecting

        "Connected" ->
            Json.map Cast.Connected
                (Json.field "name" Json.string)

        _ ->
            unknownValue "cast status" name


remoteControlCommand : Json.Decoder Cast.RemoteControlCommand
remoteControlCommand =
    Json.field "command" Json.string |> Json.andThen remoteControlCommandByName


remoteControlCommandByName : String -> Json.Decoder Cast.RemoteControlCommand
remoteControlCommandByName name =
    case name of
        "Spectate" ->
            spectateCommand

        _ ->
            unknownValue "remote command" name


spectateCommand : Json.Decoder Cast.RemoteControlCommand
spectateCommand =
    Json.map2 (\t -> \l -> Cast.Spectate { token = t, language = l })
        (Json.field "token" lobbyToken)
        (Json.field "language" language)


flags : Json.Decoder Flags
flags =
    Json.map3 Flags
        (Json.maybe (Json.field "settings" settings))
        (Json.field "browserLanguages" (Json.list Json.string))
        (Json.maybe (Json.field "remoteMode" Json.bool) |> Json.map (Maybe.withDefault False))


settings : Json.Decoder Settings
settings =
    Json.succeed Settings
        |> Json.required "tokens" (Json.dict lobbyToken)
        |> Json.required "openUserList" Json.bool
        |> Json.optional "lastUsedName" (Json.string |> Json.map Just) Nothing
        |> Json.required "recentDecks" (Json.list externalSource)
        |> Json.optional "chosenLanguage" (language |> Json.map Just) Nothing
        |> Json.required "compactCards" cardSize
        |> Json.optional "speech" speech Speech.default
        |> Json.optional "notifications" notifications Notifications.default
        |> Json.optional "autoAdvance" (Json.bool |> Json.map Just) Nothing


notifications : Json.Decoder Notifications.Settings
notifications =
    Json.map2 Notifications.Settings
        (Json.field "enabled" Json.bool)
        (Json.field "requireNotVisible" Json.bool)


speech : Json.Decoder Speech.Settings
speech =
    Json.map2 Speech.Settings
        (Json.field "enabled" Json.bool)
        (Json.maybe (Json.field "selectedVoice" Json.string))


cardSize : Json.Decoder Settings.CardSize
cardSize =
    let
        toCardSize i =
            i
                |> Settings.cardSizeFromValue
                |> Maybe.map Json.succeed
                |> Maybe.withDefault (unknownValue "card size" (String.fromInt i))
    in
    Json.int |> Json.andThen toCardSize


gameCode : Json.Decoder GameCode
gameCode =
    Json.string |> Json.map GameCode.trusted


source : Json.Decoder Source
source =
    Json.field "source" Json.string |> Json.andThen sourceByName


sourceByName : String -> Json.Decoder Source
sourceByName name =
    case name of
        "Custom" ->
            Json.succeed Source.Custom

        "Generated" ->
            Json.succeed Source.Generated
                |> Json.required "by" generator

        _ ->
            Json.field "source" Source.generalDecoder |> Json.andThen externalSourceByGeneral |> Json.map Source.Ex


generator : Json.Decoder Generated.Generator
generator =
    let
        fromName name =
            case name of
                "HappyEndingRule" ->
                    Json.succeed Generated.HappyEndingRule

                _ ->
                    unknownValue "generator" name
    in
    Json.string |> Json.andThen fromName


externalSource : Json.Decoder Source.External
externalSource =
    Json.field "source" Source.generalDecoder |> Json.andThen externalSourceByGeneral


externalSourceByGeneral : Source.General -> Json.Decoder Source.External
externalSourceByGeneral general =
    case general of
        Source.GBuiltIn ->
            Json.field "id" BuiltIn.idDecoder |> Json.map Source.BuiltIn

        Source.GManyDecks ->
            Json.field "deckCode" (Json.string |> Json.map ManyDecks.deckCode) |> Json.map Source.ManyDecks

        Source.GJsonAgainstHumanity ->
            Json.field "id" (JsonAgianstHumanity.idDecoder |> Json.map Source.JsonAgainstHumanity)


tokenValidity : Json.Decoder (List Lobby.Token)
tokenValidity =
    Json.list lobbyToken


lobbyToken : Json.Decoder Lobby.Token
lobbyToken =
    Json.string


language : Json.Decoder Language
language =
    Json.string |> Json.andThen languageFromCode


languageFromCode : String -> Json.Decoder Language
languageFromCode code =
    code
        |> Lang.fromCode
        |> Maybe.map Json.succeed
        |> Maybe.withDefault (unknownValue "language code" code)


lobby : Maybe LikeDetail -> Json.Decoder Lobby
lobby ld =
    Json.succeed Lobby
        |> Json.required "users" users
        |> Json.required "owner" userId
        |> Json.required "config" config
        |> Json.optional "game" (game ld |> Json.map (Game.emptyModel >> Just)) Nothing
        |> Json.optional "errors" (Json.list gameStateError) []


game : Maybe LikeDetail -> Json.Decoder Game
game ld =
    Json.succeed Game
        |> Json.required "round" (round ld)
        |> Json.required "history" (Json.list (specificRound (completeRound Nothing)))
        |> Json.required "playerOrder" (Json.list userId)
        |> Json.required "players" (Json.dict player)
        |> Json.required "rules" rules
        |> Json.optional "winner" (Json.list userId |> Json.map (Set.fromList >> Just)) Nothing
        |> Json.optional "paused" Json.bool False


config : Json.Decoder Configure.Config
config =
    Json.map5 Configure.Config
        (Json.field "name" Json.string)
        (Json.field "rules" rules)
        (Json.field "decks" (Json.list deckOrError))
        privacyConfig
        (Json.field "version" Json.string)


privacyConfig : Json.Decoder PrivacyConfig.Config
privacyConfig =
    Json.succeed PrivacyConfig.Config
        |> Json.optional "password" (Json.string |> Json.map Just) Nothing
        |> Json.optional "public" Json.bool False
        |> Json.optional "audienceMode" Json.bool False


deckOrError : Json.Decoder DeckConfig.DeckOrError
deckOrError =
    let
        which e =
            case e of
                Just _ ->
                    deckError |> Json.map DeckConfig.errorToDeckOrError

                Nothing ->
                    deck |> Json.map DeckConfig.deckToDeckOrError
    in
    Json.field "failure" Json.string |> Json.maybe |> Json.andThen which


deck : Json.Decoder DeckConfig.Deck
deck =
    Json.map2 DeckConfig.Deck
        (Json.field "source" externalSource)
        (Json.maybe (Json.field "summary" summary))


deckError : Json.Decoder DeckConfig.Error
deckError =
    Json.map2 DeckConfig.Error
        (Json.field "source" externalSource)
        (Json.field "failure" failReason)


summary : Json.Decoder Source.Summary
summary =
    Json.map3 Source.Summary
        (Json.field "details" details)
        (Json.field "calls" Json.int)
        (Json.field "responses" Json.int)


details : Json.Decoder Source.Details
details =
    Json.succeed Source.Details
        |> Json.required "name" Json.string
        |> Json.optional "url" (Json.string |> Json.map Just) Nothing
        |> Json.optional "author" (Json.string |> Json.map Just) Nothing
        |> Json.optional "language" (Json.string |> Json.map Just) Nothing
        |> Json.optional "translator" (Json.string |> Json.map Just) Nothing


rules : Json.Decoder Rules
rules =
    Json.map4 Rules
        (Json.field "handSize" Json.int)
        (Json.maybe (Json.field "scoreLimit" score))
        (Json.field "houseRules" houseRules)
        (Json.field "stages" stages)


stages : Json.Decoder Rules.Stages
stages =
    Json.succeed Rules.Stages
        |> Json.required "timeLimitMode" timeLimitMode
        |> Json.required "playing" stageRules
        |> Json.optional "revealing" (stageRules |> Json.map Just) Nothing
        |> Json.required "judging" stageRules


stageRules : Json.Decoder Rules.Stage
stageRules =
    Json.succeed Rules.Stage
        |> Json.optional "duration" (Json.int |> Json.map Just) Nothing
        |> Json.required "after" Json.int


timeLimitMode : Json.Decoder Rules.TimeLimitMode
timeLimitMode =
    Json.string |> Json.andThen timeLimitModeByName


timeLimitModeByName : String -> Json.Decoder Rules.TimeLimitMode
timeLimitModeByName name =
    case name of
        "Hard" ->
            Json.succeed Rules.Hard

        "Soft" ->
            Json.succeed Rules.Soft

        _ ->
            unknownValue "time limit mode" name


houseRules : Json.Decoder Rules.HouseRules
houseRules =
    Json.succeed Rules.HouseRules
        |> Json.optional "rando" (rando |> Json.map Just) Nothing
        |> Json.optional "packingHeat" (packingHeat |> Json.map Just) Nothing
        |> Json.optional "reboot" (reboot |> Json.map Just) Nothing
        |> Json.optional "comedyWriter" (comedyWriter |> Json.map Just) Nothing
        |> Json.optional "neverHaveIEver" (neverHaveIEver |> Json.map Just) Nothing
        |> Json.optional "happyEnding" (happyEnding |> Json.map Just) Nothing


comedyWriter : Json.Decoder Rules.ComedyWriter
comedyWriter =
    Json.map2 Rules.ComedyWriter
        (Json.field "number" Json.int)
        (Json.field "exclusive" Json.bool)


packingHeat : Json.Decoder Rules.PackingHeat
packingHeat =
    {} |> Json.succeed


neverHaveIEver : Json.Decoder Rules.NeverHaveIEver
neverHaveIEver =
    {} |> Json.succeed


happyEnding : Json.Decoder Rules.HappyEnding
happyEnding =
    {} |> Json.succeed


reboot : Json.Decoder Rules.Reboot
reboot =
    Json.map Rules.Reboot
        (Json.field "cost" score)


rando : Json.Decoder Rules.Rando
rando =
    Json.map Rules.Rando
        (Json.field "number" score)


player : Json.Decoder Player
player =
    Json.map3 Player
        (Json.field "score" score)
        (Json.field "likes" Json.int)
        (Json.field "presence" playerPresence)


playerPresence : Json.Decoder Player.Presence
playerPresence =
    Json.string |> Json.andThen playerPresenceByName


playerPresenceByName : String -> Json.Decoder Player.Presence
playerPresenceByName name =
    case name of
        "Active" ->
            Json.succeed Player.Active

        "Away" ->
            Json.succeed Player.Away

        _ ->
            unknownValue "player presence" name


control : Json.Decoder User.Control
control =
    Json.string |> Json.andThen controlByName


controlByName : String -> Json.Decoder User.Control
controlByName name =
    case name of
        "Human" ->
            Json.succeed User.Human

        "Computer" ->
            Json.succeed User.Computer

        _ ->
            unknownValue "user controller" name


score : Json.Decoder Player.Score
score =
    Json.int


users : Json.Decoder (Dict User.Id User)
users =
    Json.dict user


user : Json.Decoder User
user =
    Json.map6 User
        (Json.field "name" Json.string)
        (Json.field "presence" userPresence)
        (Json.field "connection" userConnection)
        (Json.field "privilege" privilege)
        (Json.field "role" userRole)
        (Json.field "control" control)


userConnection : Json.Decoder User.Connection
userConnection =
    Json.string |> Json.andThen userConnectionByName


userConnectionByName : String -> Json.Decoder User.Connection
userConnectionByName name =
    case name of
        "Connected" ->
            Json.succeed User.Connected

        "Disconnected" ->
            Json.succeed User.Disconnected

        _ ->
            unknownValue "connection state" name


userPresence : Json.Decoder User.Presence
userPresence =
    Json.string |> Json.andThen userPresenceByName


userPresenceByName : String -> Json.Decoder User.Presence
userPresenceByName name =
    case name of
        "Joined" ->
            Json.succeed User.Joined

        "Left" ->
            Json.succeed User.Left

        _ ->
            unknownValue "presence state" name


role : Json.Decoder User.Role
role =
    Json.string |> Json.andThen roleByName


roleByName : String -> Json.Decoder User.Role
roleByName name =
    case name of
        "Spectator" ->
            Json.succeed User.Spectator

        "Player" ->
            Json.succeed User.Player

        _ ->
            unknownValue "user role" name


lobbyState : Json.Decoder Lobby.State
lobbyState =
    Json.string |> Json.andThen lobbyStateByName


lobbyStateByName : String -> Json.Decoder Lobby.State
lobbyStateByName name =
    case name of
        "Playing" ->
            Json.succeed Lobby.Playing

        "SettingUp" ->
            Json.succeed Lobby.SettingUp

        _ ->
            unknownValue "lobby state" name


lobbySummary : Json.Decoder LobbyBrowser.Summary
lobbySummary =
    Json.map5 LobbyBrowser.Summary
        (Json.field "name" Json.string)
        (Json.field "gameCode" gameCode)
        (Json.field "state" lobbyState)
        (Json.field "users" userSummary)
        (Json.maybe (Json.field "password" Json.bool) |> Json.map (Maybe.withDefault False))


userId : Json.Decoder User.Id
userId =
    Json.string


privilege : Json.Decoder User.Privilege
privilege =
    Json.string |> Json.andThen privilegeByName


privilegeByName : String -> Json.Decoder User.Privilege
privilegeByName name =
    case name of
        "Privileged" ->
            Json.succeed User.Privileged

        "Unprivileged" ->
            Json.succeed User.Unprivileged

        _ ->
            unknownValue "privilege level" name


userSummary : Json.Decoder LobbyBrowser.UserSummary
userSummary =
    Json.map2 LobbyBrowser.UserSummary
        (Json.field "players" Json.int)
        (Json.field "spectators" Json.int)


eventOrMdError : Json.Decoder (Result MdError Event)
eventOrMdError =
    let
        which e =
            case e of
                Just name ->
                    mdErrorByName name |> Json.map Result.Err

                Nothing ->
                    event |> Json.map Result.Ok
    in
    Json.field "error" Json.string |> Json.maybe |> Json.andThen which


event : Json.Decoder Event
event =
    Json.field "event" Json.string |> Json.andThen eventByName


eventByName : String -> Json.Decoder Event
eventByName name =
    case name of
        "Sync" ->
            sync

        "Connected" ->
            connection User.Connected

        "Disconnected" ->
            connection User.Disconnected

        "Joined" ->
            userJoined |> Json.andThen presence

        "Left" ->
            userLeft |> Json.andThen presence

        "UserRoleChanged" ->
            userRoleChanged

        "Configured" ->
            configured

        "GameStarted" ->
            gameStarted

        "RoundStarted" ->
            timedGameEvent roundStarted

        "PlaySubmitted" ->
            gameEvent playSubmitted

        "PlayTakenBack" ->
            gameEvent playTakenBack

        "PlayLiked" ->
            gameEvent playLiked

        "StartRevealing" ->
            timedGameEvent startRevealing

        "StartJudging" ->
            timedGameEvent startJudging

        "PlayRevealed" ->
            timedGameEvent playRevealed

        "RoundFinished" ->
            timedGameEvent roundFinished

        "HandRedrawn" ->
            gameEvent handRedrawn

        "CardDiscarded" ->
            gameEvent cardDiscarded

        "Away" ->
            gameEvent playerAway

        "Back" ->
            gameEvent playerBack

        "PrivilegeChanged" ->
            privilegeChanged

        "Paused" ->
            gameEvent (Json.succeed Events.Paused)

        "Continued" ->
            gameEvent (Json.succeed Events.Continued)

        "StageTimerDone" ->
            gameEvent stageTimerDone

        "GameEnded" ->
            gameEvent ended

        "ErrorEncountered" ->
            errorEncountered

        _ ->
            unknownValue "event" name


userRoleChanged : Json.Decoder Events.Event
userRoleChanged =
    Json.map3 (\u -> \r -> \h -> Events.UserRoleChanged { user = u, role = r, hand = h })
        (Json.field "user" userId)
        (Json.field "role" role)
        (Json.maybe (Json.field "hand" (Json.list response)))


errorEncountered : Json.Decoder Events.Event
errorEncountered =
    Json.map (\e -> Events.ErrorEncountered { error = e })
        (Json.field "error" gameStateError)


configured : Json.Decoder Events.Event
configured =
    Json.map (\c -> Events.Configured { change = c })
        (Json.field "change" Json.Patch.decoder)


ended : Json.Decoder Events.GameEvent
ended =
    Json.map (\w -> Events.GameEnded { winner = w })
        (Json.field "winner" (Json.list userId |> Json.map Set.fromList))


stageTimerDone : Json.Decoder Events.GameEvent
stageTimerDone =
    Json.map2 (\r -> \s -> Events.StageTimerDone { round = r, stage = s })
        (Json.field "round" Round.idDecoder)
        (Json.field "stage" stage)


playerAway : Json.Decoder Events.GameEvent
playerAway =
    Json.map (\p -> Events.PlayerAway { player = p })
        (Json.field "player" userId)


playerBack : Json.Decoder Events.GameEvent
playerBack =
    Json.map (\p -> Events.PlayerBack { player = p })
        (Json.field "player" userId)


handRedrawn : Json.Decoder Events.GameEvent
handRedrawn =
    Json.map2 (\pl -> \ha -> Events.HandRedrawn { player = pl, hand = ha })
        (Json.field "player" userId)
        (Json.maybe (Json.field "hand" (Json.list response)))


cardDiscarded : Json.Decoder Events.GameEvent
cardDiscarded =
    Json.succeed (\pl -> \ca -> \re -> Events.CardDiscarded { player = pl, card = ca, replacement = re })
        |> Json.required "player" userId
        |> Json.required "card" response
        |> Json.optional "replacement" (response |> Json.map Just) Nothing


roundFinished : Json.Decoder Events.TimedGameEvent
roundFinished =
    Json.map2 (\wi -> \pb -> Events.RoundFinished { winner = wi, playedBy = pb })
        (Json.field "winner" userId)
        (Json.field "playDetails" (Json.dict playDetails))


playDetails : Json.Decoder Play.Details
playDetails =
    Json.map2 Play.Details
        (Json.field "playedBy" userId)
        (Json.maybe (Json.field "likes" Json.int))


playRevealed : Json.Decoder Events.TimedGameEvent
playRevealed =
    Json.map2 (\id -> \pl -> Events.PlayRevealed { id = id, play = pl })
        (Json.field "id" playId)
        (Json.field "play" (Json.list response))


afterPlaying : Json.Decoder Events.AfterPlaying
afterPlaying =
    Json.succeed Events.AfterPlaying
        |> Json.optional "played" (playId |> Json.map Just) Nothing
        |> Json.optional "drawn" (Json.list response |> Json.map Just) Nothing


startRevealing : Json.Decoder Events.TimedGameEvent
startRevealing =
    Json.succeed (\ps -> \ap -> Events.StartRevealing { plays = ps, afterPlaying = ap })
        |> Json.required "plays" (Json.list playId)
        |> Json.custom afterPlaying


startJudging : Json.Decoder Events.TimedGameEvent
startJudging =
    Json.succeed (\ps -> \ap -> Events.StartJudging { plays = ps, afterPlaying = ap })
        |> Json.optional "plays" (knownPlay |> Json.list |> Json.map Just) Nothing
        |> Json.custom afterPlaying


gameEvent : Json.Decoder Events.GameEvent -> Json.Decoder Event
gameEvent =
    Json.map Events.Game


timedGameEvent : Json.Decoder Events.TimedGameEvent -> Json.Decoder Event
timedGameEvent =
    Json.map (\e -> Events.NoTime { event = e } |> Events.Timed) >> gameEvent


playSubmitted : Json.Decoder Events.GameEvent
playSubmitted =
    Json.map (\by -> Events.PlaySubmitted { by = by })
        (Json.field "by" userId)


playTakenBack : Json.Decoder Events.GameEvent
playTakenBack =
    Json.map (\by -> Events.PlayTakenBack { by = by })
        (Json.field "by" userId)


playLiked : Json.Decoder Events.GameEvent
playLiked =
    Json.map (\id -> Events.PlayLiked { play = id })
        (Json.field "id" playId)


roundStarted : Json.Decoder Events.TimedGameEvent
roundStarted =
    Json.map5 (\id -> \ca -> \cz -> \pl -> \d -> { id = id, call = ca, czar = cz, players = pl, drawn = d } |> Events.RoundStarted)
        (Json.field "id" Round.idDecoder)
        (Json.field "call" call)
        (Json.field "czar" userId)
        (Json.field "players" playerSet)
        (Json.maybe (Json.field "drawn" (Json.list response)))


privilegeChanged : Json.Decoder Events.Event
privilegeChanged =
    Json.map2 (\u -> \p -> Events.PrivilegeChanged { user = u, privilege = p })
        (Json.field "user" userId)
        (Json.field "privilege" privilege)


gameStarted : Json.Decoder Events.Event
gameStarted =
    Json.succeed (\r -> \h -> { round = r, hand = h } |> Events.GameStarted)
        |> Json.required "round" (specificRound playingRound)
        |> Json.optional "hand" (Json.list response |> Json.map Just) Nothing


sync : Json.Decoder Event
sync =
    let
        construct ls h p pa =
            Events.Sync { state = ls, hand = h, play = p, partialTimeAnchor = pa }

        decodeSync ld =
            Json.succeed construct
                |> Json.required "state" (lobby ld)
                |> Json.optional "hand" (Json.list response |> Json.map Just) Nothing
                |> Json.optional "play" (Json.list Json.string |> Json.map Just) Nothing
                |> Json.required "gameTime" Time.partialAnchorDecoder
    in
    Json.maybe (Json.field "likeDetail" likeDetail) |> Json.andThen decodeSync


connection : User.Connection -> Json.Decoder Event
connection state =
    Json.map (\u -> Events.Connection { user = u, state = state })
        (Json.field "user" userId)


presence : Events.PresenceState -> Json.Decoder Event
presence state =
    Json.map (\u -> Events.Presence { user = u, state = state })
        (Json.field "user" userId)


userJoined : Json.Decoder Events.PresenceState
userJoined =
    Json.map3 (\n -> \p -> \c -> Events.UserJoined { name = n, privilege = p, control = c })
        (Json.field "name" Json.string)
        (Json.maybe (Json.field "privilege" privilege) |> Json.map (Maybe.withDefault User.Unprivileged))
        (Json.maybe (Json.field "control" control) |> Json.map (Maybe.withDefault User.Human))


userLeft : Json.Decoder Events.PresenceState
userLeft =
    Json.map (\r -> Events.UserLeft { reason = r })
        (Json.maybe (Json.field "reason" leaveReason) |> Json.map (Maybe.withDefault User.LeftNormally))


leaveReason : Json.Decoder User.LeaveReason
leaveReason =
    Json.string |> Json.andThen leaveReasonByName


leaveReasonByName : String -> Json.Decoder User.LeaveReason
leaveReasonByName name =
    case name of
        "Left" ->
            Json.succeed User.LeftNormally

        "Kicked" ->
            Json.succeed User.Kicked

        _ ->
            unknownValue "leaving reason" name


failReason : Json.Decoder Source.LoadFailureReason
failReason =
    Json.string |> Json.andThen failReasonByName


failReasonByName : String -> Json.Decoder Source.LoadFailureReason
failReasonByName name =
    case name of
        "SourceFailure" ->
            Json.succeed Source.SourceFailure

        "NotFound" ->
            Json.succeed Source.NotFound

        _ ->
            unknownValue "failure reason" name


play : Json.Decoder Play
play =
    Json.map2 Play
        (Json.field "id" playId)
        (Json.maybe (Json.field "play" (Json.list response)))


playId : Json.Decoder Play.Id
playId =
    Json.string


knownPlay : Json.Decoder Play.Known
knownPlay =
    Json.map2 Play.Known
        (Json.field "id" playId)
        (Json.field "play" (Json.list response))


cardId : Json.Decoder Card.Id
cardId =
    Json.string


response : Json.Decoder Card.Response
response =
    Json.map3 Card.response
        (Json.field "text" Json.string)
        (Json.field "id" cardId)
        (Json.field "source" source)


call : Json.Decoder Card.Call
call =
    Json.map3 Card.call
        (Json.field "parts" parts)
        (Json.field "id" cardId)
        (Json.field "source" source)


parts : Json.Decoder Parts
parts =
    let
        handleResult result =
            case result of
                Ok s ->
                    Json.succeed s

                Err e ->
                    "Not a valid call: " ++ e |> Json.fail
    in
    Json.list (Json.list part)
        |> Json.map enrich
        |> Json.map Parts.fromList
        |> Json.andThen handleResult


type PartData
    = Text String Parts.Style
    | Slot (Maybe Int) Parts.Transform Parts.Style


enrich : List (List PartData) -> List (List Parts.Part)
enrich partData =
    let
        foldParts p ( nextIndex, output ) =
            case p of
                Text t s ->
                    ( nextIndex, Parts.Text t s :: output )

                Slot givenIndex t s ->
                    case givenIndex of
                        Just i ->
                            ( nextIndex, Parts.Slot i t s :: output )

                        Nothing ->
                            ( nextIndex + 1, Parts.Slot nextIndex t s :: output )

        foldLine line ( nextIndex, output ) =
            let
                ( lastIndex, outLine ) =
                    line |> List.foldl foldParts ( nextIndex, [] )
            in
            ( lastIndex, (outLine |> List.reverse) :: output )

        ( _, enriched ) =
            partData |> List.foldl foldLine ( 0, [] )
    in
    enriched |> List.reverse


part : Json.Decoder PartData
part =
    Json.oneOf
        [ Json.string |> Json.map (\t -> Text t Parts.NoStyle)
        , styled
        , slot
        ]


slot : Json.Decoder PartData
slot =
    Json.succeed Slot
        |> Json.optional "index" (Json.int |> Json.map Just) Nothing
        |> Json.optional "transform" transform Parts.NoTransform
        |> Json.optional "style" style Parts.NoStyle


styled : Json.Decoder PartData
styled =
    Json.succeed Text
        |> Json.required "text" Json.string
        |> Json.optional "style" style Parts.NoStyle


transform : Json.Decoder Parts.Transform
transform =
    Json.string |> Json.andThen transformByName


transformByName : String -> Json.Decoder Parts.Transform
transformByName name =
    case name of
        "UpperCase" ->
            Json.succeed Parts.UpperCase

        "Capitalize" ->
            Json.succeed Parts.Capitalize

        _ ->
            unknownValue "transform" name


style : Json.Decoder Parts.Style
style =
    Json.string |> Json.andThen styleByName


styleByName : String -> Json.Decoder Parts.Style
styleByName name =
    case name of
        "Em" ->
            Json.succeed Parts.Em

        _ ->
            unknownValue "style" name


round : Maybe LikeDetail -> Json.Decoder Round
round ld =
    let
        stageDetailsByName name =
            case name of
                "Playing" ->
                    playingRound |> Json.map Round.P

                "Revealing" ->
                    revealingRound ld |> Json.map Round.R

                "Judging" ->
                    judgingRound ld |> Json.map Round.J

                "Complete" ->
                    completeRound ld |> Json.map Round.C

                _ ->
                    unknownValue "round stage" name

        byName stageName =
            specificRound (stageDetailsByName stageName)
    in
    Json.field "stage" Json.string |> Json.andThen byName


specificRound : Json.Decoder stageDetails -> Json.Decoder (Round.Specific stageDetails)
specificRound stageDetails =
    Json.succeed Round.Specific
        |> Json.required "id" Round.idDecoder
        |> Json.required "czar" userId
        |> Json.required "players" playerSet
        |> Json.required "call" call
        |> Json.required "startedAt" Time.timeDecoder
        |> Json.custom stageDetails


playerSet : Json.Decoder (Set User.Id)
playerSet =
    Json.list userId |> Json.map Set.fromList


playingRound : Json.Decoder Round.Playing
playingRound =
    Json.succeed (Round.Playing Round.noPick)
        |> Json.required "played" playerSet
        |> Json.optional "timedOut" Json.bool False


likeDetail : Json.Decoder Round.LikeDetail
likeDetail =
    Json.succeed Round.LikeDetail
        |> Json.optional "played" (playId |> Json.map Just) Nothing
        |> Json.required "liked" (Json.list playId |> Json.map Set.fromList)


revealingRound : Maybe Round.LikeDetail -> Json.Decoder Round.Revealing
revealingRound ld =
    Json.succeed (Round.Revealing (ld |> Maybe.withDefault Round.defaultLikeDetail) Nothing Nothing)
        |> Json.required "plays" (Json.list play)
        |> Json.optional "timedOut" Json.bool False


judgingRound : Maybe Round.LikeDetail -> Json.Decoder Round.Judging
judgingRound ld =
    Json.succeed (Round.Judging (ld |> Maybe.withDefault Round.defaultLikeDetail) Nothing)
        |> Json.required "plays" (Json.list knownPlay)
        |> Json.optional "timedOut" Json.bool False


completeRound : Maybe Round.LikeDetail -> Json.Decoder Round.Complete
completeRound ld =
    Json.succeed (Round.Complete (ld |> Maybe.withDefault Round.defaultLikeDetail) Nothing)
        |> Json.required "plays" (Json.dict playWithDetails)
        |> Json.required "playOrder" (Json.list userId)
        |> Json.required "winner" userId


playWithDetails : Json.Decoder Play.WithDetails
playWithDetails =
    Json.succeed Play.WithDetails
        |> Json.required "play" (Json.list response)
        |> Json.required "playedBy" userId
        |> Json.optional "likes" (Json.int |> Json.map Just) Nothing


playerRole : Json.Decoder Player.Role
playerRole =
    Json.string |> Json.andThen playerRoleByName


playerRoleByName : String -> Json.Decoder Player.Role
playerRoleByName name =
    case name of
        "Czar" ->
            Json.succeed Player.RCzar

        "Player" ->
            Json.succeed Player.RPlayer

        _ ->
            unknownValue "player role" name


userRole : Json.Decoder User.Role
userRole =
    Json.string |> Json.andThen userRoleByName


userRoleByName : String -> Json.Decoder User.Role
userRoleByName name =
    case name of
        "Spectator" ->
            Json.succeed User.Spectator

        "Player" ->
            Json.succeed User.Player

        _ ->
            unknownValue "user role" name


mdError : Json.Decoder MdError
mdError =
    Json.field "error" Json.string |> Json.andThen mdErrorByName


mdErrorByName : String -> Json.Decoder MdError
mdErrorByName name =
    case name of
        "IncorrectPlayerRole" ->
            incorrectPlayerRole |> Json.map MdError.ActionExecution

        "IncorrectUserRole" ->
            incorrectUserRole |> Json.map MdError.ActionExecution

        "IncorrectRoundStage" ->
            incorrectRoundStageError |> Json.map MdError.ActionExecution

        "ConfigEditConflict" ->
            configEditConflictError |> Json.map MdError.ActionExecution

        "Unprivileged" ->
            Json.succeed (MdError.ActionExecution MdError.Unprivileged)

        "GameNotStarted" ->
            Json.succeed (MdError.ActionExecution MdError.GameNotStarted)

        "AuthenticationFailure" ->
            authenticationError |> Json.map MdError.Authentication

        "LobbyNotFound" ->
            Json.map2 (\r -> \g -> MdError.LobbyNotFound { reason = r, gameCode = g })
                (Json.field "reason" lobbyError)
                (Json.field "gameCode" gameCode)

        "Registration" ->
            registrationError |> Json.map MdError.Registration

        "OutOfCards" ->
            gameStateErrorByName name |> Json.map MdError.Game

        "InvalidAction" ->
            invalidActionError |> Json.map MdError.ActionExecution

        _ ->
            unknownValue "error" name


gameStateError : Json.Decoder MdError.GameStateError
gameStateError =
    Json.field "error" Json.string |> Json.andThen gameStateErrorByName


gameStateErrorByName : String -> Json.Decoder MdError.GameStateError
gameStateErrorByName name =
    case name of
        "OutOfCards" ->
            Json.succeed MdError.OutOfCardsError

        _ ->
            unknownValue "game state error" name


stage : Json.Decoder Round.Stage
stage =
    let
        stageByName name =
            case name of
                "Playing" ->
                    Json.succeed Round.SPlaying

                "Revealing" ->
                    Json.succeed Round.SRevealing

                "Judging" ->
                    Json.succeed Round.SJudging

                "Complete" ->
                    Json.succeed Round.SComplete

                _ ->
                    unknownValue "round stage" name
    in
    Json.string |> Json.andThen stageByName


invalidActionError : Json.Decoder MdError.ActionExecutionError
invalidActionError =
    Json.map (\r -> MdError.InvalidAction { reason = r })
        (Json.field "reason" Json.string)


incorrectRoundStageError : Json.Decoder MdError.ActionExecutionError
incorrectRoundStageError =
    Json.map2 (\s -> \e -> MdError.IncorrectRoundStage { stage = s, expected = e })
        (Json.field "stage" stage)
        (Json.field "expected" stage)


configEditConflictError : Json.Decoder MdError.ActionExecutionError
configEditConflictError =
    Json.map2 (\v -> \e -> MdError.ConfigEditConflict { version = v, expected = e })
        (Json.field "version" Json.string)
        (Json.field "expected" Json.string)


incorrectPlayerRole : Json.Decoder MdError.ActionExecutionError
incorrectPlayerRole =
    Json.map2 (\r -> \e -> MdError.IncorrectPlayerRole { role = r, expected = e })
        (Json.field "role" playerRole)
        (Json.field "expected" playerRole)


incorrectUserRole : Json.Decoder MdError.ActionExecutionError
incorrectUserRole =
    Json.map2 (\r -> \e -> MdError.IncorrectUserRole { role = r, expected = e })
        (Json.field "role" userRole)
        (Json.field "expected" userRole)


authenticationError : Json.Decoder MdError.AuthenticationError
authenticationError =
    Json.field "reason" Json.string |> Json.andThen authenticationErrorByName


authenticationErrorByName : String -> Json.Decoder MdError.AuthenticationError
authenticationErrorByName name =
    case name of
        "IncorrectIssuer" ->
            Json.succeed MdError.IncorrectIssuer

        "InvalidAuthentication" ->
            Json.succeed MdError.InvalidAuthentication

        "InvalidLobbyPassword" ->
            Json.succeed MdError.InvalidLobbyPassword

        "AlreadyLeftError" ->
            Json.succeed MdError.AlreadyLeftError

        _ ->
            unknownValue "authentication failure reason" name


registrationError : Json.Decoder MdError.RegistrationError
registrationError =
    Json.field "reason" Json.string |> Json.andThen registrationErrorByName


registrationErrorByName : String -> Json.Decoder MdError.RegistrationError
registrationErrorByName name =
    case name of
        "UsernameAlreadyInUse" ->
            Json.map (\u -> MdError.UsernameAlreadyInUseError { username = u })
                (Json.field "username" Json.string)

        _ ->
            unknownValue "registration error" name


lobbyError : Json.Decoder MdError.LobbyNotFoundError
lobbyError =
    Json.string |> Json.andThen lobbyErrorByName


lobbyErrorByName : String -> Json.Decoder MdError.LobbyNotFoundError
lobbyErrorByName name =
    case name of
        "Closed" ->
            Json.succeed MdError.Closed

        "DoesNotExist" ->
            Json.succeed MdError.DoesNotExist

        _ ->
            unknownValue "lobby not found error" name
