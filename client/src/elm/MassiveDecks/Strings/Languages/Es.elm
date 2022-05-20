module MassiveDecks.Strings.Languages.Es exposing (pack)

{-| Spanish localization.
Contributors:
a humble man :o
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
            let
                singular =
                    case noun of
                        Call ->
                            [ Text "Carta Negra" ]

                        Response ->
                            [ Text "Carta Blanca" ]

                        Point ->
                            [ Text "Punto Especial" ]

                        Player ->
                            [ Text "Jugador" ]

                        Spectator ->
                            [ Text "Espectador" ]

                plural =
                    case quantity of
                        Quantity 1 ->
                            []

                        _ ->
                            [ Text "s" ]
            in
            List.concat [ singular, plural ]

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
            [ Text "Un juego para fiestas de comedia." ]

        WhatIsThis ->
            [ Text "¿Qué es ", ref MassiveDecks, Text "?" ]

        GameDescription ->
            [ ref MassiveDecks
            , Text " es un juego de comedia basado en "
            , ref CardsAgainstHumanity
            , Text ", desarrolado por "
            , ref RereadGames
            , Text " y otros contribuidores—el juego es open—source debajo de "
            , ref License
            , Text ", así que puedes ayudar a mejorar el juego, acceder al codigo fuente o solo ver más en "
            , ref MDProject
            , Text "."
            ]

        NewGame ->
            [ Text "Nuevo" ]

        NewGameDescription ->
            [ Text "Empezar un juego nuevo de ", ref MassiveDecks, Text "." ]

        FindPublicGame ->
            [ Text "Buscar" ]

        JoinPrivateGame ->
            [ Text "Unirse" ]

        JoinPrivateGameDescription ->
            [ Text "Unirse a una partida a la que le han invitado." ]

        PlayGame ->
            [ Text "Jugar" ]

        AboutTheGame ->
            [ Text "Saber más" ]

        AboutTheGameDescription ->
            [ Text "Saber más sobre ", ref MassiveDecks, Text " ." ]

        MDLogoDescription ->
            [ Text "Una ", ref (noun Call 1), Text " y una ", ref (noun Response 1), Text " marcadas con una “M” y con una “D”." ]

        RereadLogoDescription ->
            [ Text "Un libro enecerrado en un circulo por una flecha de reciclaje." ]

        MDProject ->
            [ Text "El proyecto de github" ]

        License ->
            [ Text "La licencia AGPLv3" ]

        DevelopedByReread ->
            [ Text "Desarrollado por ", ref RereadGames, Text "." ]

        RereadGames ->
            [ Text "Reread Games" ]

        NameLabel ->
            [ Text "Tu Nombre" ]

        NameInUse ->
            [ Text "Otra persona esta usando este nombre en la partida—porfavor elija otro diferente." ]

        RejoinTitle ->
            [ Text "Volver a unirse a una partida" ]

        RejoinGame { code } ->
            [ Text "Volver a unirse a “", GameCode { code = code } |> ref, Text "”." ]

        LobbyRequiresPassword ->
            [ Text "Necesitas una contraseña para entrar a la partida. Preguntasela a la persona que te ha invitado." ]

        YouWereKicked ->
            [ Text "Has sido expulsado de la partida." ]

        ScrollToTop ->
            [ Text "Desliza hasta arriba." ]

        Copy ->
            [ Text "Copiar" ]

        -- Rules
        CardsAgainstHumanity ->
            [ Text "Cartas Contra La Humanidad" ]

        Rules ->
            [ Text "Como jugar." ]

        RulesHand ->
            [ Text "Cada jugador tiene una baraja de  ", ref (nounUnknownQuantity Response), Text "." ]

        RulesCzar ->
            [ Text "El primer jugador empieza como el "
            , ref Czar
            , Text ". El "
            , ref Czar
            , Text " leerá la pregunta o la frase sin completar en la "
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
            , Text " las leerá en voz alta—para un efecto completo, el "
            , ref Czar
            , Text " tendrá que re-leer la "
            , ref (noun Call 1)
            , Text " antes de presentar cada respuesta. El "
            , ref Czar
            , Text " entonces escogerá la mejor respuesta y el jugador que la ha escogido se llevará un "
            , ref (noun Point 1)
            , Text "."
            ]

        RulesPickTitle ->
            [ ref (Pick { numberOfCards = 2 }) ]

        RulesPick ->
            [ Text "Algunas cartas necesitaran más de una "
            , ref (noun Response 1)
            , Text " como respuesta. Juega las cartas en el orden que el "
            , ref Czar
            , Text " las deberia leer en voz alta."
            ]

        ExamplePickDescription ->
            [ ref (nounUnknownQuantity Call)
            , Text " como esta requerirán escoger más "
            , ref (nounUnknownQuantity Response)
            , Text ", pero te darán más para escoger."
            ]

        RulesDraw ->
            [ Text "Algunas "
            , ref (nounUnknownQuantity Call)
            , Text " necesitarán aún más "
            , ref (nounUnknownQuantity Response)
            , Text "—estas dirán "
            , ref (Draw { numberOfCards = 2 })
            , Text " o más, y obtendrás ese mismo numero más de cartas antes de jugar."
            ]

        GameRulesTitle ->
            [ Text "Normas del juego" ]

        HouseRulesTitle ->
            [ Text "Normas de la casa" ]

        HouseRules ->
            [ Text "Puedes cambiar la manera en la que se juega el juego en una gran variedad de formas. Cuando vayas a preparar el juego, escoge "
            , Text "tantas normas de la casa como quieras usar."
            ]

        HouseRuleReboot ->
            [ Text "Reiniciando el Universo" ]

        HouseRuleRebootDescription { cost } ->
            [ Text "En qualquier momento, los jugadores podrán intercambiar "
            , Text (an cost)
            , ref (nounMaybe Point cost)
            , Text " para descartar toda su baraja y obtener otra nueva."
            ]

        HouseRuleRebootAction { cost } ->
            [ Text "Gastar "
            , Text (asWord cost)
            , Text " "
            , ref (noun Point cost)
            , Text " para descartar tu baraja y obtener una nueva."
            ]

        HouseRuleRebootCost ->
            [ ref (noun Point 1), Text " Coste" ]

        HouseRuleRebootCostDescription ->
            [ Text "Cuantas ", ref (nounUnknownQuantity Point), Text " cuesta reiniciar la baraja." ]

        HouseRulePackingHeat ->
            [ Text "Con plomo en los bolsillos" ]

        HouseRulePackingHeatDescription ->
            [ Text "Qualquier "
            , ref (nounUnknownQuantity Call)
            , Text " con "
            , ref (Pick { numberOfCards = 2 })
            , Text " también obtendrá "
            , ref (Draw { numberOfCards = 1 })
            , Text ", para que todos tengan más opciones."
            ]

        HouseRuleComedyWriter ->
            [ Text "Escritor de cartas" ]

        HouseRuleComedyWriterDescription ->
            [ Text "Añade "
            , ref (nounUnknownQuantity Response)
            , Text " en blanco, donde los jugadores podran diseñar cartas blancas nuevas."
            ]

        HouseRuleComedyWriterNumber ->
            [ Text "Blank ", ref (nounUnknownQuantity Response) ]

        HouseRuleComedyWriterNumberDescription ->
            [ Text "El numero de "
            , ref (nounUnknownQuantity Response)
            , Text " que habrá en el juego."
            ]

        HouseRuleComedyWriterExclusive ->
            [ Text "Solo en blanco ", ref (nounUnknownQuantity Response) ]

        HouseRuleComedyWriterExclusiveDescription ->
            [ Text "Si se activa, todas las otras  "
            , ref (nounUnknownQuantity Response)
            , Text " serán ignoradas, solo las que esten en blanco serán usadas."
            ]

        HouseRuleRandoCardrissian ->
            [ Text "Rando Cardrissian" ]

        HouseRuleRandoCardrissianDescription ->
            [ Text "Cada ronda, el primer "
            , ref (noun Response 1)
            , Text " en la baraja será usado como respuesta. Esta jugada pertenecerá a un bot llamado "
            , Text "Rando Cardrissian, y si gana la partida, todos los jugadores deberán irse a casa en un estado de depressión severa."
            ]

        HouseRuleRandoCardrissianNumber ->
            [ Text "Jugadores IA" ]

        HouseRuleRandoCardrissianNumberDescription ->
            [ Text "Numero de Bots en la partida." ]

        HouseRuleNeverHaveIEver ->
            [ Text "Yo Nunca" ]

        HouseRuleNeverHaveIEverDescription ->
            [ Text "En qualquier momento, un jugador podrá descartar las cartas que no entienda, sin embargo, tendrá que confesar su "
            , Text "ignorancia: la carta será compartida con todos."
            ]

        HouseRuleHappyEnding ->
            [ Text "Final Feliz" ]

        HouseRuleHappyEndingDescription ->
            [ Text "Cuando el juego acaba, la ultima ronda es 'Hacer un Haiku' ", ref (noun Call 1), Text "." ]

        HouseRuleCzarChoices ->
            [ ref Czar, Text " Elecciones" ]

        HouseRuleCzarChoicesDescription ->
            [ Text "Al empezar la ronda, el "
            , ref Czar
            , Text " roba multiples "
            , ref (nounUnknownQuantity Call)
            , Text " y escoje una de ellas o puede escribir una propia."
            ]

        HouseRuleCzarChoicesNumber ->
            [ Text "Número" ]

        HouseRuleCzarChoicesNumberDescription ->
            [ Text "El número de elecciones que tiene el ", ref Czar, Text " para escojer." ]

        HouseRuleCzarChoicesCustom ->
            [ Text "Personalizado" ]

        HouseRuleCzarChoicesCustomDescription ->
            [ Text "Si el ", ref Czar, Text " puede escribir cartas personalizadas. Esto eliminará una de las elecciones." ]

        -- TODO: Translate
        HouseRuleWinnersPick ->
            [ Missing ]

        -- TODO: Translate
        HouseRuleWinnersPickDescription ->
            [ Missing ]

        SeeAlso { rule } ->
            [ Text "Ver también: ", ref rule ]

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
            [ Text "Ayuda a traducir "
            , ref MassiveDecks
            , Text "!"
            ]

        CardSizeSetting ->
            [ Text "Cartas Compactas" ]

        CardSizeExplanation ->
            [ Text "Cambia el tamaño de las cartas-esto puede ayudar en pantallas más pequeñas." ]

        AutoAdvanceSetting ->
            [ Text "Avanzar la Ronda Automáticamente" ]

        AutoAdvanceExplanation ->
            [ Text "Cuando una ronda se acabe, automáticamente avanzar a la siguiente sin esperar." ]

        SpeechSetting ->
            [ Text "Texto A Voz" ]

        SpeechExplanation ->
            [ Text "Leerá las cartas en voz alta usando texto a voz." ]

        SpeechNotSupportedExplanation ->
            [ Text "Tu navegador no soporta texto a voz o no tiene voces instaladas." ]

        VoiceSetting ->
            [ Text "Voz del Narrador" ]

        NotificationsSetting ->
            [ Text "Notificaciones del Navegador" ]

        NotificationsExplanation ->
            [ Text "Te avisará cuando tengas que hacer algo en el juego usando las notificaciones del navegador."
            ]

        NotificationsUnsupportedExplanation ->
            [ Text "Tu navegador no soporta notificaciones." ]

        NotificationsBrowserPermissions ->
            [ Text "Tendrás que dar permiso a "
            , ref MassiveDecks
            , Text " para que te notifique. Esto solo se usará mientras tengas el juego abierto y esto este activado."
            ]

        NotificationOnlyWhenHiddenSetting ->
            [ Text "Solo en segundo plano" ]

        NotificationsOnlyWhenHiddenExplanation ->
            [ Text "Solo mandará notificaciones cuando el juego esté en segundo plano(e.g: en otra página o minimizado)." ]

        NotificationsOnlyWhenHiddenUnsupportedExplanation ->
            [ Text "Tu navegador no puede comprobar la visivilidad de la página." ]

        -- Terms
        Czar ->
            [ Text "Zar" ]

        CzarDescription ->
            [ Text "El jugador a cargo de la ronda." ]

        CallDescription ->
            [ Text "Una carta negra con una pregunta o una frase sin completar." ]

        ResponseDescription ->
            [ Text "Una carta blanca con una frase que se juega en las rondas." ]

        PointDescription ->
            [ Text "Quien tenga el mayor numero de puntos ganará la partida." ]

        GameCodeTerm ->
            [ Text "Codigo de la partida" ]

        GameCodeDescription ->
            [ Text "Un codigo que permite a otros jugadores encontrar y unirse a la partida." ]

        GameCode { code } ->
            [ Text code ]

        GameCodeSpecificDescription ->
            [ Text "Dale este codigo a gente para que se pueda unir a la partida.." ]

        GameCodeHowToAcquire ->
            [ Text "Preguntale a la persona que te ha invitado por el ", ref GameCodeTerm, Text " de la partida." ]

        Deck ->
            [ Text "Baraja" ]

        DeckSource ->
            [ ref Deck, Text " Source" ]

        DeckLanguage { language } ->
            [ Text "en ", Text language ]

        DeckAuthor { author } ->
            [ Text "hecho por ", Text author ]

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
            [ Text "¡Unirse a la sala!" ]

        ToggleAdvertDescription ->
            [ Text "Cambia mostrar la información en entrar a la sala." ]

        -- Cards
        Pick numberOfCards ->
            [ Text "Escoger", ref (NumberOfCards numberOfCards) ]

        Draw numberOfCards ->
            [ Text "Robar", ref (NumberOfCards numberOfCards) ]

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
            , Text " extras "
            , ref (noun Response numberOfCards)
            , Text " antes de jugar."
            ]

        NumberOfCards { numberOfCards } ->
            [ Text (String.fromInt numberOfCards) ]

        -- Lobby
        LobbyNameLabel ->
            [ Text "Nombre de la partida" ]

        DefaultLobbyName { owner } ->
            [ Text "La partida de ", Text owner, Text "." ]

        Invite ->
            [ Text "Invita a jugadores a la sala." ]

        InviteLinkHelp ->
            [ Text "Envia este link a los jugadores para invitarlos a la sala, o haz que escaneen el codigo QR de debajo." ]

        InviteExplanation { gameCode, password } ->
            let
                extra =
                    password
                        |> Maybe.map
                            (\p ->
                                [ Text " y la contraseña de la sala “"
                                , Text p
                                , Text "”"
                                ]
                            )
                        |> Maybe.withDefault []
            in
            List.concat
                [ [ Text "El codigo de tu sala es "
                  , ref (GameCode { code = gameCode })
                  , Text ". Los jugadores pueden acceder a la sala inciando "
                  , ref MassiveDecks
                  , Text " y entrando el código"
                  ]
                , extra
                , [ Text "."
                  ]
                ]

        Cast ->
            [ Text "Enviar a la TV." ]

        CastConnecting ->
            [ Text "Conectando…" ]

        CastConnected { deviceName } ->
            [ Text "Enviando a ", Text deviceName, Text "." ]

        Players ->
            [ ref (nounUnknownQuantity Player) ]

        PlayersDescription ->
            [ Text "Jugadores en la partida." ]

        Spectators ->
            [ ref (nounUnknownQuantity Spectator) ]

        SpectatorsDescription ->
            [ Text "Jugadores en la partida espectando." ]

        Left ->
            [ Text "Se ha ido" ]

        LeftDescription ->
            [ Text "Jugadores que se han ido de la sala." ]

        Away ->
            [ Text "Fuera" ]

        AwayDescription ->
            [ Text "Este jugador está temporalmente fuera de la partida." ]

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
            [ Text "Invitar Jugadores" ]

        InvitePlayersDescription ->
            [ Text "Obtiene el codigo/link/codigo qr para que los otros jugadores puedan entrar." ]

        SetAway ->
            [ Text "Marcar como afuera" ]

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
            [ Text "Acaba la partida instantaneamente." ]

        ReturnViewToGame ->
            [ Text "Volver al juego" ]

        ReturnViewToGameDescription ->
            [ Text "Vuelve a la vista original." ]

        ViewConfiguration ->
            [ Text "Configura" ]

        ViewConfigurationDescription ->
            [ Text "Cambia para ver la configuración de la partida." ]

        KickUser ->
            [ Text "Expulsar" ]

        Promote ->
            [ Text "Promover" ]

        Demote ->
            [ Text "Relegar" ]

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
            [ Text "Ignorar" ]

        -- Configuration
        ConfigureTitle ->
            [ Text "Configuración de la partida" ]

        NoDecks ->
            [ Segment [ Text "Sin barajas. " ]
            , Text " "
            , Segment [ Text "Tendrás que añadir almenos una a la partida." ]
            ]

        NoDecksHint ->
            [ Text "No estas seguro? Añade la original ", raw CardsAgainstHumanity, Text " baraja." ]

        WaitForDecks ->
            [ Text "las barajas deben cargarse antes de empezar el juego." ]

        MissingCardType { cardType } ->
            [ Text "Ninguna de tus barajas contiene "
            , ref (nounUnknownQuantity cardType)
            , Text ". Necesitas una baraja que lo tenga para empezar la partida."
            ]

        NotEnoughCardsOfType { cardType, needed, have } ->
            [ Text "Con el número de jugadores en la partida, necesitarás almenos "
            , Text (needed |> String.fromInt)
            , Text " "
            , ref (noun cardType needed)
            , Text " pero solo tienes "
            , Text (have |> String.fromInt)
            , Text "."
            ]

        AddBlankCards { amount } ->
            [ Text "Añade "
            , amount |> String.fromInt |> Text
            , Text " blank "
            , ref (noun Response amount)
            ]

        AddDeck ->
            [ Text "Añade una baraja." ]

        RemoveDeck ->
            [ Text "Elimina una baraja." ]

        SourceNotFound { source } ->
            [ ref source, Text " no reconoce la baraja elegida. Revisa que los datos introducidos sean correctos." ]

        SourceServiceFailure { source } ->
            [ ref source, Text " ha fallado en conseguir la baraja. Porfavor prueba más tarde o cambia de proveedor." ]

        ManyDecks ->
            [ Text "Many Decks" ]

        ManyDecksDeckCodeTitle ->
            [ Text "Codigo de la Baraja" ]

        ManyDecksDeckCodeShort ->
            [ Text "Un codigo de baraja tiene que ser de al menos 5 caracteres." ]

        ManyDecksWhereToGet ->
            [ Text "Puedes crear y obtener barajas en ", ref ManyDecks, Text "." ]

        JsonAgainstHumanity ->
            [ Text "JSON Against Humanity" ]

        JsonAgainstHumanityAbout ->
            [ Text "Barajas obtenidas por ", ref JsonAgainstHumanity ]

        BuiltIn ->
            [ Text "Integrado" ]

        APlayer ->
            [ Text "Un Jugador" ]

        Generated { by } ->
            [ Text "Generado por ", ref by ]

        DeckAlreadyAdded ->
            [ Text "La baraja ya está en la partida." ]

        ConfigureDecks ->
            [ Text "Barajas" ]

        ConfigureRules ->
            [ Text "Normas" ]

        ConfigureTimeLimits ->
            [ Text "Limites de Tiempo" ]

        ConfigurePrivacy ->
            [ Text "Privacidad" ]

        HandSize ->
            [ Text "Tamaño de la Baraja" ]

        HandSizeDescription ->
            [ Text "El número base de cartas que tiene cada jugador durante la partida." ]

        ScoreLimit ->
            [ ref (noun Point 1), Text " Limit" ]

        ScoreLimitDescription ->
            [ Segment
                [ Text "El numero de "
                , ref (nounUnknownQuantity Point)
                , Text " que necesita un jugador para ganar la partida."
                ]
            , Text " "
            , Segment [ Text "Si se desabilita, el juego no acaba nunca." ]
            ]

        UnsavedChangesWarning ->
            [ Text "Tienes cambios sin guardar en la configuración, tienes que guardarlos primero si quieres que se guarden "
            , Text "a la partida."
            ]

        SaveChanges ->
            [ Text "Guarda los cambios." ]

        RevertChanges ->
            [ Text "Descartar los cambios." ]

        NeedAtLeastOneDeck ->
            [ Text "Necesitas una baraja para empezar la partida." ]

        NeedAtLeastThreePlayers ->
            [ Text "Se necesitan al menos tres jugadores para empezar la partida." ]

        NeedAtLeastOneHuman ->
            [ Text "Desafortunadamente, los bots no pueden ser el "
            , ref Czar
            , Text ", así que se necesita al menos un jugador humano para empezar la partida."
            , Text " (¡Aunque solo un humano puede ser un poco aburrido!)"
            ]

        RandoCantWrite ->
            [ Text "Los bots no pueden escribir sus propias cartas." ]

        DisableComedyWriter ->
            [ Text "Desabilitar ", ref HouseRuleComedyWriter ]

        DisableRando ->
            [ Text "Desabilitar ", ref HouseRuleRandoCardrissian ]

        AddAnAiPlayer ->
            [ Text "Añade un bot a la partida." ]

        PasswordShared ->
            [ Text "¡Cualquier jugador en la partida puede ver la contraseña! "
            , Text "Esconderlo solo te afectará a ti (útil para stremear, etc...)."
            ]

        PasswordNotSecured ->
            [ Text "Las contraseñas de las partidas "
            , Em [ Text "no" ]
            , Text " están seguramente guardadas, por eso, porfavor "
            , Em [ Text "¡no" ]
            , Text " uses contraseñas que uses ya en otros sitios!"
            ]

        LobbyPassword ->
            [ Text "Contraseña de la partida" ]

        LobbyPasswordDescription ->
            [ Text "Una contraseña que deberán usar todos los jugadores para entrar." ]

        AudienceMode ->
            [ Text "Modo Audiencia" ]

        AudienceModeDescription ->
            [ Text "Si se activa, todos los jugadores entrarán como espectadores, y tu escogerás si cambiarlos a jugadores."
            ]

        StartGame ->
            [ Text "Empezar la partida" ]

        Public ->
            [ Text "Juego público" ]

        PublicDescription ->
            [ Text "Si se activa, el juego saldrá en el apartado de salas publicas en el menú." ]

        ApplyConfiguration ->
            [ Text "Guardar cambios." ]

        AppliedConfiguration ->
            [ Text "Guardado." ]

        InvalidConfiguration ->
            [ Text "El valor de la configuración no es valido." ]

        Automatic ->
            [ Text "Marcar automaticamente a los jugadores como afuera" ]

        AutomaticDescription ->
            [ Text "Si se activa, los jugadores que excedan el tiempo limite serán marcados como afuera. "
            , Text "Sinó alguien tendrá que marcarlos manualmente."
            ]

        TimeLimit { stage } ->
            [ ref stage, Text " Time Limit" ]

        StartingTimeLimitDescription ->
            [ Text "Cuanto tiempo (en segundos) el "
            , ref Czar
            , Text " tiene para escoger/escribir una "
            , ref (noun Call 1)
            , Text ", cuando el "
            , raw HouseRuleCzarChoices
            , Text " esté activado."
            ]

        PlayingTimeLimitDescription ->
            [ Text "Cuanto tiempo (en segundos) el ", ref Players, Text " tiene en su turno." ]

        PlayingAfterDescription ->
            [ Text "Cuanto tiempo (en segundos) tienen los jugadores para cambiar su eleccion antes de que se pase de fase.." ]

        RevealingTimeLimitDescription ->
            [ Text "Cuanto tiempo (en segundos) el ", ref Czar, Text " tiene para enseñar las respuestas." ]

        RevealingAfterDescription ->
            [ Text "Cuanto tiempo (en segundos) se tiene que esperar después de que la ultima respuesta sea revelada para que empieza la siguiente fase." ]

        JudgingTimeLimitDescription ->
            [ Text "Cuanto tiempo (en segundos) el ", ref Czar, Text " tiene para escojer la mejor respuesta." ]

        CompleteTimeLimitDescription ->
            [ Text "Cuanto tiempo (en segundos) hay que esperar después de una ronda para que empieze la siguiente." ]

        RevealingEnabledTitle ->
            [ Text "Lider muestra las respuestas" ]

        RevealingEnabled ->
            [ Text "Si se activa, el "
            , ref Czar
            , Text " revelará cada respuesta antes de escoger la ganadora."
            ]

        DuringTitle ->
            [ Text "Limite de tiempo" ]

        AfterTitle ->
            [ Text "Después" ]

        Conflict ->
            [ Text "Conflicto" ]

        ConflictDescription ->
            [ Text "Alguien más ha cambiado la configuración mientras tu lo hacias. "
            , Text "Escoge si quieres mantener sus cambios o los tuyos."
            ]

        YourChanges ->
            [ Text "Tus cambios" ]

        TheirChanges ->
            [ Text "Sus cambios" ]

        ConfigurationDisabledWhileInGame ->
            [ Text "Mientras el jeugo está en progreso no puedes cambiar la configuración." ]

        ConfigurationDisabledIfNotPrivileged ->
            [ Text "No puedes cambiar la configuración de esta partida." ]

        ConfigureNextGame ->
            [ Text "Configura la siguiente partida" ]

        -- Game
        PickCall ->
            [ Text "Escoge esto ", ref (noun Call 1), Text " para que los otros jueguen esta ronda." ]

        WriteCall ->
            [ Text "Escribe una ", ref (noun Call 1), Text "personalizada para que los otros jueguen esta ronda." ]

        SubmitPlay ->
            [ Text "Entrega estas cartas al ", ref Czar, Text " como tu propuesta para la ronda." ]

        TakeBackPlay ->
            [ Text "Cambia las cartas para modificar tu respuesta esta ronda." ]

        JudgePlay ->
            [ Text "Escoge esta respuesta como ganadora para la ronda." ]

        LikePlay ->
            [ Text "Dale un like a esta respuesta." ]

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
            [ Text "Ver rondas previas." ]

        ViewHelpAction ->
            [ Text "Ayuda" ]

        EnforceTimeLimitAction ->
            [ Text "Pon todos los jugadores pendientes de turno en afuera y salta su turno hasta que vuelvan." ]

        Blank ->
            [ Text "Vacio" ]

        RoundStarted ->
            [ Text "Ronda empezada" ]

        JudgingStarted ->
            [ Text "Se está juzgando" ]

        Paused ->
            [ Text "La partida se ha parado porque no hay suficientes jugadores para continuar."
            , Text "Cuando alguien se una o vuelva, el juego se reaunudara automáticamente."
            ]

        ClientAway ->
            [ Text "Estas afuera,  y no estás jugando." ]

        Discard ->
            [ Text "Descarta la carta seleccionada, revelandola a todos los otros jugadores en la partida." ]

        Discarded { player } ->
            [ Text player
            , Text " ha descartado la carta siguiente:"
            ]

        -- Instructions
        PickCallInstruction ->
            [ Text "Escoge ", ref (noun Call 1), Text " para que los otros jueguen con ella esta ronda." ]

        WaitForCallInstruction ->
            [ Text "Estas esperando a que el "
            , ref Czar
            , Text " escoja una "
            , ref (noun Call 1)
            , Text " para jugarla esta ronda."
            ]

        PlayInstruction { numberOfCards } ->
            [ Text "Tienes que escoger "
            , Text (asWord numberOfCards)
            , Text " más "
            , ref (noun Response numberOfCards)
            , Text " de tu baraja antes de entregar tu respuesta."
            ]

        SubmitInstruction ->
            [ Text "Tienes que entregar tu respuesta para la ronda." ]

        WaitingForPlaysInstruction ->
            [ Text "Estás esperando a que los otros jugadores acaben su turno." ]

        CzarsDontPlayInstruction ->
            [ Text "Eres el "
            , ref Czar
            , Text " esta ronda - no entregarás ninguna "
            , ref (nounUnknownQuantity Response)
            , Text ". En cambio, escogerás al ganador de la ronda cuando todo el mundo acabe su turno."
            ]

        NotInRoundInstruction ->
            [ Text "No estas jugando esta ronda. Jugarás en la siguiente." ]

        RevealPlaysInstruction ->
            [ Text "Pulsa en las respuestas para girarlas, entonces escoge la que creas que sea la mejor." ]

        WaitingForCzarInstruction ->
            [ Text "Puedes darle like a las respuestas mientras esperas al ", ref Czar, Text " para enseñar las respuestas y escoger un ganador de la ronda." ]

        AdvanceRoundInstruction ->
            [ Text "La siguiente ronda ha empezado, puedes avanzar." ]

        -- 404 Unknown
        UnknownPageTitle ->
            [ Text "404 Error: Unknown page." ]

        GoBackHome ->
            [ Text "Ir al menú." ]

        -- Actions
        Refresh ->
            [ Text "Actualizar" ]

        Accept ->
            [ Text "Ok" ]

        -- Editor
        AddSlot ->
            [ Text "Añadir ", ref Blank ]

        AddText ->
            [ Text "Añadir Texto" ]

        EditText ->
            [ Text "Editar" ]

        EditSlotIndex ->
            [ Text "Editar" ]

        MoveLeft ->
            [ Text "Mover Tempranamente" ]

        Remove ->
            [ Text "Eliminar" ]

        MoveRight ->
            [ Text "Mover Después" ]

        Normal ->
            [ Text "Normal" ]

        Capitalise ->
            [ Text "Capitalizar" ]

        UpperCase ->
            [ Text "Mayúsculas" ]

        Emphasise ->
            [ Text "Destacar" ]

        MustContainAtLeastOneSlot ->
            [ Text "Necesitas al menos una ", ref Blank, Text " para que la gente juegue." ]

        SlotIndexExplanation ->
            [ Text "Que número "
            , ref (noun Response 1)
            , Text " jugado será usado para este "
            , ref Blank
            , Text ". Esto te deja repetir una "
            , ref (noun Response 1)
            , Text "."
            ]

        -- Errors
        Error ->
            [ Text "Error" ]

        ErrorHelp ->
            [ Text "El servidor puede estar caido, o pueder ser un error. Reinicia la página "
            , Text "para continuar. Más detalles debajo."
            ]

        ErrorHelpTitle ->
            [ Text "Perdón, algo ha ido mal." ]

        ErrorCheckOutOfBand ->
            [ Text "Porfavor mira ", ref TwitterHandle, Text " por actualizaciones y estado del servicio. El servidor del juego caerás por un corto tiempo cuando una nueva versión sea lanzada, así que si ves una actualización reciente vuelve a intentarlo en unos minutos." ]

        TwitterHandle ->
            [ Text "@Massive_Decks" ]

        ReportError ->
            [ Text "Reportar bug" ]

        ReportErrorDescription ->
            [ Text "Deja saber a los desarrolladores el bug que has encontrado para que puedan arreglarlo." ]

        ReportErrorBody ->
            [ Text "Estava [reemplaza esto con una corta explicación de lo que estavas haciendo] cuando me encontré con el siguiente error:" ]

        BadUrlError ->
            [ Text "Intentamos hacer una solicitud a una página inválida." ]

        TimeoutError ->
            [ Text "El servidor no respondió por demasiado tiempo. Puede estar caido, prueba de nuevo en un tiempo." ]

        NetworkError ->
            [ Text "Se te fué la conexión a internet, prueba más tarde." ]

        ServerDownError ->
            [ Text "El servidor está offline, porfavor prueba más tarde." ]

        BadStatusError ->
            [ Text "El servidor dio una respuesta que no esperavamos." ]

        BadPayloadError ->
            [ Text "El servidor dio una respuesta que no entendimos." ]

        PatchError ->
            [ Text "El servidor nos dió una actualización que no pudimos aplicar." ]

        VersionMismatch ->
            [ Text "El servidor nos dió un cambio de configuración para una versión diferente de la que esperavamos." ]

        CastError ->
            [ Text "Algo fué mal intentando conectarte a la partida." ]

        ActionExecutionError ->
            [ Text "No puedes hacer esa acción." ]

        IncorrectPlayerRoleError { role, expected } ->
            [ Text "Tienes que ser un ", ref expected, Text " para hacer eso, pero eres un ", ref role, Text "." ]

        IncorrectUserRoleError { role, expected } ->
            [ Text "Tienes que ser un ", ref expected, Text " para hacer eso, pero eres un ", ref role, Text "." ]

        IncorrectRoundStageError { stage, expected } ->
            [ Text "La ronda tiene que estar a ", ref expected, Text " fase para hacer eso pero está a la ", ref stage, Text " fase." ]

        ConfigEditConflictError ->
            [ Text "Alguien cambió la configuración antes que tú, asi que tus cambios no se guardaron." ]

        UnprivilegedError ->
            [ Text "No tienes los permisos para hacer eso." ]

        GameNotStartedError ->
            [ Text "El juego tiene que estar empezado para hacer eso" ]

        InvalidActionError { reason } ->
            [ Text "El server no entendió una petición del cliente. Details: ", Text reason ]

        AuthenticationError ->
            [ Text "No puedes unirte a esta partida." ]

        IncorrectIssuerError ->
            [ Text "Tus credenciales para entrar a la partida están caducados o el juego ya no existe." ]

        InvalidAuthenticationError ->
            [ Text "Tus credenciales para entrar a la partida están corruptos." ]

        InvalidLobbyPasswordError ->
            [ Text "La contraseña es incorrecta." ]

        AlreadyLeftError ->
            [ Text "Te has ido de la partida." ]

        LobbyNotFoundError ->
            [ Text "La partida no existe." ]

        LobbyClosedError { gameCode } ->
            [ Text "La partida a la que deseas acceder (", ref (GameCode { code = gameCode }), Text ") ha acabado." ]

        LobbyDoesNotExistError { gameCode } ->
            [ Text "El codigo que has introducido ("
            , ref (GameCode { code = gameCode })
            , Text ") no existe. "
            , Text "Revisalo."
            ]

        RegistrationError ->
            [ Text "Problema entrando a la partida." ]

        UsernameAlreadyInUseError { username } ->
            [ Text "Alguien está usando su nombre“"
            , Text username
            , Text "”—prueba otro diferente"
            ]

        GameError ->
            [ Text "Algo ha ido mal en la partida." ]

        OutOfCardsError ->
            [ Text "No havian suficientes cartas en la baraja para todos los jugadores. Prueba de añadir más en la configuración." ]

        -- Language Names
        English ->
            [ Text "Inglés" ]

        BritishEnglish ->
            [ Text "Inglés (Británico)" ]

        Italian ->
            [ Text "Italiano" ]

        BrazilianPortuguese ->
            [ Text "Portugués (De Brazil)" ]

        German ->
            [ Text "Alemán (Formal)" ]

        GermanInformal ->
            [ Text "Alemán (Informal)" ]

        Polish ->
            [ Text "Polaco" ]

        Indonesian ->
            [ Text "Indonesio" ]

        Spanish ->
            [ Text "Español" ]


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
            "zero"

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
            "nuevo"

        10 ->
            "diez"

        11 ->
            "once"

        12 ->
            "doce"

        other ->
            String.fromInt other
