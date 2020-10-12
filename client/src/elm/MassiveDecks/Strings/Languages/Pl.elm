module MassiveDecks.Strings.Languages.Pl exposing (pack)

{-| Polish localization.

Contributors:

  - TheChilliPL <https://github.com/TheChilliPL>

-}

import MassiveDecks.Card.Source.BuiltIn.Model as BuiltIn
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Strings exposing (MdString(..), Noun(..), Quantity(..), noun, nounUnknownQuantity)
import MassiveDecks.Strings.Languages.Model exposing (Language(..))
import MassiveDecks.Strings.Translation as Translation
import MassiveDecks.Strings.Translation.Model as Translation exposing (Result(..))


pack : Translation.Pack
pack =
    Translation.pack
        { lang = Pl
        , code = "pl"
        , name = Polish
        , translate = translate
        , recommended = "cah-base-en" |> BuiltIn.hardcoded |> Source.BuiltIn
        }



{- Private -}


raw : MdString -> Translation.Result DeclensionCase
raw =
    Raw Nothing


ref : MdString -> Translation.Result DeclensionCase
ref =
    Ref Nothing


refDecl : DeclensionCase -> MdString -> Translation.Result DeclensionCase
refDecl declCase =
    Ref (Just declCase)


{-| The Polish translation
-}
translate : Maybe DeclensionCase -> MdString -> List (Translation.Result DeclensionCase)
translate maybeDeclCase mdString =
    let
        declCase =
            maybeDeclCase |> Maybe.withDefault Nominative
    in
    case mdString of
        -- General
        MassiveDecks ->
            [ Text "Massive Decks" ]

        Close ->
            [ Text "Zamknij" ]

        -- -- Special
        Noun { noun, quantity } ->
            [ Text (decl noun quantity declCase) ]

        -- Start screen.
        Version { versionNumber } ->
            [ Text "Wersja „", Text versionNumber, Text "”" ]

        ShortGameDescription ->
            [ Text "Komediowa gra towarzyska." ]

        WhatIsThis ->
            [ Text "Czym jest ", ref MassiveDecks, Text "?" ]

        GameDescription ->
            [ ref MassiveDecks
            , Text " to komediowa gra towarzyska bazowana na "
            , refDecl Locative CardsAgainstHumanity
            , Text ", stworzona przez "
            , ref RereadGames
            , Text " i innych kontrybutorów—gra jest open-source z licencją "
            , ref License
            , Text ", więc możesz wesprzeć rozwój gry, sprawdzić kod źródłowy, lub po prostu dowiedzieć się więcej na jej "
            , refDecl Locative MDProject
            , Text "."
            ]

        NewGame ->
            [ Text "Nowa gra" ]

        NewGameDescription ->
            [ Text "Rozpocznij nową grę ", ref MassiveDecks, Text "." ]

        FindPublicGame ->
            [ Text "Znajdź" ]

        JoinPrivateGame ->
            [ Text "Dołącz" ]

        JoinPrivateGameDescription ->
            [ Text "Dołącz do gry do której ktoś cię zaprosił." ]

        PlayGame ->
            [ Text "Graj" ]

        AboutTheGame ->
            [ Text "O grze" ]

        AboutTheGameDescription ->
            [ Text "Dowiedz się więcej o ", ref MassiveDecks, Text " i o jego rozwoju." ]

        MDLogoDescription ->
            [ ref (noun Call 1), Text " i ", ref (noun Response 1), Text " podpisane literami „M” oraz „D”." ]

        RereadLogoDescription ->
            [ Text "Książka otoczona strzałką recyklingu." ]

        MDProject ->
            [ Text
                (case declCase of
                    Nominative ->
                        "projekt GitHubowy"

                    Genitive ->
                        "projektu GitHubowego"

                    Dative ->
                        "projektowi GitHubowemu"

                    Accusative ->
                        "projekt GitHubowy"

                    Instrumental ->
                        "projektem GitHubowym"

                    Locative ->
                        "projekcie GitHubowym"

                    Vocative ->
                        "projekcie GitHubowy"
                )
            ]

        License ->
            [ Text "AGPLv3" ]

        DevelopedByReread ->
            [ Text "Rozwijane przez ", ref RereadGames, Text "." ]

        RereadGames ->
            [ Text "Reread Games" ]

        NameLabel ->
            [ Text "Twoja nazwa" ]

        NameInUse ->
            [ Text "Ktoś już dołączył do gry z tą nazwą — spróbuj użyć innej." ]

        RejoinTitle ->
            [ Text "Dołącz ponownie" ]

        RejoinGame { code } ->
            [ Text "Dołącz do „", GameCode { code = code } |> ref, Text "”." ]

        LobbyRequiresPassword ->
            [ Text "Potrzebujesz hasła by dołączyć. Poproś o nie osobę która cię zaprosiła." ]

        YouWereKicked ->
            [ Text "Zostałeś wyrzucony z gry." ]

        ScrollToTop ->
            [ Text "Przewiń na górę." ]

        Copy ->
            [ Text "Kopiuj" ]

        -- Rules
        CardsAgainstHumanity ->
            [ Text
                (case declCase of
                    Nominative ->
                        "karty przeciwko ludzkości"

                    Genitive ->
                        "kart przeciwko ludzkości"

                    Dative ->
                        "kartom przeciwko ludzkości"

                    Accusative ->
                        "karty przeciwko ludzkości"

                    Instrumental ->
                        "kartami przeciwko ludzkości"

                    Locative ->
                        "kartach przeciwko ludzkości"

                    Vocative ->
                        "karty przeciwko ludzkości"
                )
            ]

        Rules ->
            [ Text "Jak grać." ]

        RulesHand ->
            [ Text "Każdy gracz ma w ręce ", refDecl Accusative (nounUnknownQuantity Response), Text "." ]

        RulesCzar ->
            [ Text "Pierwszy gracz zaczyna jako "
            , ref Czar
            , Text ". "
            , ref Czar
            , Text " czyta pytanie lub zdanie do uzupełnienia na "
            , refDecl Locative (noun Call 1)
            , Text " na głos."
            ]

        RulesPlaying ->
            [ Text "Cała reszta odpowiada na to pytanie lub uzupełnia lukę wybierając "
            , refDecl Accusative (noun Response 1)
            , Text " ze swojej ręki."
            ]

        RulesJudging ->
            [ Text "Odpowiedzi są wymieszane, a "
            , ref Czar
            , Text " czyta je wszystkim innym—dla pełnego efektu, "
            , ref Czar
            , Text " powinien zwykle czytać "
            , refDecl Accusative (noun Call 1)
            , Text " przed każdą z odpowiedzi. "
            , ref Czar
            , Text " następnie wybiera najśmieszniejszą, a ten kto ją wybrał dostaje "
            , refDecl Accusative (noun Point 1)
            , Text "."
            ]

        RulesPickTitle ->
            [ ref (Pick { numberOfCards = 2 }) ]

        RulesPick ->
            [ Text "Niektóre czarne karty potrzebują więcej niż jednej "
            , refDecl Genitive (noun Response 1)
            , Text " do odpowiedzi. Wybierz karty w kolejności w jakiej "
            , ref Czar
            , Text " powinien je przeczytać — to ważne."
            ]

        ExamplePickDescription ->
            [ Text "Takie "
            , ref (nounUnknownQuantity Call)
            , Text " wymagają wybierania większej ilości "
            , refDecl Genitive (nounUnknownQuantity Response)
            , Text ", ale dają większy wybór."
            ]

        RulesDraw ->
            [ Text "Niektóre "
            , ref (nounUnknownQuantity Call)
            , Text " potrzebują jeszcze więcej "
            , refDecl Genitive (nounUnknownQuantity Response)
            , Text " — będzie napisane "
            , ref (Draw { numberOfCards = 2 })
            , Text " lub więcej — tyle kart dostaniesz przed zagraniem."
            ]

        GameRulesTitle ->
            [ Text "Zasady Gry" ]

        HouseRulesTitle ->
            [ Text "Zasady specjalne" ]

        HouseRules ->
            [ Text "Możesz zmienić różne zasady tej gry na różne sposoby. Podczas ustawiania gry, wybierz tyle "
            , Text "domowych zasad ile tylko chcesz."
            ]

        HouseRuleReboot ->
            [ Text "Restart Wszechświata" ]

        HouseRuleRebootDescription { cost } ->
            [ Text "W każdej chwili gracze mogą wymienić "
            , refDecl Accusative
                (case cost of
                    Just 1 ->
                        noun Point 1

                    _ ->
                        nounUnknownQuantity Point
                )
            , Text " aby wyrzucić wszystkie karty i zacząć z nowymi."
            ]

        HouseRuleRebootAction { cost } ->
            [ Text "Wydaj "
            , Text (asWord cost Masculine)
            , Text " "
            , ref (noun Point cost)
            , Text " aby wyrzucić karty i dobrać nowe."
            ]

        HouseRuleRebootCost ->
            [ Text "Koszt użycia" ]

        HouseRuleRebootCostDescription ->
            [ Text "Ile "
            , refDecl Genitive (nounUnknownQuantity Point)
            , Text " kosztuje ponowne dobranie "
            , Text "wszystkich kart."
            ]

        HouseRulePackingHeat ->
            [ Text "Napakowany" ]

        HouseRulePackingHeatDescription ->
            [ Text "Wszystkie "
            , ref (nounUnknownQuantity Call)
            , Text " z "
            , ref (Pick { numberOfCards = 2 })
            , Text " także dostaną "
            , ref (Draw { numberOfCards = 1 })
            , Text ", aby wszyscy mieli więcej do wyboru."
            ]

        HouseRuleComedyWriter ->
            [ Text "Memiarz" ]

        HouseRuleComedyWriterDescription ->
            [ Text "Dodaj puste "
            , ref (nounUnknownQuantity Response)
            , Text " na których gracze mogą pisać własne odpowiedzi."
            ]

        HouseRuleComedyWriterNumber ->
            [ Text "Puste ", ref (nounUnknownQuantity Response) ]

        HouseRuleComedyWriterNumberDescription ->
            [ Text "Ilość pustych "
            , refDecl Genitive (nounUnknownQuantity Response)
            , Text " które znajdą się w grze."
            ]

        HouseRuleComedyWriterExclusive ->
            [ Text "Tylko puste ", ref (nounUnknownQuantity Response) ]

        HouseRuleComedyWriterExclusiveDescription ->
            [ Text "Po włączeniu, wszystkie "
            , ref (nounUnknownQuantity Response)
            , Text " z talii znikną, i tylko puste zostaną w grze."
            ]

        HouseRuleRandoCardrissian ->
            [ Text "Rando Cardrissian" ]

        HouseRuleRandoCardrissianDescription ->
            [ Text "W każdej rundzie, pierwsza "
            , ref (noun Response 1)
            , Text " z talii zostanie wybrana jako odpowiedź. Należy ona do bota nazwanego "
            , Text "Rando Cardrissian, a jeśli on wygra, wszyscy gracze wrócą do domu z niekończącym się wstydem."
            ]

        HouseRuleRandoCardrissianNumber ->
            [ Text "Ilość botów" ]

        HouseRuleRandoCardrissianNumberDescription ->
            [ Text "Ilość botów, które znajdą się w grze." ]

        HouseRuleNeverHaveIEver ->
            [ Text "Nigdy w życiu nie…" ]

        HouseRuleNeverHaveIEverDescription ->
            [ Text "W każdej chwili, gracz może pozbyć się kart których nie rozumie, ale musi wyznać swą "
            , Text "ignorancję: wyrzucona karta będzie publicznie widoczna."
            ]

        HouseRuleHappyEnding ->
            [ Text "Szczęśliwe zakończenie" ]

        HouseRuleHappyEndingDescription ->
            [ Text "Gdy gra się kończy, ostatnią czarną kartą jest „Stwórz haiku”." ]

        MustBeMoreThanOrEqualValidationError { min } ->
            [ Text "Wartość musi być większa lub równa ", Text (String.fromInt min), Text "." ]

        MustBeLessThanOrEqualValidationError { max } ->
            [ Text "Wartość nie może przekraczać ", Text (String.fromInt max), Text "." ]

        SetValue { value } ->
            [ Text "Ustaw wartość na ", Text (String.fromInt value), Text "." ]

        CantBeEmpty ->
            [ Text "To pole nie może być puste." ]

        SettingsTitle ->
            [ Text "Ustawienia" ]

        LanguageSetting ->
            [ Text "Język" ]

        MissingLanguage ->
            [ Text "Nie widzisz swojego języka na liście? ", ref TranslationBeg ]

        AutonymFormat { autonym } ->
            [ Text "(", Text autonym, Text ")" ]

        TranslationBeg ->
            [ Text "Pomóż przetłumaczyć "
            , ref MassiveDecks
            , Text "!"
            ]

        CardSizeSetting ->
            [ Text "Kompaktowe karty" ]

        CardSizeExplanation ->
            [ Text "Dostosuj wielkość kart — przydatne na mniejszych ekranach, aby mniej przewijać." ]

        AutoAdvanceSetting ->
            [ Text "Automatyczne przejście do następnej rundy" ]

        AutoAdvanceExplanation ->
            [ Text "Kiedy runda się kończy, automatycznie przejdź do następnej, bez czekania na potwierdzenie." ]

        SpeechSetting ->
            [ Text "Syntezator mowy" ]

        SpeechExplanation ->
            [ Text "Przeczytaj karty używając syntezatora mowy." ]

        SpeechNotSupportedExplanation ->
            [ Text "Twoja przeglądarka nie obsługuje syntezy mowy, lub żaden syntezator nie jest zainstalowany." ]

        VoiceSetting ->
            [ Text "Głos syntezatora" ]

        NotificationsSetting ->
            [ Text "Powiadomienia przeglądarki" ]

        NotificationsExplanation ->
            [ Text "Powiadomi cię gdy musisz coś zrobić w grze, używając powiadomień przeglądarki."
            ]

        NotificationsUnsupportedExplanation ->
            [ Text "Twoja przeglądarka nie obsługuje powiadomień." ]

        NotificationsBrowserPermissions ->
            [ Text "Musisz dać uprawnienia grze "
            , ref MassiveDecks
            , Text ", aby mogła używać powiadomień. Będzie to używane tylko podczas gry jeśli ta opcja jest włączona."
            ]

        NotificationOnlyWhenHiddenSetting ->
            [ Text "Tylko w tle" ]

        NotificationsOnlyWhenHiddenExplanation ->
            [ Text "Wysyła powiadomienia tylko wtedy, gdy nie patrzysz na grę (np. jesteś w innej karcie lub okno jest"
            , Text "zminimalizowane)."
            ]

        NotificationsOnlyWhenHiddenUnsupportedExplanation ->
            [ Text "Twoja przeglądarka nie obsługuje sprawdzania widzialności strony." ]

        -- Terms
        Czar ->
            [ Text
                (case declCase of
                    Nominative ->
                        "Karciany Car"

                    Genitive ->
                        "Karcianego Cara"

                    Dative ->
                        "Karcianemu Carowi"

                    Accusative ->
                        "Karcianego Cara"

                    Instrumental ->
                        "Karcianym Carem"

                    Locative ->
                        "Karcianym Carze"

                    Vocative ->
                        "Karciany Carze"
                )
            ]

        CzarDescription ->
            [ Text "Gracz oceniający odpowiedzi." ]

        CallDescription ->
            [ Text "Czarna karta z pytaniem lub luką do uzupełnienia." ]

        ResponseDescription ->
            [ Text "Biała karta z wyrażeniem używanym jako odpowiedź." ]

        PointDescription ->
            [ Text "Punkt—kto ma ich więcej, ten wygrywa." ]

        GameCodeTerm ->
            [ Text
                (if declCase == Nominative then
                    "Kod gry"

                 else
                    "kod gry"
                )
            ]

        GameCodeDescription ->
            [ Text "Kod dzięki któremu inni mogą dołączyć do tej gry." ]

        GameCode { code } ->
            [ Text code ]

        GameCodeSpecificDescription ->
            [ Text "Wyślij ten kod znajomym, aby mogli dołączyć do gry." ]

        GameCodeHowToAcquire ->
            [ Text "Zapytaj zapraszającego o ", refDecl Accusative GameCodeTerm, Text "." ]

        Deck ->
            [ Text "Talia" ]

        DeckSource ->
            [ Text "Źródło talii" ]

        DeckLanguage { language } ->
            [ Text "w języku ", Text language ]

        DeckAuthor { author } ->
            [ Text "od ", Text author ]

        DeckTranslator { translator } ->
            [ Text "tłumaczona przez ", Text translator ]

        StillPlaying ->
            [ Text "Grający" ]

        PlayingDescription ->
            [ Text "Ten gracz jest w grze, ale nie wybrał swojej karty." ]

        Played ->
            [ Text "Gotowy" ]

        PlayedDescription ->
            [ Text "Ten gracz już wybrał swoją kartę w tej rundzie." ]

        -- Lobby Browser
        LobbyBrowserTitle ->
            [ Text "Gry publiczne" ]

        NoPublicGames ->
            [ Text "Żadna publiczna gra nie jest dostępna." ]

        PlayingGame ->
            [ Text "Gry w trakcie" ]

        SettingUpGame ->
            [ Text "Gry które jeszcze się nie zaczęły." ]

        StartYourOwn ->
            [ Text "Rozpocząć nową grę?" ]

        -- Spectation
        JoinTheGame ->
            [ Text "Dołącz do gry!" ]

        ToggleAdvertDescription ->
            [ Text "Pokaż informacje o dołączaniu do gry." ]

        -- Cards
        Pick numberOfCards ->
            [ Text "Wybierz", ref (NumberOfCards numberOfCards) ]

        Draw numberOfCards ->
            [ Text "Dobierz", ref (NumberOfCards numberOfCards) ]

        PickDescription { numberOfCards } ->
            [ Text "Musisz wybrać "
            , Text (asWord numberOfCards Feminine)
            , Text " "
            , refDecl Accusative (noun Response numberOfCards)
            , Text "."
            ]

        DrawDescription { numberOfCards } ->
            [ Text "Dostajesz "
            , Text (asWord numberOfCards Feminine)
            , Text " "
            , Text
                (case numberOfCards of
                    1 ->
                        "dodatkową"

                    _ ->
                        let
                            realCase =
                                paucal Accusative (Quantity numberOfCards)
                        in
                        if realCase == Genitive then
                            "dodatkowych"

                        else
                            "dodatkowe"
                )
            , Text " "
            , refDecl Accusative (noun Response numberOfCards)
            , Text " przed zagraniem."
            ]

        NumberOfCards { numberOfCards } ->
            [ Text (String.fromInt numberOfCards) ]

        -- Lobby
        LobbyNameLabel ->
            [ Text "Nazwa gry" ]

        DefaultLobbyName { owner } ->
            [ Text "Gra ", Text owner ]

        Invite ->
            [ Text "Zaproś graczy do gry." ]

        InviteLinkHelp ->
            [ Text "Wyślij ten link do graczy, których chcesz zaprosić, lub daj im kod QR do zeskanowania." ]

        InviteExplanation { gameCode, password } ->
            let
                extra =
                    password
                        |> Maybe.map
                            (\p ->
                                [ Text " oraz hasło gry: „"
                                , Text p
                                , Text "”"
                                ]
                            )
                        |> Maybe.withDefault []
            in
            List.concat
                [ [ Text "Twój kod gry to "
                  , ref (GameCode { code = gameCode })
                  , Text ". Gracze mogą dołączyć do gry otwierając "
                  , ref MassiveDecks
                  , Text " i wpisując ten kod"
                  ]
                , extra
                , [ Text "."
                  ]
                ]

        Cast ->
            [ Text "Wyślij na ekran." ]

        CastConnecting ->
            [ Text "Łączenie…" ]

        CastConnected { deviceName } ->
            [ Text "Wysyłanie obrazu do urządzenia ", Text deviceName, Text "." ]

        Players ->
            [ ref (nounUnknownQuantity Player) ]

        PlayersDescription ->
            [ Text "Użytkownicy w grze." ]

        Spectators ->
            [ ref (nounUnknownQuantity Spectator) ]

        SpectatorsDescription ->
            [ Text "Użytkownicy oglądający grę, ale nie grający." ]

        Left ->
            [ Text "Opuścili grę" ]

        LeftDescription ->
            [ Text "Użytkownicy którzy wyszli z gry." ]

        Away ->
            [ Text "Poza grą" ]

        AwayDescription ->
            [ Text "Użytkownicy którzy tymczasowo są poza grą." ]

        Disconnected ->
            [ Text "Rozłączony" ]

        DisconnectedDescription ->
            [ Text "Ten użytkownik stracił połączenie." ]

        Privileged ->
            [ Text "Właściciel" ]

        PrivilegedDescription ->
            [ Text "Ten użytkownik może dostosować ustawienia gry." ]

        Ai ->
            [ Text "Bot" ]

        AiDescription ->
            [ Text "Ten gracz jest kontrolowany przez komputer." ]

        Score { total } ->
            [ Text (String.fromInt total) ]

        ScoreDescription ->
            [ Text "Liczba "
            , refDecl Genitive (nounUnknownQuantity Point)
            , Text " które ma ten gracz."
            ]

        Likes { total } ->
            [ Text (String.fromInt total) ]

        LikesDescription ->
            [ Text "Liczba otrzymanych polubień." ]

        ToggleUserList ->
            [ Text "Ukryj lub pokaż listę graczy." ]

        GameMenu ->
            [ Text "Menu gry." ]

        UnknownUser ->
            [ Text "Nieznany użytkownik" ]

        InvitePlayers ->
            [ Text "Zaproś graczy" ]

        InvitePlayersDescription ->
            [ Text "Pokaż kod gry/link/kod QR, aby inni mogli dołączyć." ]

        SetAway ->
            [ Text "Oznacz jako poza grą" ]

        SetBack ->
            [ Text "Oznacz jako aktywny" ]

        LeaveGame ->
            [ Text "Opuść grę" ]

        LeaveGameDescription ->
            [ Text "Opuść grę na stałe." ]

        Spectate ->
            [ Text "Widok obserwatora" ]

        SpectateDescription ->
            [ Text "Pokaż widok obserwatora gry w nowej karcie/oknie." ]

        BecomeSpectator ->
            [ Text "Obserwuj" ]

        BecomeSpectatorDescription ->
            [ Text "Zacznij oglądać grę innych graczy." ]

        BecomePlayer ->
            [ Text "Zagraj" ]

        BecomePlayerDescription ->
            [ Text "Dołącz do gry." ]

        EndGame ->
            [ Text "Zakończ grę" ]

        EndGameDescription ->
            [ Text "Zakończ grę teraz." ]

        ReturnViewToGame ->
            [ Text "Wróć do gry" ]

        ReturnViewToGameDescription ->
            [ Text "Wróć do podstawowego widoku gry." ]

        ViewConfiguration ->
            [ Text "Konfiguruj" ]

        ViewConfigurationDescription ->
            [ Text "Pokaż konfigurację gry." ]

        KickUser ->
            [ Text "Wyrzuć" ]

        Promote ->
            [ Text "Awansuj" ]

        Demote ->
            [ Text "Zdegraduj" ]

        -- Notifications
        UserConnected { username } ->
            [ Text username, Text " wrócił do gry." ]

        UserDisconnected { username } ->
            [ Text username, Text " rozłączył się." ]

        UserJoined { username } ->
            [ Text username, Text " dołączył do gry." ]

        UserLeft { username } ->
            [ Text username, Text " opuścił grę." ]

        UserKicked { username } ->
            [ Text username, Text " został wyrzucony z gry." ]

        Dismiss ->
            [ Text "Zamknij" ]

        -- Configuration
        ConfigureTitle ->
            [ Text "Ustawienia gry" ]

        NoDecks ->
            [ Segment [ Text "Brak talii. " ]
            , Text " "
            , Segment [ Text "Potrzeba co najmniej jednej talii aby zacząć grę." ]
            ]

        NoDecksHint ->
            [ Text "Nie jesteś pewien? Dodaj oryginalną talię z "
            , refDecl Genitive CardsAgainstHumanity
            , Text " (po angielsku)."
            ]

        WaitForDecks ->
            [ Text "Talie muszą się załadować przed rozpoczęciem gry." ]

        MissingCardType { cardType } ->
            [ Text "Żadna z talii nie zawiera żadnych "
            , refDecl Genitive (nounUnknownQuantity cardType)
            , Text ". Potrzebujesz je mieć do rozpoczęcia gry."
            ]

        NotEnoughCardsOfType { cardType, needed, have } ->
            [ Text "Dla tej liczby graczy, potrzebujesz co najmniej "
            , Text (asWord needed Feminine)
            , Text " "
            , ref (noun cardType needed)
            , Text ", ale masz tylko "
            , Text (asWord have Feminine)
            , Text "."
            ]

        AddBlankCards { amount } ->
            [ Text "Dodaj "
            , Text (asWord amount Feminine)
            , Text " "
            , Text
                (case amount of
                    1 ->
                        "pustą"

                    _ ->
                        let
                            realCase =
                                paucal Accusative (Quantity amount)
                        in
                        if realCase == Genitive then
                            "pustych"

                        else
                            "puste"
                )
            , Text " "
            , refDecl Accusative (noun Response amount)
            , Text "."
            ]

        AddDeck ->
            [ Text "Dodaj talię." ]

        RemoveDeck ->
            [ Text "Usuń talię." ]

        SourceNotFound { source } ->
            [ ref source, Text " nie zawiera talii którą podałeś. Sprawdź czy wszystkie podane informacje są poprawne." ]

        SourceServiceFailure { source } ->
            [ ref source, Text " nie mógł z jakiegoś powodu odesłać talii. Spróbuj ponownie później lub skorzystaj z innego źródła." ]

        ManyDecks ->
            [ Text "Many Decks" ]

        ManyDecksDeckCodeTitle ->
            [ Text "Kod talii" ]

        ManyDecksDeckCodeShort ->
            [ Text "Kod talii musi mieć co najmniej 5 znaków." ]

        ManyDecksWhereToGet ->
            [ Text "Możesz stworzyć lub znaleźć talie na ", ref ManyDecks, Text "." ]

        JsonAgainstHumanity ->
            [ Text "JSON Against Humanity" ]

        JsonAgainstHumanityAbout ->
            [ Text "Talie dostarczone przez ", ref JsonAgainstHumanity, Text "." ]

        BuiltIn ->
            [ Text "Wbudowane" ]

        APlayer ->
            [ Text "Gracz" ]

        -- TODO: Translate
        Generated { by } ->
            [ Missing ]

        DeckAlreadyAdded ->
            [ Text "Ta talia jest już w grze." ]

        ConfigureDecks ->
            [ Text "Talie" ]

        ConfigureRules ->
            [ Text "Zasady" ]

        ConfigureTimeLimits ->
            [ Text "Limity czasowe" ]

        ConfigurePrivacy ->
            [ Text "Prywatność" ]

        HandSize ->
            [ Text "Liczba kart w ręce" ]

        HandSizeDescription ->
            [ Text "Podstawowa liczba kart jakie mają gracze podczas gry." ]

        ScoreLimit ->
            [ Text "Limit ", refDecl Genitive (nounUnknownQuantity Point) ]

        ScoreLimitDescription ->
            [ Segment
                [ Text "Liczba "
                , refDecl Genitive (nounUnknownQuantity Point)
                , Text " jaką potrzebuje gracz do wygrania gry."
                ]
            , Text " "
            , Segment [ Text "Jeśli wyłączone, gra trwa w nieskończoność." ]
            ]

        UnsavedChangesWarning ->
            [ Text "Masz niezapisane zmiany w konfiguracji, musisz je zapisać jeśli chcesz zmienić zasady gry." ]

        SaveChanges ->
            [ Text "Zapisz zmiany." ]

        RevertChanges ->
            [ Text "Odrzuć zmiany." ]

        NeedAtLeastOneDeck ->
            [ Text "Potrzebujesz co najmniej jednej talii aby zacząć grę." ]

        NeedAtLeastThreePlayers ->
            [ Text "Potrzebujesz co najmniej trzech graczy aby zacząć grę." ]

        NeedAtLeastOneHuman ->
            [ Text "Niestety boty nie mogą wybierać kart jako Car"
            , Text ", więc potrzebujesz minimum jednego ludzkiego gracza."
            , Text " (Chociaż z tylko jednym człowiekiem może być nudno!)"
            ]

        RandoCantWrite ->
            [ Text "Boty nie mogą pisać własnych kart." ]

        DisableComedyWriter ->
            [ Text "Wyłącz Memiarza" ]

        DisableRando ->
            [ Text "Wyłącz Rando Cardrissiana" ]

        AddAnAiPlayer ->
            [ Text "Dodaj bota do gry." ]

        PasswordShared ->
            [ Text "Wszyscy w grze mogą zobaczyć hasło! "
            , Text "Ukrywanie dotyczy tylko ciebie (przydatne gdy streamujesz, itd…)."
            ]

        PasswordNotSecured ->
            [ Text "Hasła gry "
            , Em [ Text "nie są" ]
            , Text " przechowywane bezpiecznie — "
            , Em [ Text "nie używaj" ]
            , Text " prawdziwych haseł jak w innych miejscach!"
            ]

        LobbyPassword ->
            [ Text "Hasło gry" ]

        LobbyPasswordDescription ->
            [ Text "Hasło które gracze muszą wpisać przed dołączeniem do gry." ]

        AudienceMode ->
            [ Text "Tryb widowni" ]

        AudienceModeDescription ->
            [ Text "Jeśli włączone, nowi gracze będą domyślnie obserwatorami, i tylko ty będziesz mógł "
            , Text "dodać ich do gry."
            ]

        StartGame ->
            [ Text "Rozpocznij grę" ]

        Public ->
            [ Text "Gra publiczna" ]

        PublicDescription ->
            [ Text "Jeśli włączone, gra będzie pokazana na publicznej liście gier i każdy będzie mógł dołączyć." ]

        ApplyConfiguration ->
            [ Text "Zastosuj zmianę." ]

        AppliedConfiguration ->
            [ Text "Zapisano." ]

        InvalidConfiguration ->
            [ Text "Ta wartość konfiguracji nie jest poprawna." ]

        Automatic ->
            [ Text "Automatycznie oznaczaj graczy jako poza grą" ]

        AutomaticDescription ->
            [ Text "Jeśli włączone, po skończeniu limitu czasowego, gracze zostaną automatycznie oznaczeni jako poza grą. "
            , Text "W przeciwnym wypadku będzie ktoś musiał oznaczać ich ręcznie"
            ]

        TimeLimit { stage } ->
            [ Text "Limit czasowy ", refDecl Genitive stage ]

        PlayingTimeLimitDescription ->
            [ Text "Jak długo (w sekundach) mają ", ref Players, Text " na wybór swoich kart." ]

        PlayingAfterDescription ->
            [ Text "Jak długo (w sekundach) mają ", ref Players, Text " na zmianę przed rozpoczęciem kolejnego etapu." ]

        RevealingTimeLimitDescription ->
            [ Text "Jak długo (w sekundach) ma ", ref Czar, Text " na odkrycie kart." ]

        RevealingAfterDescription ->
            [ Text "Jak długo (w sekundach) czekać na rozpoczęcie kolejnego etapu po odkryciu kart." ]

        JudgingTimeLimitDescription ->
            [ Text "Jak długo (w sekundach) ma ", ref Czar, Text " na wybranie najlepszej karty." ]

        CompleteTimeLimitDescription ->
            [ Text "Jak długo (w sekundach) czekać po zakończeniu całej rundy przed rozpoczęciem kolejnej." ]

        RevealingEnabledTitle ->
            [ Text "Car odkrywa odpowiedzi" ]

        RevealingEnabled ->
            [ Text "Jeśli włączone, "
            , ref Czar
            , Text " odkrywa odpowiedzi po kolei przed wybraniem najlepszej."
            ]

        DuringTitle ->
            [ Text "Limit czasowy" ]

        AfterTitle ->
            [ Text "Po rundzie" ]

        Conflict ->
            [ Text "Konflikt" ]

        ConflictDescription ->
            [ Text "Ktoś inny zmienił te ustawienia w tym samym czasie co ty. "
            , Text "Wybierz czy chcesz zachować twoje zmiany czy tamtej osoby."
            ]

        YourChanges ->
            [ Text "Moje zmiany" ]

        TheirChanges ->
            [ Text "Zmiany drugiej osoby" ]

        ConfigurationDisabledWhileInGame ->
            [ Text "Podczas gdy gra jest w trakcie, nie można zmieniać konfiguracji." ]

        ConfigurationDisabledIfNotPrivileged ->
            [ Text "Nie możesz zmienić konfiguracji tej gry." ]

        ConfigureNextGame ->
            [ Text "Skonfiguruj następną grę" ]

        -- Game
        SubmitPlay ->
            [ Text "Daj te karty ", refDecl Dative Czar, Text " jako odpowiedzi w tej rundzie." ]

        TakeBackPlay ->
            [ Text "Wycofaj swoje karty w tej rundzie aby je zmienić." ]

        JudgePlay ->
            [ Text "Wybierz tę odpowiedź jako najlepszą w tej rundzie." ]

        LikePlay ->
            [ Text "Polub tę odpowiedź." ]

        AdvanceRound ->
            [ Text "Następna runda." ]

        Playing ->
            [ Text "Odpowiadanie" ]

        Revealing ->
            [ Text "Odkrywanie" ]

        Judging ->
            [ Text "Ocenianie" ]

        Complete ->
            [ Text "Ukończono" ]

        ViewGameHistoryAction ->
            [ Text "Pokaż poprzednie rundy tej gry." ]

        ViewHelpAction ->
            [ Text "Pomoc" ]

        EnforceTimeLimitAction ->
            [ Text "Ustaw wszystkich graczy którzy nie wykonali wyboru jako poza grą i pomijaj ich kolej aż wrócą." ]

        Blank ->
            [ Text "Puste pole" ]

        RoundStarted ->
            [ Text "Runda rozpoczęta" ]

        JudgingStarted ->
            [ Text "Ocenianie rozpoczęte" ]

        Paused ->
            [ Text "Gra została zatrzymana ponieważ nie ma wystarczającej liczby graczy by kontynuować."
            , Text "Gdy ktoś dołączy lub wróci, gra zostanie automatycznie wznowiona."
            ]

        ClientAway ->
            [ Text "Jesteś oznaczony obecnie jako poza grą, więc twoje kolejki są pomijane." ]

        Discard ->
            [ Text "Odrzuć tę kartę, pokazując ją wszystkim innym w grze." ]

        Discarded { player } ->
            [ Text player
            , Text " odrzucił następującą kartę:"
            ]

        -- Instructions
        PlayInstruction { numberOfCards } ->
            [ Text "Musisz wybrać jeszcze "
            , Text (asWord numberOfCards Feminine)
            , refDecl Accusative (noun Response numberOfCards)
            , Text " z ręki w tej rundzie, aby wysłać odpowiedź."
            ]

        SubmitInstruction ->
            [ Text "Musisz wysłać odpowiedź w tej rundzie." ]

        WaitingForPlaysInstruction ->
            [ Text "Czekaj aż inni gracze wyślą swoje odpowiedzi." ]

        CzarsDontPlayInstruction ->
            [ Text "Jesteś "
            , refDecl Instrumental Czar
            , Text " w tej rundzie - nie wybierasz żadnych "
            , refDecl Genitive (nounUnknownQuantity Response)
            , Text ". Zamiast tego gdy reszta wybierze odpowiedzi, ty wybierzesz zwycięzcę."
            ]

        NotInRoundInstruction ->
            [ Text "Nie bierzesz udziału w tej rundzie. Weźmiesz udział w kolejnej o ile nie jesteś poza grą." ]

        RevealPlaysInstruction ->
            [ Text "Klikaj na karty by je odkryć, po czym wybierz najlepszą z odpowiedzi." ]

        WaitingForCzarInstruction ->
            [ Text "Możesz polubić odpowiedzi podczas gdy ", ref Czar, Text " odkrywa kolejne i wybiera zwycięzcę." ]

        AdvanceRoundInstruction ->
            [ Text "Następna runda się zaczęła, możesz kontynuować." ]

        -- 404 Unknown
        UnknownPageTitle ->
            [ Text "Błąd 404: Nie znaleziono strony." ]

        GoBackHome ->
            [ Text "Wróć na stronę główną." ]

        -- Actions
        Refresh ->
            [ Text "Odśwież" ]

        Accept ->
            [ Text "OK" ]

        -- Errors
        Error ->
            [ Text "Błąd" ]

        ErrorHelp ->
            [ Text "Serwery gry mogą nie działać lub mógł wystąpić błąd. Odświeżenie strony może "
            , Text "pomóc. Więcej szczegółów jest poniżej."
            ]

        ErrorHelpTitle ->
            [ Text "Wybacz, coś poszło nie tak." ]

        ErrorCheckOutOfBand ->
            [ Text "Prosimy sprawdzić aktualizacje i status na "
            , ref TwitterHandle
            , Text ". Serwery gry są wyłączane na krótki czas podczas aktualizacji, więc jeśli taka nastąpiła ostatnio, "
            , Text "spróbuj ponownie za kilka minut."
            ]

        TwitterHandle ->
            [ Text "@Massive_Decks" ]

        ReportError ->
            [ Text "Zgłoś błąd" ]

        ReportErrorDescription ->
            [ Text "Zgłoś twórcom napotkany błąd aby mogli go naprawić." ]

        ReportErrorBody ->
            [ Text "Napisz co robiłeś gdy wystąpił błąd:" ]

        BadUrlError ->
            [ Text "Wysłano zapytanie na nieprawidłową stronę." ]

        TimeoutError ->
            [ Text "Serwer zbyt długo nie odpowiadał. Może mieć awarię, spróbuj ponownie za chwilę." ]

        NetworkError ->
            [ Text "Twoje połączenie zostało przerwane." ]

        ServerDownError ->
            [ Text "Serwer gry jest obecnie niedostępny. Spróbuj ponownie później." ]

        BadStatusError ->
            [ Text "Serwer odpowiedział w niespodziewany sposób." ]

        BadPayloadError ->
            [ Text "Serwer odpowiedział w nieprawidłowy sposób." ]

        PatchError ->
            [ Text "Łatka od serwera nie mogła zostać użyta." ]

        VersionMismatch ->
            [ Text "Serwer odpowiedział nieprawidłową wersją." ]

        CastError ->
            [ Text "Przepraszamy, wystąpił błąd podczas dołączania do gry." ]

        ActionExecutionError ->
            [ Text "Nie możesz tego zrobić." ]

        IncorrectPlayerRoleError { role, expected } ->
            [ Text "Musisz być ", ref expected, Text " do tego, a jesteś ", ref role, Text "." ]

        IncorrectUserRoleError { role, expected } ->
            [ Text "Musisz być ", ref expected, Text " do tego, a jesteś ", ref role, Text "." ]

        IncorrectRoundStageError { stage, expected } ->
            [ Text "Runda musi być na etapie ", ref expected, Text ", a jest na etapie ", ref stage, Text " stage." ]

        ConfigEditConflictError ->
            [ Text "Ktoś inny zmienił konfigurację przed tobą, twoje zmiany nie zostały zapisane." ]

        UnprivilegedError ->
            [ Text "Nie masz permisji do wykonania tej akcji." ]

        GameNotStartedError ->
            [ Text "Aby to zrobić, gra musi być rozpoczęta." ]

        InvalidActionError { reason } ->
            [ Text "Serwer nie zrozumiał zapytania klienta. Szczegóły: ", Text reason ]

        AuthenticationError ->
            [ Text "Nie możesz dołączyć do tej gry." ]

        IncorrectIssuerError ->
            [ Text "Twoje dane dostępu do gry są nieaktualne, gra nie istnieje." ]

        InvalidAuthenticationError ->
            [ Text "Twoje dane dostępu do gry są uszkodzone." ]

        InvalidLobbyPasswordError ->
            [ Text "Podane hasło gry jest nieprawidłowe. Spróbuj wpisać je jeszcze raz, i jeśli to nie zadziała, "
            , Text "zapytaj znów osobę która cię zaprosiła."
            ]

        AlreadyLeftError ->
            [ Text "Już opuściłeś tę grę." ]

        LobbyNotFoundError ->
            [ Text "Ta gra nie istnieje." ]

        LobbyClosedError { gameCode } ->
            [ Text "Gra do której chcesz dołączyć (", ref (GameCode { code = gameCode }), Text ") zakończyła się." ]

        LobbyDoesNotExistError { gameCode } ->
            [ Text "Gra o podanym kodzie ("
            , ref (GameCode { code = gameCode })
            , Text ") nie istnieje. "
            , Text "Spróbuj wpisać go jeszcze raz, i jeśli to nie zadziała, zapytaj znów osobę która cię zaprosiła."
            ]

        RegistrationError ->
            [ Text "Wystąpił problem przy dołączaniu do gry." ]

        UsernameAlreadyInUseError { username } ->
            [ Text "Ktoś już korzysta z nazwy „"
            , Text username
            , Text "” — wybierz inną nazwę."
            ]

        GameError ->
            [ Text "Wystąpił błąd podczas gry." ]

        OutOfCardsError ->
            [ Text "Nie ma wystarczającej liczby kart by wszystkim rozdać! Spróbuj dodać więcej talii w konfiguracji." ]

        -- Language Names
        English ->
            [ Text "Angielski" ]

        BritishEnglish ->
            [ Text "Angielski (brytyjski)" ]

        Italian ->
            [ Text "Włoski" ]

        BrazilianPortuguese ->
            [ Text "Portugalski (brazylijski)" ]

        German ->
            [ Text "Niemiecki (formalny)" ]

        GermanInformal ->
            [ Text "Niemiecki (nieformalny)" ]

        Polish ->
            [ Text "Polski" ]

        Indonesian ->
            [ Text "Indonezyski" ]


