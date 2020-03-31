module MassiveDecks.Strings.Languages.It exposing (pack)

{- General Italian translation -}

import MassiveDecks.Strings exposing (MdString(..))
import MassiveDecks.Strings.Translation as Translation exposing (Result(..))


pack : Translation.Pack
pack =
    { code = "it"
    , name = Italian
    , translate = translate
    }



{- Private -}


{-| The English translation
-}
translate : MdString -> List Translation.Result
translate mdString =
    case mdString of
        -- General
        MassiveDecks ->
            [ Text "Massive Decks" ]

        Close ->
            [ Text "Chiudi" ]

        -- Special
        Plural { singular, amount } ->
            if amount == Just 1 then
                [ Raw singular ]

            else
                -- Not ideal, but pluralization is not trivial in Italian, su we just handle the very few cases
                case singular of
                    Call ->
                        [ Text "Carte Nere" ]

                    Response ->
                        [ Text "Carte Bianche" ]

                    Point ->
                        [ Text "Punti" ]

                    Player ->
                        [ Text "Giocatori" ]

                    Spectator ->
                        [ Text "Spettatori" ]

                    _ ->
                        [ Raw singular ]

        -- Start screen.
        Version { versionNumber } ->
            [ Text "Versione “", Text versionNumber, Text "”" ]

        ShortGameDescription ->
            [ Text "Un divertente gioco di società." ]

        WhatIsThis ->
            [ Text "Cos’è ", Ref MassiveDecks, Text "?" ]

        GameDescription ->
            [ Ref MassiveDecks
            , Text " è un gioco di società basato su "
            , Ref CardsAgainstHumanity
            , Text ", sviluppato da "
            , Ref RereadGames
            , Text " e altri contributori—il gioco è open source sotto "
            , Ref License
            , Text ", quindi puoi aiutare a migliorare il gioco, accedere al codice sorgente, o semplicemente scoprire di più sul "
            , Ref MDProject
            , Text "."
            ]

        NewGame ->
            [ Text "Nuovo" ]

        FindPublicGame ->
            [ Text "Trova" ]

        JoinPrivateGame ->
            [ Text "Partecipa" ]

        PlayGame ->
            [ Text "Gioca" ]

        AboutTheGame ->
            [ Text "Info" ]

        AboutTheGameDescription ->
            [ Text "Scopri di più su ", Ref MassiveDecks, Text " e come è sviluppato." ]

        MDLogoDescription ->
            [ Text "Una ", Ref Call, Text " e una ", Ref Response, Text " marcate con una “M” e una “D”." ]

        RereadLogoDescription ->
            [ Text "Un libro cerchiato con una freccia di riciclo." ]

        MDProject ->
            [ Text "progetto GitHub" ]

        License ->
            [ Text "licenza AGPLv3" ]

        DevelopedByReread ->
            [ Text "Sviluppato da ", Ref RereadGames, Text "." ]

        RereadGames ->
            [ Text "Reread Games" ]

        NameLabel ->
            [ Text "Il tuo nome" ]

        NameInUse ->
            [ Text "Qualcun altro sta utilizzando questo nome nel gioco—per favore scegline un altro." ]

        RejoinTitle ->
            [ Text "Rientra nel gioco" ]

        RejoinGame { code } ->
            [ Text "Rientra in “", GameCode { code = code } |> Ref, Text "”." ]

        LobbyRequiresPassword ->
            [ Text "Hai bisogno di una password per partecipare a questo gioco. Prova a chiedere alla persona che ti ha invitato." ]

        YouWereKicked ->
            [ Text "Sei stato espulso dal gioco." ]

        -- Rules
        CardsAgainstHumanity ->
            [ Text "Cards Against Humanity" ]

        Rules ->
            [ Text "Come giocare." ]

        RulesHand ->
            [ Text "Ogni giocatore ha una mano di ", Ref (Plural { singular = Response, amount = Nothing }), Text "." ]

        RulesCzar ->
            [ Text "Il primo giocatore inizia come  "
            , Ref Czar
            , Text ". Il "
            , Ref Czar
            , Text " legge la domanda o frase da completare nella "
            , Ref Call
            , Text " a voce alta."
            ]

        RulesPlaying ->
            [ Text "Tutti gli altri rispondono alla domanda o completano gli spazi scegliendo una "
            , Ref Response
            , Text " dalla loro mano per giocare nel turno."
            ]

        RulesJudging ->
            [ Text "Le risposte sono poi mescolate e il  "
            , Ref Czar
            , Text " le legge a voce alta agli altri giocatori—per il pieno effetto, il "
            , Ref Czar
            , Text " dovrebbe rileggere la "
            , Ref Call
            , Text " prima di presentare ogni risposta. Il "
            , Ref Czar
            , Text " poi sceglie la giocata più divertente, e la persona che l’ha giocata prende un "
            , Ref Point
            , Text "."
            ]

        RulesPickTitle ->
            [ Ref (Pick { numberOfCards = 2 }) ]

        RulesPick ->
            [ Text "Alcune carte necessitano più di una "
            , Ref Response
            , Text " come risposta. Gioca le carte nell’ordine in cui il "
            , Ref Czar
            , Text " le dovrebbe leggere—l’ordine è importante."
            ]

        ExamplePickDescription ->
            [ Ref (Plural { singular = Call, amount = Nothing })
            , Text " come questa richiederanno di scegliere multiple "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text ", ma te ne danno di più da cui scegliere."
            ]

        RulesDraw ->
            [ Text "Alcune "
            , Ref (Plural { singular = Call, amount = Nothing })
            , Text " richiederenno ancora più "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text "—queste diranno "
            , Ref (Draw { numberOfCards = 2 })
            , Text " o più, e riceverai quel numero di carte aggiuntive prima della giocata."
            ]

        GameRulesTitle ->
            [ Text "Regole del gioco" ]

        HouseRulesTitle ->
            [ Text "Regole della casa" ]

        HouseRules ->
            [ Text "Puoi cambiare il modo in cui il gioco funziona in vari modi. Mentre configuri il gioco, scegli "
            , Text "tutte le regole della casa che vuoi utilizzare."
            ]

        HouseRuleReboot ->
            [ Text "Riavvia l’universo" ]

        HouseRuleRebootDescription { cost } ->
            [ Text "In qualunque momento, i giocatori possono cedere "
            , Text (an cost)
            , Ref (Plural { singular = Point, amount = cost })
            , Text " per scartare la loro mano e pescarne una nuova."
            ]

        HouseRuleRebootAction { cost } ->
            [ Text "Spendi "
            , Text (asWord cost)
            , Text " "
            , Ref (Plural { singular = Point, amount = Just cost })
            , Text " per scartare la mano e pescarne una nuova."
            ]

        HouseRuleRebootCost ->
            [ Text "Costo ", Ref Point ]

        HouseRuleRebootCostDescription ->
            [ Text "Quanti ", Ref (Plural { singular = Point, amount = Nothing }), Text " costa ripescare." ]

        HouseRulePackingHeat ->
            [ Text "Porto d’armi" ]

        HouseRulePackingHeatDescription ->
            [ Text "Qualunque "
            , Ref (Plural { singular = Call, amount = Nothing })
            , Text " con "
            , Ref (Pick { numberOfCards = 2 })
            , Text " riceve anche "
            , Ref (Draw { numberOfCards = 1 })
            , Text ", così tutti hanno più opzioni."
            ]

        HouseRuleComedyWriter ->
            [ Text "Scrittore comico" ]

        HouseRuleComedyWriterDescription ->
            [ Text "Aggiungi  "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text " in bianco dove i giocatori possono scrivere una risposta personalizzata."
            ]

        HouseRuleComedyWriterNumber ->
            [ Ref (Plural { singular = Response, amount = Nothing }), Text " in bianco" ]

        HouseRuleComedyWriterNumberDescription ->
            [ Text "Il numero di "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text " in bianco da utilizzare nel gioco."
            ]

        HouseRuleComedyWriterExclusive ->
            [ Text "Solo ", Ref (Plural { singular = Response, amount = Nothing }), Text " in bianco" ]

        HouseRuleComedyWriterExclusiveDescription ->
            [ Text "Se abilitato, tutte le altre "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text " saranno ignorate, solo quelle in bianco esisteranno nel gioco."
            ]

        HouseRuleRandoCardrissian ->
            [ Text "Rando Cardrissian" ]

        HouseRuleRandoCardrissianDescription ->
            [ Text "Ogni turno, la prima "
            , Ref Response
            , Text " nel mazzo sarà giocata come risposta. Questa mano appartiene al giocatore IA chiamato "
            , Text "Rando Cardrissian e, se vince il gioco, tutti i giocatori vanno a casa in uno stato di vergogna perenne."
            ]

        HouseRuleRandoCardrissianNumber ->
            [ Text "Giocatori IA" ]

        HouseRuleRandoCardrissianNumberDescription ->
            [ Text "Il numero di giocatori IA che saranno presenti nel gioco." ]

        MustBeMoreThanOrEqualValidationError { min } ->
            [ Text "Il valore deve essere almeno ", Text (String.fromInt min), Text "." ]

        MustBeLessThanOrEqualValidationError { max } ->
            [ Text "Il valore deve essere al massimo ", Text (String.fromInt max), Text "." ]

        SetValue { value } ->
            [ Text "Imposta il valore a ", Text (String.fromInt value), Text "." ]

        CantBeEmpty ->
            [ Text "Questo non può essere vuoto." ]

        SettingsTitle ->
            [ Text "Impostazioni" ]

        LanguageSetting ->
            [ Text "Lingua" ]

        MissingLanguage ->
            [ Text "Non vedi la tua lingua? ", Ref TranslationBeg ]

        TranslationBeg ->
            [ Text "Aiuta a tradurre "
            , Ref MassiveDecks
            , Text "!"
            ]

        CardSizeSetting ->
            [ Text "Carte compatte" ]

        CardSizeExplanation ->
            [ Text "Modifica quanto sono grandi le carte—questo può essere utile su schermi piccoli per scorrere meno lo schermo." ]

        SpeechSetting ->
            [ Text "Sintesi vocale" ]

        SpeechExplanation ->
            [ Text "Leggi le carte con la sintesi vocale." ]

        SpeechNotSupportedExplanation ->
            [ Text "Il tuo broswer non supporta la sintesi vocale, o non ha nessuna voce installata." ]

        VoiceSetting ->
            [ Text "Voce di sintesi" ]

        NotificationsSetting ->
            [ Text "Notifiche del browser" ]

        NotificationsExplanation ->
            [ Text "Avvisa quando devi fare qualcosa nel gioco con le notifiche del browser."
            ]

        NotificationsUnsupportedExplanation ->
            [ Text "Il tuo browser non supporta le notifiche." ]

        NotificationsBrowserPermissions ->
            [ Text "Dovrai permettere a "
            , Ref MassiveDecks
            , Text " di mandare notifiche. Questo sarà utilizzato solo finchè il gioco è aperto e hai questo abilitato."
            ]

        NotificationOnlyWhenHiddenSetting ->
            [ Text "Solo quando nascosto" ]

        NotificationsOnlyWhenHiddenExplanation ->
            [ Text "Manda le notifiche solo quando non stai guardando la pagina (per esempio: su un’altra scheda o minimizzato)." ]

        NotificationsOnlyWhenHiddenUnsupportedExplanation ->
            [ Text "Il tuo browser non permette di verificare se una pagina è visibile." ]

        -- Terms
        Czar ->
            [ Text "Giudice" ]

        CzarDescription ->
            [ Text "Il giocatore che giudica un turno." ]

        Player ->
            [ Text "Giocatore" ]

        Spectator ->
            [ Text "Spettatore" ]

        Call ->
            [ Text "Carta Nera" ]

        CallDescription ->
            [ Text "Una carta nera con una domanda o frase da riempire." ]

        Response ->
            [ Text "Carta Bianca" ]

        ResponseDescription ->
            [ Text "Una carta bianca da giocare nei turni." ]

        Point ->
            [ Text "Punto" ]

        PointDescription ->
            [ Text "Un punto—averne di più significa vincere." ]

        GameCodeTerm ->
            [ Text "Codice Gioco" ]

        GameCodeDescription ->
            [ Text "Un codice che permette alle altre personi di trovare il gioco e parteciparvi." ]

        GameCode { code } ->
            [ Text code ]

        GameCodeSpecificDescription ->
            [ Text "Dai questo codice gioco alle altre persone per farle partecipare." ]

        GameCodeHowToAcquire ->
            [ Text "Chiedi il ", Ref GameCodeTerm, Text " alla persona che ti ha invitato a giocare." ]

        Deck ->
            [ Text "Mazzo" ]

        StillPlaying ->
            [ Text "Sta giocando" ]

        PlayingDescription ->
            [ Text "Questo giocatore è nel turno, ma non ha ancora fatto la sua giocata." ]

        Played ->
            [ Text "Ha giocato" ]

        PlayedDescription ->
            [ Text "Questo giocatore ha fatto la sua giocata." ]

        -- Lobby Browser
        LobbyBrowserTitle ->
            [ Text "Giochi pubblici" ]

        NoPublicGames ->
            [ Text "Nessun gioco pubblico disponibile." ]

        PlayingGame ->
            [ Text "Giochi in corso." ]

        SettingUpGame ->
            [ Text "Giochi che non sono ancora iniziati." ]

        StartYourOwn ->
            [ Text "Inizia un nuovo gioco?" ]

        -- Spectation
        JoinTheGame ->
            [ Text "Partecipa al gioco!" ]

        ToggleAdvertDescription ->
            [ Text "Nascondi visualizzazione info su come partecipare al gioco." ]

        -- Cards
        Pick numberOfCards ->
            [ Text "Scegli", Ref (NumberOfCards numberOfCards) ]

        Draw numberOfCards ->
            [ Text "Pesca", Ref (NumberOfCards numberOfCards) ]

        PickDescription { numberOfCards } ->
            [ Text "Devi giocare "
            , Text (asWord numberOfCards)
            , Text " "
            , Ref (Plural { singular = Response, amount = Just numberOfCards })
            , Text "."
            ]

        DrawDescription { numberOfCards } ->
            [ Text "Ottieni "
            , Text (asWord numberOfCards)
            , Text " "
            , Ref (Plural { singular = Response, amount = Just numberOfCards })
            , Text " in più prima di giocare."
            ]

        NumberOfCards { numberOfCards } ->
            [ Text (String.fromInt numberOfCards) ]

        -- Lobby
        Invite ->
            [ Text "Invita giocatori al gioco." ]

        InviteLinkHelp ->
            [ Text "Invia questo link ai giocatori per invitarli al gioco, o fagli scansionare il codice QR qui sotto." ]

        InviteExplanation { gameCode, password } ->
            let
                extra =
                    password
                        |> Maybe.map
                            (\p ->
                                [ Text " e la password “"
                                , Text p
                                , Text "”"
                                ]
                            )
                        |> Maybe.withDefault []
            in
            List.concat
                [ [ Text "Il tuo codice gioco è "
                  , Ref (GameCode { code = gameCode })
                  , Text ". I giocatori possono partecipare al gioco caricando "
                  , Ref MassiveDecks
                  , Text " e inserendo questo codice"
                  ]
                , extra
                , [ Text "."
                  ]
                ]

        Cast ->
            [ Text "Proietta su TV." ]

        CastConnecting ->
            [ Text "Collegamento…" ]

        CastConnected { deviceName } ->
            [ Text "Proiezione su ", Text deviceName, Text "." ]

        Players ->
            [ Ref (Plural { singular = Player, amount = Nothing }) ]

        PlayersDescription ->
            [ Text "Utenti che partecipano al gioco." ]

        Spectators ->
            [ Ref (Plural { singular = Spectator, amount = Nothing }) ]

        SpectatorsDescription ->
            [ Text "Utenti che guardano il gioco senza parteciparvi." ]

        Left ->
            [ Text "È uscito" ]

        LeftDescription ->
            [ Text "Utenti che sono usciti dal gioco." ]

        Away ->
            [ Text "Allontanato" ]

        AwayDescription ->
            [ Text "Questo utente si è temporaneamente allontanato dal gioco." ]

        Disconnected ->
            [ Text "Disconnesso" ]

        DisconnectedDescription ->
            [ Text "Questo utente non è collegato al gioco." ]

        Privileged ->
            [ Text "Proprietario" ]

        PrivilegedDescription ->
            [ Text "Questo utente può modificare le impostazioni del gioco." ]

        Ai ->
            [ Text "IA" ]

        AiDescription ->
            [ Text "Questo giocatore è controllato dal computer." ]

        Score { total } ->
            [ Text (String.fromInt total) ]

        ScoreDescription ->
            [ Text "Il numero di "
            , Ref (Plural { singular = Point, amount = Nothing })
            , Text " che questo giocatore ha."
            ]

        Likes { total } ->
            [ Text (String.fromInt total) ]

        LikesDescription ->
            [ Text "Il numero di Mi Piace ricevuti."
            ]

        ToggleUserList ->
            [ Text "Mostra o nascondi la classifica." ]

        GameMenu ->
            [ Text "Menu del gioco." ]

        UnknownUser ->
            [ Text "Un utente sconosciuto" ]

        InvitePlayers ->
            [ Text "Invita giocatori" ]

        InvitePlayersDescription ->
            [ Text "Ottieni il codice gioco/link/codice QR per far partecipare gli altri a questo gioco." ]

        SetAway ->
            [ Text "Segna come Allontanato" ]

        SetBack ->
            [ Text "Segna come Ritornato" ]

        LeaveGame ->
            [ Text "Abbandona gioco" ]

        LeaveGameDescription ->
            [ Text "Abbandona permanentemente il gioco." ]

        Spectate ->
            [ Text "Vista spettatore" ]

        SpectateDescription ->
            [ Text "Apri una vista spettatore del gioco in una nuova scheda/finestra." ]

        BecomeSpectator ->
            [ Text "Diventa spettatore" ]

        BecomeSpectatorDescription ->
            [ Text "Guarda il gioco senza partecipare." ]

        BecomePlayer ->
            [ Text "Gioca" ]

        BecomePlayerDescription ->
            [ Text "Partecipa al gioco." ]

        EndGame ->
            [ Text "Termina gioco" ]

        EndGameDescription ->
            [ Text "Termina il gioco adesso." ]

        ReturnViewToGame ->
            [ Text "Torna" ]

        ReturnViewToGameDescription ->
            [ Text "Torna alla vista principale del gioco." ]

        ViewConfgiuration ->
            [ Text "Configura" ]

        ViewConfgiurationDescription ->
            [ Text "Passa a visualizzare la configurazione del gioco." ]

        KickUser ->
            [ Text "Espelli" ]

        Promote ->
            [ Text "Promuovi" ]

        Demote ->
            [ Text "Degrada" ]

        -- Notifications
        UserConnected { username } ->
            [ Text username, Text " si è ricollegato al gioco." ]

        UserDisconnected { username } ->
            [ Text username, Text " si è scollegato dal gioco." ]

        UserJoined { username } ->
            [ Text username, Text " si è unito al gioco." ]

        UserLeft { username } ->
            [ Text username, Text " ha lasciato il gioco." ]

        UserKicked { username } ->
            [ Text username, Text " è stato espulso dal gioco." ]

        Dismiss ->
            [ Text "Nascondi" ]

        -- Configuration
        ConfigureTitle ->
            [ Text "Configura gioco" ]

        NoDecks ->
            [ Segment [ Text "Nessun mazzo. " ]
            , Text " "
            , Segment [ Text "Dovrai aggiungere almeno un mazzo al gioco." ]
            ]

        NoDecksHint ->
            [ Text "Non sei sicuro? Aggiungi il mazzo ", Raw CardsAgainstHumanity, Text " originale." ]

        WaitForDecks ->
            [ Text "I mazzi si devono caricare prima che tu possa iniziare il gioco." ]

        MissingCardType { cardType } ->
            [ Text "Nessuno dei mazzi contiene "
            , Ref (Plural { singular = cardType, amount = Nothing })
            , Text ". Sono necessarie per poter iniziare il gioco."
            ]

        NotEnoughCardsOfType { cardType, needed, have } ->
            [ Text "Per il numero di giocatori nel gioco, ti servono almeno "
            , Text (needed |> String.fromInt)
            , Text " "
            , Ref (Plural { singular = cardType, amount = Just needed })
            , Text " ma ne hai solo "
            , Text (have |> String.fromInt)
            , Text "."
            ]

        AddDeck ->
            [ Text "Aggiungi mazzo." ]

        RemoveDeck ->
            [ Text "Rimuovi mazzo." ]

        SourceNotFound { source } ->
            [ Ref source, Text " non riconosce il mazzo che hai richiesto. Verifica che i dettagli che hai inserito sono corretti." ]

        SourceServiceFailure { source } ->
            [ Ref source, Text " non ha potuto fornire il mazzo. Prova più tardi o prova un’altra sorgente." ]

        Cardcast ->
            [ Text "Cardcast" ]

        CardcastPlayCode ->
            [ Ref Cardcast, Text " Play Code" ]

        CardcastEmptyPlayCode ->
            [ Text "Inserisci il ", Ref CardcastPlayCode, Text " per il mazzo che vuoi aggiungere." ]

        APlayer ->
            [ Text "Un giocatore" ]

        DeckAlreadyAdded ->
            [ Text "Questo mazzo è già nel gioco." ]

        ConfigureDecks ->
            [ Text "Mazzi" ]

        ConfigureRules ->
            [ Text "Regole" ]

        ConfigureTimeLimits ->
            [ Text "Limiti di tempo" ]

        ConfigurePrivacy ->
            [ Text "Privacy" ]

        HandSize ->
            [ Text "Dimensione mano" ]

        HandSizeDescription ->
            [ Text "Il numero di carte di base che ogni giocatore ha durante il gioco." ]

        ScoreLimit ->
            [ Text "Limite ", Ref (Plural { singular = Point, amount = Nothing }) ]

        ScoreLimitDescription ->
            [ Segment
                [ Text "Il numero di "
                , Ref (Plural { singular = Point, amount = Nothing })
                , Text " che un giocatore deve avere per vincere il gioco."
                ]
            , Text " "
            , Segment [ Text "Se disabilitato, il gioco continua all’infinito." ]
            ]

        UnsavedChangesWarning ->
            [ Text "Hai modifiche alla configurazione non salvate, devono essere salvate se vuoi che abbiano effetto "
            , Text "nel gioco."
            ]

        SaveChanges ->
            [ Text "Salva le modifiche." ]

        RevertChanges ->
            [ Text "Annulla le modifiche non salvate." ]

        NeedAtLeastOneDeck ->
            [ Text "Hai bisogno di almeno un mazzo per iniziare il gioco." ]

        NeedAtLeastThreePlayers ->
            [ Text "Hai bisogno di almeno 3 giocatori per iniziare il gioco." ]

        NeedAtLeastOneHuman ->
            [ Text "Purtroppo, i giocatori computer non possono essere il "
            , Ref Czar
            , Text ", quindi ti serve almeno un giocatore umano per iniziare il gioco."
            , Text " (Anche se un solo giocatore umano potrebbe essere piuttosto noioso!)"
            ]

        RandoCantWrite ->
            [ Text "I giocatori computer non possono scrivere le loro carte." ]

        DisableComedyWriter ->
            [ Text "Disabilita ", Ref HouseRuleComedyWriter ]

        DisableRando ->
            [ Text "Disabilita ", Ref HouseRuleRandoCardrissian ]

        AddAnAiPlayer ->
            [ Text "Aggiungi un giocatore IA al gioco." ]

        PasswordShared ->
            [ Text "Chiunque può vedere la password all’interno del gioco! "
            , Text "Nasconderla qui sopra ha effetto solo su di te (utile se fai uno streaming, ecc…)."
            ]

        PasswordNotSecured ->
            [ Text "Le password del gioco "
            , Em [ Text "non" ]
            , Text " sono memorizzate in modo sicuro—quindi, per favore "
            , Em [ Text "non" ]
            , Text " utilizzare password vere che utilizzi in altri posti!"
            ]

        LobbyPassword ->
            [ Text "Password gioco" ]

        LobbyPasswordDescription ->
            [ Text "La password che gli utenti devono inserire per partecipare al gioco." ]

        StartGame ->
            [ Text "Inizia gioco" ]

        Public ->
            [ Text "Gioco pubblico" ]

        PublicDescription ->
            [ Text "Se abilitato, il gioco sarà visibile nella lista dei giochi pubblici che chiunque può vedere." ]

        ApplyConfiguration ->
            [ Text "Applica questa modifica." ]

        AppliedConfiguration ->
            [ Text "Salvato." ]

        InvalidConfiguration ->
            [ Text "Questo valore di configurazione non è valido." ]

        Automatic ->
            [ Text "Segna automaticamente giocatori come Allontanati" ]

        AutomaticDescription ->
            [ Text "Se abilitato, quando il tempo limite è trascorso, i giocatori verranno automaticamente segnati come Allontanati. "
            , Text "Altrimenti, dovrai premere il pulsante per segnarli come tali."
            ]

        TimeLimit { stage } ->
            [ Text "Tempo limite ", Ref stage ]

        PlayingTimeLimitDescription ->
            [ Text "Quanto tempo (in secondi) i ", Ref Players, Text " hanno per fare la giocata." ]

        RevealingTimeLimitDescription ->
            [ Text "Quanto tempo (in secondi) il ", Ref Czar, Text " ha per rivelare le giocate." ]

        JudgingTimeLimitDescription ->
            [ Text "Quanto tempo (in secondi) il ", Ref Czar, Text " ha per giudicare le giocate." ]

        CompleteTimeLimitDescription ->
            [ Text "Quanto tempo (in secondi) attendere dopo un turno prima di iniziare quello sucessivo." ]

        Conflict ->
            [ Text "Conflitto" ]

        ConflictDescription ->
            [ Text "Qualcun altro ha fatto delle modifiche mentre le stavi facendo anche tu. "
            , Text "Scegli se mantenere le tuo modifiche o le sue."
            ]

        YourChanges ->
            [ Text "Le tue modifiche" ]

        TheirChanges ->
            [ Text "Le sue modifiche" ]

        -- Game
        SubmitPlay ->
            [ Text "Dai queste carte al ", Ref Czar, Text " come giocata per il turno." ]

        TakeBackPlay ->
            [ Text "Riprenditi le carte per cambiare la giocata del turno." ]

        JudgePlay ->
            [ Text "Scegli questa giocata come vincitrice del turno." ]

        LikePlay ->
            [ Text "Aggiungi un Mi Piace a questa giocata." ]

        AdvanceRound ->
            [ Text "Prossimo turno." ]

        Playing ->
            [ Text "Giocata" ]

        Revealing ->
            [ Text "Rivelazione" ]

        Judging ->
            [ Text "Giudizio" ]

        Complete ->
            [ Text "Fine turno" ]

        ViewGameHistoryAction ->
            [ Text "Visualizza turni precedenti da questo gioco." ]

        ViewHelpAction ->
            [ Text "Aiuto" ]

        EnforceTimeLimitAction ->
            [ Text "Imposta tutti i giocatori che il gioco sta aspettando come Allontanati e saltali finchè non tornano." ]

        Blank ->
            [ Text "Spazio" ]

        RoundStarted ->
            [ Text "Turno iniziato" ]

        JudgingStarted ->
            [ Text "Giudizio iniziato" ]

        Paused ->
            [ Text "Il gioco è stato sospeso perchè non ci sono abbastanza giocatori attivi per continuare."
            , Text "Quando qualcuno si aggiunge o torna, riprenderà automaticamente."
            ]

        ClientAway ->
            [ Text "Sei impostato come Allontanato e non stai giocando." ]

        -- Instructions
        PlayInstruction { numberOfCards } ->
            [ Text "Devi scegliere altre "
            , Text (asWord numberOfCards)
            , Text " "
            , Ref (Plural { singular = Response, amount = Just numberOfCards })
            , Text " in questo turno prima di poter inviare la giocata."
            ]

        SubmitInstruction ->
            [ Text "Devi inviare la tua giocata per questo turno." ]

        WaitingForPlaysInstruction ->
            [ Text "Stai aspettando che gli altri giocatori facciano la loro scelta." ]

        CzarsDontPlayInstruction ->
            [ Text "Sei il "
            , Ref Czar
            , Text " per questo turno - non scegli nessuna "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text ". Invece, scegli il vincitore quando tutti gli altri hanno fatto le loro giocate."
            ]

        NotInRoundInstruction ->
            [ Text "Non partecipi in questo turno. Parteciperai al prossimo se non sei segnato come Allontanato." ]

        RevealPlaysInstruction ->
            [ Text "Clicca le carte giocate per girarle, poi scegli la giocata che ti piace di più." ]

        WaitingForCzarInstruction ->
            [ Text "Puoi dare un Mi Piace alle giocate mentre attendi che il ", Ref Czar, Text " riveli le carte e scelga il vincitore." ]

        AdvanceRoundInstruction ->
            [ Text "Il prossimo round è iniziato, puoi procedere." ]

        -- 404 Unknown
        UnknownPageTitle ->
            [ Text "Errore 404: Pagina sconosciuta." ]

        GoBackHome ->
            [ Text "Vai alla pagina principale." ]

        -- Actions
        Refresh ->
            [ Text "Aggiorna" ]

        -- Errors
        Error ->
            [ Text "Errore" ]

        ErrorHelp ->
            [ Text "Il server di gioco può non essere in funzione, o questo potrebbe essere un bug. Aggiornare la pagina dovrebbe "
            , Text "risolvere. Maggiori dettagli sono qui sotto."
            ]

        ErrorHelpTitle ->
            [ Text "Spiacenti, qualcosa è andato storto." ]

        ReportError ->
            [ Text "Segnala bug" ]

        ReportErrorDescription ->
            [ Text "Informa gli sviluppatori di un bug che hai riscontrato, in modo che possano correggerlo." ]

        ReportErrorBody ->
            [ Text "Stavo [sostituisci con una semplice spiegazione di cosa stavi facendo] quando è apparso il seguente errore:" ]

        BadUrlError ->
            [ Text "Abbiamo provato a fare una richiesta ad una pagina non valida." ]

        TimeoutError ->
            [ Text "Il server non ha risposto per troppo a lungo. Potrebbe non essere in funzione, riprova tra poco." ]

        NetworkError ->
            [ Text "La tua connessione ad internet si è interrotta." ]

        ServerDownError ->
            [ Text "Il server di gioco non è in funzione. Riprova tra poco." ]

        BadStatusError ->
            [ Text "Il server ha dato una risposta inaspettata." ]

        BadPayloadError ->
            [ Text "Il server ha dato una risposta incomprensibile." ]

        PatchError ->
            [ Text "Il server ha fornito una patch che non è stato possibile applicare." ]

        VersionMismatch ->
            [ Text "Il server ha fornito un cambiamento di configurazione per una versione differente da quanto ci si aspettava." ]

        CastError ->
            [ Text "Spiacenti, qualcosa è andato storto provando a collegarsi al gioco." ]

        ActionExecutionError ->
            [ Text "Non puoi eseguire quell’azione." ]

        IncorrectPlayerRoleError { role, expected } ->
            [ Text "Devi essere un ", Ref expected, Text " per farlo, ma sei un ", Ref role, Text "." ]

        IncorrectUserRoleError { role, expected } ->
            [ Text "Devi essere un ", Ref expected, Text " per farlo, ma sei un ", Ref role, Text "." ]

        IncorrectRoundStageError { stage, expected } ->
            [ Text "Il turno deve essere nello stato ", Ref expected, Text " per farlo, ma sei nello stato ", Ref stage, Text "." ]

        ConfigEditConflictError ->
            [ Text "Qualcun altro ha cambiato la configurazione prima di te, le tue modifiche non sono state salvate." ]

        UnprivilegedError ->
            [ Text "Non hai i privilegi per farlo." ]

        GameNotStartedError ->
            [ Text "I gioco devere essere iniziato per farlo." ]

        InvalidActionError { reason } ->
            [ Text "Il server non ha compreso una richiesta dal client. Dettagli: ", Text reason ]

        AuthenticationError ->
            [ Text "Non puoi partecipare a quel gioco." ]

        IncorrectIssuerError ->
            [ Text "Le tue credenziali per partecipare a questo gioco sono obsolete, il gioco non esiste più." ]

        InvalidAuthenticationError ->
            [ Text "Le tue credenziali per partecipare a questo gioco sono corrotte." ]

        InvalidLobbyPasswordError ->
            [ Text "La password di gioco che hai fornito è sbagliata. Prova a scriverla di nuovo e, se non funziona ancora, chiedila di nuovo a chi ti ha invitato." ]

        AlreadyLeftError ->
            [ Text "Hai già abbandonato questo gioco." ]

        LobbyNotFoundError ->
            [ Text "Il gioco non esiste." ]

        LobbyClosedError { gameCode } ->
            [ Text "Il gioco a cui vuoi partecipare (", Ref (GameCode { code = gameCode }), Text ") è terminato." ]

        LobbyDoesNotExistError { gameCode } ->
            [ Text "Il codice di gioco che hai inserito ("
            , Ref (GameCode { code = gameCode })
            , Text ") non esiste. "
            , Text "Prova a scriverlo di nuovo e, se non funziona ancora, chiedilo di nuovo a chi ti ha invitato."
            ]

        RegistrationError ->
            [ Text "Problema mentre si entrava nel gioco." ]

        UsernameAlreadyInUseError { username } ->
            [ Text "Qualcuno sta già utilizzando il nome utente “"
            , Text username
            , Text "”—provane uno diverso."
            ]

        GameError ->
            [ Text "Qualcosa è andato storto nel gioco." ]

        OutOfCardsError ->
            [ Text "Non c’erano abbastanza carte nel mazzo per dare a tutti una mano! Prova ad aggiungere altri mazzi nella configurazione del gioco." ]

        -- Language Names
        English ->
            [ Text "Inglese" ]

        BritishEnglish ->
            [ Text "Inglese (Britannico)" ]

        Italian ->
            [ Text "Italiano" ]

        BrazilianPortuguese ->
            [ Text "Portoghese (Brasiliano)" ]


an : Maybe Int -> String
an amount =
    case amount of
        Just 1 ->
            "un "

        _ ->
            ""


a : Maybe Int -> String
a amount =
    case amount of
        Just 1 ->
            "un "

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
            "due"

        3 ->
            "tre"

        4 ->
            "quattro"

        5 ->
            "cinque"

        6 ->
            "sei"

        7 ->
            "sette"

        8 ->
            "otto"

        9 ->
            "nove"

        10 ->
            "dieci"

        11 ->
            "undici"

        12 ->
            "dodici"

        other ->
            String.fromInt other
