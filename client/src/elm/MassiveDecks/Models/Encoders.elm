module MassiveDecks.Models.Encoders exposing
    ( castFlags
    , checkAlive
    , houseRuleChange
    , language
    , lobbyCreation
    , lobbyToken
    , settings
    , source
    , userRegistration
    )

import Dict
import Json.Encode as Json
import MassiveDecks.Card.Source.Cardcast.Model as Cardcast
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Cast.Model as Cast
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Pages.Lobby.Model as Lobby
import MassiveDecks.Pages.Start.Model as Start
import MassiveDecks.Settings.Model as Settings exposing (Settings)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Strings.Languages.Model as Lang exposing (Language)
import MassiveDecks.User as User


checkAlive : List Lobby.Token -> Json.Value
checkAlive tokens =
    [ ( "tokens", Json.list lobbyToken tokens ) ] |> Json.object


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
                  , ( "compactCards", Json.bool s.compactCards )
                  ]
                , lun
                , cl
                ]
    in
    Json.object fields


lobbyCreation : Start.LobbyCreation -> Json.Value
lobbyCreation c =
    Json.object
        [ ( "owner", c.owner |> userRegistration ) ]


castFlags : Cast.Flags -> Json.Value
castFlags cf =
    Json.object
        [ ( "token", cf.token |> Json.string )
        , ( "language", cf.language |> language )
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