type DeclensionCase
    = Nominative -- Mianownik   kto co
    | Genitive -- Dopełniacz  kogo czego
    | Dative -- Celownik    komu czemu
    | Accusative -- Biernik     kogo co
    | Instrumental -- Narzędnik   z kim z czym
    | Locative -- Miejscownik o kim o czym
    | Vocative -- Wołacz


type alias ByDeclensionCase =
    { nominative : String
    , genitive : String
    , dative : String
    , accusative : String
    , instrumental : String
    , locative : String
    , vocative : String
    }


type alias ByQuantity =
    { singular : ByDeclensionCase
    , plural : ByDeclensionCase
    }


getByCase : DeclensionCase -> ByDeclensionCase -> String
getByCase declCase =
    case declCase of
        Nominative ->
            .nominative

        Genitive ->
            .genitive

        Dative ->
            .dative

        Accusative ->
            .accusative

        Instrumental ->
            .instrumental

        Locative ->
            .locative

        Vocative ->
            .vocative


getByQuantity : Quantity -> ByQuantity -> ByDeclensionCase
getByQuantity quantity =
    case quantity of
        Quantity 1 ->
            .singular

        _ ->
            .plural


{-| Gets a new declension case according to the paucal plural rules.
In some cases, it shifts the declension case to genitive.
-}
paucal : DeclensionCase -> Quantity -> DeclensionCase
paucal declCase quantity =
    case quantity of
        Unknown ->
            declCase

        Quantity 1 ->
            declCase

        Quantity fullQ ->
            let
                q100 =
                    modBy 100 fullQ

                paucalUseGenitive =
                    if q100 >= 5 && q100 <= 21 then
                        True

                    else
                        let
                            q10 =
                                modBy 10 q100
                        in
                        q10 <= 1 || q10 >= 5
            in
            if paucalUseGenitive then
                Genitive

            else
                declCase


