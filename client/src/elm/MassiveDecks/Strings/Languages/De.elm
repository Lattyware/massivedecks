module MassiveDecks.Strings.Languages.De exposing (pack)

{-| German (Formal) localization.

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
        { lang = De
        , code = "de"
        , name = German
        , translate = translate
        , recommended = "cah-base-en" |> BuiltIn.hardcoded |> Source.BuiltIn
        }



{- Private -}


raw : MdString -> Translation.Result never
raw =
    Raw Nothing


ref : MdString -> Translation.Result never
ref =
    Ref Nothing


{-| The German translation
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
            , Text ", damit Sie helfen können, das Spiel zu verbessern, auf den Quellcode zuzugreifen oder einfach mehr unter "
            , ref MDProject
            , Text "."
            ]

        NewGame ->
            [ Text "Neu" ]

        NewGameDescription ->
            [ Text "Beginnen Sie eine neues Spiel ", ref MassiveDecks, Text "." ]

        FindPublicGame ->
            [ Text "Suchen" ]

        JoinPrivateGame ->
            [ Text "Teilnehmen" ]

        JoinPrivateGameDescription ->
            [ Text "Nehmen Sie an einem Spiel teil, zu dem Sie eingeladen wurden." ]

        PlayGame ->
            [ Text "Spielen" ]

        AboutTheGame ->
            [ Text "Über" ]

        AboutTheGameDescription ->
            [ Text "Informieren Sie sich über ", ref MassiveDecks, Text " und wie es entwickelt wurde." ]

        MDLogoDescription ->
            [ Text "Ein ", ref (noun Call 1), Text " und ein ", ref (noun Response 1), Text "mit einem “M” un einem “D” beschriftet." ]

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
            [ Text "Jemand anderes benutzt diesen Namen in dem angegeben Spiel - bitte versuchen Sie es mit einen anderen Namen." ]

        RejoinTitle ->
            [ Text "Zurück zum Spiel" ]

        RejoinGame { code } ->
            [ Text "Zurück zu “", GameCode { code = code } |> ref, Text "”." ]

        LobbyRequiresPassword ->
            [ Text "Sie benötigen ein Passwort, um an diesem Spiel teilzunehmen. Versuchen Sie die Person danach zu fragen, die Sie eingeladen hat." ]

        YouWereKicked ->
            [ Text "Sie wurden aus dem Spiel geworfen." ]

        ScrollToTop ->
            [ Text "Zum Anfang blättern." ]

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
            [ Text "Alle anderen beantworten die Frage oder füllen den Lückentext aus, indem sie eine "
            , ref (noun Response 1)
            , Text " aus ihrer Hand auswählen."
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
            , Text " als Antwort. Spielen Sie die Karten in der Reihenfolge, wie der "
            , ref Czar
            , Text " sie vorlesen soll - die Reihenfolge ist bei deisen Karten entscheidend."
            ]

        ExamplePickDescription ->
            [ ref (nounUnknownQuantity Call)
            , Text " wie diese erfordern die Auswahl von mehreren "
            , ref (nounUnknownQuantity Response)
            , Text ", die Ihnen vorab zur Verfügung gestellt werden."
            ]

        RulesDraw ->
            [ Text "Einige "
            , ref (nounUnknownQuantity Call)
            , Text " benötigen mehrere "
            , ref (nounUnknownQuantity Response)
            , Text "— diese sind mit  "
            , ref (Draw { numberOfCards = 2 })
            , Text " oder mehr beschriftet. Die Spieler erhalten entsprechend viele zusätzliche Karten für Ihre Hand."
            ]

        GameRulesTitle ->
            [ Text "Spielregeln" ]

        HouseRulesTitle ->
            [ Text "Hausregeln" ]

        HouseRules ->
            [ Text "Sie können die Art und Weise, wie das Spiel gespielt wird, auf verschiedene Weise ändern. Wählen Sie beim Einrichten des Spiels "
            , Text "so viele Hausregeln, wie Sie verwenden möchten."
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
            , Text ", um die Hand gegen eine neue Hand auszuwechseln."
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
            , Text ", die im Spiel verfügbar sind."
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
            [ Text "Setzen Sie den Wert auf ", Text (String.fromInt value), Text "." ]

        CantBeEmpty ->
            [ Text "Das darf nicht leer sein." ]

        SettingsTitle ->
            [ Text "Einstellungen" ]

        LanguageSetting ->
            [ Text "Sprache" ]

        MissingLanguage ->
            [ Text "Sie sehen Ihre Sprache nicht? ", ref TranslationBeg ]

        AutonymFormat { autonym } ->
            [ Text "(", Text autonym, Text ")" ]

        TranslationBeg ->
            [ Text "Helfen Sie  "
            , ref MassiveDecks
            , Text " zu übersetzen!"
            ]

        CardSizeSetting ->
            [ Text "Kompakte Karten" ]

        CardSizeExplanation ->
            [ Text "Stellen Sie ein, wie groß die Karten dargestellt werden - dies kann auf kleinen Bildschirmen nützlich sein, um weniger scrollen zu müssen." ]

        AutoAdvanceSetting ->
            [ Text "Runde automatisch vorrücken" ]

        AutoAdvanceExplanation ->
            [ Text "Wenn eine Runde beendet ist, werden Sie automatisch zur nächsten Runde übergeblendet, anstatt warten zu müssen." ]

        SpeechSetting ->
            [ Text "Text aussprechen" ]

        SpeechExplanation ->
            [ Text "Karten mit Hilfe von Text-to-Speech vorlesen." ]

        SpeechNotSupportedExplanation ->
            [ Text "Ihr Browser unterstützt Text-to-Speech nicht oder hat keine Stimmen installiert." ]

        VoiceSetting ->
            [ Text "Sprachstimme" ]

        NotificationsSetting ->
            [ Text "Browser Benachrichtigungen" ]

        NotificationsExplanation ->
            [ Text "Sie werden mittels Browser-Benachrichtigungen benachrichtigt, wenn Sie im Spiel etwas tun müssen."
            ]

        NotificationsUnsupportedExplanation ->
            [ Text "Ihr Browser unterstützt keine Benachrichtigungen." ]

        NotificationsBrowserPermissions ->
            [ Text "Sie müssen eine Genehmigung für "
            , ref MassiveDecks
            , Text " erteilen, um benachrichtigt zu werden. Dies wird nur verwendet, solange das Spiel geöffnet ist und Sie diese Option aktiviert haben."
            ]

        NotificationOnlyWhenHiddenSetting ->
            [ Text "Nur wenn versteckt" ]

        NotificationsOnlyWhenHiddenExplanation ->
            [ Text "Sendet Benachrichtigungen nur, wenn Sie sich die Seite nicht ansehen (z.B.: auf einem anderen Tab oder minimiert)." ]

        NotificationsOnlyWhenHiddenUnsupportedExplanation ->
            [ Text "Ihr Browser unterstützt die Überprüfung der Seitensichtbarkeit nicht." ]

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
            [ Text "Ein Code, der es anderen Personen ermöglicht, Ihr Spiel zu finden und daran teilzunehmen." ]

        GameCode { code } ->
            [ Text code ]

        GameCodeSpecificDescription ->
            [ Text "Geben Sie diesen Spiel-Code an Personen weiter und diese können dem Spiel beitreten." ]

        GameCodeHowToAcquire ->
            [ Text "Fragen Sie die Person, die Sie für das Spiel eingeladen hat, nach dem ", ref GameCodeTerm, Text "." ]

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
            [ Text "Nehmen Sie an dem Spiel teil!" ]

        ToggleAdvertDescription ->
            [ Text "Umschalten, um die Informationen zur Teilnahme von Spielern an dem Spiel anzuzeigen." ]

        -- Cards
        Pick numberOfCards ->
            [ Text "Wähle", ref (NumberOfCards numberOfCards) ]

        Draw numberOfCards ->
            [ Text "Ablegen", ref (NumberOfCards numberOfCards) ]

        PickDescription { numberOfCards } ->
            [ Text "Sie müssen "
            , Text (asWord numberOfCards)
            , Text " "
            , ref (noun Response numberOfCards)
            , Text " spielen."
            ]

        DrawDescription { numberOfCards } ->
            [ Text "Sie bekommen "
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
            [ Text "Laden Sie Spieler zum Spiel ein." ]

        InviteLinkHelp ->
            [ Text "Senden Sie diesen Link an die Spieler, um sie zum Spiel einzuladen, oder lassen Sie sie den untenstehenden QR-Code einscannen." ]

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
            [ Text "Holen Sie sich den Spielcode/Link/QR-Code, um andere an diesem Spiel teilnehmen zu lassen." ]

        SetAway ->
            [ Text "Als abwesend markieren" ]

        SetBack ->
            [ Text "Als zurück markieren" ]

        LeaveGame ->
            [ Text "Spiel verlassen" ]

        LeaveGameDescription ->
            [ Text "Verlassen Sie das Spiel endgültig." ]

        Spectate ->
            [ Text "Zuschauer-Ansicht" ]

        SpectateDescription ->
            [ Text "Öffnen Sie die Sicht eines Zuschauers auf das Spiel in einem neuen Tab/Fenster." ]

        BecomeSpectator ->
            [ Text "Zuschauen" ]

        BecomeSpectatorDescription ->
            [ Text "Schauen Sie sich einfach das Spiel an, ohne zu spielen." ]

        BecomePlayer ->
            [ Text "Spielen" ]

        BecomePlayerDescription ->
            [ Text "Spielen Sie in dem Spiel mit." ]

        EndGame ->
            [ Text "Spiel beenden" ]

        EndGameDescription ->
            [ Text "Beenden Sie das Spiel jetzt." ]

        ReturnViewToGame ->
            [ Text "Zurück zum Spiel" ]

        ReturnViewToGameDescription ->
            [ Text "Zurück zur Hauptansicht." ]

        ViewConfiguration ->
            [ Text "Konfiguration" ]

        ViewConfigurationDescription ->
            [ Text "Wechseln Sie zur Anzeige der Konfiguration des Spiels." ]

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
            [ Text "Entlassen Sie" ]

        -- Configuration
        ConfigureTitle ->
            [ Text "Spiel einrichten" ]

        NoDecks ->
            [ Segment [ Text "Keine Kartensätze. " ]
            , Text " "
            , Segment [ Text "Sie müssen mindestens ein Kartensatz zum Spiel hinzufügen." ]
            ]

        NoDecksHint ->
            [ Text "Nicht sicher? Hinzufügen des originalen ", raw CardsAgainstHumanity, Text " Kartensatzes." ]

        WaitForDecks ->
            [ Text "Die Decks müssen geladen werden, bevor Sie das Spiel beginnen können." ]

        MissingCardType { cardType } ->
            [ Text "Keiner Ihrer Kartensätze enthält irgendwelche "
            , ref (nounUnknownQuantity cardType)
            , Text ". Um das Spiel beginnen zu können, benötigen Sie ein entsprechenden Kartensatz."
            ]

        NotEnoughCardsOfType { cardType, needed, have } ->
            [ Text "Für die Anzahl der Spieler im Spiel benötigen Sie mindestens "
            , Text (needed |> String.fromInt)
            , Text " "
            , ref (noun cardType needed)
            , Text " aber Sie haben nur "
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
            [ ref source, Text " kennt den Kartensatz nicht, um den Sie gebeten haben. Überprüfen Sie, ob die von Ihnen gemachten Angaben korrekt sind." ]

        SourceServiceFailure { source } ->
            [ ref source, Text " hat es nicht geschafft, den Kartensatz bereitzustellen. Bitte versuchen Sie es später noch einmal oder versuchen Sie eine andere Quelle." ]

        ManyDecks ->
            [ Text "Many Decks" ]

        ManyDecksDeckCodeTitle ->
            [ Text "Kartensatz-Code" ]

        ManyDecksDeckCodeShort ->
            [ Text "Ein Kartensatz-Code muss mindestens fünf Zeichen lang sein." ]

        ManyDecksWhereToGet ->
            [ Text "Sie können Kartensätze bei ", ref ManyDecks, Text " zum Spielen finden oder selber erstellen." ]

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
            [ Text "Sie haben ungespeicherte Änderungen an der Konfiguration vorgenommen; diese müssen zuerst gespeichert werden, wenn Sie diese auf das Spiel "
            , Text "anwenden möchten."
            ]

        SaveChanges ->
            [ Text "Sichern Sie Ihre Änderungen." ]

        RevertChanges ->
            [ Text "Verwerfen Sie Ihre ungespeicherten Änderungen." ]

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
            [ Text "Fügen Sie dem Spiel einen KI-Spieler hinzu." ]

        PasswordShared ->
            [ Text "Jeder im Spiel kann das Passwort sehen! "
            , Text "Das Ausblenden oben betrifft nur Sie (nützlich beim Streaming, etc.)."
            ]

        PasswordNotSecured ->
            [ Text "Spiel-Passwörter werden "
            , Em [ Text "nicht" ]
            , Text " sicher gespeichert - bitte geben Sie  "
            , Em [ Text "kein" ]
            , Text " Passwort an, dass Sie woanders auch nutzen!"
            ]

        LobbyPassword ->
            [ Text "Spiel-Passwort" ]

        LobbyPasswordDescription ->
            [ Text "Ein Passwort für Benutzer muss eingegeben werden, bevor diese dem Spiel beitreten können." ]

        AudienceMode ->
            [ Text "Publikums-Modus" ]

        AudienceModeDescription ->
            [ Text "Wenn diese Option aktiviert ist, sind neu hinzukommende Benutzer standardmäßig Zuschauer, und nur Sie können sie "
            , Text "zu Spielern machen."
            ]

        StartGame ->
            [ Text "Spiel starten" ]

        Public ->
            [ Text "Öffentliches Spiel" ]

        PublicDescription ->
            [ Text "Wenn diese Option aktiviert ist, erscheint das Spiel in der öffentlichen Spielliste, so dass jeder es finden kann." ]

        ApplyConfiguration ->
            [ Text "Übernehmen Sie diese Änderung." ]

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
            [ Text "Jemand anderes hat Änderungen vorgenommen, während Sie ebenfalls Änderungen vorgenommen haben. "
            , Text "Bitte wählen Sie aus, ob Sie Ihre Änderungen oder die anderen Änderungen behalten möchten."
            ]

        YourChanges ->
            [ Text "Ihre Änderungen" ]

        TheirChanges ->
            [ Text "Deren Änderungen" ]

        ConfigurationDisabledWhileInGame ->
            [ Text "Während das Spiel läuft, können Sie die Konfiguration nicht ändern." ]

        ConfigurationDisabledIfNotPrivileged ->
            [ Text "Sie können die Konfiguration dieses Spiels nicht ändern." ]

        ConfigureNextGame ->
            [ Text "Nächstes Spiel konfigurieren" ]

        -- Game
        SubmitPlay ->
            [ Text "Geben Sie diese Karten dem ", ref Czar, Text " zum Abschluss dieser Runde." ]

        TakeBackPlay ->
            [ Text "Nehmen Sie Ihre Karten zurück, um Ihr Spiel für die Runde zu ändern." ]

        JudgePlay ->
            [ Text "Wählen Sie dieses Blatt als Rundensieger." ]

        LikePlay ->
            [ Text "Fügen Sie diesem Spiel ein Like hinzu." ]

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
            [ Text "Sehen Sie sich frühere Runden aus diesem Spiel an." ]

        ViewHelpAction ->
            [ Text "Hilfe" ]

        EnforceTimeLimitAction ->
            [ Text "Setzen Sie alle Spieler, auf die das Spiel wartet, auf Abwesend und überspringen Sie sie, bis sie zurückkehren." ]

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
            [ Text "Sie sind derzeit nicht im Spiel und spielen nicht." ]

        Discard ->
            [ Text "Werfen Sie die ausgewählte Karte ab und zeigen Sie sie den anderen Spielern im Spiel." ]

        Discarded { player } ->
            [ Text player
            , Text " hat die folgende Karte abgeworfen.:"
            ]

        -- Instructions
        PlayInstruction { numberOfCards } ->
            [ Text "Sie müssen "
            , Text (asWord numberOfCards)
            , Text " weitere "
            , ref (noun Response numberOfCards)
            , Text " von Ihrer Hand abwerfen, bevor die Runde übermittelt werden kann."
            ]

        SubmitInstruction ->
            [ Text "Sie müssen Ihr Blatt für diese Runde einreichen." ]

        WaitingForPlaysInstruction ->
            [ Text "Sie warten darauf, dass andere Spieler in die Runde spielen." ]

        CzarsDontPlayInstruction ->
            [ Text "Sie sind der "
            , ref Czar
            , Text " für diese Runde - Sie reichen keine "
            , ref (nounUnknownQuantity Response)
            , Text " ein. Stattdessen wählen Sie den Gewinner, sobald alle anderen ihre Beiträge eingereicht haben."
            ]

        NotInRoundInstruction ->
            [ Text "Sie sind nicht in dieser Runde. Sie spielen in der nächsten Runde, es sei denn, Sie sind auf Auswärtsspiel eingestellt." ]

        RevealPlaysInstruction ->
            [ Text "Klicken Sie auf die Karten, um sie umzudrehen, und wählen Sie dann die Antwort aus, die Ihnen am besten gefällt." ]

        WaitingForCzarInstruction ->
            [ Text "Sie können Spiele liken, während Sie auf die Gewinner-Auswahl durch den ", ref Czar, Text " warten." ]

        AdvanceRoundInstruction ->
            [ Text "Die nächste Runde hat begonnen, Sie können weitermachen." ]

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
            [ Text "Möglicherweise ist der Spielserver ausgefallen, oder es handelt sich um einen Fehler. Das Aktualisieren der Seite sollte Sie wieder in "
            , Text "Gang bringen. Weitere Einzelheiten finden Sie weiter unten."
            ]

        ErrorHelpTitle ->
            [ Text "Entschuldigung, etwas ist schief gelaufen." ]

        ErrorCheckOutOfBand ->
            [ Text "Bitte prüfen Sie ", ref TwitterHandle, Text " für Updates und Servicestatus. Der Spieleserver wird für eine kurze Zeit ausfallen, wenn eine neue Version veröffentlicht wird. Wenn Sie also ein aktuelles Update sehen, versuchen Sie es in ein paar Minuten erneut." ]

        TwitterHandle ->
            [ Text "@Massive_Decks" ]

        ReportError ->
            [ Text "Fehler melden" ]

        ReportErrorDescription ->
            [ Text "Informieren Sie die Entwickler über einen Fehler, auf den Sie gestoßen sind, damit sie ihn beheben können." ]

        ReportErrorBody ->
            [ Text "Ich war [ersetzen Sie durch eine kurze Erklärung, was Sie getan haben], als ich den folgenden Fehler erhielt:" ]

        BadUrlError ->
            [ Text "Wir haben versucht, einen Aufruf zu einer ungültigen Seite zu machen." ]

        TimeoutError ->
            [ Text "Der Server hat zu lange nicht geantwortet. Er ist möglicherweise ausgefallen, bitte versuchen Sie es nach einer kurzen Verzögerung erneut." ]

        NetworkError ->
            [ Text "Ihre Internetverbindung wurde unterbrochen." ]

        ServerDownError ->
            [ Text "Der Spielserver ist derzeit offline. Bitte versuchen Sie es später noch einmal." ]

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
            [ Text "Sie können diese Aktion nicht ausführen." ]

        IncorrectPlayerRoleError { role, expected } ->
            [ Text "Sie müssen ", ref expected, Text " sein, um das machen zu können. Sie sind aber ", ref role, Text "." ]

        IncorrectUserRoleError { role, expected } ->
            [ Text "Sie müssen ", ref expected, Text " sein, um das machen zu können. Sie sind aber ", ref role, Text "." ]

        IncorrectRoundStageError { stage, expected } ->
            [ Text "Die Runde muss bei der ", ref expected, Text " Phase sein, um das machen zu können. Derzeit läuft die Phase ", ref stage, Text "." ]

        ConfigEditConflictError ->
            [ Text "Jemand anderes hat die Konfiguration vor Ihnen geändert, Ihre Änderung wurde nicht gespeichert." ]

        UnprivilegedError ->
            [ Text "Sie haben nicht die Rechte, dies zu tun." ]

        GameNotStartedError ->
            [ Text "Dazu muss das Spiel gestartet sein." ]

        InvalidActionError { reason } ->
            [ Text "Der Server hat eine Anfrage des Clients nicht verstanden. Details: ", Text reason ]

        AuthenticationError ->
            [ Text "Sie können an diesem Spiel nicht teilnehmen." ]

        IncorrectIssuerError ->
            [ Text "Ihre Anmeldedaten für die Teilnahme an diesem Spiel sind veraltet, das Spiel existiert nicht mehr." ]

        InvalidAuthenticationError ->
            [ Text "Ihre Zugangsdaten für die Teilnahme an diesem Spiel sind fehlerhaft." ]

        InvalidLobbyPasswordError ->
            [ Text "Das von Ihnen angegebene Spiel-Kennwort war falsch. Versuchen Sie, es noch einmal einzugeben, und wenn es immer noch nicht funktioniert, fragen Sie die Person, die Sie eingeladen hat, noch einmal." ]

        AlreadyLeftError ->
            [ Text "Sie haben dieses Spiel bereits verlassen." ]

        LobbyNotFoundError ->
            [ Text "Dieses Spiel existiert nicht." ]

        LobbyClosedError { gameCode } ->
            [ Text "Das angegebene Spiel (", ref (GameCode { code = gameCode }), Text ") wurde bereit beendet." ]

        LobbyDoesNotExistError { gameCode } ->
            [ Text "Das angegebene Spiel-Kennwort ("
            , ref (GameCode { code = gameCode })
            , Text ") existiert nicht. "
            , Text "Versuchen Sie, es noch einmal einzugeben, und wenn es immer noch nicht funktioniert, fragen Sie die Person, die Sie eingeladen hat, noch einmal."
            ]

        RegistrationError ->
            [ Text "Problem bei der Teilnahme am Spiel." ]

        UsernameAlreadyInUseError { username } ->
            [ Text "Jemand benutzt bereits den Benutzernamen “"
            , Text username
            , Text "”— versuchen Sie einen anderen Namen."
            ]

        GameError ->
            [ Text "Irgendetwas ist im Spiel schief gelaufen." ]

        OutOfCardsError ->
            [ Text "Es waren nicht genug Karten im Stapel, um jedem eine Hand zu geben! Versuchen Sie, in der Spielkonfiguration weitere Kartensätze hinzuzufügen." ]

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
