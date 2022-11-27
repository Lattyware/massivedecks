module MassiveDecks.Strings.Languages.Es exposing (pack)

{-| Spanish localization.

Contributors:

  - carlesvimas <https://github.com/carlesvimas>
  - Polsaker <https://github.com/Polsaker>
  - rafitamolin <https://github.com/rafitamolin>

-}

import MassiveDecks.Card.Source.BuiltIn.Model as BuiltIn
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Strings exposing (MdString(..), Noun(..), Quantity(..), noun, nounMaybe, nounUnknownQuantity)
import MassiveDecks.Strings.Languages.Model exposing (Language(..))
import MassiveDecks.Strings.Translation as Translation
import MassiveDecks.Strings.Translation.Model as Translation exposing (Result(..))


pack : Translation.Pack
pack =
    Translation.pack
        { lang = Es
        , code = "es"
        , name = Spanish
        , translate = translate
        , recommended = "cah-base-en" |> BuiltIn.hardcoded |> Source.BuiltIn
        }



{- Private -}


translate : Maybe never -> MdString -> List (Translation.Result never)
translate _ mdString =
    case mdString of
        -- General
        MassiveDecks ->
            [ Text "Massive Decks" ]

        Close ->
            [ Text "Cerrar" ]

        Noun { noun, quantity } ->
            case quantity of
                Quantity 1 ->
                    case noun of
                        Call ->
                            [ Text "Carta negra" ]

                        Response ->
                            [ Text "Carta blanca" ]

                        Point ->
                            [ Text "Punto especial" ]

                        Player ->
                            [ Text "Jugador" ]

                        Spectator ->
                            [ Text "Espectador" ]

                _ ->
                    case noun of
                        Call ->
                            [ Text "Cartas negras" ]

                        Response ->
                            [ Text "Cartas blancas" ]

                        Point ->
                            [ Text "Puntos especiales" ]

                        Player ->
                            [ Text "Jugadores" ]

                        Spectator ->
                            [ Text "Espectadores" ]

        -- Start screen.
        Version { clientVersion, serverVersion } ->
            let
                quote version =
                    [ Text "“", Text version, Text "”" ]
            in
            List.concat
                [ [ Text "Versión " ]
                , clientVersion |> quote
                , [ Text " / " ]
                , serverVersion |> Maybe.map quote |> Maybe.withDefault []
                ]

        ShortGameDescription ->
            [ Text "Un juego de comedia para fiestas." ]

        WhatIsThis ->
            [ Text "¿Qué es ", ref MassiveDecks, Text "?" ]

        GameDescription ->
            [ ref MassiveDecks
            , Text " es un juego de comedia basado en "
            , ref CardsAgainstHumanity
            , Text ", desarrollado por "
            , ref RereadGames
            , Text " y otros colaboradores. El juego es de código abierto bajo "
            , ref License
            , Text ", por lo que puedes ayudar a mejorar el juego, acceder al código fuente, o simplemente ver más en "
            , ref MDProject
            , Text "."
            ]

        NewGame ->
            [ Text "Nuevo" ]

        NewGameDescription ->
            [ Text "Empezar una partida nueva de ", ref MassiveDecks, Text "." ]

        FindPublicGame ->
            [ Text "Buscar" ]

        JoinPrivateGame ->
            [ Text "Unirse" ]

        JoinPrivateGameDescription ->
            [ Text "Unirse a una partida a la que te han invitado." ]

        PlayGame ->
            [ Text "Jugar" ]

        AboutTheGame ->
            [ Text "Saber más" ]

        AboutTheGameDescription ->
            [ Text "Saber más sobre ", ref MassiveDecks, Text " ." ]

        MDLogoDescription ->
            [ Text "Una ", ref (noun Call 1), Text " y una ", ref (noun Response 1), Text " marcadas con una “M” y con una “D”." ]

        RereadLogoDescription ->
            [ Text "Un libro encerrado en un círculo por una flecha de reciclaje." ]

        MDProject ->
            [ Text "el proyecto de GitHub" ]

        License ->
            [ Text "la licencia AGPLv3" ]

        DevelopedByReread ->
            [ Text "Desarrollado por ", ref RereadGames, Text "." ]

        RereadGames ->
            [ Text "Reread Games" ]

        NameLabel ->
            [ Text "Tu nombre" ]

        NameInUse ->
            [ Text "Otra persona está usando este nombre en la partida. Por favor, elige otro diferente." ]

        RejoinTitle ->
            [ Text "Volver a unirse a la partida" ]

        RejoinGame { code } ->
            [ Text "Volver a unirse a “", GameCode { code = code } |> ref, Text "”." ]

        LobbyRequiresPassword ->
            [ Text "Necesitas una contraseña para entrar a la partida. Pídesela a la persona que te ha invitado." ]

        YouWereKicked ->
            [ Text "Has sido expulsado de la partida." ]

        ScrollToTop ->
            [ Text "Desplazar hacia arriba." ]

        Copy ->
            [ Text "Copiar" ]

        -- Rules
        CardsAgainstHumanity ->
            [ Text "Cartas contra la Humanidad" ]

        Rules ->
            [ Text "Cómo jugar." ]

        RulesHand ->
            [ Text "Cada jugador tiene una baraja de  ", ref (nounUnknownQuantity Response), Text "." ]

        RulesCzar ->
            [ Text "El primer jugador empieza como el "
            , ref Czar
            , Text ". El "
            , ref Czar
            , Text " leerá la pregunta o la frase sin completar de la "
            , ref (noun Call 1)
            , Text " en voz alta."
            ]

        RulesPlaying ->
            [ Text "Todo el mundo responde a la pregunta o completa la frase escogiendo una "
            , ref (noun Response 1)
            , Text " de su baraja."
            ]

        RulesJudging ->
            [ Text "Las respuestas serán entonces mezcladas y el "
            , ref Czar
            , Text " las leerá en voz alta. Para una inmersión completa, el "
            , ref Czar
            , Text " debe re-leer la "
            , ref (noun Call 1)
            , Text " antes de presentar cada respuesta. El "
            , ref Czar
            , Text " escogerá entonces la mejor respuesta, y el jugador que la haya hecho se llevará un "
            , ref (noun Point 1)
            , Text "."
            ]

        RulesPickTitle ->
            [ ref (Pick { numberOfCards = 2 }) ]

        RulesPick ->
            [ Text "Algunas cartas necesitarán más de una "
            , ref (noun Response 1)
            , Text " como respuesta. Juega las cartas en el orden que el "
            , ref Czar
            , Text " las debería leer en voz alta."
            ]

        ExamplePickDescription ->
            [ ref (nounUnknownQuantity Call)
            , Text " como esta requerirán escoger más "
            , ref (nounUnknownQuantity Response)
            , Text ", pero tendrás más para escoger."
            ]

        RulesDraw ->
            [ Text "Algunas "
            , ref (nounUnknownQuantity Call)
            , Text " necesitarán aún más "
            , ref (nounUnknownQuantity Response)
            , Text ". Estas dirán "
            , ref (Draw { numberOfCards = 2 })
            , Text " o más, y obtendrás esa cantidad de cartas extra antes de jugar."
            ]

        GameRulesTitle ->
            [ Text "Normas del juego" ]

        HouseRulesTitle ->
            [ Text "Normas de la casa" ]

        HouseRules ->
            [ Text "Puedes cambiar la forma de jugar de diversas maneras. Al configurar la partida, elige "
            , Text "tantas normas de la casa como quieras usar."
            ]

        HouseRuleReboot ->
            [ Text "Reiniciar el universo" ]

        HouseRuleRebootDescription { cost } ->
            [ Text "En cualquier momento, los jugadores podrán intercambiar "
            , Text (an cost)
            , ref (nounMaybe Point cost)
            , Text " para descartar toda su baraja y conseguir otra nueva."
            ]

        HouseRuleRebootAction { cost } ->
            [ Text "Gastar "
            , Text (asWord cost)
            , Text " "
            , ref (noun Point cost)
            , Text " para descartar tu baraja y obtener una nueva."
            ]

        HouseRuleRebootCost ->
            [ Text "Coste de ", ref (nounUnknownQuantity Point) ]

        HouseRuleRebootCostDescription ->
            [ Text "Cuántos ", ref (nounUnknownQuantity Point), Text " cuesta reiniciar la baraja." ]

        HouseRulePackingHeat ->
            [ Text "Plomo en los bolsillos" ]

        HouseRulePackingHeatDescription ->
            [ Text "Cualquier "
            , ref (noun Call 1)
            , Text " con "
            , ref (Pick { numberOfCards = 2 })
            , Text " también tendrá "
            , ref (Draw { numberOfCards = 1 })
            , Text ", para que todos tengan más opciones a elegir."
            ]

        HouseRuleComedyWriter ->
            [ Text "Escritor de cartas" ]

        HouseRuleComedyWriterDescription ->
            [ Text "Incluye "
            , ref (nounUnknownQuantity Response)
            , Text " vacías, en las que los jugadores podrán escribir respuestas personalizadas."
            ]

        HouseRuleComedyWriterNumber ->
            [ ref (nounUnknownQuantity Response), Text " vacías" ]

        HouseRuleComedyWriterNumberDescription ->
            [ Text "La cantidad de "
            , ref (nounUnknownQuantity Response)
            , Text " que habrá en la partida."
            ]

        HouseRuleComedyWriterExclusive ->
            [ Text "Solo ", ref (nounUnknownQuantity Response), Text " vacías" ]

        HouseRuleComedyWriterExclusiveDescription ->
            [ Text "Si se activa, todas las demás  "
            , ref (nounUnknownQuantity Response)
            , Text " serán ignoradas, solo se usarán cartas vacías."
            ]

        HouseRuleRandoCardrissian ->
            [ Text "Cartero aleatorio" ]

        HouseRuleRandoCardrissianDescription ->
            [ Text "Cada ronda, la primera "
            , ref (noun Response 1)
            , Text " en la baraja será jugada como respuesta de un bot llamado "
            , Text "Cartero aleatorio, y si gana la partida, todos los jugadores deberán irse a casa en un estado de depresión severa."
            ]

        HouseRuleRandoCardrissianNumber ->
            [ Text "Jugadores IA" ]

        HouseRuleRandoCardrissianNumberDescription ->
            [ Text "El número de bots en la partida." ]

        HouseRuleNeverHaveIEver ->
            [ Text "Yo nunca" ]

        HouseRuleNeverHaveIEverDescription ->
            [ Text "En cualquier momento, un jugador podrá descartar las cartas que no entienda, sin embargo, tendrá que confesar su "
            , Text "ignorancia: se revelará la carta a todos."
            ]

        HouseRuleHappyEnding ->
            [ Text "Final feliz" ]

        HouseRuleHappyEndingDescription ->
            [ Text "Cuando la partida esté por terminar, se añadirá una ronda extra con una ", ref (noun Call 1), Text " sobre crear un poema." ]

        HouseRuleCzarChoices ->
            [ Text "Decisión del ", ref Czar ]

        HouseRuleCzarChoicesDescription ->
            [ Text "Al empezar la ronda, el "
            , ref Czar
            , Text " roba varias "
            , ref (nounUnknownQuantity Call)
            , Text " y elige una de ellas, y/o puede escribir una propia."
            ]

        HouseRuleCzarChoicesNumber ->
            [ Text "Número" ]

        HouseRuleCzarChoicesNumberDescription ->
            [ Text "El número de opciones que tiene el ", ref Czar, Text " para elegir." ]

        HouseRuleCzarChoicesCustom ->
            [ Text "Personalizado" ]

        HouseRuleCzarChoicesCustomDescription ->
            [ Text "Si se activa, el ", ref Czar, Text " podrá escribir cartas personalizadas. Esto eliminará una de las otras opciones." ]

        HouseRuleWinnersPick ->
            [ Text "Decisión del ganador" ]

        HouseRuleWinnersPickDescription ->
            [ Text "El ganador de cada ronda será el ", ref Czar, Text " durante la próxima ronda." ]

        SeeAlso { rule } ->
            [ Text "Véase también: ", ref rule ]

        MustBeMoreThanOrEqualValidationError { min } ->
            [ Text "El valor tiene que ser al menos ", Text (String.fromInt min), Text "." ]

        MustBeLessThanOrEqualValidationError { max } ->
            [ Text "El valor tiene que ser como máximo ", Text (String.fromInt max), Text "." ]

        SetValue { value } ->
            [ Text "Establecer el valor a ", Text (String.fromInt value), Text "." ]

        CantBeEmpty ->
            [ Text "No puedes dejarlo en blanco." ]

        SettingsTitle ->
            [ Text "Configuración" ]

        LanguageSetting ->
            [ Text "Idioma" ]

        MissingLanguage ->
            [ Text "¿No ves tu idioma? ", ref TranslationBeg ]

        AutonymFormat { autonym } ->
            [ Text "(", Text autonym, Text ")" ]

        TranslationBeg ->
            [ Text "¡Ayuda a traducir "
            , ref MassiveDecks
            , Text "!"
            ]

        CardSizeSetting ->
            [ Text "Cartas compactas" ]

        CardSizeExplanation ->
            [ Text "Cambia el tamaño de las cartas. Esto puede ayudar en pantallas más pequeñas." ]

        AutoAdvanceSetting ->
            [ Text "Avanzar automáticamente la ronda" ]

        AutoAdvanceExplanation ->
            [ Text "Cuando se acabe una ronda, avanzar automáticamente a la siguiente sin esperar." ]

        SpeechSetting ->
            [ Text "Texto a voz" ]

        SpeechExplanation ->
            [ Text "Leerá las cartas en voz alta usando texto a voz." ]

        SpeechNotSupportedExplanation ->
            [ Text "Tu navegador no soporta texto a voz o no tiene voces instaladas." ]

        VoiceSetting ->
            [ Text "Voz del narrador" ]

        NotificationsSetting ->
            [ Text "Notificaciones del navegador" ]

        NotificationsExplanation ->
            [ Text "Te avisará cuando tengas que hacer algo en el juego mediante las notificaciones del navegador."
            ]

        NotificationsUnsupportedExplanation ->
            [ Text "Tu navegador no soporta notificaciones." ]

        NotificationsBrowserPermissions ->
            [ Text "Tendrás que dar permiso a "
            , ref MassiveDecks
            , Text " para que te notifique. Solo se usarán mientras tengas el juego abierto y tengas este ajuste activado."
            ]

        NotificationOnlyWhenHiddenSetting ->
            [ Text "Solo en segundo plano" ]

        NotificationsOnlyWhenHiddenExplanation ->
            [ Text "Solo se enviarán notificaciones cuando el juego esté en segundo plano (p.ej: en otra pestaña o minimizado)." ]

        NotificationsOnlyWhenHiddenUnsupportedExplanation ->
            [ Text "Tu navegador no soporta comprobar la visibilidad de la página." ]

        -- Terms
        Czar ->
            [ Text "Zar" ]

        CzarDescription ->
            [ Text "El jugador que juzga la ronda." ]

        CallDescription ->
            [ Text "Una carta negra con una pregunta o una frase sin completar." ]

        ResponseDescription ->
            [ Text "Una carta blanca con una frase para responder en las rondas." ]

        PointDescription ->
            [ Text "Quien tenga el mayor numero de puntos ganará la partida." ]

        GameCodeTerm ->
            [ Text "Código de la partida" ]

        GameCodeDescription ->
            [ Text "Un código que permite a otros jugadores encontrar y unirse a la partida." ]

        GameCode { code } ->
            [ Text code ]

        GameCodeSpecificDescription ->
            [ Text "Comparte este código para que la gente pueda unirse a la partida." ]

        GameCodeHowToAcquire ->
            [ Text "Pide el ", ref GameCodeTerm, Text " a la persona que te ha invitado." ]

        Deck ->
            [ Text "Baraja" ]

        DeckSource ->
            [ Text "Origen de la ", ref Deck ]

        DeckLanguage { language } ->
            [ Text "en ", Text language ]

        DeckAuthor { author } ->
            [ Text "hecha por ", Text author ]

        DeckTranslator { translator } ->
            [ Text "traducción hecha por ", Text translator ]

        StillPlaying ->
            [ Text "Jugando" ]

        PlayingDescription ->
            [ Text "El jugador está en la ronda pero aún no ha acabado su turno." ]

        Played ->
            [ Text "Jugado" ]

        PlayedDescription ->
            [ Text "Este jugador ha acabado su turno." ]

        -- Lobby Browser
        LobbyBrowserTitle ->
            [ Text "Partidas públicas" ]

        NoPublicGames ->
            [ Text "No hay partidas públicas disponibles." ]

        PlayingGame ->
            [ Text "Partidas en progreso." ]

        SettingUpGame ->
            [ Text "Partidas sin empezar." ]

        StartYourOwn ->
            [ Text "¿Crear una nueva partida?" ]

        -- Spectation
        JoinTheGame ->
            [ Text "¡Unirse a la partida!" ]

        ToggleAdvertDescription ->
            [ Text "Cambia mostrar la información al entrar a la sala." ]

        -- Cards
        Pick numberOfCards ->
            [ Text "Eliges", ref (NumberOfCards numberOfCards) ]

        Draw numberOfCards ->
            [ Text "Robas", ref (NumberOfCards numberOfCards) ]

        PickDescription { numberOfCards } ->
            [ Text "Tienes que jugar "
            , Text (asWord numberOfCards)
            , Text " "
            , ref (noun Response numberOfCards)
            , Text "."
            ]

        DrawDescription { numberOfCards } ->
            [ Text "Obtienes "
            , Text (asWord numberOfCards)
            , Text " extra "
            , ref (noun Response numberOfCards)
            , Text " antes de jugar."
            ]

        NumberOfCards { numberOfCards } ->
            [ Text (String.fromInt numberOfCards) ]

        -- Lobby
        LobbyNameLabel ->
            [ Text "Nombre de la partida" ]

        DefaultLobbyName { owner } ->
            [ Text "Partida de ", Text owner ]

        Invite ->
            [ Text "Invita jugadores a la partida." ]

        InviteLinkHelp ->
            [ Text "Envía este link a los jugadores para invitarlos a la partida, o haz que escaneen el código QR de abajo." ]

        InviteExplanation { gameCode, password } ->
            let
                extra =
                    password
                        |> Maybe.map
                            (\p ->
                                [ Text " y la contraseña de la partida “"
                                , Text p
                                , Text "”"
                                ]
                            )
                        |> Maybe.withDefault []
            in
            List.concat
                [ [ Text "El código de tu partida es "
                  , ref (GameCode { code = gameCode })
                  , Text ". Los jugadores pueden acceder a la partida abriendo "
                  , ref MassiveDecks
                  , Text " e introduciendo el código"
                  ]
                , extra
                , [ Text "."
                  ]
                ]

        Cast ->
            [ Text "Transmitir a la TV." ]

        CastConnecting ->
            [ Text "Conectando…" ]

        CastConnected { deviceName } ->
            [ Text "Transmitiendo a ", Text deviceName, Text "." ]

        Players ->
            [ ref (nounUnknownQuantity Player) ]

        PlayersDescription ->
            [ Text "Jugadores en la partida." ]

        Spectators ->
            [ ref (nounUnknownQuantity Spectator) ]

        SpectatorsDescription ->
            [ Text "Jugadores espectando la partida." ]

        Left ->
            [ Text "Se fueron" ]

        LeftDescription ->
            [ Text "Jugadores que se han ido de la partida." ]

        Away ->
            [ Text "Ausente" ]

        AwayDescription ->
            [ Text "Este jugador está temporalmente ausente de la partida." ]

        Disconnected ->
            [ Text "Desconectado" ]

        DisconnectedDescription ->
            [ Text "El jugador no está conectado a la partida." ]

        Privileged ->
            [ Text "Propietario" ]

        PrivilegedDescription ->
            [ Text "Este jugador puede cambiar las normas de la partida." ]

        Ai ->
            [ Text "Bot" ]

        AiDescription ->
            [ Text "El jugador está controlado por el ordenador." ]

        Score { total } ->
            [ Text (String.fromInt total) ]

        ScoreDescription ->
            [ Text "El número de "
            , ref (nounUnknownQuantity Point)
            , Text " que tiene el jugador."
            ]

        Likes { total } ->
            [ Text (String.fromInt total) ]

        LikesDescription ->
            [ Text "Numero de likes recibidos."
            ]

        ToggleUserList ->
            [ Text "Mostrar o esconder el marcador." ]

        GameMenu ->
            [ Text "Menú de la partida." ]

        UnknownUser ->
            [ Text "Jugador desconocido" ]

        InvitePlayers ->
            [ Text "Invitar jugadores" ]

        InvitePlayersDescription ->
            [ Text "Consigue el código/link/código QR para que otros se unan a la partida." ]

        SetAway ->
            [ Text "Marcar como ausente" ]

        SetBack ->
            [ Text "Marcar como de vuelta" ]

        LeaveGame ->
            [ Text "Abandonar la partida" ]

        LeaveGameDescription ->
            [ Text "Abandona la partida permanentemente." ]

        Spectate ->
            [ Text "Vista de espectador" ]

        SpectateDescription ->
            [ Text "Abre una vista de espectador en otra pestaña/ventana." ]

        BecomeSpectator ->
            [ Text "Espectar" ]

        BecomeSpectatorDescription ->
            [ Text "Mirar la partida sin jugar." ]

        BecomePlayer ->
            [ Text "Jugar" ]

        BecomePlayerDescription ->
            [ Text "Jugar la partida." ]

        EndGame ->
            [ Text "Acabar la partida" ]

        EndGameDescription ->
            [ Text "Acaba la partida instantáneamente." ]

        ReturnViewToGame ->
            [ Text "Volver al juego" ]

        ReturnViewToGameDescription ->
            [ Text "Vuelve a la vista original." ]

        ViewConfiguration ->
            [ Text "Configurar" ]

        ViewConfigurationDescription ->
            [ Text "Ver la configuración de la partida." ]

        KickUser ->
            [ Text "Expulsar" ]

        Promote ->
            [ Text "Ascender" ]

        Demote ->
            [ Text "Degradar" ]

        -- Notifications
        UserConnected { username } ->
            [ Text username, Text " se ha reconectado a la partida." ]

        UserDisconnected { username } ->
            [ Text username, Text " se ha desconectado de la partida." ]

        UserJoined { username } ->
            [ Text username, Text " ha entrado en la partida." ]

        UserLeft { username } ->
            [ Text username, Text " ha abandonado la partida." ]

        UserKicked { username } ->
            [ Text username, Text " ha sido expulsado de la partida." ]

        Dismiss ->
            [ Text "Descartar" ]

        -- Configuration
        ConfigureTitle ->
            [ Text "Configuración de la partida" ]

        NoDecks ->
            [ Segment [ Text "Sin barajas. " ]
            , Text " "
            , Segment [ Text "Tendrás que añadir al menos una a la partida." ]
            ]

        NoDecksHint ->
            [ Text "¿No estás seguro? Añade la baraja original de ", raw CardsAgainstHumanity ]

        WaitForDecks ->
            [ Text "Las barajas deben cargarse antes de empezar la partida." ]

        MissingCardType { cardType } ->
            [ Text "Ninguna de tus barajas contiene "
            , ref (nounUnknownQuantity cardType)
            , Text ". Necesitas una baraja que sí las tenga para empezar la partida."
            ]

        NotEnoughCardsOfType { cardType, needed, have } ->
            [ Text "Para el número de jugadores en la partida, se necesitan al menos "
            , Text (needed |> String.fromInt)
            , Text " "
            , ref (noun cardType needed)
            , Text " pero solo tienes "
            , Text (have |> String.fromInt)
            , Text "."
            ]

        AddBlankCards { amount } ->
            [ Text "Añadir "
            , amount |> String.fromInt |> Text
            , ref (noun Response amount)
            , Text " vacías "
            ]

        AddDeck ->
            [ Text "Añadir baraja." ]

        RemoveDeck ->
            [ Text "Eliminar baraja." ]

        SourceNotFound { source } ->
            [ ref source, Text " no reconoce la baraja elegida. Revisa que los datos introducidos sean correctos." ]

        SourceServiceFailure { source } ->
            [ ref source, Text " falló al cargar la baraja. Por favor, inténtalo más tarde o cambia de proveedor." ]

        ManyDecks ->
            [ Text "Many Decks" ]

        ManyDecksDeckCodeTitle ->
            [ Text "Codigo de la baraja" ]

        ManyDecksDeckCodeShort ->
            [ Text "El código de una baraja debe tener al menos 5 caracteres." ]

        ManyDecksWhereToGet ->
            [ Text "Puedes crear y obtener barajas en ", ref ManyDecks, Text "." ]

        JsonAgainstHumanity ->
            [ Text "JSON Against Humanity" ]

        JsonAgainstHumanityAbout ->
            [ Text "Barajas proporcionadas por ", ref JsonAgainstHumanity ]

        BuiltIn ->
            [ Text "Integradas" ]

        APlayer ->
            [ Text "Un jugador" ]

        Generated { by } ->
            [ Text "Generado por ", ref by ]

        DeckAlreadyAdded ->
            [ Text "Esta baraja ya está en la partida." ]

        ConfigureDecks ->
            [ Text "Barajas" ]

        ConfigureRules ->
            [ Text "Normas" ]

        ConfigureTimeLimits ->
            [ Text "Limites de tiempo" ]

        ConfigurePrivacy ->
            [ Text "Privacidad" ]

        HandSize ->
            [ Text "Tamaño de la baraja" ]

        HandSizeDescription ->
            [ Text "El número inicial de cartas que tiene cada jugador durante la partida." ]

        ScoreLimit ->
            [ Text "Límite de ", ref (nounUnknownQuantity Point) ]

        ScoreLimitDescription ->
            [ Segment
                [ Text "El numero de "
                , ref (nounUnknownQuantity Point)
                , Text " que necesita un jugador para ganar la partida."
                ]
            , Text " "
            , Segment [ Text "Si se desactiva, el juego continúa indefinidamente." ]
            ]

        UnsavedChangesWarning ->
            [ Text "Tienes cambios sin guardar en la configuración, deben ser guardados primero si quieres que se apliquen "
            , Text "a la partida."
            ]

        SaveChanges ->
            [ Text "Guardar los cambios." ]

        RevertChanges ->
            [ Text "Descartar los cambios no guardados." ]

        NeedAtLeastOneDeck ->
            [ Text "Necesitas una baraja para empezar la partida." ]

        NeedAtLeastThreePlayers ->
            [ Text "Se necesitan al menos tres jugadores para empezar la partida." ]

        NeedAtLeastOneHuman ->
            [ Text "Desafortunadamente, los bots no pueden ser el "
            , ref Czar
            , Text ", por lo que se necesita al menos un jugador humano para empezar la partida."
            , Text " (¡Aunque solo un humano puede ser un poco aburrido!)"
            ]

        RandoCantWrite ->
            [ Text "Los bots no pueden escribir sus propias cartas." ]

        DisableComedyWriter ->
            [ Text "Desactivar ", ref HouseRuleComedyWriter ]

        DisableRando ->
            [ Text "Desactivar ", ref HouseRuleRandoCardrissian ]

        AddAnAiPlayer ->
            [ Text "Añadir un bot a la partida." ]

        PasswordShared ->
            [ Text "¡Cualquier jugador en la partida puede ver la contraseña! "
            , Text "Esconderla solo te afectará a ti (útil para streamear, etc...)."
            ]

        PasswordNotSecured ->
            [ Text "Las contraseñas de las partidas "
            , Em [ Text "no" ]
            , Text " se guardan de forma segura, por ello, por favor, ¡"
            , Em [ Text "no" ]
            , Text " uses contraseñas serias que uses ya en otros sitios!"
            ]

        LobbyPassword ->
            [ Text "Contraseña de la partida" ]

        LobbyPasswordDescription ->
            [ Text "Una contraseña que deberán usar todos los jugadores para entrar a la partida." ]

        AudienceMode ->
            [ Text "Modo audiencia" ]

        AudienceModeDescription ->
            [ Text "Si se activa, todos los jugadores entrarán como espectadores, y tú eligirás si cambiarlos a jugadores."
            ]

        StartGame ->
            [ Text "Empezar la partida" ]

        Public ->
            [ Text "Partida pública" ]

        PublicDescription ->
            [ Text "Si se activa, el juego aparecerá en el listado de salas públicas en el menú." ]

        ApplyConfiguration ->
            [ Text "Guardar cambios." ]

        AppliedConfiguration ->
            [ Text "Guardado." ]

        InvalidConfiguration ->
            [ Text "El valor de la configuración no es válido." ]

        Automatic ->
            [ Text "Marcar automáticamente a los jugadores como ausentes" ]

        AutomaticDescription ->
            [ Text "Si se activa, los jugadores que excedan el tiempo límite serán marcados como ausentes. "
            , Text "Si no, alguien tendrá que marcarlos manualmente."
            ]

        TimeLimit { stage } ->
            [ Text "Tiempo límite ", ref stage ]

        StartingTimeLimitDescription ->
            [ Text "Cuánto tiempo (en segundos) tiene el "
            , ref Czar
            , Text " para escoger/escribir una "
            , ref (noun Call 1)
            , Text ", cuando "
            , raw HouseRuleCzarChoices
            , Text " esté activado."
            ]

        PlayingTimeLimitDescription ->
            [ Text "Cuánto tiempo (en segundos) tienen los ", ref Players, Text " en sus turnos." ]

        PlayingAfterDescription ->
            [ Text "Cuánto tiempo (en segundos) tienen los jugadores para cambiar su elección antes de que comience la siguiente fase." ]

        RevealingTimeLimitDescription ->
            [ Text "Cuánto tiempo (en segundos) tiene el ", ref Czar, Text " para revelar las respuestas." ]

        RevealingAfterDescription ->
            [ Text "Cuánto tiempo (en segundos) hay que esperar después de que se revele la última carta antes de que comience la siguiente fase." ]

        JudgingTimeLimitDescription ->
            [ Text "Cuánto tiempo (en segundos) tiene el ", ref Czar, Text " para elegir la mejor respuesta." ]

        CompleteTimeLimitDescription ->
            [ Text "Cuánto tiempo (en segundos) hay que esperar después de una ronda para que comience la siguiente." ]

        RevealingEnabledTitle ->
            [ Text "El Zar revela las respuestas" ]

        RevealingEnabled ->
            [ Text "Si se activa, el "
            , ref Czar
            , Text " revelará cada respuesta antes de escoger la ganadora."
            ]

        DuringTitle ->
            [ Text "Límite de tiempo" ]

        AfterTitle ->
            [ Text "Después" ]

        Conflict ->
            [ Text "Conflicto" ]

        ConflictDescription ->
            [ Text "Alguien más ha cambiado la configuración mientras tú lo hacías. "
            , Text "Decide si quieres mantener tus cambios o los suyos."
            ]

        YourChanges ->
            [ Text "Tus cambios" ]

        TheirChanges ->
            [ Text "Sus cambios" ]

        ConfigurationDisabledWhileInGame ->
            [ Text "No puedes cambiar la configuración mientras la partida está en progreso." ]

        ConfigurationDisabledIfNotPrivileged ->
            [ Text "No puedes cambiar la configuración de esta partida." ]

        ConfigureNextGame ->
            [ Text "Configurar la siguiente partida" ]

        -- Game
        PickCall ->
            [ Text "Elegir esta ", ref (noun Call 1), Text " para que los demás jueguen con ella esta ronda." ]

        WriteCall ->
            [ Text "Escribir una ", ref (noun Call 1), Text " personalizada para que los demás jueguen con ella esta ronda." ]

        SubmitPlay ->
            [ Text "Entregar estas cartas al ", ref Czar, Text " como tu respuesta para la ronda." ]

        TakeBackPlay ->
            [ Text "Cambiar las cartas para modificar tu respuesta de la ronda." ]

        JudgePlay ->
            [ Text "Escoger esta respuesta como ganadora para la ronda." ]

        LikePlay ->
            [ Text "Dar un like a esta respuesta." ]

        AdvanceRound ->
            [ Text "Siguiente ronda." ]

        Starting ->
            [ raw HouseRuleCzarChoices ]

        Playing ->
            [ Text "Jugando" ]

        Revealing ->
            [ Text "Revelando" ]

        Judging ->
            [ Text "Juzgando" ]

        Complete ->
            [ Text "Acabado" ]

        ViewGameHistoryAction ->
            [ Text "Ver rondas previas de esta partida." ]

        ViewHelpAction ->
            [ Text "Ayuda" ]

        EnforceTimeLimitAction ->
            [ Text "Poner a todos los jugadores pendientes de turno como ausentes y saltar su turno hasta que vuelvan." ]

        Blank ->
            [ Text "Espacio en blanco" ]

        RoundStarted ->
            [ Text "Ronda iniciada" ]

        JudgingStarted ->
            [ Text "Juicio iniciado" ]

        Paused ->
            [ Text "La partida se ha detenido porque no hay suficientes jugadores para continuar."
            , Text "Cuando alguien se una o vuelva, el juego se reanudará automáticamente."
            ]

        ClientAway ->
            [ Text "Estás marcado como ausente de la partida actualmente, y no estás jugando." ]

        Discard ->
            [ Text "Descartar la carta seleccionada, revelándola a todos los demás jugadores de la partida." ]

        Discarded { player } ->
            [ Text player
            , Text " ha descartado la siguiente carta:"
            ]

        -- Instructions
        PickCallInstruction ->
            [ Text "Elige una ", ref (noun Call 1), Text " para que los demás jueguen con ella esta ronda." ]

        WaitForCallInstruction ->
            [ Text "Estás esperando a que el "
            , ref Czar
            , Text " elija una "
            , ref (noun Call 1)
            , Text " para jugarla esta ronda."
            ]

        PlayInstruction { numberOfCards } ->
            [ Text "Tienes que elegir "
            , Text (asWord numberOfCards)
            , Text " "
            , ref (noun Response numberOfCards)
            , Text " más de tu baraja antes de entregar tu respuesta."
            ]

        SubmitInstruction ->
            [ Text "Tienes que entregar tu respuesta para la ronda." ]

        WaitingForPlaysInstruction ->
            [ Text "Estás esperando a que los demás jugadores acaben su turno." ]

        CzarsDontPlayInstruction ->
            [ Text "Eres el "
            , ref Czar
            , Text " de esta ronda - no entregarás ninguna "
            , ref (noun Response 1)
            , Text ". En su lugar, escogerás al ganador de la ronda cuando todo el mundo acabe su turno."
            ]

        NotInRoundInstruction ->
            [ Text "No estás jugando esta ronda. Jugarás en la siguiente." ]

        RevealPlaysInstruction ->
            [ Text "Pulsa las respuestas para darles la vuelta, y elige la que consideres la mejor." ]

        WaitingForCzarInstruction ->
            [ Text "Puedes darle like a las respuestas mientras esperas que el ", ref Czar, Text " revele las respuestas y elija el ganador de la ronda." ]

        AdvanceRoundInstruction ->
            [ Text "La siguiente ronda ha empezado, puedes avanzar." ]

        -- 404 Unknown
        UnknownPageTitle ->
            [ Text "Error 404: Página desconocida." ]

        GoBackHome ->
            [ Text "Ir a la página principal." ]

        -- Actions
        Refresh ->
            [ Text "Actualizar" ]

        Accept ->
            [ Text "Ok" ]

        -- Editor
        AddSlot ->
            [ Text "Añadir ", ref Blank ]

        AddText ->
            [ Text "Añadir texto" ]

        EditText ->
            [ Text "Editar" ]

        EditSlotIndex ->
            [ Text "Editar" ]

        MoveLeft ->
            [ Text "Mover antes" ]

        Remove ->
            [ Text "Eliminar" ]

        MoveRight ->
            [ Text "Mover después" ]

        Normal ->
            [ Text "Normal" ]

        Capitalise ->
            [ Text "Primera letra en mayúsculas" ]

        UpperCase ->
            [ Text "Todo en mayúsculas" ]

        Emphasise ->
            [ Text "Destacar" ]

        MustContainAtLeastOneSlot ->
            [ Text "Necesitas al menos un ", ref Blank, Text " para que la gente juegue." ]

        SlotIndexExplanation ->
            [ Text "Qué "
            , ref (noun Response 1)
            , Text " será utilizada para este "
            , ref Blank
            , Text ". También puedes repetir una misma "
            , ref (noun Response 1)
            , Text "."
            ]

        -- Errors
        Error ->
            [ Text "Error" ]

        ErrorHelp ->
            [ Text "Es posible que el servidor del juego no funcione o que se trate de un bug. Recarga la página "
            , Text "para intentarlo de nuevo. Más detalles abajo."
            ]

        ErrorHelpTitle ->
            [ Text "Perdón, algo ha ido mal." ]

        ErrorCheckOutOfBand ->
            [ Text "Por favor, echa un vistazo a ", ref TwitterHandle, Text " para actualizaciones y el estado del servicio. El servidor del juego se caerá por un corto tiempo cuando una nueva versión sea lanzada, por lo que si ves una actualización reciente vuelve a intentarlo en unos minutos." ]

        TwitterHandle ->
            [ Text "@Massive_Decks" ]

        ReportError ->
            [ Text "Reportar bug" ]

        ReportErrorDescription ->
            [ Text "Deja saber a los desarrolladores el bug que has encontrado para que puedan arreglarlo." ]

        ReportErrorBody ->
            [ Text "Estaba [reemplaza esto con una corta explicación de lo que estabas haciendo] cuando me encontré con el siguiente error:" ]

        BadUrlError ->
            [ Text "Intentamos hacer una solicitud a una página inválida." ]

        TimeoutError ->
            [ Text "El servidor no ha respondido durante mucho tiempo. Puede que esté caído, inténtalo de nuevo en un rato." ]

        NetworkError ->
            [ Text "Se te ha caído la conexión a internet." ]

        ServerDownError ->
            [ Text "El servidor está offline, por favor, inténtalo de nuevo más tarde." ]

        BadStatusError ->
            [ Text "El servidor dio una respuesta que no esperábamos." ]

        BadPayloadError ->
            [ Text "El servidor dio una respuesta que no entendimos." ]

        PatchError ->
            [ Text "El servidor lanzó una actualización que no pudimos aplicar." ]

        VersionMismatch ->
            [ Text "El servidor lanzó un cambio de configuración para una versión diferente de la que esperábamos." ]

        CastError ->
            [ Text "Algo salió mal al intentar conectarse a la partida." ]

        ActionExecutionError ->
            [ Text "No puedes realizar esa acción." ]

        IncorrectPlayerRoleError { role, expected } ->
            [ Text "Tienes que ser ", ref expected, Text " para hacer eso, pero eres un ", ref role, Text "." ]

        IncorrectUserRoleError { role, expected } ->
            [ Text "Tienes que ser ", ref expected, Text " para hacer eso, pero eres un ", ref role, Text "." ]

        IncorrectRoundStageError { stage, expected } ->
            [ Text "La ronda debe estar en la fase ", ref expected, Text " para hacer eso, pero está en la fase ", ref stage, Text "." ]

        ConfigEditConflictError ->
            [ Text "Alguien cambió la configuración antes que tú, por lo que tus cambios no se guardaron." ]

        UnprivilegedError ->
            [ Text "No tienes permisos para hacer eso." ]

        GameNotStartedError ->
            [ Text "El juego tiene que haber comenzado para hacer eso." ]

        InvalidActionError { reason } ->
            [ Text "El servidor no entendió una petición del cliente. Detalles: ", Text reason ]

        AuthenticationError ->
            [ Text "No puedes unirte a esta partida." ]

        IncorrectIssuerError ->
            [ Text "Tus credenciales para entrar a la partida están caducadas o el juego ya no existe." ]

        InvalidAuthenticationError ->
            [ Text "Tus credenciales para entrar a la partida están corruptas." ]

        InvalidLobbyPasswordError ->
            [ Text "La contraseña que has proporcionado es incorrecta. Revísala." ]

        AlreadyLeftError ->
            [ Text "Ya te has ido de esta partida." ]

        LobbyNotFoundError ->
            [ Text "Esa partida no existe." ]

        LobbyClosedError { gameCode } ->
            [ Text "La partida a la que deseas acceder (", ref (GameCode { code = gameCode }), Text ") ha terminado." ]

        LobbyDoesNotExistError { gameCode } ->
            [ Text "El código que has introducido ("
            , ref (GameCode { code = gameCode })
            , Text ") no existe. "
            , Text "Revísalo."
            ]

        RegistrationError ->
            [ Text "Problema al entrar en la partida." ]

        UsernameAlreadyInUseError { username } ->
            [ Text "Alguien ya está usando el nombre de usuario “"
            , Text username
            , Text "”. Prueba otro diferente."
            ]

        GameError ->
            [ Text "Algo ha salido mal en la partida." ]

        OutOfCardsError ->
            [ Text "No habían suficientes cartas en la baraja para todos los jugadores. Prueba a añadir más barajas en la configuración de la partida." ]

        -- Language Names
        English ->
            [ Text "Inglés" ]

        BritishEnglish ->
            [ Text "Inglés (británico)" ]

        Italian ->
            [ Text "Italiano" ]

        BrazilianPortuguese ->
            [ Text "Portugués (brasileño)" ]

        German ->
            [ Text "Alemán (formal)" ]

        GermanInformal ->
            [ Text "Alemán (informal)" ]

        Polish ->
            [ Text "Polaco" ]

        Indonesian ->
            [ Text "Indonesio" ]

        Spanish ->
            [ Text "Español" ]

        Korean ->
            [ Text "Coreano" ]

        French ->
            [ Text "Francés" ]

raw : MdString -> Translation.Result never
raw =
    Raw Nothing


ref : MdString -> Translation.Result never
ref =
    Ref Nothing


an : Maybe Int -> String
an amount =
    case amount of
        Just 1 ->
            "an "

        _ ->
            ""


{-| Take a number and give back the name of that number. Falls back to the number when it gets too big.
-}
asWord : Int -> String
asWord number =
    case number of
        0 ->
            "cero"

        1 ->
            "uno"

        2 ->
            "dos"

        3 ->
            "tres"

        4 ->
            "cuatro"

        5 ->
            "cinco"

        6 ->
            "seis"

        7 ->
            "siete"

        8 ->
            "ocho"

        9 ->
            "nueve"

        10 ->
            "diez"

        11 ->
            "once"

        12 ->
            "doce"

        other ->
            String.fromInt other