declTable : Noun -> ByQuantity
declTable noun =
    case noun of
        Call ->
            { singular =
                ByDeclensionCase
                    "czarna karta"
                    "czarnej karty"
                    "czarnej karcie"
                    "czarną kartę"
                    "czarną kartą"
                    "czarnej karcie"
                    "czarna karto"
            , plural =
                ByDeclensionCase
                    "czarne karty"
                    "czarnych kart"
                    "czarnym kartom"
                    "czarne karty"
                    "czarnymi kartami"
                    "czarnych kartach"
                    "czarne karty"
            }

        Response ->
            { singular =
                ByDeclensionCase
                    "biała karta"
                    "białej karty"
                    "białej karcie"
                    "białą kartę"
                    "białą kartą"
                    "białej karcie"
                    "biała karto"
            , plural =
                ByDeclensionCase
                    "białe karty"
                    "białych kart"
                    "białym kartom"
                    "białe karty"
                    "białymi kartami"
                    "białych kartach"
                    "białe karty"
            }

        Point ->
            { singular =
                ByDeclensionCase
                    "superowy punkt"
                    "superowego punktu"
                    "superowemu punktowi"
                    "superowy punkt"
                    "superowym punktem"
                    "superowym punkcie"
                    "superowy punkcie"
            , plural =
                ByDeclensionCase
                    "superowe punkty"
                    "superowych punktów"
                    "superowym punktom"
                    "superowe punkty"
                    "superowymi punktami"
                    "superowych punktach"
                    "superowe punkty"
            }

        Player ->
            { singular =
                ByDeclensionCase
                    "gracz"
                    "gracza"
                    "graczowi"
                    "gracza"
                    "graczem"
                    "graczu"
                    "graczu"
            , plural =
                ByDeclensionCase
                    "gracze"
                    "graczy"
                    "graczom"
                    "graczy"
                    "graczami"
                    "graczach"
                    "gracze"
            }

        Spectator ->
            { singular =
                ByDeclensionCase
                    "obserwator"
                    "obserwatora"
                    "obserwatorowi"
                    "obserwatora"
                    "obserwatorem"
                    "obserwatorze"
                    "obserwatorze"
            , plural =
                ByDeclensionCase
                    "obserwatorzy"
                    "obserwatorów"
                    "obserwatorom"
                    "obserwatorów"
                    "obserwatorami"
                    "obserwatorach"
                    "obserwatorzy"
            }


