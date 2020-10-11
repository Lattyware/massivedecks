module MassiveDecks.Strings.Languages.Id exposing (pack)

{-| Indonesian localization.

Contributors:

  - fadila-amin <https://github.com/fadila-amin>

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
        { lang = Id
        , code = "id"
        , name = Indonesian
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


translate : Maybe Never -> MdString -> List (Translation.Result Never)
translate _ mdString =
    case mdString of
        -- General
        MassiveDecks ->
            [ Text "Massive Decks" ]

        Close ->
            [ Text "Tutup" ]

        Noun { noun, quantity } ->
            let
                singular =
                    case noun of
                        Call ->
                            [ Text "Kartu Hitam" ]

                        Response ->
                            [ Text "Kartu Putih" ]

                        Point ->
                            [ Text "Point Keren" ]

                        Player ->
                            [ Text "Pemain" ]

                        Spectator ->
                            [ Text "Penonton" ]

                plural =
                    case quantity of
                        Quantity 1 ->
                            []

                        _ ->
                            [ Text "s" ]
            in
            List.concat [ singular, plural ]

        -- Start screen.
        Version { versionNumber } ->
            [ Text "Versi “", Text versionNumber, Text "”" ]

        ShortGameDescription ->
            [ Text "Sebuah permainan pesta komedi." ]

        WhatIsThis ->
            [ Text "Apa itu ", ref MassiveDecks, Text "?" ]

        GameDescription ->
            [ ref MassiveDecks
            , Text " adalah sebuah permainan pesta komedi berbasis "
            , ref CardsAgainstHumanity
            , Text ", dikembangkan oleh "
            , ref RereadGames
            , Text " dan kontributor lainnya-game ini merupakan open source "
            , ref License
            , Text ", jadi kamu dapat membantu meningkatkan permainan ini, akses kode sumber, atau sekadar mencari tahu lebih lanjut di "
            , ref MDProject
            , Text "."
            ]

        NewGame ->
            [ Text "Baru" ]

        NewGameDescription ->
            [ Text "Mulai permainan baru ", ref MassiveDecks, Text "." ]

        FindPublicGame ->
            [ Text "Temukan" ]

        JoinPrivateGame ->
            [ Text "Bergabung" ]

        JoinPrivateGameDescription ->
            [ Text "Bergabung dengan pemain yang mengundangmu." ]

        PlayGame ->
            [ Text "Mainkan" ]

        AboutTheGame ->
            [ Text "Tentang" ]

        AboutTheGameDescription ->
            [ Text "Temukan tentang ", ref MassiveDecks, Text " dan bagaimana dikembangkan." ]

        MDLogoDescription ->
            [ Text "sebuah ", ref (noun Call 1), Text " dan sebuah ", ref (noun Response 1), Text " marked with an “M” and a “D”." ]

        RereadLogoDescription ->
            [ Text "Sebuah buku yang dilingkari panah daur ulang." ]

        MDProject ->
            [ Text "Proyek Github" ]

        License ->
            [ Text "the AGPLv3 license" ]

        DevelopedByReread ->
            [ Text "Dikembangkan oleh ", ref RereadGames, Text "." ]

        RereadGames ->
            [ Text "membaca ulang permainan" ]

        NameLabel ->
            [ Text "Namamu" ]

        NameInUse ->
            [ Text "Orang lain menggunakan nama ini dalam permainan — coba nama lain." ]

        RejoinTitle ->
            [ Text "bergabung kembali ke permainan" ]

        RejoinGame { code } ->
            [ Text "bergabung kembali “", GameCode { code = code } |> ref, Text "”." ]

        LobbyRequiresPassword ->
            [ Text "Anda memerlukan kata sandi untuk bergabung dengan permainan ini. Coba tanyakan pada orang yang mengundang Anda." ]

        YouWereKicked ->
            [ Text "Anda dikeluarkan dari permainan." ]

        ScrollToTop ->
            [ Text "kembali ke atas." ]

        Copy ->
            [ Text "Salin" ]

        -- Rules
        CardsAgainstHumanity ->
            [ Text "Kartu Melawan Kemanusiaan" ]

        Rules ->
            [ Text "Cara bermain." ]

        RulesHand ->
            [ Text "Setiap pemain memiliki ", ref (Noun { noun = Response, quantity = Unknown }), Text "." ]

        RulesCzar ->
            [ Text "Pemain pertama dimulai sebagai "
            , ref Czar
            , Text ". the "
            , ref Czar
            , Text " membaca pertanyaan atau mengisi frasa kosong di "
            , ref (noun Call 1)
            , Text " dengan lantang."
            ]

        RulesPlaying ->
            [ Text "Semua orang menjawab pertanyaan atau mengisi bagian yang kosong dengan memilih sebuah "
            , ref (noun Response 1)
            , Text " dari tangan mereka untuk bermain untuk putaran itu."
            ]

        RulesJudging ->
            [ Text "Jawabannya kemudian diacak dan "
            , ref Czar
            , Text " membacakannya kepada pemain lain — untuk efek penuh, "
            , ref Czar
            , Text " biasanya harus membaca ulang "
            , ref (noun Call 1)
            , Text " sebelum menyajikan setiap jawaban.  "
            , ref Czar
            , Text " lalu memilih permainan paling lucu, dan siapa pun yang memainkannya akan mendapatkannya "
            , ref (noun Point 1)
            , Text "."
            ]

        RulesPickTitle ->
            [ ref (Pick { numberOfCards = 2 }) ]

        RulesPick ->
            [ Text "Beberapa kartu membutuhkan lebih dari satu "
            , ref (noun Response 1)
            , Text " sebagai jawaban. Mainkan kartu dalam urutan "
            , ref Czar
            , Text " harus membacanya — urutannya penting."
            ]

        ExamplePickDescription ->
            [ ref (nounUnknownQuantity Call)
            , Text " seperti ini akan membutuhkan pemilihan lebih banyak "
            , ref (nounUnknownQuantity Response)
            , Text ", tetapi memberi Anda lebih banyak untuk dipilih."
            ]

        RulesDraw ->
            [ Text "Beberapa "
            , ref (nounUnknownQuantity Call)
            , Text " akan membutuhkan lebih banyak lagi "
            , ref (nounUnknownQuantity Response)
            , Text "—Ini akan mengatakannya "
            , ref (Draw { numberOfCards = 2 })
            , Text " atau lebih, dan Anda akan mendapatkan banyak kartu tambahan sebelum bermain."
            ]

        GameRulesTitle ->
            [ Text "Aturan Permainan" ]

        HouseRulesTitle ->
            [ Text "Aturan Rumah" ]

        HouseRules ->
            [ Text "Anda dapat mengubah cara permainan ini dimainkan dengan berbagai cara. Saat menyiapkan game, pilih "
            , Text "sebanyak peraturan rumah yang ingin Anda gunakan."
            ]

        HouseRuleReboot ->
            [ Text "Mem-boot ulang Semesta" ]

        HouseRuleRebootDescription { cost } ->
            [ Text "Kapan saja, pemain dapat berdagang "
            , Text (an cost)
            , ref (nounMaybe Point cost)
            , Text " untuk membuang tangan mereka dan mengambil yang baru."
            ]

        HouseRuleRebootAction { cost } ->
            [ Text "Menghabiskan "
            , Text (asWord cost)
            , Text " "
            , ref (noun Point cost)
            , Text " untuk membuang tangan mereka dan mengambil yang baru."
            ]

        HouseRuleRebootCost ->
            [ ref (noun Point 1), Text " Biaya" ]

        HouseRuleRebootCostDescription ->
            [ Text "Berapa banyak ", ref (nounUnknownQuantity Point), Text " biaya untuk mengambil ulang." ]

        HouseRulePackingHeat ->
            [ Text "Packing Heat" ]

        HouseRulePackingHeatDescription ->
            [ Text "apapun "
            , ref (nounUnknownQuantity Call)
            , Text " dengan "
            , ref (Pick { numberOfCards = 2 })
            , Text " juga mendapatkan "
            , ref (Draw { numberOfCards = 1 })
            , Text ", sehingga setiap orang memiliki lebih banyak pilihan."
            ]

        HouseRuleComedyWriter ->
            [ Text "Comedy Writer" ]

        HouseRuleComedyWriterDescription ->
            [ Text "Tambahkan kosong "
            , ref (nounUnknownQuantity Response)
            , Text " tempat pemain dapat menulis tanggapan khusus."
            ]

        HouseRuleComedyWriterNumber ->
            [ Text "Kosong ", ref (nounUnknownQuantity Response) ]

        HouseRuleComedyWriterNumberDescription ->
            [ Text "Jumlah Kosong "
            , ref (nounUnknownQuantity Response)
            , Text "itu akan ada di dalam game."
            ]

        HouseRuleComedyWriterExclusive ->
            [ Text "Only Blank ", ref (nounUnknownQuantity Response) ]

        HouseRuleComedyWriterExclusiveDescription ->
            [ Text "Jika diaktifkan, semua lainnya "
            , ref (nounUnknownQuantity Response)
            , Text " akan diabaikan, hanya yang kosong yang akan ada dalam game."
            ]

        HouseRuleRandoCardrissian ->
            [ Text "Rando Cardrissian" ]

        HouseRuleRandoCardrissianDescription ->
            [ Text "Setiap ronde, yang pertama "
            , ref (noun Response 1)
            , Text " di dek akan dimainkan sebagai jawaban. Permainan ini milik pemain AI bernama "
            , Text "Rando Cardrissian, dan jika dia memenangkan permainan, semua pemain pulang dalam keadaan malu selamanya."
            ]

        HouseRuleRandoCardrissianNumber ->
            [ Text "AI Players" ]

        HouseRuleRandoCardrissianNumberDescription ->
            [ Text "Jumlah pemain AI yang akan ada dalam game." ]

        HouseRuleNeverHaveIEver ->
            [ Text "Never Have I Ever" ]

        HouseRuleNeverHaveIEverDescription ->
            [ Text "Setiap saat, seorang pemain dapat membuang kartu yang tidak mereka mengerti, namun mereka harus mengakuinya "
            , Text "ketidaktahuan: kartu dibagikan secara publik."
            ]

        -- TODO: Translate
        HouseRuleHappyEnding ->
            [ Missing ]

        -- TODO: Translate
        HouseRuleHappyEndingDescription ->
            [ Missing ]

        MustBeMoreThanOrEqualValidationError { min } ->
            [ Text "Nilai minimal harus ", Text (String.fromInt min), Text "." ]

        MustBeLessThanOrEqualValidationError { max } ->
            [ Text "Nilainya harus paling banyak ", Text (String.fromInt max), Text "." ]

        SetValue { value } ->
            [ Text "Setel nilainya menjadi ", Text (String.fromInt value), Text "." ]

        CantBeEmpty ->
            [ Text "Ini tidak boleh kosong." ]

        SettingsTitle ->
            [ Text "Pengaturan" ]

        LanguageSetting ->
            [ Text "Bahasa" ]

        MissingLanguage ->
            [ Text "Tidak melihat bahasa Anda? ", ref TranslationBeg ]

        AutonymFormat { autonym } ->
            [ Text "(", Text autonym, Text ")" ]

        TranslationBeg ->
            [ Text "Bantu menerjemahkan "
            , ref MassiveDecks
            , Text "!"
            ]

        CardSizeSetting ->
            [ Text "Compact Cards" ]

        CardSizeExplanation ->
            [ Text "Sesuaikan seberapa besar kartu — ini dapat berguna pada layar kecil untuk menggulir lebih sedikit." ]

        AutoAdvanceSetting ->
            [ Text "Secara Otomatis Memajukan Putaran" ]

        AutoAdvanceExplanation ->
            [ Text "Saat ronde berakhir, secara otomatis maju ke ronde berikutnya daripada menunggu." ]

        SpeechSetting ->
            [ Text "Text To Speech" ]

        SpeechExplanation ->
            [ Text "Bacakan kartu menggunakan text to speech." ]

        SpeechNotSupportedExplanation ->
            [ Text "Browser Anda tidak mendukung text to speech, atau tidak ada suara yang terpasang." ]

        VoiceSetting ->
            [ Text "Suara Ucapan" ]

        NotificationsSetting ->
            [ Text "Pemberitahuan Peramban" ]

        NotificationsExplanation ->
            [ Text "Memberi tahu Anda saat Anda perlu melakukan sesuatu dalam game menggunakan notifikasi browser."
            ]

        NotificationsUnsupportedExplanation ->
            [ Text "Browser Anda tidak mendukung notifikasi." ]

        NotificationsBrowserPermissions ->
            [ Text "Anda harus memberikan izin untuk "
            , ref MassiveDecks
            , Text " untuk memberi tahu Anda. Ini hanya akan digunakan saat permainan terbuka dan saat Anda mengaktifkannya."
            ]

        NotificationOnlyWhenHiddenSetting ->
            [ Text "Hanya Saat Tersembunyi" ]

        NotificationsOnlyWhenHiddenExplanation ->
            [ Text "Hanya mengirim pemberitahuan ketika Anda tidak melihat halaman (misalnya: di tab lain atau diminimalkan)." ]

        NotificationsOnlyWhenHiddenUnsupportedExplanation ->
            [ Text "Browser Anda tidak mendukung pemeriksaan visibilitas halaman." ]

        -- Terms
        Czar ->
            [ Text "Kartu Czar" ]

        CzarDescription ->
            [ Text "Pemain yang menilai babak." ]

        CallDescription ->
            [ Text "Kartu hitam dengan pertanyaan atau frase isi-di-kosong." ]

        ResponseDescription ->
            [ Text "Kartu putih dengan frase yang dimainkan menjadi putaran." ]

        PointDescription ->
            [ Text "Satu poin — memiliki lebih banyak berarti menang." ]

        GameCodeTerm ->
            [ Text "Game Code" ]

        GameCodeDescription ->
            [ Text "Kode yang memungkinkan orang lain menemukan dan bergabung dengan game Anda." ]

        GameCode { code } ->
            [ Text code ]

        GameCodeSpecificDescription ->
            [ Text "Berikan kode game ini kepada orang-orang dan mereka dapat bergabung dalam game." ]

        GameCodeHowToAcquire ->
            [ Text "Tanyakan pada orang yang mengundang Anda untuk permainan tersebut ", ref GameCodeTerm, Text "." ]

        Deck ->
            [ Text "Deck" ]

        DeckSource ->
            [ ref Deck, Text " Sumber" ]

        DeckLanguage { language } ->
            [ Text "dalam ", Text language ]

        DeckAuthor { author } ->
            [ Text "oleh ", Text author ]

        DeckTranslator { translator } ->
            [ Text "diterjemahkan oleh ", Text translator ]

        StillPlaying ->
            [ Text "Bermain" ]

        PlayingDescription ->
            [ Text "Pemain ini ada di babak, tetapi belum mengirimkan permainan." ]

        Played ->
            [ Text "termainkan" ]

        PlayedDescription ->
            [ Text "Pemain ini telah mengirimkan permainan mereka untuk babak tersebut." ]

        -- Lobby Browser
        LobbyBrowserTitle ->
            [ Text "Public Games" ]

        NoPublicGames ->
            [ Text "Tidak ada permainan publik yang tersedia." ]

        PlayingGame ->
            [ Text "Game yang sedang berlangsung." ]

        SettingUpGame ->
            [ Text "Game yang belum dimulai." ]

        StartYourOwn ->
            [ Text "Memulai permainan baru?" ]

        -- Spectation
        JoinTheGame ->
            [ Text "Bergabung dengan permainan!" ]

        ToggleAdvertDescription ->
            [ Text "Toggle menampilkan informasi untuk bergabung dengan permainan." ]

        -- Cards
        Pick numberOfCards ->
            [ Text "Pilih", ref (NumberOfCards numberOfCards) ]

        Draw numberOfCards ->
            [ Text "Ambil", ref (NumberOfCards numberOfCards) ]

        PickDescription { numberOfCards } ->
            [ Text "Anda perlu bermain "
            , Text (asWord numberOfCards)
            , Text " "
            , ref (noun Response numberOfCards)
            , Text "."
            ]

        DrawDescription { numberOfCards } ->
            [ Text "Kamu mendapatkan "
            , Text (asWord numberOfCards)
            , Text " ekstra "
            , ref (noun Response numberOfCards)
            , Text " sebelum bermain."
            ]

        NumberOfCards { numberOfCards } ->
            [ Text (String.fromInt numberOfCards) ]

        -- Lobby
        LobbyNameLabel ->
            [ Text "Nama Permainan" ]

        DefaultLobbyName { owner } ->
            [ Text owner, Text "'s Game" ]

        Invite ->
            [ Text "Undang pemain ke permainan." ]

        InviteLinkHelp ->
            [ Text "Kirim tautan ini ke pemain untuk mengundang mereka ke permainan, atau biarkan mereka memindai kode QR di bawah." ]

        InviteExplanation { gameCode, password } ->
            let
                extra =
                    password
                        |> Maybe.map
                            (\p ->
                                [ Text " dan kata sandi permainan “"
                                , Text p
                                , Text "”"
                                ]
                            )
                        |> Maybe.withDefault []
            in
            List.concat
                [ [ Text "Kode permainan Anda adalah "
                  , ref (GameCode { code = gameCode })
                  , Text ". Pemain dapat bergabung dengan permainan dengan memuat "
                  , ref MassiveDecks
                  , Text " dan memasukkan kode"
                  ]
                , extra
                , [ Text "."
                  ]
                ]

        Cast ->
            [ Text "Transmisikan ke TV." ]

        CastConnecting ->
            [ Text "Sambungkan…" ]

        CastConnected { deviceName } ->
            [ Text "Mentransmisikan ke ", Text deviceName, Text "." ]

        Players ->
            [ ref (nounUnknownQuantity Player) ]

        PlayersDescription ->
            [ Text "Pengguna memainkan game." ]

        Spectators ->
            [ ref (nounUnknownQuantity Spectator) ]

        SpectatorsDescription ->
            [ Text "Pengguna menonton game tanpa bermain." ]

        Left ->
            [ Text "Meninggalkan" ]

        LeftDescription ->
            [ Text "Pengguna yang telah keluar dari game." ]

        Away ->
            [ Text "Away" ]

        AwayDescription ->
            [ Text "Pengguna ini sementara keluar dari game." ]

        Disconnected ->
            [ Text "Terputus" ]

        DisconnectedDescription ->
            [ Text "Pengguna ini tidak terhubung ke game." ]

        Privileged ->
            [ Text "Owner" ]

        PrivilegedDescription ->
            [ Text "Pengguna ini dapat menyesuaikan pengaturan di dalam game." ]

        Ai ->
            [ Text "AI" ]

        AiDescription ->
            [ Text "Pemain ini dikendalikan oleh komputer." ]

        Score { total } ->
            [ Text (String.fromInt total) ]

        ScoreDescription ->
            [ Text "Jumlah "
            , ref (nounUnknownQuantity Point)
            , Text " pemain ini memiliki."
            ]

        Likes { total } ->
            [ Text (String.fromInt total) ]

        LikesDescription ->
            [ Text "Jumlah suka yang diterima."
            ]

        ToggleUserList ->
            [ Text "Menampilkan atau menyembunyikan papan skor." ]

        GameMenu ->
            [ Text "Menu permainan." ]

        UnknownUser ->
            [ Text "Pengguna yang tidak dikenal" ]

        InvitePlayers ->
            [ Text "Undang Pemain" ]

        InvitePlayersDescription ->
            [ Text "Dapatkan kode game / tautan / kode qr agar orang lain dapat bergabung dengan game ini. " ]

        SetAway ->
            [ Text "Tandai Sebagai Tidak Ada" ]

        SetBack ->
            [ Text "Tandai Sebagai Kembali" ]

        LeaveGame ->
            [ Text "Meninggalkan Permainan" ]

        LeaveGameDescription ->
            [ Text "Meninggalkan permainan secara permanen." ]

        Spectate ->
            [ Text "Tampilan Penonton" ]

        SpectateDescription ->
            [ Text "Buka tampilan penonton game di tab / jendela baru." ]

        BecomeSpectator ->
            [ Text "Saksikan" ]

        BecomeSpectatorDescription ->
            [ Text "Tonton saja permainannya tanpa bermain." ]

        BecomePlayer ->
            [ Text "Bermain" ]

        BecomePlayerDescription ->
            [ Text "Bermain dalam gamenya." ]

        EndGame ->
            [ Text "Akhir permainan" ]

        EndGameDescription ->
            [ Text "Akhiri permainannya sekarang." ]

        ReturnViewToGame ->
            [ Text "Kembali ke permainan" ]

        ReturnViewToGameDescription ->
            [ Text "Kembali ke tampilan permainan utama." ]

        ViewConfiguration ->
            [ Text "Konfigurasi" ]

        ViewConfigurationDescription ->
            [ Text "Beralih untuk melihat konfigurasi game." ]

        KickUser ->
            [ Text "Keluarkan" ]

        Promote ->
            [ Text "Ajukan" ]

        Demote ->
            [ Text "Turunkan" ]

        -- Notifications
        UserConnected { username } ->
            [ Text username, Text " telah tersambung kembali ke game." ]

        UserDisconnected { username } ->
            [ Text username, Text " telah terputus dari game." ]

        UserJoined { username } ->
            [ Text username, Text " telah bergabung dalam permainan." ]

        UserLeft { username } ->
            [ Text username, Text " telah meninggalkan permainan." ]

        UserKicked { username } ->
            [ Text username, Text " telah dikeluarkan dari permainan." ]

        Dismiss ->
            [ Text "Memberhentikan" ]

        -- Configuration
        ConfigureTitle ->
            [ Text "Game Setup" ]

        NoDecks ->
            [ Segment [ Text "No decks. " ]
            , Text " "
            , Segment [ Text "Anda perlu menambahkan setidaknya satu ke dalam game." ]
            ]

        NoDecksHint ->
            [ Text "Tidak yakin? Tambahkan yang asli ", raw CardsAgainstHumanity, Text " deck." ]

        WaitForDecks ->
            [ Text "Dek harus dimuat sebelum Anda dapat memulai permainan." ]

        MissingCardType { cardType } ->
            [ Text "Tidak ada dek Anda yang berisi "
            , ref (nounUnknownQuantity cardType)
            , Text ". Anda membutuhkan sebuah dek untuk memulai permainan."
            ]

        NotEnoughCardsOfType { cardType, needed, have } ->
            [ Text "Untuk jumlah pemain dalam game, Anda membutuhkan setidaknya "
            , Text (needed |> String.fromInt)
            , Text " "
            , ref (noun cardType needed)
            , Text " tapi kamu hanya punya "
            , Text (have |> String.fromInt)
            , Text "."
            ]

        AddBlankCards { amount } ->
            [ Text "Tambahkan "
            , amount |> String.fromInt |> Text
            , Text " kosong "
            , ref (noun Response amount)
            ]

        AddDeck ->
            [ Text "Tambah dek." ]

        RemoveDeck ->
            [ Text "Hapus deck." ]

        SourceNotFound { source } ->
            [ ref source, Text " tidak mengenali dek yang Anda minta. Periksa apakah detail yang Anda berikan sudah benar." ]

        SourceServiceFailure { source } ->
            [ ref source, Text " gagal menyediakan dek. Silakan coba lagi nanti atau coba sumber lain." ]

        ManyDecks ->
            [ Text "Banyak Deck" ]

        ManyDecksDeckCodeTitle ->
            [ Text "Kode Dek" ]

        ManyDecksDeckCodeShort ->
            [ Text "Kode dek setidaknya harus terdiri dari lima karakter." ]

        ManyDecksWhereToGet ->
            [ Text "Anda dapat membuat dan menemukan dek untuk dimainkan ", ref ManyDecks, Text "." ]

        JsonAgainstHumanity ->
            [ Text "JSON Melawan Kemanusiaan" ]

        JsonAgainstHumanityAbout ->
            [ Text "Dek disediakan oleh ", ref JsonAgainstHumanity ]

        BuiltIn ->
            [ Text "Bawaan" ]

        APlayer ->
            [ Text "Seorang Player" ]

        -- TODO: Translate
        Generated { by } ->
            [ Missing ]

        DeckAlreadyAdded ->
            [ Text "Dek ini sudah ada dalam game." ]

        ConfigureDecks ->
            [ Text "Peraturan" ]

        ConfigureRules ->
            [ Text "Rules" ]

        ConfigureTimeLimits ->
            [ Text "Batas Waktu" ]

        ConfigurePrivacy ->
            [ Text "Privasi" ]

        HandSize ->
            [ Text "Ukuran Tangan" ]

        HandSizeDescription ->
            [ Text "Jumlah dasar kartu yang dimiliki setiap pemain selama permainan." ]

        ScoreLimit ->
            [ ref (noun Point 1), Text " Limit" ]

        ScoreLimitDescription ->
            [ Segment
                [ Text "Jumlah "
                , ref (nounUnknownQuantity Point)
                , Text " pemain harus memenangkan permainan."
                ]
            , Text " "
            , Segment [ Text "Jika dinonaktifkan, permainan berlanjut tanpa batas." ]
            ]

        UnsavedChangesWarning ->
            [ Text "Anda memiliki perubahan yang belum disimpan pada konfigurasi, perubahan tersebut harus disimpan terlebih dahulu jika Anda ingin menerapkannya "
            , Text "ke permainan."
            ]

        SaveChanges ->
            [ Text "Simpan perubahan Anda." ]

        RevertChanges ->
            [ Text "Buang perubahan Anda yang belum disimpan." ]

        NeedAtLeastOneDeck ->
            [ Text "Anda membutuhkan setumpuk kartu yang ditambahkan untuk memulai permainan." ]

        NeedAtLeastThreePlayers ->
            [ Text "Anda membutuhkan setidaknya tiga pemain untuk memulai permainan." ]

        NeedAtLeastOneHuman ->
            [ Text "Sayangnya pemain komputer tidak bisa menjadi "
            , ref Czar
            , Text ", jadi Anda membutuhkan setidaknya satu pemain manusia untuk memulai permainan."
            , Text " (Meskipun hanya satu manusia yang mungkin sedikit membosankan!)"
            ]

        RandoCantWrite ->
            [ Text "Pemain komputer tidak bisa menulis kartunya sendiri." ]

        DisableComedyWriter ->
            [ Text "Nonaktifkan" ]

        DisableRando ->
            [ Text "Nonaktifkan ", ref HouseRuleRandoCardrissian ]

        AddAnAiPlayer ->
            [ Text "Tambahkan pemain AI ke dalam game." ]

        PasswordShared ->
            [ Text "Siapa pun di dalam game dapat melihat kata sandinya! "
            , Text "Menyembunyikannya di atas hanya memengaruhi Anda (berguna jika streaming, dll…)."
            ]

        PasswordNotSecured ->
            [ Text "Kata sandi game "
            , Em [ Text "tidak" ]
            , Text " disimpan dengan aman — mohon berikan ini "
            , Em [ Text "jangan" ]
            , Text " gunakan sandi serius yang Anda gunakan di tempat lain!"
            ]

        LobbyPassword ->
            [ Text "Sandi Game" ]

        LobbyPasswordDescription ->
            [ Text "Kata sandi untuk pengguna harus dimasukkan sebelum mereka dapat bergabung dalam permainan." ]

        AudienceMode ->
            [ Text "Mode Audiens" ]

        AudienceModeDescription ->
            [ Text "Jika diaktifkan, pengguna yang baru bergabung akan menjadi penonton secara default, dan hanya Anda yang bisa "
            , Text "jadikan mereka pemain."
            ]

        StartGame ->
            [ Text "Mulai Permainan" ]

        Public ->
            [ Text "Permainan Publik" ]

        PublicDescription ->
            [ Text "Jika diaktifkan, game tersebut akan muncul di daftar game publik untuk ditemukan siapa saja." ]

        ApplyConfiguration ->
            [ Text "Terapkan perubahan ini." ]

        AppliedConfiguration ->
            [ Text "Tersimpan." ]

        InvalidConfiguration ->
            [ Text "Nilai konfigurasi ini tidak valid." ]

        Automatic ->
            [ Text "Secara Otomatis Tandai Pemain Sebagai Away" ]

        AutomaticDescription ->
            [ Text "Jika diaktifkan, ketika batas waktu habis, pemain secara otomatis akan ditandai sebagai pergi. "
            , Text "Jika tidak, seseorang perlu menekan tombol untuk melakukannya."
            ]

        TimeLimit { stage } ->
            [ ref stage, Text " Batas waktu" ]

        PlayingTimeLimitDescription ->
            [ Text "Berapa lama (dalam detik) ", ref Players, Text " harus membuat permainan mereka." ]

        PlayingAfterDescription ->
            [ Text "Berapa lama (dalam detik) pemain harus mengubah permainan mereka sebelum tahap berikutnya dimulai." ]

        RevealingTimeLimitDescription ->
            [ Text "Berapa lama (dalam detik) file ", ref Czar, Text " harus mengungkap plays." ]

        RevealingAfterDescription ->
            [ Text "Berapa lama (dalam detik) menunggu setelah kartu terakhir diumumkan sebelum tahap selanjutnya dimulai." ]

        JudgingTimeLimitDescription ->
            [ Text "Berapa lama (dalam detik) ", ref Czar, Text " harus menilai plays." ]

        CompleteTimeLimitDescription ->
            [ Text "Berapa lama waktu (dalam detik) untuk menunggu setelah satu putaran berakhir sebelum memulai putaran berikutnya." ]

        RevealingEnabledTitle ->
            [ Text "Czar Reveals Plays" ]

        RevealingEnabled ->
            [ Text "Jika ini diaktifkan,  "
            , ref Czar
            , Text " mengungkapkan satu permainan pada satu waktu sebelum memilih pemenang."
            ]

        DuringTitle ->
            [ Text "Batas waktu" ]

        AfterTitle ->
            [ Text "Setelah" ]

        Conflict ->
            [ Text "Konflik" ]

        ConflictDescription ->
            [ Text "Orang lain membuat perubahan ini sementara Anda juga membuat perubahan. "
            , Text "Pilih apakah Anda ingin menyimpan perubahan Anda atau milik mereka."
            ]

        YourChanges ->
            [ Text "pergerekanmu" ]

        TheirChanges ->
            [ Text "Pergerakan mereka" ]

        ConfigurationDisabledWhileInGame ->
            [ Text "Saat permainan berlangsung, Anda tidak dapat mengubah konfigurasi." ]

        ConfigurationDisabledIfNotPrivileged ->
            [ Text "Anda tidak dapat mengubah konfigurasi game ini." ]

        ConfigureNextGame ->
            [ Text "Konfigurasi Game Berikutnya" ]

        -- Game
        SubmitPlay ->
            [ Text "Berikan kartu ini ke ", ref Czar, Text " sebagai permainan Anda untuk putaran tersebut." ]

        TakeBackPlay ->
            [ Text "Ambil kembali kartu Anda untuk mengubah permainan Anda untuk putaran tersebut." ]

        JudgePlay ->
            [ Text "Pilih permainan ini sebagai pemenang putaran." ]

        LikePlay ->
            [ Text "Tambahkan suka untuk permainan ini." ]

        AdvanceRound ->
            [ Text "Putaran Selanjutnya." ]

        Playing ->
            [ Text "Bermain" ]

        Revealing ->
            [ Text "Pembuktian" ]

        Judging ->
            [ Text "Penjurian" ]

        Complete ->
            [ Text "Selesai" ]

        ViewGameHistoryAction ->
            [ Text "Lihat babak sebelumnya dari game ini." ]

        ViewHelpAction ->
            [ Text "Bantuan" ]

        EnforceTimeLimitAction ->
            [ Text "Atur semua pemain yang ditunggu permainan untuk pergi dan lewati mereka sampai mereka kembali." ]

        Blank ->
            [ Text "Blank" ]

        RoundStarted ->
            [ Text "Putaran Dimulai" ]

        JudgingStarted ->
            [ Text "Penjurian Dimulai" ]

        Paused ->
            [ Text "Permainan telah dihentikan sementara karena tidak ada cukup pemain aktif untuk melanjutkan."
            , Text "Ketika seseorang bergabung atau kembali, itu akan berlanjut secara otomatis."
            ]

        ClientAway ->
            [ Text "Anda saat ini ditetapkan sebagai jauh dari permainan, dan tidak sedang bermain." ]

        Discard ->
            [ Text "Buang kartu yang dipilih, tunjukkan kepada pengguna lain dalam game." ]

        Discarded { player } ->
            [ Text player
            , Text " membuang kartu berikut:"
            ]

        -- Instructions
        PlayInstruction { numberOfCards } ->
            [ Text "Anda harus memilih "
            , Text (asWord numberOfCards)
            , Text " more "
            , ref (noun Response numberOfCards)
            , Text " dari tangan Anda ke babak ini sebelum Anda dapat mengirimkan permainan Anda."
            ]

        SubmitInstruction ->
            [ Text "Anda harus mengirimkan permainan Anda untuk babak ini." ]

        WaitingForPlaysInstruction ->
            [ Text "Anda sedang menunggu pemain lain untuk bermain di ronde tersebut." ]

        CzarsDontPlayInstruction ->
            [ Text "Kamu adalah "
            , ref Czar
            , Text " untuk putaran - Anda tidak mengirimkan apapun "
            , ref (nounUnknownQuantity Response)
            , Text ". Sebaliknya Anda memilih pemenang setelah semua orang mengirimkan milik mereka."
            ]

        NotInRoundInstruction ->
            [ Text "Anda tidak berada di babak ini. Anda akan bermain di pertandingan berikutnya kecuali Anda siap untuk pergi." ]

        RevealPlaysInstruction ->
            [ Text "Klik plays untuk membaliknya, lalu pilih yang menurut Anda terbaik." ]

        WaitingForCzarInstruction ->
            [ Text "Anda bisa menyukai permainan sambil menunggu ", ref Czar, Text " untuk mengungkap permainan dan memilih pemenang untuk babak tersebut." ]

        AdvanceRoundInstruction ->
            [ Text "Babak berikutnya telah dimulai, Anda bisa maju." ]

        -- 404 Unknown
        UnknownPageTitle ->
            [ Text "404 Error: Unknown page." ]

        GoBackHome ->
            [ Text "Go to the main page." ]

        -- Actions
        Refresh ->
            [ Text "refresh" ]

        Accept ->
            [ Text "OK" ]

        -- Errors
        Error ->
            [ Text "Error" ]

        ErrorHelp ->
            [ Text "Server game mungkin sedang down, atau ini mungkin bug. Menyegarkan halaman akan membantu Anda melanjutkan "
            , Text "lagi. Rincian lebih lanjut dapat ditemukan di bawah."
            ]

        ErrorHelpTitle ->
            [ Text "Maaf, terjadi kesalahan." ]

        ErrorCheckOutOfBand ->
            [ Text "Please check ", ref TwitterHandle, Text " untuk pembaruan dan status layanan. Server game akan mati sebentar saat versi baru dirilis, jadi jika Anda melihat pembaruan terkini, coba lagi dalam beberapa menit." ]

        TwitterHandle ->
            [ Text "@Massive_Decks" ]

        ReportError ->
            [ Text "Report Bug" ]

        ReportErrorDescription ->
            [ Text "Beri tahu pengembang tentang bug yang Anda temui sehingga mereka dapat memperbaikinya." ]

        ReportErrorBody ->
            [ Text "Saya [ganti dengan penjelasan singkat tentang apa yang Anda lakukan] ketika saya mendapatkan error berikut:" ]

        BadUrlError ->
            [ Text "Kami mencoba membuat permintaan ke halaman yang tidak valid." ]

        TimeoutError ->
            [ Text "Server tidak merespons terlalu lama. Mungkin sedang down, coba lagi setelah penundaan singkat." ]

        NetworkError ->
            [ Text "Koneksi internet Anda terputus." ]

        ServerDownError ->
            [ Text "Server game sedang offline. Silakan coba lagi nanti." ]

        BadStatusError ->
            [ Text "Server mendapatkan tanggapan yang tidak kami harapkan." ]

        BadPayloadError ->
            [ Text "Server memiliki tanggapan yang tidak kami mengerti." ]

        PatchError ->
            [ Text "Server memberikan tambalan yang tidak dapat kami terapkan." ]

        VersionMismatch ->
            [ Text "Server memberikan perubahan konfigurasi untuk versi yang berbeda dari yang kami harapkan." ]

        CastError ->
            [ Text "Maaf, terjadi kesalahan saat mencoba menyambung ke game." ]

        ActionExecutionError ->
            [ Text "Anda tidak dapat melakukan tindakan itu." ]

        IncorrectPlayerRoleError { role, expected } ->
            [ Text "Anda harus menjadi ", ref expected, Text " untuk melakukan itu, tetapi Anda adalah  ", ref role, Text "." ]

        IncorrectUserRoleError { role, expected } ->
            [ Text "Anda harus menjadi ", ref expected, Text " untuk melakukan itu, tetapi Anda adalah  ", ref role, Text "." ]

        IncorrectRoundStageError { stage, expected } ->
            [ Text "Putarannya harus di ", ref expected, Text " tahap untuk melakukan itu, tetapi pada ", ref stage, Text " stage." ]

        ConfigEditConflictError ->
            [ Text "Orang lain mengubah konfigurasi sebelum Anda, perubahan Anda tidak disimpan." ]

        UnprivilegedError ->
            [ Text "Anda tidak memiliki hak istimewa untuk melakukan itu." ]

        GameNotStartedError ->
            [ Text "Game harus mulai melakukan itu." ]

        InvalidActionError { reason } ->
            [ Text "Server tidak memahami permintaan dari klien. Rincian: ", Text reason ]

        AuthenticationError ->
            [ Text "Anda tidak dapat bergabung dengan game." ]

        IncorrectIssuerError ->
            [ Text "Kredensial Anda untuk bergabung dengan game ini sudah usang, game tidak lagi ada." ]

        InvalidAuthenticationError ->
            [ Text "Kredensial Anda untuk bergabung dengan game ini rusak." ]

        InvalidLobbyPasswordError ->
            [ Text "Kata sandi permainan yang Anda berikan salah. Coba ketikkan lagi dan jika masih tidak berhasil, tanyakan orang yang mengundang Anda lagi." ]

        AlreadyLeftError ->
            [ Text "Anda sudah keluar dari game ini." ]

        LobbyNotFoundError ->
            [ Text "Game itu tidak ada." ]

        LobbyClosedError { gameCode } ->
            [ Text "Game yang ingin Anda ikuti (", ref (GameCode { code = gameCode }), Text ") telah berakhir." ]

        LobbyDoesNotExistError { gameCode } ->
            [ Text "Kode game yang Anda masukkan ("
            , ref (GameCode { code = gameCode })
            , Text ") tidak ada. "
            , Text "Coba ketikkan lagi dan jika masih tidak berhasil, tanyakan orang yang mengundang Anda lagi."
            ]

        RegistrationError ->
            [ Text "Masalah saat bergabung dengan game." ]

        UsernameAlreadyInUseError { username } ->
            [ Text "Seseorang sudah menggunakan nama pengguna “"
            , Text username
            , Text "”—coba nama lain."
            ]

        GameError ->
            [ Text "Ada yang tidak beres dalam game." ]

        OutOfCardsError ->
            [ Text "Tidak ada cukup kartu di dek untuk membantu semua orang! Coba tambahkan lebih banyak dek dalam konfigurasi game." ]

        -- Language Names
        English ->
            [ Text "English" ]

        BritishEnglish ->
            [ Text "English (British)" ]

        Italian ->
            [ Text "Italian" ]

        BrazilianPortuguese ->
            [ Text "Portuguese (Brazilian)" ]

        German ->
            [ Text "German (Formal)" ]

        GermanInformal ->
            [ Text "German (Informal)" ]

        Polish ->
            [ Text "Polandia" ]

        Indonesian ->
            [ Text "Bahasa Indonesia" ]


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


{-| Take a number and give back the name of that number. Falls back to the number when it gets too big.
-}
asWord : Int -> String
asWord number =
    case number of
        0 ->
            "nol"

        1 ->
            "satu"

        2 ->
            "dua"

        3 ->
            "tiga"

        4 ->
            "empat"

        5 ->
            "lima"

        6 ->
            "enam"

        7 ->
            "tujuh"

        8 ->
            "delapan"

        9 ->
            "sembilan"

        10 ->
            "sepuluh"

        11 ->
            "sebelas"

        12 ->
            "duabelas"

        other ->
            String.fromInt other
