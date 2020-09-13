module MassiveDecks.Strings.Languages.Pl exposing (pack)

{-| Polish translation of Massive Decks, made by TheChilliPL on GitHub.
-}

import MassiveDecks.Card.Source.BuiltIn.Model as BuiltIn
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Strings exposing (MdString(..))
import MassiveDecks.Strings.Translation as Translation exposing (Result(..))


pack : Translation.Pack
pack =
    { code = "pl"
    , name = Polish
    , translate = translate
    , recommended = "cah-base-en" |> BuiltIn.hardcoded |> Source.BuiltIn
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
            [ Text "Zamknij" ]

        -- Special
        Plural { singular, amount } -> [ Raw singular ]

        -- Start screen.
        Version { versionNumber } ->
            [ Text "Wersja “", Text versionNumber, Text "”" ]

        ShortGameDescription ->
            [ Text "Komediowa gra towarzyska." ]

        WhatIsThis ->
            [ Text "Czym jest ", Ref MassiveDecks, Text "?" ]

        GameDescription ->
            [ Ref MassiveDecks
            , Text " to komediowa gra towarzyska bazowana na "
            , Ref CardsAgainstHumanity
            , Text ", stworzona przez "
            , Ref RereadGames
            , Text " i innych kontrybutorów—gra jest open-source z licencją "
            , Ref License
            , Text ", więc możesz wesprzeć rozwój gry, sprawdzić kod źródłowy, lub po prostu dowiedzieć się więcej na "
            , Ref MDProject
            , Text "."
            ]

        NewGame ->
            [ Text "Nowa gra" ]

        NewGameDescription ->
            [ Text "Rozpocznij nową grę ", Ref MassiveDecks, Text "." ]

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
            [ Text "Dowiedz się więcej o ", Ref MassiveDecks, Text " i o jej rozwoju." ]

        MDLogoDescription ->
            [ Ref Call, Text " i ", Ref Response, Text " podpisane literami „M” oraz „D”." ]

        RereadLogoDescription ->
            [ Text "Książka otoczona strzałką recyklingu." ]

        MDProject ->
            [ Text "projekcie GitHubowym" ]

        License ->
            [ Text "AGPLv3" ]

        DevelopedByReread ->
            [ Text "Rozwijane przez ", Ref RereadGames, Text "." ]

        RereadGames ->
            [ Text "Reread Games" ]

        NameLabel ->
            [ Text "Twoja nazwa" ]

        NameInUse ->
            [ Text "Ktoś już dołączył do gry z tą nazwą — spróbuj użyć innej." ]

        RejoinTitle ->
            [ Text "Dołącz ponownie" ]

        RejoinGame { code } ->
            [ Text "Dołącz do “", GameCode { code = code } |> Ref, Text "”." ]

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
            [ Text "Cards Against Humanity" ]

        Rules ->
            [ Text "Jak grać." ]

        RulesHand ->
            [ Text "Każdy gracz ma w ręce ", Ref (Plural { singular = Response, amount = Nothing }), Text "." ]

        RulesCzar ->
            [ Text "Pierwszy gracz zaczyna jako "
            , Ref Czar
            , Text ". "
            , Ref Czar
            , Text " czyta pytanie lub zdanie do uzupełnienia na "
            , Ref Call
            , Text " na głos."
            ]

        RulesPlaying ->
            [ Text "Cała reszta odpowiada na pytanie lub uzupełnia lukę wybierając "
            , Ref Response
            , Text " ze swojej ręki."
            ]

        RulesJudging ->
            [ Text "Odpowiedzi są wymieszane, a "
            , Ref Czar
            , Text " czyta je wszystkim innym—for full effect, " -- TODO
            , Ref Czar
            , Text " powinien zwykle czytać "
            , Ref Call
            , Text " przed każdą z odpowiedzi. "
            , Ref Czar
            , Text " następnie wybiera najśmieszniejszą, a ten kto ją wybrał dostaje "
            , Ref Point
            , Text "."
            ]

        RulesPickTitle ->
            [ Ref (Pick { numberOfCards = 2 }) ]

        RulesPick ->
            [ Text "Niektóre karty potrzebują więcej niż jednej "
            , Ref Response
            , Text " do odpowiedzi. Wybierz karty w kolejności w jakiej "
            , Ref Czar
            , Text " powinien je przeczytać — to ważne."
            ]

        ExamplePickDescription ->
            [ Text "Takie"
            , Ref (Plural { singular = Call, amount = Nothing })
            , Text " wymagają wybierania większej ilości "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text ", ale dają większy wybór." --TODO
            ]

        RulesDraw ->
            [ Text "Niektóre "
            , Ref (Plural { singular = Call, amount = Nothing })
            , Text " potrzebują jeszcze więcej "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text " — będzie napisane "
            , Ref (Draw { numberOfCards = 2 })
            , Text " lub więcej — tyle kart dostaniesz przed zagraniem."
            ]

        GameRulesTitle ->
            [ Text "Zasady Gry" ]

        HouseRulesTitle ->
            [ Text "Zasady Domowe" ] --TODO

        HouseRules ->
            [ Text "Możesz zmienić różne zasady tej gry na różne sposoby. Podczas ustawiania gry, wybierz tyle "
            , Text "domowych zasad ile tylko chcesz."
            ]

        HouseRuleReboot ->
            [ Text "Restart Wszechświata" ]

        HouseRuleRebootDescription { cost } ->
            [ Text "W każdej chwili gracze mogą wymienić "
            --, Text (an cost)
            , Ref (Plural { singular = Point, amount = cost })
            , Text " aby wyrzucić wrzyctkie karty i zacząć z nowymi."
            ]

        HouseRuleRebootAction { cost } ->
            [ Text "Wydaj "
            , Text (asWord cost)
            , Text " "
            , Ref (Plural { singular = Point, amount = Just cost })
            , Text " aby wyrzucić karty i dobrać nowe."
            ]

        HouseRuleRebootCost ->
            [ Text "Koszt użycia" ]

        HouseRuleRebootCostDescription ->
            [ Text "Ile "
            , Ref (Plural { singular = Point, amount = Nothing }), Text " kosztuje ponowne dobranie "
            , Text "wszystkich kart."
            ]

        HouseRulePackingHeat ->
            [ Text "Packing Heat" ] --TODO

        HouseRulePackingHeatDescription ->
            [ Text "Wszystkie "
            , Ref (Plural { singular = Call, amount = Nothing })
            , Text " z "
            , Ref (Pick { numberOfCards = 2 })
            , Text " także dostaną "
            , Ref (Draw { numberOfCards = 1 })
            , Text ", aby wszyscy mieli więcej do wyboru."
            ]

        HouseRuleComedyWriter ->
            [ Text "Pisarz Komedii" ]

        HouseRuleComedyWriterDescription ->
            [ Text "Dodaj puste "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text " na których gracze mogą pisać własne odpowiedzi."
            ]

        HouseRuleComedyWriterNumber ->
            [ Text "Puste ", Ref (Plural { singular = Response, amount = Nothing }) ]

        HouseRuleComedyWriterNumberDescription ->
            [ Text "Ilość pustych "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text " które znajdą się w grze."
            ]

        HouseRuleComedyWriterExclusive ->
            [ Text "Tylko puste ", Ref (Plural { singular = Response, amount = Nothing }) ]

        HouseRuleComedyWriterExclusiveDescription ->
            [ Text "Po włączeniu, wszystkie "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text " z talii znikną, i tylko puste zostaną w grze."
            ]

        HouseRuleRandoCardrissian ->
            [ Text "Rando Cardrissian" ] --TODO

        HouseRuleRandoCardrissianDescription ->
            [ Text "Każdego dnia, pierwsza "
            , Ref Response
            , Text " z talii zostanie wybrana jako odpowiedź. Należy ona do bota nazwanego "
            , Text "Rando Cardrissian, a jeśli on wygra, wszyscy gracze wrócą do domu z niekończącym się wstydem."
            ]

        HouseRuleRandoCardrissianNumber ->
            [ Text "Ilość botów" ]

        HouseRuleRandoCardrissianNumberDescription ->
            [ Text "Ilość botów, które znajdą się w grze." ]

        HouseRuleNeverHaveIEver ->
            [ Text "Nigdy w Życiu Nie" ]

        HouseRuleNeverHaveIEverDescription ->
            [ Text "W każdej chwili, gracz może pozbyć się kart których nie rozumie, ale musi wyznać swą "
            , Text "ignorancję: wyrzucona karta będzie publicznie widoczna."
            ]

        MustBeMoreThanOrEqualValidationError { min } ->
            [ Text "Wartość musi być większa lub równa ", Text (String.fromInt min), Text "." ]

        MustBeLessThanOrEqualValidationError { max } ->
            [ Text "Wartość nie może przekraczać ", Text (String.fromInt max), Text "." ]

        SetValue { value } ->
            [ Text "Ustaw wartość na ", Text (String.fromInt value), Text "." ]

        CantBeEmpty ->
            [ Text "To nie może być puste." ]

        SettingsTitle ->
            [ Text "Ustawienia" ]

        LanguageSetting ->
            [ Text "Język" ]

        MissingLanguage ->
            [ Text "Nie widzisz swojego języka? ", Ref TranslationBeg ]

        AutonymFormat { autonym } ->
            [ Text "(", Text autonym, Text ")" ]

        TranslationBeg ->
            [ Text "Pomóż przetłumaczyć "
            , Ref MassiveDecks
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
            [ Text "Syntezator Mowy" ]

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
            , Ref MassiveDecks
            , Text " aby mogła używać powiadomień. Będzie to używane tylko podczas gry jeśli ta opcja jest włączona."
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
            [ Text "Karciany Car" ]

        CzarDescription ->
            [ Text "Gracz oceniający odpowiedzi." ]

        Player ->
            [ Text "Gracz" ]

        Spectator ->
            [ Text "Obserwator" ]

        Call ->
            [ Text "Czarna Karta" ]

        CallDescription ->
            [ Text "Czarna karta z pytaniem lub luką do uzupełnienia." ]

        Response ->
            [ Text "Biała karta" ]

        ResponseDescription ->
            [ Text "Biała karta z wyrażeniem używanym jako odpowiedź." ]

        Point ->
            [ Text "Superowy Punkt" ]

        PointDescription ->
            [ Text "Punkcik—kto ma więcej ten wygrywa." ]

        GameCodeTerm ->
            [ Text "Kod Gry" ]

        GameCodeDescription ->
            [ Text "Kod dzięki któremu inni mogą dołączyć do tej gry." ]

        GameCode { code } ->
            [ Text code ]

        GameCodeSpecificDescription ->
            [ Text "Wyślij ten kod znajomym, aby mógli dołączyć do gry." ]

        GameCodeHowToAcquire ->
            [ Text "Zapytaj zapraszającego o ", Ref GameCodeTerm, Text "." ]

        Deck ->
            [ Text "Talia" ]

        DeckSource ->
            [ Text "Pochodzenie talii" ]

        DeckLanguage { language } ->
            [ Text "w ", Text language ]

        DeckAuthor { author } ->
            [ Text "od ", Text author ]

        DeckTranslator { translator } ->
            [ Text "tłumaczone przez ", Text translator ]

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
            [ Text "Gry w trakcie." ]

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
            [ Text "Wybierz", Ref (NumberOfCards numberOfCards) ]

        Draw numberOfCards ->
            [ Text "Dobierz", Ref (NumberOfCards numberOfCards) ]

        PickDescription { numberOfCards } ->
            [ Text "Musisz wybrać "
            , Text (asWord numberOfCards)
            , Text " "
            , Ref (Plural { singular = Response, amount = Just numberOfCards })
            , Text "."
            ]

        DrawDescription { numberOfCards } ->
            [ Text "Dostajesz "
            , Text (asWord numberOfCards)
            , Text " dodatkowych "
            , Ref (Plural { singular = Response, amount = Just numberOfCards })
            , Text " before playing."
            ]

        NumberOfCards { numberOfCards } ->
            [ Text (String.fromInt numberOfCards) ]

        -- Lobby
        LobbyNameLabel ->
            [ Text "Nazwa gry" ]

        DefaultLobbyName { owner } ->
            [ Text "Gra", Text owner ]

        Invite ->
            [ Text "Zaproś graczy." ]

        InviteLinkHelp ->
            [ Text "Wyślij ten link do graczy, których chcesz zaprosić, lub daj im kod QR do zeskanowania." ]

        InviteExplanation { gameCode, password } ->
            let
                extra =
                    password
                        |> Maybe.map
                            (\p ->
                                [ Text " oraz hasło gry: “"
                                , Text p
                                , Text "”"
                                ]
                            )
                        |> Maybe.withDefault []
            in
            List.concat
                [ [ Text "Twój kod gry to "
                  , Ref (GameCode { code = gameCode })
                  , Text ". Gracze mogą dołączyć do gry otwierając "
                  , Ref MassiveDecks
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
            [ Text "Wysyłanie obrazu do ", Text deviceName, Text "." ]

        Players ->
            [ Ref (Plural { singular = Player, amount = Nothing }) ]

        PlayersDescription ->
            [ Text "Użytkownicy w grze." ]

        Spectators ->
            [ Ref (Plural { singular = Spectator, amount = Nothing }) ]

        SpectatorsDescription ->
            [ Text "Użytkownicy oglądający grę, ale nie grający." ]

        Left ->
            [ Text "Left" ] --TODO

        LeftDescription ->
            [ Text "Użytkownicy którzy opuścili grę." ]

        Away ->
            [ Text "Away" ] --TODO

        AwayDescription ->
            [ Text "Ten użytkownik tymczasowo opuścił grę." ]

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
            , Ref (Plural { singular = Point, amount = Nothing })
            , Text " które ma ten gracz."
            ]

        Likes { total } ->
            [ Text (String.fromInt total) ]

        LikesDescription ->
            [ Text "Liczba otrzymanych polubień." --TODO
            ]

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
            [ Text "Oznacz jako Away" ] --TODO

        SetBack ->
            [ Text "Oznacz jako Back" ] --TODO

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
            [ Text "Zacznij oglądać grę innych graczy." ] --TODO

        BecomePlayer ->
            [ Text "Graj" ]

        BecomePlayerDescription ->
            [ Text "Dołącz do gry." ]

        EndGame ->
            [ Text "Zakończ grę" ]

        EndGameDescription ->
            [ Text "Zakończ grę teraz." ]

        ReturnViewToGame ->
            [ Text "Wróć do gry" ]

        ReturnViewToGameDescription ->
            [ Text "Wróć do podstawowego widoku gry." ] --TODO

        ViewConfgiuration ->
            [ Text "Konfiguruj" ]

        ViewConfgiurationDescription ->
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
            [ Text "Zamknij" ] --TODO

        -- Configuration
        ConfigureTitle ->
            [ Text "Ustawienia gry" ]

        NoDecks ->
            [ Segment [ Text "Brak talii. " ]
            , Segment [ Text "Potrzeba co najmniej jednej talii aby zacząć grę." ]
            ]

        NoDecksHint ->
            [ Text "Nie jesteś pewien? Dodaj oryginalną talię z ", Raw CardsAgainstHumanity, Text " (po angielsku)." ]

        WaitForDecks ->
            [ Text "Talie muszą się załadować przed rozpoczęciem gry." ]

        MissingCardType { cardType } ->
            [ Text "Żadna z talii nie zawiera żadnych "
            , Ref (Plural { singular = cardType, amount = Nothing })
            , Text ". Potrzebujesz je mieć do rozpoczęcia gry."
            ]

        NotEnoughCardsOfType { cardType, needed, have } ->
            [ Text "Dla tej liczby graczy, potrzebujesz co najmniej "
            , Text (needed |> String.fromInt)
            , Text " "
            , Ref (Plural { singular = cardType, amount = Just needed })
            , Text ", ale masz tylko "
            , Text (have |> String.fromInt)
            , Text "."
            ]

        AddBlankCards { amount } ->
            [ Text "Dodaj "
            , amount |> String.fromInt |> Text
            , Text " pustych "
            , Ref (Plural { singular = Response, amount = Just amount })
            , Text "."
            ]

        AddDeck ->
            [ Text "Dodaj talię." ]

        RemoveDeck ->
            [ Text "Usuń talię." ]

        SourceNotFound { source } ->
            [ Ref source, Text " nie zawiera talii którą podałeś. Sprawdź czy wszystkie podane informacje są poprawne." ]

        SourceServiceFailure { source } ->
            [ Ref source, Text " nie mógł odesłać talii. Spróbuj ponownie później lub skorzystaj z innego źródła." ]

        ManyDecks ->
            [ Text "Many Decks" ]

        ManyDecksDeckCodeTitle ->
            [ Text "Kod talii" ]

        ManyDecksDeckCodeShort ->
            [ Text "Kod talii musi mieć co najmniej 5 znaków." ]

        ManyDecksWhereToGet ->
            [ Text "Możesz stworzyć lub znaleźć talie na ", Ref ManyDecks, Text "." ]

        JsonAgainstHumanity ->
            [ Text "JSON Against Humanity" ]

        JsonAgainstHumanityAbout ->
            [ Text "Talie dostarczone przez ", Ref JsonAgainstHumanity ] --TODO

        BuiltIn ->
            [ Text "Wbudowane" ]

        APlayer ->
            [ Text "Gracz" ]

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
            [ Text "Liczba kart w ręce" ] --TODO

        HandSizeDescription ->
            [ Text "Podstawowa liczba kart jakie mają gracze podczas gry." ]

        ScoreLimit ->
            [ Text "Limit", Ref Point ]

        ScoreLimitDescription ->
            [ Segment
                [ Text "Liczba "
                , Ref (Plural { singular = Point, amount = Nothing })
                , Text " jaką potrzebuje gracz do wygrania gry."
                ]
            , Text " "
            , Segment [ Text "Jeśli wyłączone, gra trwa w nieskończoność." ]
            ]

        UnsavedChangesWarning ->
            [ Text "Masz niezapisane zmiany w konfiguracji, musisz je zapisać jeśli chcesz zmienić zasady gry. " ]

        SaveChanges ->
            [ Text "Zapisz zmiany." ]

        RevertChanges ->
            [ Text "Odrzuć zmiany." ]

        NeedAtLeastOneDeck ->
            [ Text "Potrzebujesz co najmniej jednej talii aby zacząć grę." ]

        NeedAtLeastThreePlayers ->
            [ Text "Potrzebujesz co najmniej trzech graczy aby zacząć grę." ]

        NeedAtLeastOneHuman ->
            [ Text "Niestety boty nie mogą być "
            , Ref Czar
            , Text ", więc potrzebujesz minimum jednego luczkiego gracza."
            , Text " (Chociaż z tylko jednym człowiekiem może być nudno!)"
            ]

        RandoCantWrite ->
            [ Text "Boty nie mogą pisać własnych kart." ]

        DisableComedyWriter ->
            [ Text "Wyłącz ", Ref HouseRuleComedyWriter ]

        DisableRando ->
            [ Text "Wyłącz ", Ref HouseRuleRandoCardrissian ]

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
            [ Text "Automatycznie oznaczaj graczy jako Away" ] --TODO

        AutomaticDescription -> --TODO
            [ Text "If enabled, when the time limit runs out players will automatically be marked as away. "
            , Text "Otherwise someone will need to press the button to do so."
            ]

        TimeLimit { stage } ->
            [ Text "Limit czasowy", Ref stage ]

        PlayingTimeLimitDescription ->
            [ Text "Jak długo (w sekundach) mają ", Ref Players, Text " na wybór swoich kart." ]

        PlayingAfterDescription ->
            [ Text "Jak długo (w sekundach) mają ", Ref Players, Text " na zmianę przed rozpoczęciem kolejnego etapu." ]

        RevealingTimeLimitDescription ->
            [ Text "Jak długo (w sekundach) ma ", Ref Czar, Text " na odkrycie kart." ]

        RevealingAfterDescription ->
            [ Text "Jak długo (w sekundach) czekać na rozpoczęcie kolejnego etapu po odkryciu kart." ]

        JudgingTimeLimitDescription -> --TODO
            [ Text "Jak długo (w sekundach) ma ", Ref Czar, Text " na wybranie najlepszej karty." ]

        CompleteTimeLimitDescription ->
            [ Text "Jak długo (w sekundach) czekać po zakończeniu całej rundy przed rozpoczęciem kolejnej." ]

        RevealingEnabledTitle ->
            [ Text "Czar odkrywa odpowiedzi" ]

        RevealingEnabled ->
            [ Text "Jeśli włączone, "
            , Ref Czar
            , Text " odkrywa odpowiedzi po kolei przed wybraniem najlepszej."
            ]

        DuringTitle ->
            [ Text "Limit czasowy" ]

        AfterTitle ->
            [ Text "Po" ] --TODO

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
            [ Text "Daj te karty ", Ref Czar, Text " jako odpowiedzi w tej rundzie." ]

        TakeBackPlay ->
            [ Text "Wycofaj swoje karty w tej rundzie aby je zmienić." ]

        JudgePlay ->
            [ Text "Wybierz tę odpowiedź jako najlepszą w tej rundzie." ]

        LikePlay ->
            [ Text "Polub tę odpowiedź." ] --TODO

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
            [ Text "Ustaw wszystkich graczy którzy nie wykonali wyboru jako Away i pomijaj ich aż wrócą." ]

        Blank ->
            [ Text "Puste" ]

        RoundStarted ->
            [ Text "Runda rozpoczęta" ]

        JudgingStarted ->
            [ Text "Ocenianie rozpoczęte" ]

        Paused ->
            [ Text "Gra została zatrzymana ponieważ nie ma wystarczającej liczby graczy by kontynuować."
            , Text "Gdy ktoś dołączy lub wróci, gra zostanie automatycznie wznowiona."
            ]

        ClientAway -> --TODO
            [ Text "You are currently set as away from the game, and are not playing." ]

        Discard ->
            [ Text "Odrzuć tę kartę, pokazując ją wszystkim innym w grze." ]

        Discarded { player } ->
            [ Text player
            , Text " odrzucił następującą kartę:"
            ]

        -- Instructions
        PlayInstruction { numberOfCards } ->
            [ Text "Musisz wybrać jeszcze "
            , Text (asWord numberOfCards)
            , Ref (Plural { singular = Response, amount = Just numberOfCards })
            , Text " z ręki w tej rundzie, aby wysłać odpowiedź."
            ]

        SubmitInstruction ->
            [ Text "Musisz wysłać odpowiedź w tej rundzie." ]

        WaitingForPlaysInstruction ->
            [ Text "Czekaj aż inni gracze wyślą swoje odpowiedzi." ]

        CzarsDontPlayInstruction ->
            [ Text "Jesteś "
            , Ref Czar
            , Text " rundy - nie wybierasz żadnych "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text ". Zamiast tego gdy reszta wybierze odpowiedzi, ty wybierzesz zwycięzcę."
            ]

        NotInRoundInstruction -> --TODO
            [ Text "Nie bierzesz udziału w tej rundzie. Weźmiesz udział w kolejnej o ile nie jesteś Away." ]

        RevealPlaysInstruction ->
            [ Text "Klikaj na karty by je odkryć, po czym wybierz najlepszą z odpowiedzi." ]

        WaitingForCzarInstruction ->
            [ Text "Możesz polubić odpowiedzi podczas gdy ", Ref Czar, Text " odkrywa kolejne i wybiera zwycięzcę." ]

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
            [ Text "Prosimy sprawdzić aktualizacje i status na ", Ref TwitterHandle
            , Text ". Serwery gry są wyłączane na krótki czas podczas aktualizacji, więc jeśli taka nastąpiła ostatnio,"
            , Text "spróbuj ponownie za kilka minut." ]

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

        TimeoutError -> --TODO
            [ Text "Serwer zbyt długo nie odpowiadał. Może być wyłączony, spróbuj ponownie za chwilę." ]

        NetworkError ->
            [ Text "Twoje połączenie zostało przerwane." ]

        ServerDownError ->
            [ Text "Serwer gry jest obecnie niedostępny. Spróbuj ponownie później." ]

        BadStatusError ->
            [ Text "Serwer odpowiedział w niespodziewany sposób." ]

        BadPayloadError ->
            [ Text "Serwer odpowiedział w nieprawidłowy sposób." ]

        PatchError -> --TODO
            [ Text "Łatka od serwera nie mogła być użyta." ]

        VersionMismatch ->
            [ Text "Serwer odpowiedział nieprawidłową wersją." ]

        CastError ->
            [ Text "Przepraszamy, wystąpił błąd podczas dołączania do gry." ]

        ActionExecutionError ->
            [ Text "Nie możesz tego zrobić." ]

        IncorrectPlayerRoleError { role, expected } ->
            [ Text "Musisz być ", Ref expected, Text " do tego, a jesteś ", Ref role, Text "." ]

        IncorrectUserRoleError { role, expected } ->
            [ Text "Musisz być ", Ref expected, Text " do tego, a jesteś ", Ref role, Text "." ]

        IncorrectRoundStageError { stage, expected } ->
            [ Text "Runda musi być na etapie ", Ref expected, Text ", a jest na etapie ", Ref stage, Text " stage." ]

        ConfigEditConflictError ->
            [ Text "Ktoś inny zmienił konfigurację przed tobą, twoje zmiany nie zostały zapisane." ]

        UnprivilegedError -> --TODO
            [ Text "Nie masz permisji do tego." ]

        GameNotStartedError ->
            [ Text "Aby to zrobić, gra musi być rozpoczęta." ]

        InvalidActionError { reason } ->
            [ Text "Serwer nie zrozumiał zapytania klienta. Szczegóły: ", Text reason ]

        AuthenticationError ->
            [ Text "Nie możesz dołączyć do tej gry." ]

        IncorrectIssuerError -> --TODO
            [ Text "Your credentials to join this game are out of date, the game no longer exists." ]

        InvalidAuthenticationError -> --TODO
            [ Text "Your credentials to join this game are corrupt." ]

        InvalidLobbyPasswordError ->
            [ Text "Podane hasło gry jest nieprawidłowe. Spróbuj wpisać je jeszcze raz, i jeśli to nie zadziała,"
            , Text "zapytaj znów osobę która cię zaprosiła." ]

        AlreadyLeftError ->
            [ Text "Już opuściłeś tę grę." ]

        LobbyNotFoundError ->
            [ Text "Ta gra nie istnieje." ]

        LobbyClosedError { gameCode } ->
            [ Text "Gra do której chcesz dołączyć (", Ref (GameCode { code = gameCode }), Text ") zakończyła się." ]

        LobbyDoesNotExistError { gameCode } ->
            [ Text "Gra o podanym kodzie ("
            , Ref (GameCode { code = gameCode })
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
            [ Text "Angielski (Brytyjski)" ]

        Italian ->
            [ Text "Włoski" ]

        BrazilianPortuguese ->
            [ Text "Portugalski (Brazylijski)" ]

        German ->
            [ Text "Niemiecki (Formalny)" ]

        GermanInformal ->
            [ Text "Niemiecki (Nieformalny)" ]

        Polish ->
            [ Text "Polski" ]

{--
an : Maybe Int -> String
an amount =
    case amount of
        Just 1 ->
            "an "

        _ ->
            ""


a : Maybe Int -> String
a amount =
    case amount of
        Just 1 ->
            "a "

        _ ->
            ""
--}


{-| Take a number and give back the name of that number. Falls back to the number when it gets too big.
-}
asWord : Int -> String
asWord number =
    case number of
        0 ->
            "zero"

        1 ->
            "jeden"

        2 ->
            "dwa"

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