{-| Declines the specified noun to the specified case and quantity.
-}
decl : Noun -> Quantity -> DeclensionCase -> String
decl noun quantity declCase =
    let
        realCase =
            paucal declCase quantity
    in
    noun |> declTable |> getByQuantity quantity |> getByCase realCase


type Gender
    = Masculine
    | Feminine
    | Neuter


dependingOnGender : String -> String -> String -> Gender -> String
dependingOnGender masculine feminine neuter gender =
    case gender of
        Masculine ->
            masculine

        Feminine ->
            feminine

        Neuter ->
            neuter


{-| Take a number and give back the name of that number. Falls back to the number when it gets too big.
-}
asWord : Int -> Gender -> String
asWord number gender =
    case number of
        0 ->
            "zero"

        1 ->
            dependingOnGender "jeden" "jedna" "jedno" gender

        2 ->
            dependingOnGender "dwa" "dwie" "dwa" gender

        3 ->
            "trzy"

        4 ->
            "cztery"

        5 ->
            "pięć"

        6 ->
            "sześć"

        7 ->
            "siedem"

        8 ->
            "osiem"

        9 ->
            "dziewięć"

        10 ->
            "dziesięć"

        11 ->
            "jedenaście"

        12 ->
            "dwanaście"

        other ->
            String.fromInt other
