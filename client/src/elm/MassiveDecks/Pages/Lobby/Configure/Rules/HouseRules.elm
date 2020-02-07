module MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules exposing
    ( componentById
    , init
    , update
    )

import MassiveDecks.Pages.Lobby.Configure.Component as Component exposing (Component)
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.ComedyWriter as ComedyWriter
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.ComedyWriter.Model as ComedyWriter
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.PackingHeat as PackingHeat
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.PackingHeat.Model as PackingHeat
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Rando as Rando
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Rando.Model as Rando
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Reboot as Reboot
import MassiveDecks.Pages.Lobby.Configure.Rules.HouseRules.Reboot.Model as Reboot
import MassiveDecks.Strings as Strings


init : Model
init =
    { rando = Rando.init
    , packingHeat = PackingHeat.init
    , comedyWriter = ComedyWriter.init
    , reboot = Reboot.init
    }


update : String -> Msg -> Config -> Config -> Model -> ( Config, Model, Cmd msg )
update version msg remote local model =
    case msg of
        RandoMsg randoMsg ->
            let
                ( c, m, cmd ) =
                    Rando.update randoMsg local.rando model.rando
            in
            ( { local | rando = c }, { model | rando = m }, cmd )

        PackingHeatMsg packingHeatMsg ->
            let
                ( c, m, cmd ) =
                    PackingHeat.update packingHeatMsg local.packingHeat model.packingHeat
            in
            ( { local | packingHeat = c }, { model | packingHeat = m }, cmd )

        ComedyWriterMsg comedyWriterMsg ->
            let
                ( c, m, cmd ) =
                    ComedyWriter.update comedyWriterMsg local.comedyWriter model.comedyWriter
            in
            ( { local | comedyWriter = c }, { model | comedyWriter = m }, cmd )

        RebootMsg rebootMsg ->
            let
                ( c, m, cmd ) =
                    Reboot.update rebootMsg local.reboot model.reboot
            in
            ( { local | reboot = c }, { model | reboot = m }, cmd )


componentById : Id -> Component Config Model Id Msg msg
componentById id =
    case id of
        All ->
            all

        RandoId randoId ->
            Rando.componentById randoId
                |> Component.lift RandoId RandoMsg .rando (\r -> \c -> { c | rando = r }) .rando

        PackingHeatId packingHeatId ->
            PackingHeat.componentById packingHeatId
                |> Component.lift PackingHeatId PackingHeatMsg .packingHeat (\r -> \c -> { c | packingHeat = r }) .packingHeat

        ComedyWriterId comedyWriterId ->
            ComedyWriter.componentById comedyWriterId
                |> Component.lift ComedyWriterId ComedyWriterMsg .comedyWriter (\r -> \c -> { c | comedyWriter = r }) .comedyWriter

        RebootId rebootId ->
            Reboot.componentById rebootId
                |> Component.lift RebootId RebootMsg .reboot (\r -> \c -> { c | reboot = r }) .reboot



{- Private -}


all : Component Config Model Id Msg msg
all =
    Component.group All
        (Just Strings.HouseRulesTitle)
        [ componentById (RandoId Rando.All)
        , componentById (PackingHeatId PackingHeat.All)
        , componentById (RebootId Reboot.All)
        , componentById (ComedyWriterId ComedyWriter.All)
        ]
