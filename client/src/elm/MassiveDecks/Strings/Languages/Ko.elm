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
        Version { clientVersion, serverVersion } ->
            let
                quote version =
                    [ Text "“", Text version, Text "”" ]
            in
            List.concat
                [ [ Text "버전 " ]
                , clientVersion |> quote
                , [ Text " / " ]
                , serverVersion |> Maybe.map quote |> Maybe.withDefault []
                ]

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
            [ Text "새 놀이..가 아니라 게임" ]

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
            [ Text "이 게임에 참가하려면 패스워드가 필요합니다. 당신을 초대한 사람에게 물어보세요." ]

        YouWereKicked ->
            [ Text "게임에서 추방되었습니다." ]

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
            [ Text "일부 카드에 답하기 위해서는 1장보다 많은 "
            , ref (noun Response 1)
            , Text "가 필요합니다. 그때는, 카드를 낸 순서대로 "
            , ref Czar
            , Text "가 읽을 겁니다."
            ]

        ExamplePickDescription ->
            [ Text "이런 "
            , ref (nounUnknownQuantity Call)
            , Text "는 갖는 "
            , ref (nounUnknownQuantity Response)
            , Text "가 많아지지만, 선택해야 하는 카드도 많아집니다."
            ]

        RulesDraw ->
            [ Text "일부의 "
            , ref (nounUnknownQuantity Call)
            , Text "는 더 많은 "
            , ref (nounUnknownQuantity Response)
            , Text "를 필요로 할 것입니다—이런 카드에는 "
            , ref (Draw { numberOfCards = 2 })
            , Text "와 같은 표시가 있으며, 그만큼 선택하기 전에 카드를 받습니다."
            ]

        GameRulesTitle ->
            [ Text "게임 규칙" ]

        HouseRulesTitle ->
            [ Text "하우스 규칙" ]

        HouseRules ->
            [ Text "게임이 플레이되는 방식은 여러가지가 있으며, 자신이 원하는 대로 바꿀 수 있습니다. 게임을 설정할 때, 설정하고 싶은 만큼 하우스 규칙을 정해 주세요."
            ]

        HouseRuleReboot ->
            [ Text "세계의 리부팅" ]

        HouseRuleRebootDescription { cost } ->
            [ Text "언제나, 플레이어들은 "
            , Text (an cost)
            , ref (nounMaybe Point cost)
            , Text "를 써서 자신의 카드를 버리고 새 카드를 드로우할 수 있습니다."
            ]

        HouseRuleRebootAction { cost } ->
            [ Text "Spend "
            , Text (asWord cost)
            , Text " "
            , ref (noun Point cost)
            , Text " to discard your hand and draw a new one."
            ]

        HouseRuleRebootCost ->
            [ ref (noun Point 1), Text " 코스트" ]

        HouseRuleRebootCostDescription ->
            [ Text "다시 드로우하는 데에 필요한 ", ref (nounUnknownQuantity Point), Text "." ]

        HouseRulePackingHeat ->
            [ Text "패킹 히트" ]

        HouseRulePackingHeatDescription ->
            [ ref (Pick { numberOfCards = 2 })
            , Text "가 들어있는 모든 "
            , ref (nounUnknownQuantity Call)
            , Text "는, 모두가 더 많은 선택지를 가질 수 있게 "
            , ref (Draw { numberOfCards = 1 })
            , Text "가 같이 붙습니다."
            ]

        HouseRuleComedyWriter ->
            [ Text "코미디 라이터" ]

        HouseRuleComedyWriterDescription ->
            [ Text "공백인 "
            , ref (nounUnknownQuantity Response)
            , Text "를 넣어서 플레이어가 커스텀의 답변을 적을 수 있게 해 주세요."
            ]

        HouseRuleComedyWriterNumber ->
            [ Text "공백 ", ref (nounUnknownQuantity Response) ]

        HouseRuleComedyWriterNumberDescription ->
            [ Text "게임에 들어갈 공백 "
            , ref (nounUnknownQuantity Response)
            , Text "."
            ]

        HouseRuleComedyWriterExclusive ->
            [ Text "공백", ref (nounUnknownQuantity Response), Text "만으로 플레이" ]

        HouseRuleComedyWriterExclusiveDescription ->
            [ Text "만약 이 설정이 활성화되었다면, 다른 "
            , ref (nounUnknownQuantity Response)
            , Text "가 무시되며, 공백 카드만 들어가게 될 것입니다."
            ]

        HouseRuleRandoCardrissian ->
            [ Text "란도 카드리산" ]

        HouseRuleRandoCardrissianDescription ->
            [ Text "매 라운드, 덱 안의 첫"
            , ref (noun Response 1)
            , Text "가 답으로서 플레이됩니다. 이 플레이는 AI 플레이어, 란도 카드리산의 플레이로 되며, 만약 그가 게임을 이긴다면 모든 플레이어는 평생 남을, "
            , Text "AI에게 졌다는 굴욕을 맞이할 것입니다."
            ]

        HouseRuleRandoCardrissianNumber ->
            [ Text "AI 플레이어" ]

        HouseRuleRandoCardrissianNumberDescription ->
            [ Text "게임 내에 있을 AI 플레이어의 수." ]

        HouseRuleNeverHaveIEver ->
            [ Text "한번도 본 적이.." ]

        HouseRuleNeverHaveIEverDescription ->
            [ Text "언제나, 플레이어는 자신이 이해를 못하는 카드를 버릴 수 있지만, 그들은 자신의 무지를 알려야 합니다: "
            , Text "그 카드는 모든 플레이어에게 공개됩니다."
            ]

        HouseRuleHappyEnding ->
            [ Text "해피 엔딩" ]

        HouseRuleHappyEndingDescription ->
            [ Text "게임이 끝날 때, 마지막 라운드는 반드시 '하이쿠 만들기' ", ref (noun Call 1), Text "가 됩니다." ]

        HouseRuleCzarChoices ->
            [ ref Czar, Text " 초이스" ]

        HouseRuleCzarChoicesDescription ->
            [ Text "라운드의 처음에, "
            , ref Czar
            , Text "가 여러 "
            , ref (nounUnknownQuantity Call)
            , Text "를 뽑아서 하나를 고르거나, 자신이 쓸 수도 있습니다."
            ]

        HouseRuleCzarChoicesNumber ->
            [ Text "카드 수" ]

        HouseRuleCzarChoicesNumberDescription ->
            [ ref Czar, Text "에게 줄 카드 수." ]

        HouseRuleCzarChoicesCustom ->
            [ Text "커스텀" ]

        HouseRuleCzarChoicesCustomDescription ->
            [ ref Czar, Text "가 커스텀 카드를 쓸 수 있는지에 대한 설정. 이것이 위 카드 수 중 1장에 포함됩니다." ]

        HouseRuleWinnersPick ->
            [ Text "승자의 선택" ]

        HouseRuleWinnersPickDescription ->
            [ Text "각 라운드의 승자는 다음 라운드에 ", ref Czar, Text "가 됩니다." ]

        SeeAlso { rule } ->
            [ ref rule, Text " 참조" ]

        MustBeMoreThanOrEqualValidationError { min } ->
            [ Text "값이 최소 ", Text (String.fromInt min), Text "가 되어야 합니다." ]

        MustBeLessThanOrEqualValidationError { max } ->
            [ Text "값이 최대 ", Text (String.fromInt max), Text "가 되어야 합니다." ]

        SetValue { value } ->
            [ Text "값을 ", Text (String.fromInt value), Text "로 설정하세요." ]

        CantBeEmpty ->
            [ Text "이것은 절대로 공백이 될 수 없습니다." ]

        SettingsTitle ->
            [ Text "설정" ]

        LanguageSetting ->
            [ Text "언어" ]

        MissingLanguage ->
            [ Text "당신의 언어가 안 보이세요?", ref TranslationBeg ]

        AutonymFormat { autonym } ->
            [ Text "(", Text autonym, Text ")" ]

        TranslationBeg ->
            [ ref MassiveDecks
            , Text " 번역을 도와 주세요!"
            ]

        CardSizeSetting ->
            [ Text "컴팩트 카드" ]

        CardSizeExplanation ->
            [ Text "카드의 크기를 조절하세요—작은 스크린에서는 스크롤을 적게 할 수 있도록 도움이 될 겁니다." ]

        AutoAdvanceSetting ->
            [ Text "라운드 자동 진행" ]

        AutoAdvanceExplanation ->
            [ Text "라운드가 끝날 시에, 기다리지 않고 다음 라운드로 진행합니다." ]

        SpeechSetting ->
            [ Text "텍스트 음성 변환" ]

        SpeechExplanation ->
            [ Text "TTS를 사용해서 카드를 읽습니다." ]

        SpeechNotSupportedExplanation ->
            [ Text "당신의 브라우저는 TTS를 지원하지 않거나, 음성이 설치되어 있지 않습니다." ]

        VoiceSetting ->
            [ Text "TTS 음성" ]

        NotificationsSetting ->
            [ Text "브라우저 알림" ]

        NotificationsExplanation ->
            [ Text "당신이 게임에서 뭔가를 해야 할때 브라우저 알림을 보냅니다." ]

        NotificationsUnsupportedExplanation ->
            [ Text "당신의 브라우저는 알림을 지원하지 않습니다." ]

        NotificationsBrowserPermissions ->
            [ Text "알림을 보내려면, "
            , ref MassiveDecks
            , Text "에게 권한을 줘야 합니다. 당신이 게임을 키고 있을 때와 이 설정을 활성화했을 때만 이 권한이 쓰일 것입니다."
            ]

        NotificationOnlyWhenHiddenSetting ->
            [ Text "숨겨져 있을 때만" ]

        NotificationsOnlyWhenHiddenExplanation ->
            [ Text "당신이 페이지를 보고 있지 않을 때만 알림을 보냅니다. (예: 다른 탭에 있거나 최소화되어 있을 때)" ]

        NotificationsOnlyWhenHiddenUnsupportedExplanation ->
            [ Text "당신의 브라우저는 페이지 가시성 확인을 지원하지 않습니다." ]

        -- Terms
        Czar ->
            [ Text "카드 차르" ]

        CzarDescription ->
            [ Text "라운드를 심판하는 플레이어." ]

        CallDescription ->
            [ Text "질문이나 빈칸 채우기 문구가 적혀 있는 검정색 카드." ]

        ResponseDescription ->
            [ Text "문구가 적혀 있고, 라운드 중에서 플레이되는 흰색 카드." ]

        PointDescription ->
            [ Text "포인트—이기는 데에 중요한 것." ]

        GameCodeTerm ->
            [ Text "게임 코드" ]

        GameCodeDescription ->
            [ Text "다른 사람들이 당신의 게임을 찾고, 참가할 수 있게 되는 코드." ]

        GameCode { code } ->
            [ Text code ]

        GameCodeSpecificDescription ->
            [ Text "이 코드를 사이트 주소와 함께 나눠서 게임에 참가할 수 있게 하세요." ]

        GameCodeHowToAcquire ->
            [ Text "당신을 초대한 사람에게 ", ref GameCodeTerm, Text "를 물어 보세요." ]

        Deck ->
            [ Text "덱" ]

        DeckSource ->
            [ ref Deck, Text " 출처" ]

        DeckLanguage { language } ->
            [ Text "언어: ", Text language ]

        DeckAuthor { author } ->
            [ Text author, Text "작성" ]

        DeckTranslator { translator } ->
            [ Text translator, Text "번역" ]

        StillPlaying ->
            [ Text "플레이 중" ]

        PlayingDescription ->
            [ Text "이 플레이어는 라운드에 참가하고 있으나, 아직 카드를 제출하지 않았습니다." ]

        Played ->
            [ Text "플레이함" ]

        PlayedDescription ->
            [ Text "이 플레이어는 라운드 플레이를 하였습니다." ]

        -- Lobby Browser
        LobbyBrowserTitle ->
            [ Text "공개 게임" ]

        NoPublicGames ->
            [ Text "공개 게임 없음" ]

        PlayingGame ->
            [ Text "현재 진행중인 게임." ]

        SettingUpGame ->
            [ Text "아직 시작하지 않은 게임." ]

        StartYourOwn ->
            [ Text "새 게임을 시작하시겠습니까?" ]

        -- Spectation
        JoinTheGame ->
            [ Text "게임에 참가하세요!" ]

        ToggleAdvertDescription ->
            [ Text "게임 참가에 따른 정보를 보여줍니다." ]

        -- Cards
        Pick numberOfCards ->
            [ Text "Pick", ref (NumberOfCards numberOfCards) ]

        Draw numberOfCards ->
            [ Text "Draw", ref (NumberOfCards numberOfCards) ]

        PickDescription { numberOfCards } ->
            [ Text (asWord numberOfCards)
            , Text "장의 "
            , ref (noun Response numberOfCards)
            , Text "를 플레이해야 합니다."
            ]

        DrawDescription { numberOfCards } ->
            [ Text "플레이를 하기 전에 "
            , Text (asWord numberOfCards)
            , Text "장의 추가 "
            , ref (noun Response numberOfCards)
            , Text "를 받습니다."
            ]

        NumberOfCards { numberOfCards } ->
            [ Text (String.fromInt numberOfCards) ]

        -- Lobby
        LobbyNameLabel ->
            [ Text "게임 이름" ]

        DefaultLobbyName { owner } ->
            [ Text owner, Text "님의 게임" ]

        Invite ->
            [ Text "이 게임에 플레이어들을 초대하세요." ]

        InviteLinkHelp ->
            [ Text "이 링크를 플레이어에게 보내거나, 아래 QR 코드를 스캔시켜서 게임에 초대하세요." ]

        InviteExplanation { gameCode, password } ->
            let
                extra =
                    password
                        |> Maybe.map
                            (\p ->
                                [ Text "와 게임 패스워드 “"
                                , Text p
                                , Text "”"
                                ]
                            )
                        |> Maybe.withDefault []
            in
            List.concat
                [ [ Text "당신의 게임 코드는 "
                  , ref (GameCode { code = gameCode })
                  , Text "입니다. 플레이어들은 "
                  , ref MassiveDecks
                  , Text "에 들어가서 이 코드"
                  ]
                , extra
                , [ Text "를 입력해서 게임에 참가할 수 있습니다."
                  ]
                ]

        Cast ->
            [ Text "TV로 캐스트하기" ]

        CastConnecting ->
            [ Text "연결중…" ]

        CastConnected { deviceName } ->
            [ Text deviceName, Text "로 캐스팅 중" ]

        Players ->
            [ ref (nounUnknownQuantity Player) ]

        PlayersDescription ->
            [ Text "게임을 플레이하는 유저 수." ]

        Spectators ->
            [ ref (nounUnknownQuantity Spectator) ]

        SpectatorsDescription ->
            [ Text "플레이하지 않고 게임을 관전하고 있는 유저 수." ]

        Left ->
            [ Text "나감" ]

        LeftDescription ->
            [ Text "게임을 나간 유저 수." ]

        Away ->
            [ Text "자리 비움" ]

        AwayDescription ->
            [ Text "이 유저는 임시적으로 게임을 중단하고 있습니다." ]

        Disconnected ->
            [ Text "연결 끊김" ]

        DisconnectedDescription ->
            [ Text "이 유저는 게임에 연결되어 있지 않습니다." ]

        Privileged ->
            [ Text "오너" ]

        PrivilegedDescription ->
            [ Text "이 유저는 게임 설정을 조절할 수 있습니다." ]

        Ai ->
            [ Text "AI" ]

        AiDescription ->
            [ Text "이 플레이어는 컴퓨터에 의해 조작되고 있습니다." ]

        Score { total } ->
            [ Text (String.fromInt total) ]

        ScoreDescription ->
            [ Text "이 플레이어가 가지고 있는 "
            , ref (nounUnknownQuantity Point)
            , Text " 수."
            ]

        Likes { total } ->
            [ Text (String.fromInt total) ]

        LikesDescription ->
            [ Text "받은 좋아요 수."
            ]

        ToggleUserList ->
            [ Text "스코어보드를 보이거나 숨깁니다." ]

        GameMenu ->
            [ Text "게임 메뉴." ]

        UnknownUser ->
            [ Text "미확인 유저" ]

        InvitePlayers ->
            [ Text "플레이어 초대" ]

        InvitePlayersDescription ->
            [ Text "다른 사람들이 참가할 수 있도록 게임 코드/링크/QR 코드를 취득합니다." ]

        SetAway ->
            [ Text "자리 비움으로 표시" ]

        SetBack ->
            [ Text "돌아옴으로 표시" ]

        LeaveGame ->
            [ Text "게임 나가기" ]

        LeaveGameDescription ->
            [ Text "완전히 게임을 나갑니다." ]

        Spectate ->
            [ Text "관전자 시점" ]

        SpectateDescription ->
            [ Text "새 탭/창으로 관전자 시점을 엽니다." ]

        BecomeSpectator ->
            [ Text "관전" ]

        BecomeSpectatorDescription ->
            [ Text "플레이하지 않고 게임을 관전합니다." ]

        BecomePlayer ->
            [ Text "플레이" ]

        BecomePlayerDescription ->
            [ Text "관전을 멈추고 게임 안에 들어갑니다." ]

        EndGame ->
            [ Text "게임 중단" ]

        EndGameDescription ->
            [ Text "당장 게임을 중단합니다." ]

        ReturnViewToGame ->
            [ Text "게임으로 돌아가기" ]

        ReturnViewToGameDescription ->
            [ Text "메인 게임 시점으로 돌아갑니다." ]

        ViewConfiguration ->
            [ Text "설정" ]

        ViewConfigurationDescription ->
            [ Text "게임의 설정을 봅니다." ]

        KickUser ->
            [ Text "추방" ]

        Promote ->
            [ Text "승진" ]

        Demote ->
            [ Text "강등" ]

        -- Notifications
        UserConnected { username } ->
            [ Text username, Text "님이 게임에 재참가했습니다." ]

        UserDisconnected { username } ->
            [ Text username, Text "님과의 연결이 끊겼습니다." ]

        UserJoined { username } ->
            [ Text username, Text "님이 게임에 참가했습니다." ]

        UserLeft { username } ->
            [ Text username, Text "님이 게임을 나갔습니다." ]

        UserKicked { username } ->
            [ Text username, Text "님이 게임에서 추방되었습니다." ]

        Dismiss ->
            [ Text "닫기" ]

        -- Configuration
        ConfigureTitle ->
            [ Text "게임 설정" ]

        NoDecks ->
            [ Segment [ Text "덱 없음. " ]
            , Text " "
            , Segment [ Text "게임에 하나 이상의 덱은 추가해야 합니다." ]
            ]

        NoDecksHint ->
            [ Text "잘 모르겠어요? ", raw CardsAgainstHumanity, Text " 기본 덱을 추가해 보세요. 영어지만. 한국 덱은 아래의 덱 리스트 안에 있습니다." ]

        WaitForDecks ->
            [ Text "게임을 시작하기 전에 덱이 로드되어야 합니다." ]

        MissingCardType { cardType } ->
            [ Text "당신의 덱은 "
            , ref (nounUnknownQuantity cardType)
            , Text "를 포함하고 있지 않습니다. 포함하고 있는 덱을 추가해야 시작할 수 있습니다."
            ]

        NotEnoughCardsOfType { cardType, needed, have } ->
            [ Text "게임 안 플레이어 수에 대비하면, 최소"
            , Text (needed |> String.fromInt)
            , Text "장의 "
            , ref (noun cardType needed)
            , Text "가 필요하지만 현재 "
            , Text (have |> String.fromInt)
            , Text "장입니다."
            ]

        AddBlankCards { amount } ->
            [ amount |> String.fromInt |> Text
            , Text "장의 공백 "
            , ref (noun Response amount)
            , Text "를 추가"
            ]

        AddDeck ->
            [ Text "덱 추가하기." ]

        RemoveDeck ->
            [ Text "덱 제거하기." ]

        SourceNotFound { source } ->
            [ ref source, Text "가 당신이 요청한 덱을 인식하지 않습니다. 검색 조건을 다시 한번 확인해 주세요." ]

        SourceServiceFailure { source } ->
            [ ref source, Text "가 당신이 요청한 덱을 불러오지 못했습니다. 나중에 다시 시도하거나 다른 출처를 선택해 보세요." ]

        ManyDecks ->
            [ Text "Many Decks" ]

        ManyDecksDeckCodeTitle ->
            [ Text "덱 코드" ]

        ManyDecksDeckCodeShort ->
            [ Text "덱 코드는 최소 5글자여야 합니다." ]

        ManyDecksWhereToGet ->
            [ ref ManyDecks, Text "에서 덱을 만들거나 플레이할 덱을 찾을 수 있습니다." ]

        JsonAgainstHumanity ->
            [ Text "JSON Against Humanity" ]

        JsonAgainstHumanityAbout ->
            [ ref JsonAgainstHumanity, Text "제공" ]

        BuiltIn ->
            [ Text "기본" ]

        APlayer ->
            [ Text "플레이어" ]

        Generated { by } ->
            [ ref by, Text "생성" ]

        DeckAlreadyAdded ->
            [ Text "이 덱은 이미 게임 내에 추가되어 있습니다." ]

        ConfigureDecks ->
            [ Text "덱" ]

        ConfigureRules ->
            [ Text "규칙" ]

        ConfigureTimeLimits ->
            [ Text "시간 제한" ]

        ConfigurePrivacy ->
            [ Text "프라이버시" ]

        HandSize ->
            [ Text "패 카드 수" ]

        HandSizeDescription ->
            [ Text "각 플레이어가 자신의 패에서 기본적으로 가지는 카드 수." ]

        ScoreLimit ->
            [ ref (noun Point 1), Text " 제한" ]

        ScoreLimitDescription ->
            [ Segment
                [ Text "플레이어가 이기기 위해 필요한 "
                , ref (nounUnknownQuantity Point)
                , Text "."
                ]
            , Text " "
            , Segment [ Text "만약 비활성화되어 있다면, 게임이 영원히 계속됩니다." ]
            ]

        UnsavedChangesWarning ->
            [ Text "아직 저장하지 않은 설정 변경이 있습니다. 게임에 적용하고 싶다면 먼저 설정을 저장해야 합니다."
            ]

        SaveChanges ->
            [ Text "변경 저장하기." ]

        RevertChanges ->
            [ Text "미저장 변경 취소하기." ]

        NeedAtLeastOneDeck ->
            [ Text "게임을 시작하려면 덱이 최소한 1개 게임에 추가되어야 합니다." ]

        NeedAtLeastThreePlayers ->
            [ Text "게임을 시작하려면 플레이어가 최소한 3명 필요합니다." ]

        NeedAtLeastOneHuman ->
            [ Text "불행히도 컴퓨터 플레이어들은"
            , ref Czar
            , Text "가 될 수 없으므로, 인간 플레이어가 최소한 1명 필요합니다."
            , Text " (인간 1명은 좀 재미가 없을 것 같기도 하지만요!)"
            ]

        RandoCantWrite ->
            [ Text "컴퓨터 플레이어들은 자신의 커스텀 카드는 쓸 수 없습니다." ]

        DisableComedyWriter ->
            [ ref HouseRuleComedyWriter, Text " 비활성화" ]

        DisableRando ->
            [ ref HouseRuleRandoCardrissian, Text "비활성화" ]

        AddAnAiPlayer ->
            [ Text "게임에 AI 플레이어를 추가합니다." ]

        PasswordShared ->
            [ Text "게임 내에 있는 모든 플레이어들은 패스워드를 볼 수 있습니다! "
            , Text "위에서 숨기는 것은 당신에게만 적용됩니다. (방송 등에서는 유용)"
            ]

        PasswordNotSecured ->
            [ Text "게임 패스워드들은 안전하게 보관되어 있지 "
            , Em [ Text "않습니다" ]
            , Text "—당신을 위해서라도, "
            , Em [ Text "절대로" ]
            , Text " 다른 곳에서 쓰는 패스워드들을 여기서 쓰지 마세요!"
            ]

        LobbyPassword ->
            [ Text "게임 패스워드" ]

        LobbyPasswordDescription ->
            [ Text "게임에 참가하기 전에 유저들이 입력해야 할 패스워드." ]

        AudienceMode ->
            [ Text "관객 모드" ]

        AudienceModeDescription ->
            [ Text "만약 활성화되어 있다면, 새로 참가하는 유저들은 자동으로 관전자가 되며, 당신만이 그들을 "
            , Text "플레이어로 할 수 있습니다."
            ]

        StartGame ->
            [ Text "게임 시작" ]

        Public ->
            [ Text "공개 게임" ]

        PublicDescription ->
            [ Text "만약 활성화되어 있다면, 이 게임이 아무나 참가할 수 있게 공개 게임 리스트에 추가됩니다." ]

        ApplyConfiguration ->
            [ Text "이 변경을 저장하기." ]

        AppliedConfiguration ->
            [ Text "저장됨." ]

        InvalidConfiguration ->
            [ Text "이 설정 값은 유효하지 않습니다." ]

        Automatic ->
            [ Text "자동으로 플레이어들을 자리 비움으로 하기" ]

        AutomaticDescription ->
            [ Text "만약 활성화되어 있다면, 제한 시간이 끝나면 플레이어들은 자동으로 자리 비움으로 표시될 것입니다. "
            , Text "그 외에서는 누군가가 “자리 비움으로 표시” 버튼을 눌러서 설정을 해야 합니다."
            ]

        TimeLimit { stage } ->
            [ ref stage, Text " 시간 제한" ]

        StartingTimeLimitDescription ->
            [ raw HouseRuleCzarChoices
            , Text "가 활성화되어 있을 시에 "
            , ref Czar
            , Text "가 "
            , ref (noun Call 1)
            , Text "를 선택/작성하는 시간 (초 단위)."
            ]

        PlayingTimeLimitDescription ->
            [ ref Players, Text "이 카드를 플레이하는 데에 주어진 시간 (초 단위)." ]

        PlayingAfterDescription ->
            [ Text "다음 스테이지가 시작되기 전, 플레이어들이 자신의 플레이를 바꿀 수 있는 시간 (초 단위)." ]

        RevealingTimeLimitDescription ->
            [ ref Czar, Text "가 플레이들을 공개하는 데에 주어진 시간 (초 단위)." ]

        RevealingAfterDescription ->
            [ Text "마지막 카드가 공개된 이후, 다음 스테이지가 시작되기까지의 시간 (초 단위)." ]

        JudgingTimeLimitDescription ->
            [ ref Czar, Text "가 플레이들을 심판하는 데에 주어진 시간 (초 단위)." ]

        CompleteTimeLimitDescription ->
            [ Text "한 라운드가 끝나고 나서 다음 라운드가 시작할 때까지의 시간 (초 단위)." ]

        RevealingEnabledTitle ->
            [ Text "Czar가 플레이를 공개" ]

        RevealingEnabled ->
            [ Text "이게 활성화되어 있다면, "
            , ref Czar
            , Text "가 승자를 선택하기 전에 하나씩 플레이를 공개합니다."
            ]

        DuringTitle ->
            [ Text "시간 제한" ]

        AfterTitle ->
            [ Text "이후" ]

        Conflict ->
            [ Text "충돌" ]

        ConflictDescription ->
            [ Text "당신이 설정을 변경하고 있을 때 다른 누군가가 설정을 변경했습니다."
            , Text "당신과 그들 중 저장할 쪽을 선택해 주세요."
            ]

        YourChanges ->
            [ Text "당신의 변경" ]

        TheirChanges ->
            [ Text "그들의 변경" ]

        ConfigurationDisabledWhileInGame ->
            [ Text "게임 진행중, 설정을 변경할 수는 없습니다." ]

        ConfigurationDisabledIfNotPrivileged ->
            [ Text "이 게임의 설정을 변경할 수 없습니다." ]

        ConfigureNextGame ->
            [ Text "다음 게임 설정" ]

        -- Game
        PickCall ->
            [ Text "다른 사람들이 플레이할 ", ref (noun Call 1), Text "를 고릅니다." ]

        WriteCall ->
            [ Text "다른 사람들이 플레이할 커스텀 ", ref (noun Call 1), Text "를 씁니다." ]

        SubmitPlay ->
            [ Text "이 카드들을 이 라운드의 당신의 플레이로서 ", ref Czar, Text "에게 줍니다." ]

        TakeBackPlay ->
            [ Text "이 라운드의 당신의 플레이를 바꾸기 위해 카드를 다시 뺍니다." ]

        JudgePlay ->
            [ Text "이 플레이를 이 라운드의 승자로써 고릅니다." ]

        LikePlay ->
            [ Text "이 플레이에 좋아요를 추가합니다." ]

        AdvanceRound ->
            [ Text "다음 라운드" ]

        Starting ->
            [ raw HouseRuleCzarChoices ]

        Playing ->
            [ Text "플레이 중" ]

        Revealing ->
            [ Text "공개 중" ]

        Judging ->
            [ Text "심판 중" ]

        Complete ->
            [ Text "완료" ]

        ViewGameHistoryAction ->
            [ Text "이 게임에서의 이전 라운드를 봅니다." ]

        ViewHelpAction ->
            [ Text "도움말" ]

        EnforceTimeLimitAction ->
            [ Text "아직 플레이를 안한 모든 플레이어들을 자리 비움으로 설정하고 돌아올 때까지 그들을 건너뜁니다." ]

        Blank ->
            [ Text "빈칸" ]

        RoundStarted ->
            [ Text "라운드 시작됨" ]

        JudgingStarted ->
            [ Text "심판 시작됨" ]

        Paused ->
            [ Text "게임을 계속하는 데 필요한 플레이어 수가 모자라므로, 게임이 일시정지되었습니다."
            , Text "만약 누군가가 참가하거나 돌아오면 자동으로 계속될 것입니다."
            ]

        ClientAway ->
            [ Text "당신은 현재 자리 비움으로 설정되어 있으며, 플레이를 하고 있지 않습니다." ]

        Discard ->
            [ Text "선택된 카드를 버려서, 게임 내 다른 유저들에게 알립니다." ]

        Discarded { player } ->
            [ Text player
            , Text "님이 해당 카드를 버렸습니다:"
            ]

        -- Instructions
        PickCallInstruction ->
            [ Text "다른 플레이어들에게 플레이시킬 ", ref (noun Call 1), Text "를 선택하세요." ]

        WaitForCallInstruction ->
            [ Text "현재 "
            , ref Czar
            , Text "가 당신이 플레이할 "
            , ref (noun Call 1)
            , Text "를 선택하는 것을 기다리는 중입니다."
            ]

        PlayInstruction { numberOfCards } ->
            [ Text "플레이를 제출하기 전에 이 라운드에서 "
            , ref (noun Response numberOfCards)
            , Text "를 "
            , Text (asWord numberOfCards)
            , Text "장 더 선택해야 합니다."
            ]

        SubmitInstruction ->
            [ Text "이 라운드의 플레이를 재출해야 합니다." ]

        WaitingForPlaysInstruction ->
            [ Text "다른 플레이어들이 이 라운드에 플레이하는 것을 기다리고 있습니다." ]

        CzarsDontPlayInstruction ->
            [ Text "당신은 이 라운드의 "
            , ref Czar
            , Text "입니다. "
            , ref (nounUnknownQuantity Response)
            , Text "는 제출하지 않고, 모두가 그들의 카드를 제출하고 나서 승자를 선택합니다."
            ]

        NotInRoundInstruction ->
            [ Text "이 라운드에 참가하고 있지 않습니다. 자리 비움으로 설정이 안 된 이상 다음 라운드에서 참가할 것입니다." ]

        RevealPlaysInstruction ->
            [ Text "플레이를 선택해서 뒤집고, 제일 좋다고 생각하는 것을 선택해 주세요." ]

        WaitingForCzarInstruction ->
            [ ref Czar, Text "가 플레이들을 공개하고 승자를 선택할 때까지 플레이들에 좋아요를 추가할 수 있습니다." ]

        AdvanceRoundInstruction ->
            [ Text "다음 라운드가 시작되었습니다, 진행하셔도 됩니다." ]

        -- 404 Unknown
        UnknownPageTitle ->
            [ Text "404 에러: 알려지지 않은 페이지." ]

        GoBackHome ->
            [ Text "메인 페이지로 이동." ]

        -- Actions
        Refresh ->
            [ Text "새로고침하기" ]

        Accept ->
            [ Text "OK" ]

        -- Editor
        AddSlot ->
            [ ref Blank, Text "추가" ]

        AddText ->
            [ Text "텍스트 추가" ]

        EditText ->
            [ Text "편집" ]

        EditSlotIndex ->
            [ Text "편집" ]

        MoveLeft ->
            [ Text "왼쪽으로 이동" ]

        Remove ->
            [ Text "제거" ]

        MoveRight ->
            [ Text "오른쪽으로 이동" ]

        Normal ->
            [ Text "보통" ]

        Capitalise ->
            [ Text "대문자화" ]

        UpperCase ->
            [ Text "대문자" ]

        Emphasise ->
            [ Text "강조" ]

        MustContainAtLeastOneSlot ->
            [ Text "사람들이 플레이할 수 있게 최소한 하나의 ", ref Blank, Text "이 필요합니다." ]

        SlotIndexExplanation ->
            [ Text "이 "
            , ref Blank
            , Text "에 쓰일 "
            , ref (noun Response 1)
            , Text " 수입니다. 이걸로 "
            , ref (noun Response 1)
            , Text "를 반복 사용할 수 있습니다."
            ]

        -- Errors
        Error ->
            [ Text "에러" ]

        ErrorHelp ->
            [ Text "게임 서버가 오프라인이거나, 버그가 발생했을 수 있습니다. 페이지를 새로고침하면 계속 이을 수 있을 겁니다.  "
            , Text "자세한 정보는 아래에서 확인하실 수 있습니다."
            ]

        ErrorHelpTitle ->
            [ Text "무언가가 잘못되었습니다." ]

        ErrorCheckOutOfBand ->
            [ ref TwitterHandle, Text "를 확인하여 업데이트와 서비스 상태에 대해 알아 보세요. 새로운 업데이트가 추가되었을 때는 게임 서버들이 잠시 오프라인이 될 겁니다. 그러므로 만약 최근에 업데이트가 있었다면, 잠시 후에 다시 접속해 주시기 바랍니다." ]

        TwitterHandle ->
            [ Text "@Massive_Decks" ]

        ReportError ->
            [ Text "버그 신고" ]

        ReportErrorDescription ->
            [ Text "당신이 마주한 버그를 개발자들에게 알려서 그들이 고칠 수 있게 해 주세요." ]

        ReportErrorBody ->
            [ Text "제가 [당신이 하던 것의 짧은 설명으로 대체] 하고 있었을 때 이 에러를 얻었습니다:" ]

        BadUrlError ->
            [ Text "저희가 무효한 페이지로 요청을 하려고 했습니다." ]

        TimeoutError ->
            [ Text "서버가 오랜 시간동안 응답을 안했습니다. 서버가 나갔을 수도 있으니, 잠시 후에 다시 시도해 주시기 바랍니다." ]

        NetworkError ->
            [ Text "인터넷 연결이 차단되었습니다." ]

        ServerDownError ->
            [ Text "게임 서버가 현재 오프라인입니다. 나중에 다시 시도해 주세요." ]

        BadStatusError ->
            [ Text "서버가 저희가 예상 못한 응답을 했습니다." ]

        BadPayloadError ->
            [ Text "서버가 저희가 이해 못한 응답을 했습니다." ]

        PatchError ->
            [ Text "서버가 저희가 적용을 못하는 패치를 주었습니다." ]

        VersionMismatch ->
            [ Text "서버가 저희가 예상한 것과 다른 버전의 설정 변경을 했습니다." ]

        CastError ->
            [ Text "게임과 캐스트 연결 중에 문제가 발생했습니다." ]

        ActionExecutionError ->
            [ Text "그 행동은 할 수 없습니다." ]

        IncorrectPlayerRoleError { role, expected } ->
            [ Text "그걸 하려면 ", ref expected, Text "여야 하지만, 현재 ", ref role, Text "입니다." ]

        IncorrectUserRoleError { role, expected } ->
            [ Text "그걸 하려면 ", ref expected, Text "여야 하지만, 현재 ", ref role, Text "입니다." ]

        IncorrectRoundStageError { stage, expected } ->
            [ Text "그걸 하려면 라운드가 ", ref expected, Text " 스테이지에 있어야 하지만, 현재 ", ref stage, Text " 스테이지입니다." ]

        ConfigEditConflictError ->
            [ Text "누군가가 당신 이전에 설정을 바꿨으며, 당신의 변경은 저장되지 않았습니다." ]

        UnprivilegedError ->
            [ Text "그걸 할 권한이 없습니다." ]

        GameNotStartedError ->
            [ Text "게임이 시작되어야 그것을 할 수 있습니다." ]

        InvalidActionError { reason } ->
            [ Text "서버가 클라이언트의 요청을 이해하지 못했습니다. 자세한 정보:", Text reason ]

        AuthenticationError ->
            [ Text "그 게임에는 참가할 수 없습니다." ]

        IncorrectIssuerError ->
            [ Text "게임 참가시에 사용한 정보의 유효기간이 이미 지났으며, 게임은 더 이상 존재하지 않습니다." ]

        InvalidAuthenticationError ->
            [ Text "게임 참가시에 사용한 정보가 파손되었습니다." ]

        InvalidLobbyPasswordError ->
            [ Text "입력한 게임 패스워드가 알맞지 않습니다. 다시 쳐도 문제가 해결되지 않는다면, 당신을 초대한 사람에게 다시 물어보세요." ]

        AlreadyLeftError ->
            [ Text "이미 게임에서 나갔습니다." ]

        LobbyNotFoundError ->
            [ Text "그 게임은 존재하지 않습니다." ]

        LobbyClosedError { gameCode } ->
            [ Text "참가하고 싶은 게임 (", ref (GameCode { code = gameCode }), Text ")이 끝났습니다." ]

        LobbyDoesNotExistError { gameCode } ->
            [ Text "입력한 게임 코드 ("
            , ref (GameCode { code = gameCode })
            , Text ") 가 존재하지 않습니다. "
            , Text "다시 쳐도 문제가 해결되지 않는다면, 당신을 초대한 사람에게 다시 물어보세요."
            ]

        RegistrationError ->
            [ Text "게임 참가중 문제가 발생했습니다." ]

        UsernameAlreadyInUseError { username } ->
            [ Text "누군가가 벌써 “"
            , Text username
            , Text "”라는 이름을 쓰고 있습니다—다른 이름을 사용해 보세요."
            ]

        GameError ->
            [ Text "게임 내에서 무엇인가가 잘못되었습니다." ]

        OutOfCardsError ->
            [ Text "모두에게 카드를 나눠줄 정도의 카드가 없었습니다! 게임 설정에서 덱을 더 추가해 보세요." ]

        -- Language Names
        English ->
            [ Text "영어" ]

        BritishEnglish ->
            [ Text "영어 (영국)" ]

        Italian ->
            [ Text "이탈리아어" ]

        BrazilianPortuguese ->
            [ Text "포르투갈어 (브라질)" ]

        German ->
            [ Text "독일어 (정식적)" ]

        GermanInformal ->
            [ Text "독일어 (비정식적)" ]

        Polish ->
            [ Text "폴란드어" ]

        Indonesian ->
            [ Text "인도네시아어" ]

        Spanish ->
            [ Text "스페인어" ]

        Korean ->
            [ Text "한국어" ]



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
            ""

        _ ->
            ""


{-| Take a number and give back the name of that number. Falls back to the number when it gets too big.
-}
asWord : Int -> String
asWord number =
    case number of
        0 ->
            "0"

        1 ->
            "1"

        2 ->
            "2"

        3 ->
            "3"

        4 ->
            "4"

        5 ->
            "5"

        6 ->
            "6"

        7 ->
            "7"

        8 ->
            "8"

        9 ->
            "9"

        10 ->
            "10"

        11 ->
            "11"

        12 ->
            "12"

        other ->
            String.fromInt other
