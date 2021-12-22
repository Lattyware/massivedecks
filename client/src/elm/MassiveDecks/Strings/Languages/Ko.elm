module MassiveDecks.Strings.Languages.Ko exposing (pack)

{-| Korean localization.

Contributors:

  - sjkim04 <https://github.com/sjkim04>

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
        { lang = Ko
        , code = "ko-kr"
        , name = Korean
        , translate = translate
        , recommended = "cah-base-ko" |> BuiltIn.hardcoded |> Source.BuiltIn
        }



translate : Maybe never -> MdString -> List (Translation.Result never)
translate _ mdString =
    case mdString of
        -- General
        MassiveDecks ->
            [ Text "Massive Decks" ]

        Close ->
            [ Text "닫기" ]

        Noun { noun, quantity } ->
            let
                singular =
                    case noun of
                        Call ->
                            [ Text "검정 카드" ]

                        Response ->
                            [ Text "하양 카드" ]

                        Point ->
                            [ Text "머찐 포인트" ]

                        Player ->
                            [ Text "플레이어" ]

                        Spectator ->
                            [ Text "관전자" ]

                plural =
                    case quantity of
                        Quantity 1 ->
                            []

                        _ ->
                            [ Text "들" ]
            in
            List.concat [ singular, plural ]

        -- Start screen.
        Version { versionNumber } ->
            [ Text "버전 “", Text versionNumber, Text "”" ]

        ShortGameDescription ->
            [ Text "코미디 파티 게임" ]

        WhatIsThis ->
            [ ref MassiveDecks, Text "가 무엇인가요?" ]

        GameDescription ->
            [ ref MassiveDecks
            , Text "는 코미디 파티 게임입니다."
            , ref CardsAgainstHumanity
            , Text "를 기반으로 만들고,"
            , ref RereadGames
            , Text "와 다른 기여자에 의해 개발되었습니다. 이 게임은 "
            , ref License
            , Text " 아래에 오픈 소스가 되어있기 때문에, "
            , ref MDProject
            , Text "에서 게임을 더 발전시키거나, 소스코드를 보거나, 더 자세한 정보에 대해 알아볼 수 있습니다."
            ]

        NewGame ->
            [ Text "새 게임" ]

        NewGameDescription ->
            [ ref MassiveDecks, Text "의 새 게임을 시작합니다." ]

        FindPublicGame ->
            [ Text "찾기" ]

        JoinPrivateGame ->
            [ Text "참여하기" ]

        JoinPrivateGameDescription ->
            [ Text "누군가가 당신을 초대한 게임에 들어갑니다." ]

        PlayGame ->
            [ Text "플레이" ]

        AboutTheGame ->
            [ Text "정보" ]

        AboutTheGameDescription ->
            [ ref MassiveDecks, Text "에 대해 알아보고, 어떻게 개발되었는지 알아 보세요." ]

        MDLogoDescription ->
            [ ref (noun Call 1), Text "와 ", ref (noun Response 1), Text "에 “M”과 “D”가 새겨져 있습니다." ]

        RereadLogoDescription ->
            [ Text "재활용 화살표에 둘러싸인 책." ]

        MDProject ->
            [ Text "GitHub 프로젝트" ]

        License ->
            [ Text "AGPLv3 라이선스" ]

        DevelopedByReread ->
            [ ref RereadGames, Text "개발" ]

        RereadGames ->
            [ Text "Reread Games" ]

        NameLabel ->
            [ Text "당신의 이름" ]

        NameInUse ->
            [ Text "다른 누군가가 게임 내에서 이 이름을 쓰고 있습니다. 다른 이름을 지어 보세요." ]

        RejoinTitle ->
            [ Text "게임 재참가" ]

        RejoinGame { code } ->
            [ Text "“", GameCode { code = code } |> ref, Text "”에 재참가" ]

        LobbyRequiresPassword ->
            [ Text "이 게임에 참가하려면 비밀번호가 필요합니다. 당신을 초대한 사람에게 물어보세요." ]

        YouWereKicked ->
            [ Text "당신은 게임에서 추방되었습니다." ]

        ScrollToTop ->
            [ Text "페이지 최상단으로 가기" ]

        Copy ->
            [ Text "복사" ]

        -- Rules
        CardsAgainstHumanity ->
            [ Text "Cards Against Humanity" ]

        Rules ->
            [ Text "플레이하는 방법입니다." ]

        RulesHand ->
            [ Text "각 플레이어는 일정량의", ref (nounUnknownQuantity Response), Text "를 가지고 있습니다." ]

        RulesCzar ->
            [ Text "처음 플레이어가 "
            , ref Czar
            , Text "로써 시작합니다. "
            , ref Czar
            , Text "는 "
            , ref (noun Call 1)
            , Text " 안의 질문이나 빈칸 채우기 문구를 모두에게 읽어 줍니다."
            ]

        RulesPlaying ->
            [ Text "나머지 사람들은 자신이 가지고 있는 "
            , ref (noun Response 1)
            , Text " 중 하나를 선택하여 그 질문에 답하거나 빈칸을 채워넣습니다."
            ]

        RulesJudging ->
            [ Text "답안들이 섞이고 나서, "
            , ref Czar
            , Text "가 다른 플레이어들에게 그것을 읽어 줍니다—더 효과를 주기 위해서, "
            , ref Czar
            , Text "는 답안을 읽기 전에"
            , ref (noun Call 1)
            , Text "를 다시 읽어 줍니다. 그 후에"
            , ref Czar
            , Text "는 제일 재밌는 것을 고르고, 그것을 낸 사람은 "
            , ref (noun Point 1)
            , Text " 1점을 얻습니다."
            ]

        RulesPickTitle ->
            [ ref (Pick { numberOfCards = 2 }) ]

        RulesPick ->
            [ Text "일부 카드에 답하기 위해서는 1장의 "
            , ref (noun Response 1)
            , Text "보다 많은 카드가 필요합니다. 그때는, 카드를 낸 순서대로 "
            , ref Czar
            , Text "가 읽을 겁니다—ㅅ."
            ]

        ExamplePickDescription ->
            [ ref (nounUnknownQuantity Call)
            , Text " like this will require picking more "
            , ref (nounUnknownQuantity Response)
            , Text ", but give you more to pick from."
            ]

        RulesDraw ->
            [ Text "Some "
            , ref (nounUnknownQuantity Call)
            , Text " will need even more "
            , ref (nounUnknownQuantity Response)
            , Text "—these will say "
            , ref (Draw { numberOfCards = 2 })
            , Text " or more, and you’ll get that many extra cards before you play."
            ]

        GameRulesTitle ->
            [ Text "Game Rules" ]

        HouseRulesTitle ->
            [ Text "House Rules" ]

        HouseRules ->
            [ Text "You can change the way the game is played in a variety of ways. While setting up the game, choose "
            , Text "as many house rules as you would like to use."
            ]

        HouseRuleReboot ->
            [ Text "Rebooting the Universe" ]

        HouseRuleRebootDescription { cost } ->
            [ Text "At any time, players may trade in "
            , Text (an cost)
            , ref (nounMaybe Point cost)
            , Text " to discard their hand and draw a new one."
            ]

        HouseRuleRebootAction { cost } ->
            [ Text "Spend "
            , Text (asWord cost)
            , Text " "
            , ref (noun Point cost)
            , Text " to discard your hand and draw a new one."
            ]

        HouseRuleRebootCost ->
            [ ref (noun Point 1), Text " Cost" ]

        HouseRuleRebootCostDescription ->
            [ Text "How many ", ref (nounUnknownQuantity Point), Text " it costs to redraw." ]

        HouseRulePackingHeat ->
            [ Text "Packing Heat" ]

        HouseRulePackingHeatDescription ->
            [ Text "Any "
            , ref (nounUnknownQuantity Call)
            , Text " with "
            , ref (Pick { numberOfCards = 2 })
            , Text " also get "
            , ref (Draw { numberOfCards = 1 })
            , Text ", so everyone has more options."
            ]

        HouseRuleComedyWriter ->
            [ Text "Comedy Writer" ]

        HouseRuleComedyWriterDescription ->
            [ Text "Add blank "
            , ref (nounUnknownQuantity Response)
            , Text " where players can write custom responses."
            ]

        HouseRuleComedyWriterNumber ->
            [ Text "Blank ", ref (nounUnknownQuantity Response) ]

        HouseRuleComedyWriterNumberDescription ->
            [ Text "The number of Blank "
            , ref (nounUnknownQuantity Response)
            , Text " that will be in the game."
            ]

        HouseRuleComedyWriterExclusive ->
            [ Text "Only Blank ", ref (nounUnknownQuantity Response) ]

        HouseRuleComedyWriterExclusiveDescription ->
            [ Text "If enabled, all other "
            , ref (nounUnknownQuantity Response)
            , Text " will be ignored, only blank ones will exist in-game."
            ]

        HouseRuleRandoCardrissian ->
            [ Text "Rando Cardrissian" ]

        HouseRuleRandoCardrissianDescription ->
            [ Text "Every round, the first "
            , ref (noun Response 1)
            , Text " in the deck will be played as an answer. This play belongs to an AI player named "
            , Text "Rando Cardrissian, and if he wins the game, all players go home in a state of everlasting shame."
            ]

        HouseRuleRandoCardrissianNumber ->
            [ Text "AI Players" ]

        HouseRuleRandoCardrissianNumberDescription ->
            [ Text "The number of AI players that will be in the game." ]

        HouseRuleNeverHaveIEver ->
            [ Text "Never Have I Ever" ]

        HouseRuleNeverHaveIEverDescription ->
            [ Text "At any time, a player may discard cards they don't understand, however, they must confess their "
            , Text "ignorance: the card is shared publicly."
            ]

        HouseRuleHappyEnding ->
            [ Text "Happy Ending" ]

        HouseRuleHappyEndingDescription ->
            [ Text "When the game ends, the final round is a 'Make a Haiku' ", ref (noun Call 1), Text "." ]

        HouseRuleCzarChoices ->
            [ ref Czar, Text " Choices" ]

        HouseRuleCzarChoicesDescription ->
            [ Text "At the beginning of the round, the "
            , ref Czar
            , Text " draws multiple "
            , ref (nounUnknownQuantity Call)
            , Text " and chooses one of them, and/or has the choice to write their own."
            ]

        HouseRuleCzarChoicesNumber ->
            [ Text "Number" ]

        HouseRuleCzarChoicesNumberDescription ->
            [ Text "The number of choices to give the ", ref Czar, Text " to pick between." ]

        HouseRuleCzarChoicesCustom ->
            [ Text "Custom" ]

        HouseRuleCzarChoicesCustomDescription ->
            [ Text "If the ", ref Czar, Text " can write custom calls. This takes up one of the choices." ]

        HouseRuleWinnersPick ->
            [ Text "Winner's Pick" ]

        HouseRuleWinnersPickDescription ->
            [ Text "The winner of each round becomes the ", ref Czar, Text " for the next round." ]

        SeeAlso { rule } ->
            [ Text "See also: ", ref rule ]

        MustBeMoreThanOrEqualValidationError { min } ->
            [ Text "The value must be at least ", Text (String.fromInt min), Text "." ]

        MustBeLessThanOrEqualValidationError { max } ->
            [ Text "The value must be at most ", Text (String.fromInt max), Text "." ]

        SetValue { value } ->
            [ Text "Set the value to ", Text (String.fromInt value), Text "." ]

        CantBeEmpty ->
            [ Text "This can't be empty." ]

        SettingsTitle ->
            [ Text "Settings" ]

        LanguageSetting ->
            [ Text "Language" ]

        MissingLanguage ->
            [ Text "Don’t see your language? ", ref TranslationBeg ]

        AutonymFormat { autonym } ->
            [ Text "(", Text autonym, Text ")" ]

        TranslationBeg ->
            [ Text "Help translate "
            , ref MassiveDecks
            , Text "!"
            ]

        CardSizeSetting ->
            [ Text "Compact Cards" ]

        CardSizeExplanation ->
            [ Text "Adjust how big cards are—this can be useful on small screens to scroll less." ]

        AutoAdvanceSetting ->
            [ Text "Automatically Advance Round" ]

        AutoAdvanceExplanation ->
            [ Text "When a round ends, automatically advance to the next one rather than waiting." ]

        SpeechSetting ->
            [ Text "Text To Speech" ]

        SpeechExplanation ->
            [ Text "Read out cards using text to speech." ]

        SpeechNotSupportedExplanation ->
            [ Text "Your browser does not support text to speech, or has no voices installed." ]

        VoiceSetting ->
            [ Text "Speech Voice" ]

        NotificationsSetting ->
            [ Text "Browser Notifications" ]

        NotificationsExplanation ->
            [ Text "Alert you when you need to do something in the game using browser notifications."
            ]

        NotificationsUnsupportedExplanation ->
            [ Text "Your browser doesn't support notifications." ]

        NotificationsBrowserPermissions ->
            [ Text "You will need to give permission for "
            , ref MassiveDecks
            , Text " to notify you. This will only be used while the game is open and while you have this enabled."
            ]

        NotificationOnlyWhenHiddenSetting ->
            [ Text "Only When Hidden" ]

        NotificationsOnlyWhenHiddenExplanation ->
            [ Text "Only send notifications when you are not looking at the page (e.g: on another tab or minimised)." ]

        NotificationsOnlyWhenHiddenUnsupportedExplanation ->
            [ Text "Your browser doesn't support checking for page visibility." ]

        -- Terms
        Czar ->
            [ Text "Card Czar" ]

        CzarDescription ->
            [ Text "The player judging the round." ]

        CallDescription ->
            [ Text "A black card with a question or fill-in-the-blank phrase." ]

        ResponseDescription ->
            [ Text "A white card with a phrase played into rounds." ]

        PointDescription ->
            [ Text "A point—having more means winning." ]

        GameCodeTerm ->
            [ Text "Game Code" ]

        GameCodeDescription ->
            [ Text "A code that lets other people find and join your game." ]

        GameCode { code } ->
            [ Text code ]

        GameCodeSpecificDescription ->
            [ Text "Give this game code to people and they can join the game." ]

        GameCodeHowToAcquire ->
            [ Text "Ask the person who invited you for the game’s ", ref GameCodeTerm, Text "." ]

        Deck ->
            [ Text "Deck" ]

        DeckSource ->
            [ ref Deck, Text " Source" ]

        DeckLanguage { language } ->
            [ Text "in ", Text language ]

        DeckAuthor { author } ->
            [ Text "by ", Text author ]

        DeckTranslator { translator } ->
            [ Text "translation by ", Text translator ]

        StillPlaying ->
            [ Text "Playing" ]

        PlayingDescription ->
            [ Text "This player is in the round, but has not yet submitted a play." ]

        Played ->
            [ Text "Played" ]

        PlayedDescription ->
            [ Text "This player has submitted their play for the round." ]

        -- Lobby Browser
        LobbyBrowserTitle ->
            [ Text "Public Games" ]

        NoPublicGames ->
            [ Text "No public games available." ]

        PlayingGame ->
            [ Text "Games that are in progress." ]

        SettingUpGame ->
            [ Text "Games that have not yet started." ]

        StartYourOwn ->
            [ Text "Start a new game?" ]

        -- Spectation
        JoinTheGame ->
            [ Text "Join the game!" ]

        ToggleAdvertDescription ->
            [ Text "Toggle showing the information on joining the game." ]

        -- Cards
        Pick numberOfCards ->
            [ Text "Pick", ref (NumberOfCards numberOfCards) ]

        Draw numberOfCards ->
            [ Text "Draw", ref (NumberOfCards numberOfCards) ]

        PickDescription { numberOfCards } ->
            [ Text "You need to play "
            , Text (asWord numberOfCards)
            , Text " "
            , ref (noun Response numberOfCards)
            , Text "."
            ]

        DrawDescription { numberOfCards } ->
            [ Text "You get "
            , Text (asWord numberOfCards)
            , Text " extra "
            , ref (noun Response numberOfCards)
            , Text " before playing."
            ]

        NumberOfCards { numberOfCards } ->
            [ Text (String.fromInt numberOfCards) ]

        -- Lobby
        LobbyNameLabel ->
            [ Text "Game Name" ]

        DefaultLobbyName { owner } ->
            [ Text owner, Text "'s Game" ]

        Invite ->
            [ Text "Invite players to the game." ]

        InviteLinkHelp ->
            [ Text "Send this link to players to invite them to the game, or let them scan the QR code below." ]

        InviteExplanation { gameCode, password } ->
            let
                extra =
                    password
                        |> Maybe.map
                            (\p ->
                                [ Text " and the game password “"
                                , Text p
                                , Text "”"
                                ]
                            )
                        |> Maybe.withDefault []
            in
            List.concat
                [ [ Text "Your game code is "
                  , ref (GameCode { code = gameCode })
                  , Text ". Players can join the game by loading "
                  , ref MassiveDecks
                  , Text " and entering that code"
                  ]
                , extra
                , [ Text "."
                  ]
                ]

        Cast ->
            [ Text "Cast to TV." ]

        CastConnecting ->
            [ Text "Connecting…" ]

        CastConnected { deviceName } ->
            [ Text "Casting to ", Text deviceName, Text "." ]

        Players ->
            [ ref (nounUnknownQuantity Player) ]

        PlayersDescription ->
            [ Text "Users playing the game." ]

        Spectators ->
            [ ref (nounUnknownQuantity Spectator) ]

        SpectatorsDescription ->
            [ Text "Users watching the game without playing." ]

        Left ->
            [ Text "Left" ]

        LeftDescription ->
            [ Text "Users who have left the game." ]

        Away ->
            [ Text "Away" ]

        AwayDescription ->
            [ Text "This user is temporarily away from the game." ]

        Disconnected ->
            [ Text "Disconnected" ]

        DisconnectedDescription ->
            [ Text "This user is not connected to the game." ]

        Privileged ->
            [ Text "Owner" ]

        PrivilegedDescription ->
            [ Text "This user can adjust settings in the game." ]

        Ai ->
            [ Text "AI" ]

        AiDescription ->
            [ Text "This player is controlled by the computer." ]

        Score { total } ->
            [ Text (String.fromInt total) ]

        ScoreDescription ->
            [ Text "The number of "
            , ref (nounUnknownQuantity Point)
            , Text " this player has."
            ]

        Likes { total } ->
            [ Text (String.fromInt total) ]

        LikesDescription ->
            [ Text "The number of likes received."
            ]

        ToggleUserList ->
            [ Text "Show or hide the scoreboard." ]

        GameMenu ->
            [ Text "Game menu." ]

        UnknownUser ->
            [ Text "An unknown user" ]

        InvitePlayers ->
            [ Text "Invite Players" ]

        InvitePlayersDescription ->
            [ Text "Get the game code/link/qr code to let others join this game." ]

        SetAway ->
            [ Text "Mark As Away" ]

        SetBack ->
            [ Text "Mark As Back" ]

        LeaveGame ->
            [ Text "Leave Game" ]

        LeaveGameDescription ->
            [ Text "Permanently leave the game." ]

        Spectate ->
            [ Text "Spectator View" ]

        SpectateDescription ->
            [ Text "Open a spectator's view of the game in a new tab/window." ]

        BecomeSpectator ->
            [ Text "Spectate" ]

        BecomeSpectatorDescription ->
            [ Text "Just watch the game without playing." ]

        BecomePlayer ->
            [ Text "Play" ]

        BecomePlayerDescription ->
            [ Text "Play in the game." ]

        EndGame ->
            [ Text "End Game" ]

        EndGameDescription ->
            [ Text "End the game now." ]

        ReturnViewToGame ->
            [ Text "Return to game" ]

        ReturnViewToGameDescription ->
            [ Text "Return to the main game view." ]

        ViewConfiguration ->
            [ Text "Configure" ]

        ViewConfigurationDescription ->
            [ Text "Switch to view the game's configuration." ]

        KickUser ->
            [ Text "Kick" ]

        Promote ->
            [ Text "Promote" ]

        Demote ->
            [ Text "Demote" ]

        -- Notifications
        UserConnected { username } ->
            [ Text username, Text " has reconnected to the game." ]

        UserDisconnected { username } ->
            [ Text username, Text " has disconnected from the game." ]

        UserJoined { username } ->
            [ Text username, Text " has joined the game." ]

        UserLeft { username } ->
            [ Text username, Text " has left the game." ]

        UserKicked { username } ->
            [ Text username, Text " has been kicked from the game." ]

        Dismiss ->
            [ Text "Dismiss" ]

        -- Configuration
        ConfigureTitle ->
            [ Text "Game Setup" ]

        NoDecks ->
            [ Segment [ Text "No decks. " ]
            , Text " "
            , Segment [ Text "You will need to add at least one to the game." ]
            ]

        NoDecksHint ->
            [ Text "Not sure? Add the original ", raw CardsAgainstHumanity, Text " deck." ]

        WaitForDecks ->
            [ Text "The decks must load before you can start the game." ]

        MissingCardType { cardType } ->
            [ Text "None of your decks contain any "
            , ref (nounUnknownQuantity cardType)
            , Text ". You need a deck that does to start the game."
            ]

        NotEnoughCardsOfType { cardType, needed, have } ->
            [ Text "For the number of players in the game, you need at least "
            , Text (needed |> String.fromInt)
            , Text " "
            , ref (noun cardType needed)
            , Text " but you only have "
            , Text (have |> String.fromInt)
            , Text "."
            ]

        AddBlankCards { amount } ->
            [ Text "Add "
            , amount |> String.fromInt |> Text
            , Text " blank "
            , ref (noun Response amount)
            ]

        AddDeck ->
            [ Text "Add deck." ]

        RemoveDeck ->
            [ Text "Remove deck." ]

        SourceNotFound { source } ->
            [ ref source, Text " doesn't recognise the deck you asked for. Check the details you gave are correct." ]

        SourceServiceFailure { source } ->
            [ ref source, Text " failed to provide the deck. Please try again later or try another source." ]

        ManyDecks ->
            [ Text "Many Decks" ]

        ManyDecksDeckCodeTitle ->
            [ Text "Deck Code" ]

        ManyDecksDeckCodeShort ->
            [ Text "A deck code must be at least five characters long." ]

        ManyDecksWhereToGet ->
            [ Text "You can create and find decks to play with at ", ref ManyDecks, Text "." ]

        JsonAgainstHumanity ->
            [ Text "JSON Against Humanity" ]

        JsonAgainstHumanityAbout ->
            [ Text "Decks provided by ", ref JsonAgainstHumanity ]

        BuiltIn ->
            [ Text "Built-in" ]

        APlayer ->
            [ Text "A Player" ]

        Generated { by } ->
            [ Text "Generated by ", ref by ]

        DeckAlreadyAdded ->
            [ Text "This deck is already in the game." ]

        ConfigureDecks ->
            [ Text "Decks" ]

        ConfigureRules ->
            [ Text "Rules" ]

        ConfigureTimeLimits ->
            [ Text "Time Limits" ]

        ConfigurePrivacy ->
            [ Text "Privacy" ]

        HandSize ->
            [ Text "Hand Size" ]

        HandSizeDescription ->
            [ Text "The base number of cards each player has in their hand during the game." ]

        ScoreLimit ->
            [ ref (noun Point 1), Text " Limit" ]

        ScoreLimitDescription ->
            [ Segment
                [ Text "The number of "
                , ref (nounUnknownQuantity Point)
                , Text " a player needs to win the game."
                ]
            , Text " "
            , Segment [ Text "If disabled, the game continues indefinitely." ]
            ]

        UnsavedChangesWarning ->
            [ Text "You have unsaved changes to the configuration, they must be saved first if you want them to apply "
            , Text "to the game."
            ]

        SaveChanges ->
            [ Text "Save your changes." ]

        RevertChanges ->
            [ Text "Discard your unsaved changes." ]

        NeedAtLeastOneDeck ->
            [ Text "You need a deck of cards added to start the game." ]

        NeedAtLeastThreePlayers ->
            [ Text "You need at least three players to start the game." ]

        NeedAtLeastOneHuman ->
            [ Text "Unfortunately computer players can't be the "
            , ref Czar
            , Text ", so you need at least one human player to start the game."
            , Text " (Although only one human might be a bit boring!)"
            ]

        RandoCantWrite ->
            [ Text "Computer players can't write their own cards." ]

        DisableComedyWriter ->
            [ Text "Disable ", ref HouseRuleComedyWriter ]

        DisableRando ->
            [ Text "Disable ", ref HouseRuleRandoCardrissian ]

        AddAnAiPlayer ->
            [ Text "Add an AI player to the game." ]

        PasswordShared ->
            [ Text "Anyone in the game can see the password! "
            , Text "Hiding it above only affects you (useful if streaming, etc…)."
            ]

        PasswordNotSecured ->
            [ Text "Game passwords are "
            , Em [ Text "not" ]
            , Text " stored securely—given this, please "
            , Em [ Text "do not" ]
            , Text " use serious passwords you use elsewhere!"
            ]

        LobbyPassword ->
            [ Text "Game Password" ]

        LobbyPasswordDescription ->
            [ Text "A password the users must enter before they can join the game." ]

        AudienceMode ->
            [ Text "Audience Mode" ]

        AudienceModeDescription ->
            [ Text "If enabled, newly joining users will be spectators by default, and only you will be able to "
            , Text "make them players."
            ]

        StartGame ->
            [ Text "Start Game" ]

        Public ->
            [ Text "Public Game" ]

        PublicDescription ->
            [ Text "If enabled, the game will show up in the public game list for anyone to find." ]

        ApplyConfiguration ->
            [ Text "Apply this change." ]

        AppliedConfiguration ->
            [ Text "Saved." ]

        InvalidConfiguration ->
            [ Text "This configuration value isn't valid." ]

        Automatic ->
            [ Text "Automatically Mark Players As Away" ]

        AutomaticDescription ->
            [ Text "If enabled, when the time limit runs out players will automatically be marked as away. "
            , Text "Otherwise someone will need to press the button to do so."
            ]

        TimeLimit { stage } ->
            [ ref stage, Text " Time Limit" ]

        StartingTimeLimitDescription ->
            [ Text "How long (in seconds) the "
            , ref Czar
            , Text " has to choose/write a "
            , ref (noun Call 1)
            , Text ", when the "
            , raw HouseRuleCzarChoices
            , Text " house rule is enabled."
            ]

        PlayingTimeLimitDescription ->
            [ Text "How long (in seconds) the ", ref Players, Text " have to make their plays." ]

        PlayingAfterDescription ->
            [ Text "How long (in seconds) players have to change their play before the next stage starts." ]

        RevealingTimeLimitDescription ->
            [ Text "How long (in seconds) the ", ref Czar, Text " has to reveal the plays." ]

        RevealingAfterDescription ->
            [ Text "How long (in seconds) to wait after the last card is revealed before the next stage starts." ]

        JudgingTimeLimitDescription ->
            [ Text "How long (in seconds) the ", ref Czar, Text " has to judge the plays." ]

        CompleteTimeLimitDescription ->
            [ Text "How much time (in seconds) to wait after one round ends before starting the next one." ]

        RevealingEnabledTitle ->
            [ Text "Czar Reveals Plays" ]

        RevealingEnabled ->
            [ Text "If this is enabled, the "
            , ref Czar
            , Text " reveals one play at a time before picking a winner."
            ]

        DuringTitle ->
            [ Text "Time Limit" ]

        AfterTitle ->
            [ Text "After" ]

        Conflict ->
            [ Text "Conflict" ]

        ConflictDescription ->
            [ Text "Someone else made changes to this while you were also making changes. "
            , Text "Please choose if you want to keep your changes or theirs."
            ]

        YourChanges ->
            [ Text "Your Changes" ]

        TheirChanges ->
            [ Text "Their Changes" ]

        ConfigurationDisabledWhileInGame ->
            [ Text "While the game in progress, you can't change the configuration." ]

        ConfigurationDisabledIfNotPrivileged ->
            [ Text "You can't change the configuration of this game." ]

        ConfigureNextGame ->
            [ Text "Configure Next Game" ]

        -- Game
        PickCall ->
            [ Text "Pick this ", ref (noun Call 1), Text " for the others to play into for the round." ]

        WriteCall ->
            [ Text "Write a custom ", ref (noun Call 1), Text " for the others to play into for the round." ]

        SubmitPlay ->
            [ Text "Give these cards to the ", ref Czar, Text " as your play for the round." ]

        TakeBackPlay ->
            [ Text "Take back your cards to change your play for the round." ]

        JudgePlay ->
            [ Text "Pick this play as the winner for the round." ]

        LikePlay ->
            [ Text "Add a like to this play." ]

        AdvanceRound ->
            [ Text "Next round." ]

        Starting ->
            [ raw HouseRuleCzarChoices ]

        Playing ->
            [ Text "Playing" ]

        Revealing ->
            [ Text "Revealing" ]

        Judging ->
            [ Text "Judging" ]

        Complete ->
            [ Text "Finished" ]

        ViewGameHistoryAction ->
            [ Text "View previous rounds from this game." ]

        ViewHelpAction ->
            [ Text "Help" ]

        EnforceTimeLimitAction ->
            [ Text "Set all players the game is waiting on to away and skip them until they return." ]

        Blank ->
            [ Text "Blank" ]

        RoundStarted ->
            [ Text "Round Started" ]

        JudgingStarted ->
            [ Text "Judging Started" ]

        Paused ->
            [ Text "The game has been paused because there are not enough active players to continue."
            , Text "When someone joins or returns it will continue automatically."
            ]

        ClientAway ->
            [ Text "You are currently set as away from the game, and are not playing." ]

        Discard ->
            [ Text "Discard the selected card, revealing it to the other users in the game." ]

        Discarded { player } ->
            [ Text player
            , Text " discarded the following card:"
            ]

        -- Instructions
        PickCallInstruction ->
            [ Text "Pick a ", ref (noun Call 1), Text " for the others to play into." ]

        WaitForCallInstruction ->
            [ Text "You are waiting for the "
            , ref Czar
            , Text " to pick a "
            , ref (noun Call 1)
            , Text " for you to play into."
            ]

        PlayInstruction { numberOfCards } ->
            [ Text "You need to choose "
            , Text (asWord numberOfCards)
            , Text " more "
            , ref (noun Response numberOfCards)
            , Text " from your hand into this round before you can submit your play."
            ]

        SubmitInstruction ->
            [ Text "You need to submit your play for this round." ]

        WaitingForPlaysInstruction ->
            [ Text "You are waiting for other players to play into the round." ]

        CzarsDontPlayInstruction ->
            [ Text "You are the "
            , ref Czar
            , Text " for the round - you don't submit any "
            , ref (nounUnknownQuantity Response)
            , Text ". Instead you choose the winner once everyone else has submitted theirs."
            ]

        NotInRoundInstruction ->
            [ Text "You are not in this round. You will play in the next one unless you are set to away." ]

        RevealPlaysInstruction ->
            [ Text "Click on the plays to flip them, then pick the one you think is best." ]

        WaitingForCzarInstruction ->
            [ Text "You can like plays while you wait for the ", ref Czar, Text " to reveal the plays and pick a winner for the round." ]

        AdvanceRoundInstruction ->
            [ Text "The next round has started, you can advance." ]

        -- 404 Unknown
        UnknownPageTitle ->
            [ Text "404 Error: Unknown page." ]

        GoBackHome ->
            [ Text "Go to the main page." ]

        -- Actions
        Refresh ->
            [ Text "Refresh" ]

        Accept ->
            [ Text "OK" ]

        -- Editor
        AddSlot ->
            [ Text "Add ", ref Blank ]

        AddText ->
            [ Text "Add Text" ]

        EditText ->
            [ Text "Edit" ]

        EditSlotIndex ->
            [ Text "Edit" ]

        MoveLeft ->
            [ Text "Move Earlier" ]

        Remove ->
            [ Text "Remove" ]

        MoveRight ->
            [ Text "Move Later" ]

        Normal ->
            [ Text "Normal" ]

        Capitalise ->
            [ Text "Capitalise" ]

        UpperCase ->
            [ Text "Upper Case" ]

        Emphasise ->
            [ Text "Emphasise" ]

        MustContainAtLeastOneSlot ->
            [ Text "You must have at least one ", ref Blank, Text " for people to play into." ]

        SlotIndexExplanation ->
            [ Text "What number "
            , ref (noun Response 1)
            , Text " played will be used for this "
            , ref Blank
            , Text ". This lets you repeat a "
            , ref (noun Response 1)
            , Text "."
            ]

        -- Errors
        Error ->
            [ Text "Error" ]

        ErrorHelp ->
            [ Text "The game server might be down, or this might be a bug. Refreshing the page should get you going "
            , Text "again. More details can be found below."
            ]

        ErrorHelpTitle ->
            [ Text "Sorry, something went wrong." ]

        ErrorCheckOutOfBand ->
            [ Text "Please check ", ref TwitterHandle, Text " for updates and service status. The game server will go down for a short time when a new version is released, so if you see a recent update, try again in a few minutes." ]

        TwitterHandle ->
            [ Text "@Massive_Decks" ]

        ReportError ->
            [ Text "Report Bug" ]

        ReportErrorDescription ->
            [ Text "Let the developers know about a bug you encountered so they can fix it." ]

        ReportErrorBody ->
            [ Text "I was [replace with a short explanation of what you were doing] when I got the following error:" ]

        BadUrlError ->
            [ Text "We tried to make a request to an invalid page." ]

        TimeoutError ->
            [ Text "The server didn’t respond for too long. It may be down, please try again after a short delay." ]

        NetworkError ->
            [ Text "Your internet connection was interrupted." ]

        ServerDownError ->
            [ Text "The game server is currently offline. Please try again later." ]

        BadStatusError ->
            [ Text "The server gave a response we didn’t expect." ]

        BadPayloadError ->
            [ Text "The server gave a response we didn’t understand." ]

        PatchError ->
            [ Text "The server gave a patch we couldn't apply." ]

        VersionMismatch ->
            [ Text "The server gave a config change for a different version than we expected." ]

        CastError ->
            [ Text "Sorry, something went wrong trying to connect to the game." ]

        ActionExecutionError ->
            [ Text "You can't perform that action." ]

        IncorrectPlayerRoleError { role, expected } ->
            [ Text "You need to be a ", ref expected, Text " to do that, but you are a ", ref role, Text "." ]

        IncorrectUserRoleError { role, expected } ->
            [ Text "You need to be a ", ref expected, Text " to do that, but you are a ", ref role, Text "." ]

        IncorrectRoundStageError { stage, expected } ->
            [ Text "The round needs to be at the ", ref expected, Text " stage to do that, but it is at the ", ref stage, Text " stage." ]

        ConfigEditConflictError ->
            [ Text "Someone else changed the configuration before you, your change was not saved." ]

        UnprivilegedError ->
            [ Text "You don't have the privileges to do that." ]

        GameNotStartedError ->
            [ Text "The game needs to started to do that." ]

        InvalidActionError { reason } ->
            [ Text "The server didn't understand a request from the client. Details: ", Text reason ]

        AuthenticationError ->
            [ Text "You can't join that game." ]

        IncorrectIssuerError ->
            [ Text "Your credentials to join this game are out of date, the game no longer exists." ]

        InvalidAuthenticationError ->
            [ Text "Your credentials to join this game are corrupt." ]

        InvalidLobbyPasswordError ->
            [ Text "The game password you gave was wrong. Try typing it again and if it still doesn't work, ask the person who invited you again." ]

        AlreadyLeftError ->
            [ Text "You have already left this game." ]

        LobbyNotFoundError ->
            [ Text "That game doesn't exist." ]

        LobbyClosedError { gameCode } ->
            [ Text "The game you wish to join (", ref (GameCode { code = gameCode }), Text ") has ended." ]

        LobbyDoesNotExistError { gameCode } ->
            [ Text "The game code you entered ("
            , ref (GameCode { code = gameCode })
            , Text ") doesn't exist. "
            , Text "Try typing it again and if it still doesn't work, ask the person who invited you again."
            ]

        RegistrationError ->
            [ Text "Problem while joining the game." ]

        UsernameAlreadyInUseError { username } ->
            [ Text "Someone is already using the username “"
            , Text username
            , Text "”—try a different name."
            ]

        GameError ->
            [ Text "Something has gone wrong in the game." ]

        OutOfCardsError ->
            [ Text "There were not enough cards in the deck to deal everyone a hand! Try adding more decks in the game configuration." ]

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
            [ Text "Polish" ]

        Indonesian ->
            [ Text "Indonesian" ]

        Spanish ->
            [ Text "Spanish" ]



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
            "one"

        2 ->
            "two"

        3 ->
            "three"

        4 ->
            "four"

        5 ->
            "five"

        6 ->
            "six"

        7 ->
            "seven"

        8 ->
            "eight"

        9 ->
            "nine"

        10 ->
            "ten"

        11 ->
            "eleven"

        12 ->
            "twelve"

        other ->
            String.fromInt other
