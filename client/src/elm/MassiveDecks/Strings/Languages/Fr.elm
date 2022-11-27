module MassiveDecks.Strings.Languages.Fr exposing (pack)

{-| French localization.

Contributors:

  - antoinedelia <https://github.com/antoinedelia>

-}

import MassiveDecks.Card.Source.BuiltIn.Model as BuiltIn
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Strings exposing (MdString(..), Noun(..), Quantity(..))
import MassiveDecks.Strings.Languages.Model exposing (Language(..))
import MassiveDecks.Strings.Translation as Translation
import MassiveDecks.Strings.Translation.Model as Translation exposing (Result(..))


pack : Translation.Pack
pack =
    Translation.pack
        { lang = Fr
        , code = "fr"
        , name = French
        , translate = translate
        , recommended = "cah-base-en" |> BuiltIn.hardcoded |> Source.BuiltIn
        }


{-| The French translation
-}


translate : Maybe never -> MdString -> List (Translation.Result never)
translate _ mdString =
    case mdString of
        -- General
        MassiveDecks ->
            [ Text "Massive Decks" ]

        Close ->
            [ Text "Fermer" ]

        Noun { noun, quantity } ->
            case quantity of
                Quantity 1 ->
                    case noun of
                        Call ->
                            [ Text "Carte Noire" ]

                        Response ->
                            [ Text "Carte Blanche" ]

                        Point ->
                            [ Text "Point" ]

                        Player ->
                            [ Text "Joueur" ]

                        Spectator ->
                            [ Text "Spectateur" ]

                _ ->
                    case noun of
                        Call ->
                            [ Text "Cartes Noires" ]

                        Response ->
                            [ Text "Cartes Blanches" ]

                        Point ->
                            [ Text "Points" ]

                        Player ->
                            [ Text "Joueurs" ]

                        Spectator ->
                            [ Text "Spectateur" ]

        -- Start screen.
        Version { clientVersion, serverVersion } ->
            let
                quote version =
                    [ Text "“", Text version, Text "”" ]
            in
            List.concat
                [ [ Text "Version " ]
                , clientVersion |> quote
                , [ Text " / " ]
                , serverVersion |> Maybe.map quote |> Maybe.withDefault []
                ]

        ShortGameDescription ->
            [ Text "Un party game humoristique." ]

        WhatIsThis ->
            [ Text "Qu'est-ce que ", ref MassiveDecks, Text "?" ]

        GameDescription ->
            [ ref MassiveDecks
            , Text " est un party game humoristique basé sur "
            , ref CardsAgainstHumanity
            , Text ", développé par "
            , ref RereadGames
            , Text " et d'autres contributeurs — le jeu est open source sous "
            , ref License
            , Text ", ce qui vous permet d'améliorer le jeu, accéder au code source, ou simplement à en savoir plus sur "
            , ref MDProject
            , Text "."
            ]

        NewGame ->
            [ Text "Nouveau" ]

        NewGameDescription ->
            [ Text "Démarrer une nouvelle partie de ", ref MassiveDecks, Text "." ]

        FindPublicGame ->
            [ Text "Chercher" ]

        JoinPrivateGame ->
            [ Text "Rejoindre" ]

        JoinPrivateGameDescription ->
            [ Text "Rejoindre une partie à laquelle vous avez été invité." ]

        PlayGame ->
            [ Text "Jouer" ]

        AboutTheGame ->
            [ Text "À propos" ]

        AboutTheGameDescription ->
            [ Text "En savoir plus sur ", ref MassiveDecks, Text "." ]

        MDLogoDescription ->
            [ Text "Une ", ref (noun Call 1), Text " et une ", ref (noun Response 1), Text " marquées avec un “M” et un “D”." ]

        RereadLogoDescription ->
            [ Text "Un livre encerclé par une flèche circulaire." ]

        MDProject ->
            [ Text "le projet GitHub" ]

        License ->
            [ Text "la license AGPLv3" ]

        DevelopedByReread ->
            [ Text "Développé par ", ref RereadGames, Text "." ]

        RereadGames ->
            [ Text "Reread Games" ]

        NameLabel ->
            [ Text "Votre nom" ]

        NameInUse ->
            [ Text "Quelqu'un utilise déjà ce nom dans la partie. Veuillez en choisir un autre." ]

        RejoinTitle ->
            [ Text "Rejoindre une partie" ]

        RejoinGame { code } ->
            [ Text "Rejoindre “", GameCode { code = code } |> ref, Text "”." ]

        LobbyRequiresPassword ->
            [ Text "Vous avez besoin d'un mot de passe pour rejoindre cette partie. Essayez de demander à la personne qui vous a invité." ]

        YouWereKicked ->
            [ Text "Vous avez été expulsé de la partie." ]

        ScrollToTop ->
            [ Text "Faire défiler vers le haut." ]

        Copy ->
            [ Text "Copier" ]

        -- Rules
        CardsAgainstHumanity ->
            [ Text "Cards Against Humanity" ]

        Rules ->
            [ Text "Comment jouer." ]

        RulesHand ->
            [ Text "Chaque joueur a une main de ", ref (nounUnknownQuantity Response), Text "." ]

        RulesCzar ->
            [ Text "Le premier joueur commence en tant que "
            , ref Czar
            , Text ". Le "
            , ref Czar
            , Text " lit la question ou la phrase à compléter de la "
            , ref (noun Call 1)
            , Text " à haute voix."
            ]

        RulesPlaying ->
            [ Text "Tous les autres répondent à la question ou remplissent les blancs en choisissant une "
            , ref (noun Response 1)
            , Text " de leur main."
            ]

        RulesJudging ->
            [ Text "Les réponses sont ensuite mélangées et le "
            , ref Czar
            , Text " les lit aux autres joueurs. Pour un meilleur effet, le "
            , ref Czar
            , Text " peut lire de nouveau la "
            , ref (noun Call 1)
            , Text " avant de présenter chaque réponse. Le "
            , ref Czar
            , Text " choisit ensuite la meilleur réponse, et celui l'ayant jouée remporte un "
            , ref (noun Point 1)
            , Text "."
            ]

        RulesPickTitle ->
            [ ref (Pick { numberOfCards = 2 }) ]

        RulesPick ->
            [ Text "Certaines cartes nécessitent plus d'une "
            , ref (noun Response 1)
            , Text " comme réponse. Jouez les cartes dans l'ordre que le "
            , ref Czar
            , Text " devrait les lire."
            ]

        ExamplePickDescription ->
            [ ref (nounUnknownQuantity Call)
            , Text " comme celle-ci requièrent de choisir davantage de "
            , ref (nounUnknownQuantity Response)
            , Text ", mais vous en aurez plus dans votre main."
            ]

        RulesDraw ->
            [ Text "Certaines "
            , ref (nounUnknownQuantity Call)
            , Text " ont besoin d'encore plus de "
            , ref (nounUnknownQuantity Response)
            , Text ". Celles-ci indiqueront "
            , ref (Draw { numberOfCards = 2 })
            , Text " ou plus, et vous aurez d'autant plus de cartes avant de jouer."
            ]

        GameRulesTitle ->
            [ Text "Règles du jeu" ]

        HouseRulesTitle ->
            [ Text "Règles personnalisables" ]

        HouseRules ->
            [ Text "Vous pouvez changer la manière de jouer au jeu de multiples façons. Pendant la configuration de la partie, choisissez "
            , Text "autant de règles que vous le souhaitez."
            ]

        HouseRuleReboot ->
            [ Text "Reboot de l'univers" ]

        HouseRuleRebootDescription { cost } ->
            [ Text "À n'importe quel moment, les joueurs peuvent échanger "
            , Text (an cost)
            , ref (nounMaybe Point cost)
            , Text " pour défausser leur main et en piocher une nouvelle."
            ]

        HouseRuleRebootAction { cost } ->
            [ Text "Utiliser "
            , Text (asWord cost)
            , Text " "
            , ref (noun Point cost)
            , Text " pour défausser votre main et en piocher une nouvelle."
            ]

        HouseRuleRebootCost ->
            [ Text "Coût en ", ref (nounUnknownQuantity Point) ]

        HouseRuleRebootCostDescription ->
            [ Text "Combien de ", ref (nounUnknownQuantity Point), Text " sont nécessaires pour avoir une nouvelle main." ]

        HouseRulePackingHeat ->
            [ Text "Livraison Express" ]

        HouseRulePackingHeatDescription ->
            [ Text "Toutes les "
            , ref (nounUnknownQuantity Call)
            , Text " avec "
            , ref (Pick { numberOfCards = 2 })
            , Text " ont aussi "
            , ref (Draw { numberOfCards = 1 })
            , Text ", de manière à ce que tout le monde ait plus d'options."
            ]

        HouseRuleComedyWriter ->
            [ Text "Comique Apprenti" ]

        HouseRuleComedyWriterDescription ->
            [ Text "Ajoute une "
            , ref (nounUnknownQuantity Response)
            , Text " vide où chaque joueur peut écrire sa propre réponse."
            ]

        HouseRuleComedyWriterNumber ->
            [ ref (nounUnknownQuantity Response), Text " vides" ]

        HouseRuleComedyWriterNumberDescription ->
            [ Text "Le nombre de "
            , ref (nounUnknownQuantity Response)
            , Text " à ajouter dans le jeu."
            ]

        HouseRuleComedyWriterExclusive ->
            [ ref (nounUnknownQuantity Response), Text " vides uniquement" ]

        HouseRuleComedyWriterExclusiveDescription ->
            [ Text "Si cette option est activée, toutes les "
            , ref (nounUnknownQuantity Response)
            , Text " seront ignorées, et le jeu sera uniquement composé de cartes vides."
            ]

        HouseRuleRandoCardrissian ->
            [ Text "Aléa Toire" ]

        HouseRuleRandoCardrissianDescription ->
            [ Text "Chaque round, la première "
            , ref (noun Response 1)
            , Text " du deck sera jouée comme une réponse. Ce coup appartient à une joueuse robot appelée "
            , Text "Aléa Toire, et si elle gagne le jeu, tous les joueurs rentreront chez eux avec un sentiment de honte pour l'éternité."
            ]

        HouseRuleRandoCardrissianNumber ->
            [ Text "Joueurs robots" ]

        HouseRuleRandoCardrissianNumberDescription ->
            [ Text "Le nombre de joueurs robots qui seront dans la partie." ]

        HouseRuleNeverHaveIEver ->
            [ Text "J'ai jamais" ]

        HouseRuleNeverHaveIEverDescription ->
            [ Text "À tout moment, un joueur peut se défausser de cartes qu'il ne comprend pas. Il devra cependant confesser son"
            , Text "ignorance : la carte est révélée aux autres joueurs."
            ]

        HouseRuleHappyEnding ->
            [ Text "Fin heureuse" ]

        HouseRuleHappyEndingDescription ->
            [ Text "Lorsque la partie se termine, les joueurs effectuent un round final avec une ", ref (noun Call 1), Text " 'Haiku'." ]

        HouseRuleCzarChoices ->
            [ Text "Le choix du ", ref Czar ]

        HouseRuleCzarChoicesDescription ->
            [ Text "Au début du round, le "
            , ref Czar
            , Text " tire plusieurs "
            , ref (nounUnknownQuantity Call)
            , Text " et en choisis une, et/ou peut avoir le choix d'en écrire une lui-même."
            ]

        HouseRuleCzarChoicesNumber ->
            [ Text "Nombre" ]

        HouseRuleCzarChoicesNumberDescription ->
            [ Text "Le nombre d'options dont dispose le ", ref Czar, Text "." ]

        HouseRuleCzarChoicesCustom ->
            [ Text "Personnalisé" ]

        HouseRuleCzarChoicesCustomDescription ->
            [ Text "Si le ", ref Czar, Text " peut écrire une carte personnalisée. Cela éliminera l'un de ses choix possibles." ]

        HouseRuleWinnersPick ->
            [ Text "Au tour du gagnant" ]

        HouseRuleWinnersPickDescription ->
            [ Text "Le vainqueur du round devient le ", ref Czar, Text " au prochain tour." ]

        SeeAlso { rule } ->
            [ Text "Voir aussi : ", ref rule ]

        MustBeMoreThanOrEqualValidationError { min } ->
            [ Text "La valeur ne doit pas être en dessous de ", Text (String.fromInt min), Text "." ]

        MustBeLessThanOrEqualValidationError { max } ->
            [ Text "La valeur ne doit pas dépasser ", Text (String.fromInt max), Text "." ]

        SetValue { value } ->
            [ Text "Définir la valeur à ", Text (String.fromInt value), Text "." ]

        CantBeEmpty ->
            [ Text "Cela ne peut être vide." ]

        SettingsTitle ->
            [ Text "Réglages" ]

        LanguageSetting ->
            [ Text "Langue" ]

        MissingLanguage ->
            [ Text "Vous ne voyez pas votre langue ? ", ref TranslationBeg ]

        AutonymFormat { autonym } ->
            [ Text "(", Text autonym, Text ")" ]

        TranslationBeg ->
            [ Text "Aidez à la traduction de "
            , ref MassiveDecks
            , Text " !"
            ]

        CardSizeSetting ->
            [ Text "Cartes compactes" ]

        CardSizeExplanation ->
            [ Text "Ajuster la taille des cartes. Cela peut s'avérer utile sur des petits écrans pour moins scroller." ]

        AutoAdvanceSetting ->
            [ Text "Passage de round automatique" ]

        AutoAdvanceExplanation ->
            [ Text "Quand un round se termine, passe automatiquement au suivant au lieu d'attendre." ]

        SpeechSetting ->
            [ Text "Synthèse vocale" ]

        SpeechExplanation ->
            [ Text "Lire les cartes en utilisant la synthèse vocale." ]

        SpeechNotSupportedExplanation ->
            [ Text "Votre navigateur ne supporte pas la synthèse vocale, ou n'a pas de voix installées." ]

        VoiceSetting ->
            [ Text "Voix de la synthèse vocale" ]

        NotificationsSetting ->
            [ Text "Notifications du navigateur" ]

        NotificationsExplanation ->
            [ Text "Vous préviens lorsque votre attention est requise dans le jeu à l'aide des notifications du navigateur."
            ]

        NotificationsUnsupportedExplanation ->
            [ Text "Votre navigateur ne supporte pas les notifications." ]

        NotificationsBrowserPermissions ->
            [ Text "Vous allez devoir autoriser "
            , ref MassiveDecks
            , Text " à pouvoir vous notifier. Cela sera uniquement utilisé tant que le jeu est ouvert et que vous avez cette option activée."
            ]

        NotificationOnlyWhenHiddenSetting ->
            [ Text "Uniquement en arrière-plan" ]

        NotificationsOnlyWhenHiddenExplanation ->
            [ Text "Envoie des notifications uniquement lorsque le jeu n'est pas au premier plan (e.g. : si vous êtes sur un autre onglet, ou si le navigateur est minimisé)." ]

        NotificationsOnlyWhenHiddenUnsupportedExplanation ->
            [ Text "Votre navigateur ne supporte pas la vérification de la visibilité des pages." ]

        -- Terms
        Czar ->
            [ Text "Tsar" ]

        CzarDescription ->
            [ Text "Le joueur qui juge pendant le round." ]

        CallDescription ->
            [ Text "Une carte noire avec une question ou une phrase à trous." ]

        ResponseDescription ->
            [ Text "Une carte blanche avec une phrase jouée pendant les rounds." ]

        PointDescription ->
            [ Text "Un point, celui qui en a le plus à la fin du jeu remporte la partie." ]

        GameCodeTerm ->
            [ Text "Code de la partie" ]

        GameCodeDescription ->
            [ Text "Un code qui permet à d'autres personnes de chercher et de rejoindre votre partie." ]

        GameCode { code } ->
            [ Text code ]

        GameCodeSpecificDescription ->
            [ Text "Donnez ce code à d'autres joueurs pour qu'ils puissent rejoindre la partie." ]

        GameCodeHowToAcquire ->
            [ Text "Demandez le ", ref GameCodeTerm, Text " à la personne qui vous a invité." ]

        Deck ->
            [ Text "Deck" ]

        DeckSource ->
            [ Text "Origine du ", ref Deck ]

        DeckLanguage { language } ->
            [ Text "en ", Text language ]

        DeckAuthor { author } ->
            [ Text "par ", Text author ]

        DeckTranslator { translator } ->
            [ Text "traduction réalisée par ", Text translator ]

        StillPlaying ->
            [ Text "En train de jouer" ]

        PlayingDescription ->
            [ Text "Ce joueur est dans le round, mais n'a pas encore joué." ]

        Played ->
            [ Text "A joué" ]

        PlayedDescription ->
            [ Text "Ce joueur a déjà joué pour ce round." ]

        -- Lobby Browser
        LobbyBrowserTitle ->
            [ Text "Parties publiques" ]

        NoPublicGames ->
            [ Text "Aucune partie publique disponible." ]

        PlayingGame ->
            [ Text "Parties en cours." ]

        SettingUpGame ->
            [ Text "Parties n'ayant pas commencé." ]

        StartYourOwn ->
            [ Text "Démarrer une nouvelle partie ?" ]

        -- Spectation
        JoinTheGame ->
            [ Text "Rejoindre la partie !" ]

        ToggleAdvertDescription ->
            [ Text "Activer l'affichage des informations en rejoignant le jeu." ]

        -- Cards
        Pick numberOfCards ->
            [ Text "Choisir", ref (NumberOfCards numberOfCards) ]

        Draw numberOfCards ->
            [ Text "Piocher", ref (NumberOfCards numberOfCards) ]

        PickDescription { numberOfCards } ->
            [ Text "Vous devez jouer "
            , Text (asWord numberOfCards)
            , Text " "
            , ref (noun Response numberOfCards)
            , Text "."
            ]

        DrawDescription { numberOfCards } ->
            [ Text "Vous recevez "
            , Text (asWord numberOfCards)
            , Text " extra "
            , ref (noun Response numberOfCards)
            , Text " avant de jouer."
            ]

        NumberOfCards { numberOfCards } ->
            [ Text (String.fromInt numberOfCards) ]

        -- Lobby
        LobbyNameLabel ->
            [ Text "Nom de la partie" ]

        DefaultLobbyName { owner } ->
            [ Text "Partie de ", Text owner ]

        Invite ->
            [ Text "Inviter des joueurs à la partie." ]

        InviteLinkHelp ->
            [ Text "Envoyer ce lien aux joueurs pour les inviter dans la partie, ou laissez-les scanner le QR code ci-dessous." ]

        InviteExplanation { gameCode, password } ->
            let
                extra =
                    password
                        |> Maybe.map
                            (\p ->
                                [ Text " et le mot de passe de la partie “"
                                , Text p
                                , Text "”"
                                ]
                            )
                        |> Maybe.withDefault []
            in
            List.concat
                [ [ Text "Votre code de partie est "
                  , ref (GameCode { code = gameCode })
                  , Text ". Les joueurs peuvent rejoindre la partie en ouvrant "
                  , ref MassiveDecks
                  , Text " et en entrant le code"
                  ]
                , extra
                , [ Text "."
                  ]
                ]

        Cast ->
            [ Text "Caster sur la TV." ]

        CastConnecting ->
            [ Text "Connexion…" ]

        CastConnected { deviceName } ->
            [ Text "Cast vers ", Text deviceName, Text "." ]

        Players ->
            [ ref (nounUnknownQuantity Player) ]

        PlayersDescription ->
            [ Text "Joueurs dans la partie." ]

        Spectators ->
            [ ref (nounUnknownQuantity Spectator) ]

        SpectatorsDescription ->
            [ Text "Utilisateurs regardant la partie." ]

        Left ->
            [ Text "Est parti" ]

        LeftDescription ->
            [ Text "Utilisateurs ayant quitté la partie." ]

        Away ->
            [ Text "Absent" ]

        AwayDescription ->
            [ Text "Cet utilisateur est actuellement absent de la partie." ]

        Disconnected ->
            [ Text "Déconnecté" ]

        DisconnectedDescription ->
            [ Text "Cet utilisateur n'est pas connecté à la partie." ]

        Privileged ->
            [ Text "Hôte" ]

        PrivilegedDescription ->
            [ Text "Cet utilisateur peut modifier les options de la partie." ]

        Ai ->
            [ Text "Bot" ]

        AiDescription ->
            [ Text "This player is controlled by the computer." ]

        Score { total } ->
            [ Text (String.fromInt total) ]

        ScoreDescription ->
            [ Text "Le nombre de "
            , ref (nounUnknownQuantity Point)
            , Text " de ce joueur."
            ]

        Likes { total } ->
            [ Text (String.fromInt total) ]

        LikesDescription ->
            [ Text "Le nombre de likes reçus."
            ]

        ToggleUserList ->
            [ Text "Montrer ou cacher le tableau des scores." ]

        GameMenu ->
            [ Text "Menu de la partie." ]

        UnknownUser ->
            [ Text "Un utilisateur inconnu" ]

        InvitePlayers ->
            [ Text "Inviter des joueurs" ]

        InvitePlayersDescription ->
            [ Text "Obtenir le code/lien/qr code de la partie pour permettre aux autres joueurs de rejoindre la partie." ]

        SetAway ->
            [ Text "Marquer comme absent" ]

        SetBack ->
            [ Text "Marquer comme de retour" ]

        LeaveGame ->
            [ Text "Quitter la partie" ]

        LeaveGameDescription ->
            [ Text "Quitter la partie définitivement." ]

        Spectate ->
            [ Text "Vue spectateur" ]

        SpectateDescription ->
            [ Text "Ouvrir la vue d'un spectateur de la partie dans un nouvel onglet/une nouvelle fenêtre." ]

        BecomeSpectator ->
            [ Text "Devenir spectateur" ]

        BecomeSpectatorDescription ->
            [ Text "Regarder la partie sans jouer." ]

        BecomePlayer ->
            [ Text "Jouer" ]

        BecomePlayerDescription ->
            [ Text "Jouer à la partie." ]

        EndGame ->
            [ Text "Terminer la partie" ]

        EndGameDescription ->
            [ Text "Termine la partie maintenant." ]

        ReturnViewToGame ->
            [ Text "Retourner dans la partie" ]

        ReturnViewToGameDescription ->
            [ Text "Retourner à la vue principale de la partie." ]

        ViewConfiguration ->
            [ Text "Configurer" ]

        ViewConfigurationDescription ->
            [ Text "Passer à la vue de configuration de la partie." ]

        KickUser ->
            [ Text "Expulser" ]

        Promote ->
            [ Text "Promouvoir" ]

        Demote ->
            [ Text "Rétrograder" ]

        -- Notifications
        UserConnected { username } ->
            [ Text username, Text " s'est reconnecté à la partie." ]

        UserDisconnected { username } ->
            [ Text username, Text " s'est déconnecté de la partie." ]

        UserJoined { username } ->
            [ Text username, Text " a rejoint la partie." ]

        UserLeft { username } ->
            [ Text username, Text " a quitté la partie." ]

        UserKicked { username } ->
            [ Text username, Text " a été expulsé de la partie." ]

        Dismiss ->
            [ Text "Supprimer" ]

        -- Configuration
        ConfigureTitle ->
            [ Text "Configuration de la partie" ]

        NoDecks ->
            [ Segment [ Text "Aucun deck. " ]
            , Text " "
            , Segment [ Text "Vous avez besoin d'au moins un deck pour débuter la partie." ]
            ]

        NoDecksHint ->
            [ Text "Un doute ? Ajouter le deck original de", raw CardsAgainstHumanity, Text " ." ]

        WaitForDecks ->
            [ Text "Les decks doivent être chargés avant de pouvoir débuter la partie." ]

        MissingCardType { cardType } ->
            [ Text "Aucun de vos decks ne contient de "
            , ref (nounUnknownQuantity cardType)
            , Text ". Vous avez besoin d'un de ces decks pour pouvoir débuter la partie."
            ]

        NotEnoughCardsOfType { cardType, needed, have } ->
            [ Text "Pour le nombre de joueurs dans cette partie, vous avez besoin d'au moins "
            , Text (needed |> String.fromInt)
            , Text " "
            , ref (noun cardType needed)
            , Text " mais vous en avez seulement "
            , Text (have |> String.fromInt)
            , Text "."
            ]

        AddBlankCards { amount } ->
            [ Text "Ajouter "
            , amount |> String.fromInt |> Text
            , ref (noun Response amount)
            , Text " vides "
            ]

        AddDeck ->
            [ Text "Ajouter un deck." ]

        RemoveDeck ->
            [ Text "Supprimer un deck." ]

        SourceNotFound { source } ->
            [ ref source, Text " ne reconnaît pas le deck que vous avez demandé. Vérifier que les informations que vous avez rentrées sont correctes." ]

        SourceServiceFailure { source } ->
            [ ref source, Text " a échoué à charger le deck. Merci d'essayer plus tard ou d'essayer avec une autre source." ]

        ManyDecks ->
            [ Text "Many Decks" ]

        ManyDecksDeckCodeTitle ->
            [ Text "Code du deck" ]

        ManyDecksDeckCodeShort ->
            [ Text "Un code de deck doit être faire au minimum cinq caractères." ]

        ManyDecksWhereToGet ->
            [ Text "Vous pouvez créer et trouver des decks sur ", ref ManyDecks, Text "." ]

        JsonAgainstHumanity ->
            [ Text "JSON Against Humanity" ]

        JsonAgainstHumanityAbout ->
            [ Text "Decks fournis par ", ref JsonAgainstHumanity ]

        BuiltIn ->
            [ Text "Intégré" ]

        APlayer ->
            [ Text "Un joueur" ]

        Generated { by } ->
            [ Text "Genéré par ", ref by ]

        DeckAlreadyAdded ->
            [ Text "Ce deck est déjà dans la partie." ]

        ConfigureDecks ->
            [ Text "Decks" ]

        ConfigureRules ->
            [ Text "Règles" ]

        ConfigureTimeLimits ->
            [ Text "Limites de temps" ]

        ConfigurePrivacy ->
            [ Text "Confidentialité" ]

        HandSize ->
            [ Text "Taille de la main" ]

        HandSizeDescription ->
            [ Text "Le nombre de cartes dont chaque joueur dispose durant la partie." ]

        ScoreLimit ->
            [ Text "Limite de ", ref (nounUnknownQuantity Point) ]

        ScoreLimitDescription ->
            [ Segment
                [ Text "Le nombre de "
                , ref (nounUnknownQuantity Point)
                , Text " dont un joueur a besoin pour gagner la partie."
                ]
            , Text " "
            , Segment [ Text "Si désactivé, la partie continue indéfiniment." ]
            ]

        UnsavedChangesWarning ->
            [ Text "Vous avez des modifications en cours, elles doivent être sauvegardées si vous voulez les appliquer "
            , Text "à la partie."
            ]

        SaveChanges ->
            [ Text "Sauvegarder les modifications." ]

        RevertChanges ->
            [ Text "Ignorer les modifications en cours." ]

        NeedAtLeastOneDeck ->
            [ Text "Vous avez besoin d'un deck de cartes pour débuter la partie." ]

        NeedAtLeastThreePlayers ->
            [ Text "Vous avez besoin d'au minimum trois joueurs pour débuter la partie." ]

        NeedAtLeastOneHuman ->
            [ Text "Malheureusement, les bots ne peuvent pas être le "
            , ref Czar
            , Text ", vous avez donc besoin au minimum d'un joueur humain pour débuter la partie."
            , Text " (Bien qu'un seul humain risque d'être un peu ennuyant !)"
            ]

        RandoCantWrite ->
            [ Text "Les bots ne peuvent pas écrire leurs propres cartes." ]

        DisableComedyWriter ->
            [ Text "Désactiver ", ref HouseRuleComedyWriter ]

        DisableRando ->
            [ Text "Désactiver ", ref HouseRuleRandoCardrissian ]

        AddAnAiPlayer ->
            [ Text "Ajouter un bot à la partie." ]

        PasswordShared ->
            [ Text "N'importe qui dans la partie peut voir le code ! "
            , Text "Le cacher ne s'appliquera qu'à vous (utile pour les streamers, etc.)."
            ]

        PasswordNotSecured ->
            [ Text "Les mots de passe de partie "
            , Em [ Text "ne sont pas" ]
            , Text " stockés de manière sécurisés. Sachant cela, vous êtes priés de "
            , Em [ Text "ne pas" ]
            , Text " utiliser un de vos mots de passe personnel !"
            ]

        LobbyPassword ->
            [ Text "Mot de passe de la partie" ]

        LobbyPasswordDescription ->
            [ Text "Le mot de passe que les utilisateurs doivent rentrer pour rejoindre la partie." ]

        AudienceMode ->
            [ Text "Mode audience" ]

        AudienceModeDescription ->
            [ Text "Si activé, les nouveaux utilisateurs seront spectateurs par défaut, et vous seul serez capable de "
            , Text "les faire devenir joueurs."
            ]

        StartGame ->
            [ Text "Démarrer la partie" ]

        Public ->
            [ Text "Partie publique" ]

        PublicDescription ->
            [ Text "Si activé, la partie sera présente dans la liste des parties publiques en cours." ]

        ApplyConfiguration ->
            [ Text "Appliquer les modifications." ]

        AppliedConfiguration ->
            [ Text "Sauvegardé." ]

        InvalidConfiguration ->
            [ Text "Cette valeur de configuration n'est pas valide." ]

        Automatic ->
            [ Text "Automatiquement marquer les joueurs comme absent" ]

        AutomaticDescription ->
            [ Text "Si activé, quand la limite de temps est atteinte, les joueurs seront automatiquement marqués comme absent. "
            , Text "Sinon, quelqu'un devra appuyer sur le bouton pour le faire."
            ]

        TimeLimit { stage } ->
            [ Text "Temps limite ", ref stage ]

        StartingTimeLimitDescription ->
            [ Text "De combien de temps (en secondes) dispose le "
            , ref Czar
            , Text " pour choisir/écrire une "
            , ref (noun Call 1)
            , Text ", quand "
            , raw HouseRuleCzarChoices
            , Text " est activé."
            ]

        PlayingTimeLimitDescription ->
            [ Text "Combien de temps (en secondes) disposent les ", ref Players, Text " pour jouer." ]

        PlayingAfterDescription ->
            [ Text "Combien de temps (en secondes) disposent les joueurs pour changer leur jeu avant le prochain round." ]

        RevealingTimeLimitDescription ->
            [ Text "Combien de temps (en secondes) dispose le ", ref Czar, Text " pour révéler les réponses." ]

        RevealingAfterDescription ->
            [ Text "Combien de temps (en secondes) entre la révélation de la dernière réponse et le début du prochain round." ]

        JudgingTimeLimitDescription ->
            [ Text "Combien de temps (en secondes) dispose le ", ref Czar, Text " pour juger les réponses." ]

        CompleteTimeLimitDescription ->
            [ Text "Combien de temps (en secondes) entre la fin du round et le début du prochain round." ]

        RevealingEnabledTitle ->
            [ Text "Le Tsar dévoile les réponses" ]

        RevealingEnabled ->
            [ Text "Si activé, le "
            , ref Czar
            , Text " dévoile une réponse à la fois avant de choisir un gagnant."
            ]

        DuringTitle ->
            [ Text "Limite de temps" ]

        AfterTitle ->
            [ Text "Suite" ]

        Conflict ->
            [ Text "Conflit" ]

        ConflictDescription ->
            [ Text "Quelqu'un d'autre a réalisé des modifications en même temps que vous. "
            , Text "Veuillez choisir si vous désirez conserver vos changements, ou les siens."
            ]

        YourChanges ->
            [ Text "Vos changements" ]

        TheirChanges ->
            [ Text "Ses changements" ]

        ConfigurationDisabledWhileInGame ->
            [ Text "Lorsque la partie est en cours, vous ne pouvez pas modifier la configuration." ]

        ConfigurationDisabledIfNotPrivileged ->
            [ Text "Vous ne pouvez pas modifier la configuration de cette partie." ]

        ConfigureNextGame ->
            [ Text "Configurer la partie suivante" ]

        -- Game
        PickCall ->
            [ Text "Choisir cette ", ref (noun Call 1), Text " à proposer aux autres joueurs pour ce round." ]

        WriteCall ->
            [ Text "Écrire une ", ref (noun Call 1), Text " personnalisée à proposer aux autres joueurs pour ce round." ]

        SubmitPlay ->
            [ Text "Proposer ces cartes au ", ref Czar, Text " comme votre réponse pour ce round." ]

        TakeBackPlay ->
            [ Text "Récupérer vos cartes pour changer votre réponse pour ce round." ]

        JudgePlay ->
            [ Text "Choisir cette réponse comme étant la meilleur du round." ]

        LikePlay ->
            [ Text "Ajouter un like à cette réponse." ]

        AdvanceRound ->
            [ Text "Round suivant." ]

        Starting ->
            [ raw HouseRuleCzarChoices ]

        Playing ->
            [ Text "En train de jouer" ]

        Revealing ->
            [ Text "En train de révéler" ]

        Judging ->
            [ Text "En train de juger" ]

        Complete ->
            [ Text "Terminé" ]

        ViewGameHistoryAction ->
            [ Text "Voir les précédents rounds de cette partie." ]

        ViewHelpAction ->
            [ Text "Aide" ]

        EnforceTimeLimitAction ->
            [ Text "Marquer tous les joueurs en attente comme absents et les ignorer jusqu'à leur retour." ]

        Blank ->
            [ Text "Espace vide" ]

        RoundStarted ->
            [ Text "Début du round" ]

        JudgingStarted ->
            [ Text "Le jugement a commencé" ]

        Paused ->
            [ Text "La partie a été mise en pause car il n'y a pas assez de joueurs actifs pour continuer."
            , Text "Lorsque que quelqu'un rejoint ou se reconnecte, la partie continuera automatiquement."
            ]

        ClientAway ->
            [ Text "Vous êtes actuellement marqué comme absent de la partie, et ne jouez pas." ]

        Discard ->
            [ Text "Défausse la carte sélectionnée, la révélant aux autres utilisateurs de la partie." ]

        Discarded { player } ->
            [ Text player
            , Text " a défaussé la carte suivante :"
            ]

        -- Instructions
        PickCallInstruction ->
            [ Text "Choisissez une ", ref (noun Call 1), Text " à jouer pour ce round." ]

        WaitForCallInstruction ->
            [ Text "Vous attendez que le "
            , ref Czar
            , Text " choisisse une "
            , ref (noun Call 1)
            , Text " pour pouvoir jouer."
            ]

        PlayInstruction { numberOfCards } ->
            [ Text "Vous devez choisir "
            , Text (asWord numberOfCards)
            , Text " "
            , ref (noun Response numberOfCards)
            , Text " de plus de votre main avant de pouvoir soumettre votre réponse pour ce round."
            ]

        SubmitInstruction ->
            [ Text "Vous devez soumettre votre réponse pour ce round." ]

        WaitingForPlaysInstruction ->
            [ Text "Vous attendez la réponse des autres joueurs pour ce round." ]

        CzarsDontPlayInstruction ->
            [ Text "Vous êtes le "
            , ref Czar
            , Text " pour ce round - vous ne soumettez pas de "
            , ref (nounUnknownQuantity Response)
            , Text ". À la place, vous choisissez le gagnant une fois que tous les joueurs ont joué leur réponse."
            ]

        NotInRoundInstruction ->
            [ Text "Vous n'êtes pas dans ce round. Vous jouerez au prochain round, sauf si vous êtes marqués comme absent." ]

        RevealPlaysInstruction ->
            [ Text "Cliquez sur les réponses pour les révéler, et choisissez ensuite celle qui vous semble être la meilleure." ]

        WaitingForCzarInstruction ->
            [ Text "Vous pouvez liker des réponses pendant que vous attendez que le ", ref Czar, Text " révèle les réponses et choisisse un gagnant pour ce round." ]

        AdvanceRoundInstruction ->
            [ Text "Le prochain round a commencé, vous pouvez continuer." ]

        -- 404 Unknown
        UnknownPageTitle ->
            [ Text "Erreur 404 : Page inconnue." ]

        GoBackHome ->
            [ Text "Revenir à la page principale." ]

        -- Actions
        Refresh ->
            [ Text "Rafraîchir" ]

        Accept ->
            [ Text "OK" ]

        -- Editor
        AddSlot ->
            [ Text "Ajouter ", ref Blank ]

        AddText ->
            [ Text "Ajouter texte" ]

        EditText ->
            [ Text "Éditer" ]

        EditSlotIndex ->
            [ Text "Éditer" ]

        MoveLeft ->
            [ Text "Déplacer avant" ]

        Remove ->
            [ Text "Supprimer" ]

        MoveRight ->
            [ Text "Déplacer après" ]

        Normal ->
            [ Text "Normal" ]

        Capitalise ->
            [ Text "Première lettre en majuscule" ]

        UpperCase ->
            [ Text "Tout en majuscules" ]

        Emphasise ->
            [ Text "Souligner" ]

        MustContainAtLeastOneSlot ->
            [ Text "Vous devez avoir au moins un ", ref Blank, Text " pour que les joueurs puissent jouer." ]

        SlotIndexExplanation ->
            [ Text "Combien de "
            , ref (noun nounUnknownQuantity Response)
            , Text " seront nécessaires pour cet "
            , ref Blank
            , Text ". Cela vous permettra de répéter une même  "
            , ref (noun Response 1)
            , Text "."
            ]

        -- Errors
        Error ->
            [ Text "Erreur" ]

        ErrorHelp ->
            [ Text "Le serveur de jeu est peut-être en panne, ou il s'agit peut-être d'un bug. Rafraîchir la page devrait vous "
            , Text "aider. Plus d'informations ci-dessous."
            ]

        ErrorHelpTitle ->
            [ Text "Désolé, nous avons rencontré un problème." ]

        ErrorCheckOutOfBand ->
            [ Text "S'il vous plaît, visiter ", ref TwitterHandle, Text " pour des informations de mise à jour et d'état du service. Le serveur de jeu sera coupé pendant un court instant quand une nouvelle version est disponible, donc si vous voyez une mise à jour récente, veuillez réessayer d'ici quelques minutes." ]

        TwitterHandle ->
            [ Text "@Massive_Decks" ]

        ReportError ->
            [ Text "Signaler un bug" ]

        ReportErrorDescription ->
            [ Text "Signaler un bug que vous avez rencontré aux développeurs pour qu'ils puissent le résoudre." ]

        ReportErrorBody ->
            [ Text "J'étais en train de [remplacer avec une courte description de ce que vous étiez en train de faire] quand j'ai rencontré cette erreur :" ]

        BadUrlError ->
            [ Text "Nous avons essayé de faire une requête vers une page non valide." ]

        TimeoutError ->
            [ Text "Le serveur n'a pas répondu depuis un moment. Il est peut-être hors-ligne, veuillez réessayer dans quelques instants." ]

        NetworkError ->
            [ Text "Votre connexion internet a été interrompue." ]

        ServerDownError ->
            [ Text "Le serveur de jeu est actuellement hors-ligne. Veuillez réessayer plus tard." ]

        BadStatusError ->
            [ Text "Le serveur a renvoyé une réponse inattendue." ]

        BadPayloadError ->
            [ Text "Le serveur a renvoyé une réponse que nous n'avons pas compris." ]

        PatchError ->
            [ Text "Le serveur a renvoyé un patch que nous n'avons pas pu appliquer." ]

        VersionMismatch ->
            [ Text "Le serveur a renvoyé un changement de configuration pour une version différente de celle attendue." ]

        CastError ->
            [ Text "Désolé, un problème a été rencontré lors de la connexion à la partie." ]

        ActionExecutionError ->
            [ Text "Vous ne pouvez pas réaliser cette action." ]

        IncorrectPlayerRoleError { role, expected } ->
            [ Text "Vous devez être un ", ref expected, Text " pour faire cela, mais vous êtes un ", ref role, Text "." ]

        IncorrectUserRoleError { role, expected } ->
            [ Text "Vous devez être un ", ref expected, Text " pour faire cela, mais vous êtes un ", ref role, Text "." ]

        IncorrectRoundStageError { stage, expected } ->
            [ Text "Le round doit être au stade ", ref expected, Text " pour pouvoir faire cela, mais il est au stage ", ref stage, Text "." ]

        ConfigEditConflictError ->
            [ Text "Quelqu'un d'autre a changé la configuration avant vous, vos changements n'ont pas été sauvegardés." ]

        UnprivilegedError ->
            [ Text "Vous n'avez pas la permission de faire cela." ]

        GameNotStartedError ->
            [ Text "La partie doit être démarrée pour pouvoir faire ça." ]

        InvalidActionError { reason } ->
            [ Text "Le serveur n'a pas compris une requête du client. Détails : ", Text reason ]

        AuthenticationError ->
            [ Text "Vous ne pouvez pas rejoindre la partie." ]

        IncorrectIssuerError ->
            [ Text "Vos identifiants pour rejoindre la partie sont obsolètes, la partie n'existe plus." ]

        InvalidAuthenticationError ->
            [ Text "Vos identifiants pour rejoindre la partie sont corrompus." ]

        InvalidLobbyPasswordError ->
            [ Text "Le mot de passe de la partie fourni est incorrect. Veuillez l'entrer à nouveau et si cela ne fonctionne toujours pas, demandez à nouveau à la personne qui vous a invité." ]

        AlreadyLeftError ->
            [ Text "Vous avez déjà quitté la partie." ]

        LobbyNotFoundError ->
            [ Text "Cette partie n'existe pas." ]

        LobbyClosedError { gameCode } ->
            [ Text "La partie que vous souhaitez rejoindre (", ref (GameCode { code = gameCode }), Text ") est terminée." ]

        LobbyDoesNotExistError { gameCode } ->
            [ Text "Le code de jeu que vous avez entré ("
            , ref (GameCode { code = gameCode })
            , Text ") n'existe pas. "
            , Text "Veuillez l'entrer à nouveau et si cela ne fonctionne toujours pas, demandez à nouveau à la personne qui vous a invité."
            ]

        RegistrationError ->
            [ Text "Problème lors de la connexion à la partie." ]

        UsernameAlreadyInUseError { username } ->
            [ Text "Quelqu'un utilise déjà le nom d'utilisateur “"
            , Text username
            , Text "”. Essayez avec un autre nom."
            ]

        GameError ->
            [ Text "Une erreur s'est produite dans la partie." ]

        OutOfCardsError ->
            [ Text "Il n'y avait pas assez de cartes dans le deck pour distribuer une main à chaque joueur ! Essayez d'ajouter plus de decks dans la configuration de la partie." ]

        -- Language Names
        English ->
            [ Text "Anglais" ]

        BritishEnglish ->
            [ Text "Anglais (Britanique)" ]

        Italian ->
            [ Text "Italien" ]

        BrazilianPortuguese ->
            [ Text "Portugais (Brésilien)" ]

        German ->
            [ Text "Allemand (formel)" ]

        GermanInformal ->
            [ Text "Allemand (informel)" ]

        Polish ->
            [ Text "Polonais" ]

        Indonesian ->
            [ Text "Indonésien" ]

        Spanish ->
            [ Text "Espagnol" ]

        Korean ->
            [ Text "Coréen" ]

        French ->
            [ Text "Français" ]



{- Private -}


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
            "un"

        2 ->
            "deux"

        3 ->
            "trois"

        4 ->
            "quatre"

        5 ->
            "cinq"

        6 ->
            "six"

        7 ->
            "sept"

        8 ->
            "huit"

        9 ->
            "neuf"

        10 ->
            "dix"

        11 ->
            "onze"

        12 ->
            "douze"

        other ->
            String.fromInt other
