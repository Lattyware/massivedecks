module MassiveDecks.Strings.Languages.DeXInformal exposing (pack)

{-| German (Informal) localization.

Contributors:

  - rfuehrer <https://github.com/rfuehrer>

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
        { lang = DeXInformal
        , code = "de-x-informal"
        , name = GermanInformal
        , translate = translate
        , recommended = "cah-base-de" |> BuiltIn.hardcoded |> Source.BuiltIn
        }



{- Private -}


raw : MdString -> Translation.Result never
raw =
    Raw Nothing


ref : MdString -> Translation.Result never
ref =
    Ref Nothing


{-| The German informal translation
-}
translate : Maybe Never -> MdString -> List (Translation.Result Never)
translate _ mdString =
    case mdString of
        -- General
        MassiveDecks ->
            [ Text "Massive Decks" ]

        Close ->
            [ Text "Schließen" ]

        -- Special
        Noun { noun, quantity } ->
            case quantity of
                Quantity 1 ->
                    case noun of
                        Call ->
                            [ Text "Schwarze Karte" ]

                        Response ->
                            [ Text "Weiße Karte" ]

                        Point ->
                            [ Text "großartiger Punkt" ]

                        Player ->
                            [ Text "Spieler" ]

                        Spectator ->
                            [ Text "Zuschauer" ]

                _ ->
                    case noun of
                        Call ->
                            [ Text "schwarze Karten" ]

                        Response ->
                            [ Text "weiße Karten" ]

                        Point ->
                            [ Text "großartige Punkte" ]

                        Player ->
                            [ Text "Spieler" ]

                        Spectator ->
                            [ Text "Zuschauer" ]

        -- Start screen.
        Version { versionNumber } ->
            [ Text "Version “", Text versionNumber, Text "”" ]

        ShortGameDescription ->
            [ Text "Ein lustiges Party-Spiel." ]

        WhatIsThis ->
            [ Text "Was ist ", ref MassiveDecks, Text "?" ]

        GameDescription ->
            [ ref MassiveDecks
            , Text "  ist ein lustiges Partyspiel basierend auf "
            , ref CardsAgainstHumanity
            , Text ", entwickelt von "
            , ref RereadGames
            , Text " und andere Mitwirkende - das Spiel ist Open Source unter "
            , ref License
            , Text ", damit Du helfen kannst, das Spiel zu verbessern, auf den Quellcode zuzugreifen oder einfach mehr unter "
            , ref MDProject
            , Text "."
            ]

        NewGame ->
            [ Text "Neu" ]

        NewGameDescription ->
            [ Text "Beginne ein neues Spiel ", ref MassiveDecks, Text "." ]

        FindPublicGame ->
            [ Text "Suchen" ]

        JoinPrivateGame ->
            [ Text "Teilnehmen" ]

        JoinPrivateGameDescription ->
            [ Text "Nimm an einem Spiel teil, zu dem Du eingeladen wurdest." ]

        PlayGame ->
            [ Text "Spielen" ]

        AboutTheGame ->
            [ Text "Über" ]

        AboutTheGameDescription ->
            [ Text "Informiere Dich über ", ref MassiveDecks, Text " und wie es entwickelt wurde." ]

        MDLogoDescription ->
            [ Text "Eine ", ref (noun Call 1), Text " und eine ", ref (noun Response 1), Text " mit einem “M” un einem “D” beschriftet." ]

        RereadLogoDescription ->
            [ Text "Ein von einem Recycling-Pfeil umkreistes Buch." ]

        MDProject ->
            [ Text "dem GitHub-Projekt" ]

        License ->
            [ Text "AGPLv3-Lizenz" ]

        DevelopedByReread ->
            [ Text "Entwickelt von ", ref RereadGames, Text "." ]

        RereadGames ->
            [ Text "Reread Games" ]

        NameLabel ->
            [ Text "Dein Name" ]

        NameInUse ->
            [ Text "Jemand anderes benutzt diesen Namen in dem angegeben Spiel - bitte versuche es mit einem anderen Namen." ]

        RejoinTitle ->
            [ Text "Zurück zum Spiel" ]

        RejoinGame { code } ->
            [ Text "Zurück zu “", GameCode { code = code } |> ref, Text "”." ]

        LobbyRequiresPassword ->
            [ Text "Du benötigst ein Passwort, um an diesem Spiel teilzunehmen. Versuche, die Person danach zu fragen, die Dich eingeladen hat." ]

        YouWereKicked ->
            [ Text "Du wurdest aus dem Spiel geworfen." ]

        ScrollToTop ->
            [ Text "Blättere zum Anfang." ]

        Copy ->
            [ Text "Kopieren" ]

        -- Rules
        CardsAgainstHumanity ->
            [ Text "Cards Against Humanity" ]

        Rules ->
            [ Text "Wie man spielt." ]

        RulesHand ->
            [ Text "Jeder Spieler hat ein Blatt ", ref (nounUnknownQuantity Response), Text "." ]

        RulesCzar ->
            [ Text "Der erste Spieler beginnt als "
            , ref Czar
            , Text ". Der "
            , ref Czar
            , Text " liest die Frage oder den leeren Satz auf der "
            , ref (noun Call 1)
            , Text " laut vor."
            ]

        RulesPlaying ->
            [ Text "Alle anderen beantworten die Frage oder füllen den Lückentext aus, indem Du eine "
            , ref (noun Response 1)
            , Text " aus Deiner Hand auswählst."
            ]

        RulesJudging ->
            [ Text "Die Antworten werden dann gemischt und der "
            , ref Czar
            , Text " liest die Karten den anderen Spielern vor - für die volle Wirkung liest der "
            , ref Czar
            , Text " die "
            , ref (noun Call 1)
            , Text " laut vor, bevor jede Antwort einzeln aufgedeckt wird. Der "
            , ref Czar
            , Text " wählt dann die lustigste Antwort aus und der jeweilige Spieler erhält einen "
            , ref (noun Point 1)
            , Text "."
            ]

        RulesPickTitle ->
            [ ref (Pick { numberOfCards = 2 }) ]

        RulesPick ->
            [ Text "Einige Karten benötigen mehr als eine "
            , ref (noun Response 1)
            , Text " als Antwort. Spiele die Karten in der Reihenfolge, wie der "
            , ref Czar
            , Text " sie vorlesen soll - die Reihenfolge ist bei diesen Karten entscheidend."
            ]

        ExamplePickDescription ->
            [ ref (nounUnknownQuantity Call)
            , Text " wie diese erfordern die Auswahl von mehreren "
            , ref (nounUnknownQuantity Response)
            , Text ", die Dir ergänzend zur Verfügung gestellt werden."
            ]

        RulesDraw ->
            [ Text "Einige "
            , ref (nounUnknownQuantity Call)
            , Text " benötigen mehrere "
            , ref (nounUnknownQuantity Response)
            , Text "— diese sind mit "
            , ref (Draw { numberOfCards = 2 })
            , Text " oder mehr beschriftet. Die Spieler erhalten entsprechend viele zusätzliche Karten für ihre Hand."
            ]

        GameRulesTitle ->
            [ Text "Spielregeln" ]

        HouseRulesTitle ->
            [ Text "Hausregeln" ]

        HouseRules ->
            [ Text "Du kannst die Art und Weise, wie das Spiel gespielt wird, auf verschiedene Weise ändern. Wähle beim Einrichten des Spiels "
            , Text "so viele Hausregeln, wie Du verwenden möchtest."
            ]

        HouseRuleReboot ->
            [ Text "Neustart des Universums" ]

        HouseRuleRebootDescription { cost } ->
            [ Text "Die Spieler können jederzeit "
            , Text (an cost)
            , ref (nounMaybe Point cost)
            , Text " verwenden, um ihre Hand gegen eine neue Hand zu tauschen."
            ]

        HouseRuleRebootAction { cost } ->
            [ Text "Investiere "
            , Text (asWord cost)
            , Text " "
            , ref (noun Point cost)
            , Text ", um die Hand gegen eine neue auszuwechseln."
            ]

        HouseRuleRebootCost ->
            [ ref (noun Point 1), Text " Punkte" ]

        HouseRuleRebootCostDescription ->
            [ Text "Wie viele ", ref (nounUnknownQuantity Point), Text " es kostet, um neu ziehen zu können." ]

        HouseRulePackingHeat ->
            [ Text "Schwere Bewaffnung" ]

        HouseRulePackingHeatDescription ->
            [ Text "Jede "
            , ref (nounUnknownQuantity Call)
            , Text " mit "
            , ref (Pick { numberOfCards = 2 })
            , Text " erhält zusätzlich "
            , ref (Draw { numberOfCards = 1 })
            , Text ", so dass mehr Möglichkeiten bestehen."
            ]

        HouseRuleComedyWriter ->
            [ Text "Komödien-Autor" ]

        HouseRuleComedyWriterDescription ->
            [ Text "Füge leere "
            , ref (nounUnknownQuantity Response)
            , Text " hinzu, auf denen Spieler eigene Antworten schreiben können."
            ]

        HouseRuleComedyWriterNumber ->
            [ Text "Leere ", ref (nounUnknownQuantity Response) ]

        HouseRuleComedyWriterNumberDescription ->
            [ Text "Die Anzahl der leeren "
            , ref (nounUnknownQuantity Response)
            , Text "die im Spiel verfügbar sind."
            ]

        HouseRuleComedyWriterExclusive ->
            [ Text "Nur leere ", ref (nounUnknownQuantity Response) ]

        HouseRuleComedyWriterExclusiveDescription ->
            [ Text "Wenn aktiviert, werden alle nicht leeren "
            , ref (nounUnknownQuantity Response)
            , Text " ignoriert und nur leere Karten werden im Spiel angezeigt."
            ]

        HouseRuleRandoCardrissian ->
            [ Text "Rando Cardrissian" ]

        HouseRuleRandoCardrissianDescription ->
            [ Text "In jeder Runde wird die erste "
            , ref (noun Response 1)
            , Text " im Stapel als Antwort gespielt. Dieses Spiel gehört einem KI-Spieler namens "
            , Text "Rando Cardrissian und wenn er das Spiel gewinnt, gehen alle Spieler in einem Zustand ewiger Schande nach Hause."
            ]

        HouseRuleRandoCardrissianNumber ->
            [ Text "KI Spieler" ]

        HouseRuleRandoCardrissianNumberDescription ->
            [ Text "Die Anzahl der KI-Spieler, die am Spiel teilnehmen." ]

        HouseRuleNeverHaveIEver ->
            [ Text "Ich habe noch nie" ]

        HouseRuleNeverHaveIEverDescription ->
            [ Text "Ein Spieler kann jederzeit Karten ablegen, die er nicht versteht, muss aber seine Unwissenheit "
            , Text "eingestehen: die Karte wird öffentlich geteilt."
            ]

        -- TODO: Translate
        HouseRuleHappyEnding ->
            [ Missing ]

        -- TODO: Translate
        HouseRuleHappyEndingDescription ->
            [ Missing ]

        MustBeMoreThanOrEqualValidationError { min } ->
            [ Text "Der Wert muss mindestens ", Text (String.fromInt min), Text " betragen." ]

        MustBeLessThanOrEqualValidationError { max } ->
            [ Text "Der Wert darf höchstens  ", Text (String.fromInt max), Text " betragen." ]

        SetValue { value } ->
            [ Text "Setze den Wert auf ", Text (String.fromInt value), Text "." ]

        CantBeEmpty ->
            [ Text "Das darf nicht leer sein." ]

        SettingsTitle ->
            [ Text "Einstellungen" ]

        LanguageSetting ->
            [ Text "Sprache" ]

        MissingLanguage ->
            [ Text "Du siehst Deine Sprache nicht? ", ref TranslationBeg ]

        AutonymFormat { autonym } ->
            [ Text "(", Text autonym, Text ")" ]

        TranslationBeg ->
            [ Text "Helfe  "
            , ref MassiveDecks
            , Text " zu übersetzen!"
            ]

        CardSizeSetting ->
            [ Text "Kompakte Karten" ]

        CardSizeExplanation ->
            [ Text "Stelle ein, wie groß die Karten dargestellt werden - dies kann auf kleinen Bildschirmen nützlich sein, um weniger scrollen zu müssen." ]

        AutoAdvanceSetting ->
            [ Text "Runde automatisch vorrücken" ]

        AutoAdvanceExplanation ->
            [ Text "Wenn eine Runde beendet ist, wirst Du automatisch zur nächsten übergeblendet und musst nicht warten." ]

        SpeechSetting ->
            [ Text "Text aussprechen" ]

        SpeechExplanation ->
            [ Text "Karten mit Hilfe von Text-to-Speech vorlesen." ]

        SpeechNotSupportedExplanation ->
            [ Text "Dein Browser unterstützt Text-to-Speech nicht oder hat keine Stimmen installiert." ]

        VoiceSetting ->
            [ Text "Sprachstimme" ]

        NotificationsSetting ->
            [ Text "Browser Benachrichtigungen" ]

        NotificationsExplanation ->
            [ Text "Du wirst mittels Browser-Benachrichtigungen benachrichtigt, wenn Du im Spiel etwas tun musst." ]

        NotificationsUnsupportedExplanation ->
            [ Text "Dein Browser unterstützt keine Benachrichtigungen." ]

        NotificationsBrowserPermissions ->
            [ Text "Du musst eine Genehmigung für "
            , ref MassiveDecks
            , Text " erteilen, um benachrichtigt zu werden. Dies wird nur verwendet, solange das Spiel geöffnet ist und Du diese Option aktiviert hast."
            ]

        NotificationOnlyWhenHiddenSetting ->
            [ Text "Nur wenn versteckt" ]

        NotificationsOnlyWhenHiddenExplanation ->
            [ Text "Sendet Benachrichtigungen nur, wenn Du Dir die Seite nicht ansiehst (z.B.: auf einem anderen Tab oder minimiert)." ]

        NotificationsOnlyWhenHiddenUnsupportedExplanation ->
            [ Text "Dein Browser unterstützt die Überprüfung der Seitensichtbarkeit nicht." ]

        -- Terms
        Czar ->
            [ Text "Kartenzar" ]

        CzarDescription ->
            [ Text "Der Spieler, der die Runde beurteilt." ]

        CallDescription ->
            [ Text "Eine schwarze Karte mit einer Frage oder einem Lückentext." ]

        ResponseDescription ->
            [ Text "Eine weiße Karte mit einem Satz, der in Runden ausgespielt wird." ]

        PointDescription ->
            [ Text "Wer mehr Punkte hat, gewinnt." ]

        GameCodeTerm ->
            [ Text "Spiel-Code" ]

        GameCodeDescription ->
            [ Text "Ein Code, der es anderen Personen ermöglicht, Dein Spiel zu finden und daran teilzunehmen." ]

        GameCode { code } ->
            [ Text code ]

        GameCodeSpecificDescription ->
            [ Text "Gebe diesen Spiel-Code an Personen weiter und diese können dem Spiel beitreten." ]

        GameCodeHowToAcquire ->
            [ Text "Frage die Person, die Dich für das Spiel eingeladen hat, nach dem ", ref GameCodeTerm, Text "." ]

        Deck ->
            [ Text "Kartensatz" ]

        DeckSource ->
            [ ref Deck, Text " Quelle" ]

        DeckLanguage { language } ->
            [ Text "in ", Text language ]

        DeckAuthor { author } ->
            [ Text "von ", Text author ]

        DeckTranslator { translator } ->
            [ Text "Übersetzung von ", Text translator ]

        StillPlaying ->
            [ Text "Spielt noch" ]

        PlayingDescription ->
            [ Text "Dieser Spieler ist in der Runde, hat aber noch kein Spiel eingereicht." ]

        Played ->
            [ Text "Hat gespielt" ]

        PlayedDescription ->
            [ Text "Dieser Spieler hat sein Spiel für die Runde eingereicht." ]

        -- Lobby Browser
        LobbyBrowserTitle ->
            [ Text "Öffentliche Parien" ]

        NoPublicGames ->
            [ Text "Keine öffentlichen Spiele verfügbar." ]

        PlayingGame ->
            [ Text "Spiele, die gerade stattfinden." ]

        SettingUpGame ->
            [ Text "Spiele, die noch nicht begonnen haben." ]

        StartYourOwn ->
            [ Text "Eine neues Spiel beginnen?" ]

        -- Spectation
        JoinTheGame ->
            [ Text "Nehme an dem Spiel teil!" ]

        ToggleAdvertDescription ->
            [ Text "Umschalten, um die Informationen zur Teilnahme von Spielern an dem Spiel anzuzeigen." ]

        -- Cards
        Pick numberOfCards ->
            [ Text "Wähle", ref (NumberOfCards numberOfCards) ]

        Draw numberOfCards ->
            [ Text "Ablegen", ref (NumberOfCards numberOfCards) ]

        PickDescription { numberOfCards } ->
            [ Text "Du musst "
            , Text (asWord numberOfCards)
            , Text " "
            , ref (noun Response numberOfCards)
            , Text " spielen."
            ]

        DrawDescription { numberOfCards } ->
            [ Text "Du bekommst "
            , Text (asWord numberOfCards)
            , Text " "
            , ref (noun Response numberOfCards)
            , Text " zusätzlich vor dem Spiel."
            ]

        NumberOfCards { numberOfCards } ->
            [ Text (String.fromInt numberOfCards) ]

        -- Lobby
        LobbyNameLabel ->
            [ Text "Spielname" ]

        DefaultLobbyName { owner } ->
            [ Text owner, Text "'s Spiel" ]

        Invite ->
            [ Text "Lade Spieler zum Spiel ein." ]

        InviteLinkHelp ->
            [ Text "Sende diesen Link an die Spieler, um sie zum Spiel einzuladen, oder lasse sie den untenstehenden QR-Code einscannen." ]

        InviteExplanation { gameCode, password } ->
            let
                extra =
                    password
                        |> Maybe.map
                            (\p ->
                                [ Text " und das Passwort für das Spiel “"
                                , Text p
                                , Text "”"
                                ]
                            )
                        |> Maybe.withDefault []
            in
            List.concat
                [ [ Text "Der Spiele-Code lautet "
                  , ref (GameCode { code = gameCode })
                  , Text ". Spieler können dem Spiel beitreten, indem sie "
                  , ref MassiveDecks
                  , Text " laden und und diesen Code eingeben"
                  ]
                , extra
                , [ Text "."
                  ]
                ]

        Cast ->
            [ Text "Zum Fernseher übertragen." ]

        CastConnecting ->
            [ Text "Verbinden..." ]

        CastConnected { deviceName } ->
            [ Text "Übertragung zu ", Text deviceName, Text "." ]

        Players ->
            [ ref (nounUnknownQuantity Player) ]

        PlayersDescription ->
            [ Text "Benutzer, die das Spiel spielen." ]

        Spectators ->
            [ ref (nounUnknownQuantity Spectator) ]

        SpectatorsDescription ->
            [ Text "Benutzer, die sich das Spiel ansehen, ohne zu spielen." ]

        Left ->
            [ Text "Verlassen" ]

        LeftDescription ->
            [ Text "Benutzer, die das Spiel verlassen haben." ]

        Away ->
            [ Text "Abwesend" ]

        AwayDescription ->
            [ Text "Dieser Benutzer ist vorübergehend nicht im Spiel." ]

        Disconnected ->
            [ Text "Getrennt" ]

        DisconnectedDescription ->
            [ Text "Dieser Benutzer ist nicht mit dem Spiel verbunden." ]

        Privileged ->
            [ Text "Besitzer" ]

        PrivilegedDescription ->
            [ Text "Dieser Benutzer kann die Einstellungen im Spiel anpassen." ]

        Ai ->
            [ Text "KI" ]

        AiDescription ->
            [ Text "Dieser Spieler wird durch den Computer gesteuert." ]

        Score { total } ->
            [ Text (String.fromInt total) ]

        ScoreDescription ->
            [ Text "Die Anzahl der "
            , ref (nounUnknownQuantity Point)
            , Text " die der Spieler hat."
            ]

        Likes { total } ->
            [ Text (String.fromInt total) ]

        LikesDescription ->
            [ Text "Die Anzahl der erhaltenen Likes."
            ]

        ToggleUserList ->
            [ Text "Anzeigen oder Ausblenden der Anzeigetafel." ]

        GameMenu ->
            [ Text "Spiel-Menü." ]

        UnknownUser ->
            [ Text "Ein unbekannter Benutzer" ]

        InvitePlayers ->
            [ Text "Spieler einladen" ]

        InvitePlayersDescription ->
            [ Text "Hole Dir sich den Spielcode/Link/QR-Code, um andere an diesem Spiel teilnehmen zu lassen." ]

        SetAway ->
            [ Text "Als abwesend markieren" ]

        SetBack ->
            [ Text "Als zurück markieren" ]

        LeaveGame ->
            [ Text "Spiel verlassen" ]

        LeaveGameDescription ->
            [ Text "Verlasse das Spiel endgültig." ]

        Spectate ->
            [ Text "Zuschauer-Ansicht" ]

        SpectateDescription ->
            [ Text "Öffne die Sicht eines Zuschauers auf das Spiel in einem neuen Tab/Fenster." ]

        BecomeSpectator ->
            [ Text "Zuschauen" ]

        BecomeSpectatorDescription ->
            [ Text "Schaue Dir einfach das Spiel an, ohne zu spielen." ]

        BecomePlayer ->
            [ Text "Spielen" ]

        BecomePlayerDescription ->
            [ Text "Spiele in dem Spiel mit." ]

        EndGame ->
            [ Text "Spiel beenden" ]

        EndGameDescription ->
            [ Text "Beende das Spiel jetzt." ]

        ReturnViewToGame ->
            [ Text "Zurück zum Spiel" ]

        ReturnViewToGameDescription ->
            [ Text "Zurück zur Hauptansicht." ]

        ViewConfiguration ->
            [ Text "Konfiguration" ]

        ViewConfigurationDescription ->
            [ Text "Wechsel zur Anzeige der Konfiguration des Spiels." ]

        KickUser ->
            [ Text "Rausschmeißen" ]

        Promote ->
            [ Text "Fördern" ]

        Demote ->
            [ Text "Zurückstufen" ]

        -- Notifications
        UserConnected { username } ->
            [ Text username, Text " hat wieder Verbindung zum Spiel aufgenommen." ]

        UserDisconnected { username } ->
            [ Text username, Text " hat die Verbindung zum Spiel unterbrochen." ]

        UserJoined { username } ->
            [ Text username, Text " hat sich dem Spiel angeschlossen." ]

        UserLeft { username } ->
            [ Text username, Text " hat das Spiel verlassen." ]

        UserKicked { username } ->
            [ Text username, Text " wurde aus dem Spiel geworfen." ]

        Dismiss ->
            [ Text "Entlassen" ]

        -- Configuration
        ConfigureTitle ->
            [ Text "Spiel einrichten" ]

        NoDecks ->
            [ Segment [ Text "Keine Kartensätze. " ]
            , Text " "
            , Segment [ Text "Du musst  mindestens ein Kartensatz zum Spiel hinzufügen." ]
            ]

        NoDecksHint ->
            [ Text "Nicht sicher? Hinzufügen des originalen ", raw CardsAgainstHumanity, Text " Kartensatzes." ]

        WaitForDecks ->
            [ Text "Die Kartensätze müssen geladen werden, bevor Du das Spiel beginnen kannst." ]

        MissingCardType { cardType } ->
            [ Text "Keiner Deiner Kartensätze enthält irgendwelche "
            , ref (nounUnknownQuantity cardType)
            , Text ". Um das Spiel beginnen zu können, benötigst Du ein entsprechenden Kartensatz."
            ]

        NotEnoughCardsOfType { cardType, needed, have } ->
            [ Text "Für die Anzahl der Spieler im Spiel benötigst Du mindestens "
            , Text (needed |> String.fromInt)
            , Text " "
            , ref (noun cardType needed)
            , Text " aber Du hast nur "
            , Text (have |> String.fromInt)
            , Text "."
            ]

        AddBlankCards { amount } ->
            [ Text "Ergänze "
            , amount |> String.fromInt |> Text
            , Text " leere "
            , ref (noun Response amount)
            ]

        AddDeck ->
            [ Text "Füge einen Kartensatz hinzu." ]

        RemoveDeck ->
            [ Text "Entferne einen Kartensatz." ]

        SourceNotFound { source } ->
            [ ref source, Text " kennt den Kartensatz nicht, um den Du gebeten hast. Überprüfe, ob die von Dir gemachten Angaben korrekt sind." ]

        SourceServiceFailure { source } ->
            [ ref source, Text " hat es nicht geschafft, den Kartensatz bereitzustellen. Bitte versuche es später noch einmal oder versuche eine andere Quelle." ]

        ManyDecks ->
            [ Text "Many Decks" ]

        ManyDecksDeckCodeTitle ->
            [ Text "Kartensatz-Code" ]

        ManyDecksDeckCodeShort ->
            [ Text "Ein Kartensatz-Code muss mindestens fünf Zeichen lang sein." ]

        ManyDecksWhereToGet ->
            [ Text "Du kannst Kartensätze bei ", ref ManyDecks, Text " finden oder selbst erstellen." ]

        JsonAgainstHumanity ->
            [ Text "JSON Against Humanity" ]

        JsonAgainstHumanityAbout ->
            [ Text "Kartensatz bereitgestellt von ", ref JsonAgainstHumanity ]

        BuiltIn ->
            [ Text "Integriert" ]

        APlayer ->
            [ Text "Ein Spieler" ]

        -- TODO: Translate
        Generated { by } ->
            [ Missing ]

        DeckAlreadyAdded ->
            [ Text "Dieser Kartensatz ist bereits im Spiel." ]

        ConfigureDecks ->
            [ Text "Kartensätze" ]

        ConfigureRules ->
            [ Text "Regeln" ]

        ConfigureTimeLimits ->
            [ Text "Zeitliche Begrenzungen" ]

        ConfigurePrivacy ->
            [ Text "Datenschutz" ]

        HandSize ->
            [ Text "Größe der Hand" ]

        HandSizeDescription ->
            [ Text "Die Basisanzahl der Karten, die jeder Spieler während des Spiels auf der Hand hat." ]

        ScoreLimit ->
            [ ref (noun Point 1), Text " Begrenzung" ]

        ScoreLimitDescription ->
            [ Segment
                [ Text "Die Anzahl der "
                , ref (nounUnknownQuantity Point)
                , Text ", die ein Spieler zum Gewinnen des Spiels benötigt."
                ]
            , Text " "
            , Segment [ Text "Wenn ausgeschaltet, wird das Spiel auf unbestimmte Zeit fortgesetzt." ]
            ]

        UnsavedChangesWarning ->
            [ Text "Du hast ungespeicherte Änderungen an der Konfiguration vorgenommen; diese müssen zuerst gespeichert werden, wenn Du diese auf das Spiel "
            , Text "anwenden möchten."
            ]

        SaveChanges ->
            [ Text "Sichere Deine Änderungen." ]

        RevertChanges ->
            [ Text "Verwerfe Deine ungespeicherten Änderungen." ]

        NeedAtLeastOneDeck ->
            [ Text "Um das Spiel beginnen zu können, muss mindestens ein Kartensatz hinzugefügt werden." ]

        NeedAtLeastThreePlayers ->
            [ Text "Es müssen sich mindestens drei Spieler anmelden, um das Spiel beginnen zu können." ]

        NeedAtLeastOneHuman ->
            [ Text "Leider können Computerspieler nicht  "
            , ref Czar
            , Text " sein, das Spiel erfordert also mindestens einen menschlichen Spieler, um beginnen zu können."
            , Text " (auch wenn nur ein einzelner menschlicher Spieler ein bisschen langweilig sein mag!)"
            ]

        RandoCantWrite ->
            [ Text "Computerspieler können ihre Karten nicht selbst schreiben." ]

        DisableComedyWriter ->
            [ Text "Deaktiviere ", ref HouseRuleComedyWriter ]

        DisableRando ->
            [ Text "Deaktiviere ", ref HouseRuleRandoCardrissian ]

        AddAnAiPlayer ->
            [ Text "Füge dem Spiel einen KI-Spieler hinzu." ]

        PasswordShared ->
            [ Text "Jeder im Spiel kann das Passwort sehen! "
            , Text "Das Ausblenden oben betrifft nur Dich (nützlich beim Streaming, etc.)."
            ]

        PasswordNotSecured ->
            [ Text "Spiel-Passwörter werden "
            , Em [ Text "nicht" ]
            , Text " sicher gespeichert - bitte gebe "
            , Em [ Text "kein" ]
            , Text " Passwort an, dass Du woanders auch nutzt!"
            ]

        LobbyPassword ->
            [ Text "Spiel-Passwort" ]

        LobbyPasswordDescription ->
            [ Text "Ein Passwort für Benutzer muss eingegeben werden, bevor Du diese Spiel beitreten kannst." ]

        AudienceMode ->
            [ Text "Publikums-Modus" ]

        AudienceModeDescription ->
            [ Text "Wenn diese Option aktiviert ist, sind neu hinzukommende Benutzer standardmäßig Zuschauer, und nur Du kannst sie "
            , Text "zu Spielern machen."
            ]

        StartGame ->
            [ Text "Spiel starten" ]

        Public ->
            [ Text "Öffentliches Spiel" ]

        PublicDescription ->
            [ Text "Wenn diese Option aktiviert ist, erscheint das Spiel in der öffentlichen Spielliste, so dass jeder es finden kann." ]

        ApplyConfiguration ->
            [ Text "Übernehme diese Änderung." ]

        AppliedConfiguration ->
            [ Text "Gespeichert." ]

        InvalidConfiguration ->
            [ Text "Dieser Konfigurationswert ist nicht gültig." ]

        Automatic ->
            [ Text "Spieler automatisch als abwesend markieren" ]

        AutomaticDescription ->
            [ Text "Falls aktiviert, werden Spieler nach Ablauf des Zeitlimits automatisch als abwesend markiert. "
            , Text "Andernfalls muss jemand auf den Knopf drücken, um dies zu tun."
            ]

        TimeLimit { stage } ->
            [ ref stage, Text " Zeitlimit" ]

        PlayingTimeLimitDescription ->
            [ Text "Wie lange (in Sekunden) haben die ", ref Players, Text " Zeit eine Auswahl treffen." ]

        PlayingAfterDescription ->
            [ Text "Wie lange (in Sekunden) die Spieler ihr Spiel ändern dürfen, bevor die nächste Runde beginnt." ]

        RevealingTimeLimitDescription ->
            [ Text "Wie lange (in Sekunden) hat der ", ref Czar, Text " zum Aufdecken der Spielzüge." ]

        RevealingAfterDescription ->
            [ Text "Wie lange (in Sekunden) muss nach dem Aufdecken der letzten Karte gewartet werden, bevor die nächste Phase beginnt." ]

        JudgingTimeLimitDescription ->
            [ Text "Wie lange (in Sekunden) hat der ", ref Czar, Text " Zeit, die Runde zu bewerten." ]

        CompleteTimeLimitDescription ->
            [ Text "Wie viel Zeit (in Sekunden) muss nach dem Ende einer Runde gewartet werden, bevor die nächste Runde beginnt." ]

        RevealingEnabledTitle ->
            [ Text "Zar deckt Blätter auf" ]

        RevealingEnabled ->
            [ Text "Wenn aktiviert, wird der "
            , ref Czar
            , Text " vor der Siegerauswahl die Antworten einzeln aufdecken."
            ]

        DuringTitle ->
            [ Text "Zeitlimit" ]

        AfterTitle ->
            [ Text "Nach" ]

        Conflict ->
            [ Text "Konflikt" ]

        ConflictDescription ->
            [ Text "Jemand anderes hat Änderungen vorgenommen, während Du ebenfalls Änderungen vorgenommen hast. "
            , Text "Bitte wähle aus, ob Du Deine Änderungen oder die anderen Änderungen behalten möchten."
            ]

        YourChanges ->
            [ Text "Deine Änderungen" ]

        TheirChanges ->
            [ Text "Andere Änderungen" ]

        ConfigurationDisabledWhileInGame ->
            [ Text "Während das Spiel läuft, kannst Du die Konfiguration nicht ändern." ]

        ConfigurationDisabledIfNotPrivileged ->
            [ Text "Du kannst die Konfiguration dieses Spiels nicht ändern." ]

        ConfigureNextGame ->
            [ Text "Nächstes Spiel konfigurieren" ]

        -- Game
        SubmitPlay ->
            [ Text "Gib diese Karten dem ", ref Czar, Text " zum Abschluss dieser Runde." ]

        TakeBackPlay ->
            [ Text "Nimm Deine Karten zurück, um Dein Spiel für diese Runde zu ändern." ]

        JudgePlay ->
            [ Text "Wähle dieses Blatt als Rundensieger." ]

        LikePlay ->
            [ Text "Füge diesem Spiel ein Like hinzu." ]

        AdvanceRound ->
            [ Text "Nächste Runde." ]

        Playing ->
            [ Text "Spielen" ]

        Revealing ->
            [ Text "Aufdecken" ]

        Judging ->
            [ Text "Beurteilung" ]

        Complete ->
            [ Text "Beendet" ]

        ViewGameHistoryAction ->
            [ Text "Sehe Dir frühere Runden aus diesem Spiel an." ]

        ViewHelpAction ->
            [ Text "Hilfe" ]

        EnforceTimeLimitAction ->
            [ Text "Setze alle Spieler, auf die das Spiel wartet, auf Abwesend und überspringe sie, bis sie zurückkehren." ]

        Blank ->
            [ Text "Leer" ]

        RoundStarted ->
            [ Text "Runde begonnen" ]

        JudgingStarted ->
            [ Text "Beurteilung begonnen" ]

        Paused ->
            [ Text "Das Spiel wurde unterbrochen, weil es nicht genügend aktive Spieler gibt, um weiterzuspielen."
            , Text "Wenn jemand beitritt oder zurückkehrt, wird es automatisch fortgesetzt."
            ]

        ClientAway ->
            [ Text "Du bist derzeit nicht im Spiel und spielst nicht." ]

        Discard ->
            [ Text "Lege die ausgewählte Karte ab und zeigen sie den anderen Spielern im Spiel." ]

        Discarded { player } ->
            [ Text player
            , Text " hat die folgende Karte abgeworfen.:"
            ]

        -- Instructions
        PlayInstruction { numberOfCards } ->
            [ Text "Du musst "
            , Text (asWord numberOfCards)
            , Text " weitere "
            , ref (noun Response numberOfCards)
            , Text " von ihrer Hand abwerfen, bevor die Runde übermittelt werden kann."
            ]

        SubmitInstruction ->
            [ Text "Du musst Dein Blatt für diese Runde einreichen." ]

        WaitingForPlaysInstruction ->
            [ Text "Du wartest darauf, dass andere Spieler in die Runde spielen." ]

        CzarsDontPlayInstruction ->
            [ Text "Du bist der "
            , ref Czar
            , Text " für diese Runde - Du reichst keine "
            , ref (nounUnknownQuantity Response)
            , Text " ein. Stattdessen wählst Du den Gewinner, sobald alle anderen ihre Beiträge eingereicht haben."
            ]

        NotInRoundInstruction ->
            [ Text "Du bist nicht in dieser Runde. Du spielst in der nächsten Runde, es sei denn, Du bist auf Auswärtsspiel eingestellt." ]

        RevealPlaysInstruction ->
            [ Text "Klicke auf die Karten, um sie umzudrehen, und wähle dann die Antwort aus, die Dir am besten gefällt." ]

        WaitingForCzarInstruction ->
            [ Text "Du kannst Spiele liken, während Du auf die Gewinner-Auswahl durch den ", ref Czar, Text " wartest." ]

        AdvanceRoundInstruction ->
            [ Text "Die nächste Runde hat begonnen, Du kannst weitermachen." ]

        -- 404 Unknown
        UnknownPageTitle ->
            [ Text "404 Fehler: Unbekannte Seite." ]

        GoBackHome ->
            [ Text "Zur Hauptseite gehen." ]

        -- Actions
        Refresh ->
            [ Text "Aktualisieren" ]

        Accept ->
            [ Text "OK" ]

        -- Errors
        Error ->
            [ Text "Fehler" ]

        ErrorHelp ->
            [ Text "Möglicherweise ist der Spielserver ausgefallen, oder es handelt sich um einen Fehler. Das Aktualisieren der Seite sollte es wieder in "
            , Text "Gang bringen. Weitere Einzelheiten findest Du weiter unten."
            ]

        ErrorHelpTitle ->
            [ Text "Entschuldigung, etwas ist schief gelaufen." ]

        ErrorCheckOutOfBand ->
            [ Text "Bitte prüfe ", ref TwitterHandle, Text " für Updates und Servicestatus. Der Spieleserver wird für eine kurze Zeit ausfallen, wenn eine neue Version veröffentlicht wird. Wenn Du also ein aktuelles Update siehst, versuche es in ein paar Minuten erneut." ]

        TwitterHandle ->
            [ Text "@Massive_Decks" ]

        ReportError ->
            [ Text "Fehler melden" ]

        ReportErrorDescription ->
            [ Text "Informiere die Entwickler über einen Fehler, auf den Du gestoßen bist, damit sie ihn beheben können." ]

        ReportErrorBody ->
            [ Text "Ich war [ersetze dies durch eine kurze Erklärung, was Du getan hast], als ich den folgenden Fehler erhielt:" ]

        BadUrlError ->
            [ Text "Wir haben versucht, einen Aufruf zu einer ungültigen Seite zu machen." ]

        TimeoutError ->
            [ Text "Der Server hat zu lange nicht geantwortet. Er ist möglicherweise ausgefallen, bitte versuche es nach einer kurzen Verzögerung erneut." ]

        NetworkError ->
            [ Text "Deine Internetverbindung wurde unterbrochen." ]

        ServerDownError ->
            [ Text "Der Spielserver ist derzeit offline. Bitte versuche es später noch einmal." ]

        BadStatusError ->
            [ Text "Der Server gab eine Antwort, die wir nicht erwartet hatten." ]

        BadPayloadError ->
            [ Text "Der Server gab eine Antwort, die wir nicht verstanden." ]

        PatchError ->
            [ Text "Der Server gab einen Patch, den wir nicht anwenden konnten." ]

        VersionMismatch ->
            [ Text "Der Server gab eine Konfigurationsänderung für eine andere Version als wir erwartet hatten." ]

        CastError ->
            [ Text "Tut mir leid, beim Versuch, eine Verbindung zum Spiel herzustellen, ist etwas schief gelaufen." ]

        ActionExecutionError ->
            [ Text "Du kannst diese Aktion nicht ausführen." ]

        IncorrectPlayerRoleError { role, expected } ->
            [ Text "Du musst ", ref expected, Text " sein, um das machen zu können. Du bist aber ", ref role, Text "." ]

        IncorrectUserRoleError { role, expected } ->
            [ Text "Du musst ", ref expected, Text " sein, um das machen zu können. Du bist aber ", ref role, Text "." ]

        IncorrectRoundStageError { stage, expected } ->
            [ Text "Die Runde muss bei der ", ref expected, Text " Phase sein, um das machen zu können. Derzeit läuft die Phase ", ref stage, Text "." ]

        ConfigEditConflictError ->
            [ Text "Jemand anderes hat die Konfiguration vor Ihnen geändert, Deine Änderung wurde nicht gespeichert." ]

        UnprivilegedError ->
            [ Text "Du hast nicht die Rechte, dies zu tun." ]

        GameNotStartedError ->
            [ Text "Dazu muss das Spiel gestartet sein." ]

        InvalidActionError { reason } ->
            [ Text "Der Server hat eine Anfrage des Clients nicht verstanden. Details: ", Text reason ]

        AuthenticationError ->
            [ Text "Du kannst an diesem Spiel nicht teilnehmen." ]

        IncorrectIssuerError ->
            [ Text "Deine Anmeldedaten für die Teilnahme an diesem Spiel sind veraltet, das Spiel existiert nicht mehr." ]

        InvalidAuthenticationError ->
            [ Text "Deine Zugangsdaten für die Teilnahme an diesem Spiel sind fehlerhaft." ]

        InvalidLobbyPasswordError ->
            [ Text "Das von Dir angegebene Spiel-Kennwort war falsch. Versuche es noch einmal einzugeben und wenn es immer noch nicht funktioniert, frage die Person, die Dich eingeladen hat, noch einmal." ]

        AlreadyLeftError ->
            [ Text "Du hast dieses Spiel bereits verlassen." ]

        LobbyNotFoundError ->
            [ Text "Dieses Spiel existiert nicht." ]

        LobbyClosedError { gameCode } ->
            [ Text "Das angegebene Spiel (", ref (GameCode { code = gameCode }), Text ") wurde bereit beendet." ]

        LobbyDoesNotExistError { gameCode } ->
            [ Text "Das angegebene Spiel-Kennwort ("
            , ref (GameCode { code = gameCode })
            , Text ") existiert nicht. "
            , Text "Versuche es noch einmal einzugeben und wenn es immer noch nicht funktioniert, frage die Person, die Dich eingeladen hat, noch einmal."
            ]

        RegistrationError ->
            [ Text "Problem bei der Teilnahme am Spiel." ]

        UsernameAlreadyInUseError { username } ->
            [ Text "Jemand benutzt bereits den Benutzernamen “"
            , Text username
            , Text "”— versuche bitte einen anderen Namen."
            ]

        GameError ->
            [ Text "Irgendetwas ist im Spiel schief gelaufen." ]

        OutOfCardsError ->
            [ Text "Es waren nicht genug Karten im Stapel, um jedem Spieler eine Hand zu geben! Versuche in der Spielkonfiguration weitere Kartensätze hinzuzufügen." ]

        -- Language Names
        English ->
            [ Text "Englisch" ]

        BritishEnglish ->
            [ Text "Englisch (British)" ]

        Italian ->
            [ Text "Italienisch" ]

        BrazilianPortuguese ->
            [ Text "Portugisisch (Brazilian)" ]

        German ->
            [ Text "Deutsch (formell)" ]

        GermanInformal ->
            [ Text "Deutsch (informell)" ]

        Polish ->
            [ Text "Polnisch" ]

        Indonesian ->
            [ Text "Indonesisch" ]


an : Maybe Int -> String
an amount =
    case amount of
        Just 1 ->
            "ein "

        _ ->
            ""


a : Maybe Int -> String
a amount =
    case amount of
        Just 1 ->
            "ein "

        _ ->
            ""


{-| Take a number and give back the name of that number. Falls back to the number when it gets too big.
-}
asWord : Int -> String
asWord number =
    case number of
        0 ->
            "Null"

        1 ->
            "eins"

        2 ->
            "zwei"

        3 ->
            "drei"

        4 ->
            "vier"

        5 ->
            "fünf"

        6 ->
            "sechs"

        7 ->
            "sieben"

        8 ->
            "acht"

        9 ->
            "neun"

        10 ->
            "zehn"

        11 ->
            "elf"

        12 ->
            "zwölf"

        other ->
            String.fromInt other
