module MassiveDecks.Strings.Languages.PtBR exposing (pack)

{-| Brazilian Portuguese translation.
-}

import MassiveDecks.Card.Source.BuiltIn.Model as BuiltIn
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Strings exposing (MdString(..))
import MassiveDecks.Strings.Translation as Translation exposing (Result(..))


pack : Translation.Pack
pack =
    { code = "pt-BR"
    , name = BrazilianPortuguese
    , translate = translate
    , recommended = "cah-base-ptbr" |> BuiltIn.hardcoded |> Source.BuiltIn
    }



{- Private -}


{-| The Brazilian Portuguese translation
-}
translate : MdString -> List Translation.Result
translate mdString =
    case mdString of
        -- General
        MassiveDecks ->
            [ Text "Massive Decks" ]

        Close ->
            [ Text "Fechar" ]

        -- Special
        Plural { singular, amount } ->
            if amount == Just 1 then
                [ Raw singular ]

            else
                -- Same case as italian and other languages, portuguese plurarization have some specific cases to handle
                case singular of
                    Call ->
                        [ Text "Cartas Pretas" ]

                    Response ->
                        [ Text "Cartas Brancas" ]

                    Point ->
                        [ Text "Pontos Incríveis" ]

                    Player ->
                        [ Text "Jogadores" ]

                    Spectator ->
                        [ Text "Espectadores" ]

                    _ ->
                        [ Raw singular, Text "s" ]

        -- Start screen.
        Version { versionNumber } ->
            [ Text "Versão “", Text versionNumber, Text "”" ]

        ShortGameDescription ->
            [ Text "Um jogo de festa de comédia." ]

        WhatIsThis ->
            [ Text "O que é ", Ref MassiveDecks, Text "?" ]

        GameDescription ->
            [ Ref MassiveDecks
            , Text " é um jogo de festa de comédia baseado em "
            , Ref CardsAgainstHumanity
            , Text ", desenvolvido pela "
            , Ref RereadGames
            , Text " e outros contribuidores—o jogo é código aberto sobre a "
            , Ref License
            , Text ", então você pode ajudar a melhorar o jogo, acessar o código fonte, ou apenas descobrir mais no "
            , Ref MDProject
            , Text "."
            ]

        NewGame ->
            [ Text "Novo" ]

        FindPublicGame ->
            [ Text "Procurar" ]

        JoinPrivateGame ->
            [ Text "Entrar" ]

        PlayGame ->
            [ Text "Jogar" ]

        AboutTheGame ->
            [ Text "Sobre" ]

        AboutTheGameDescription ->
            [ Text "Descubra mais sobre ", Ref MassiveDecks, Text " e como é desenvolvido." ]

        MDLogoDescription ->
            [ Text "Uma ", Ref Call, Text " e uma ", Ref Response, Text " marcados com um “M” e um “D”." ]

        RereadLogoDescription ->
            [ Text "Um livro rodeado por uma flecha de reciclagem." ]

        MDProject ->
            [ Text "projeto GitHub" ]

        License ->
            [ Text "licença AGPLv3" ]

        DevelopedByReread ->
            [ Text "Desenvolvido por ", Ref RereadGames, Text "." ]

        RereadGames ->
            [ Text "Reread Games" ]

        NameLabel ->
            [ Text "Seu Nome" ]

        NameInUse ->
            [ Text "Alguém está usando esse nome no jogo—por favor tente um diferente." ]

        RejoinTitle ->
            [ Text "Entrar novamente" ]

        RejoinGame { code } ->
            [ Text "Entrar novamente em “", GameCode { code = code } |> Ref, Text "”." ]

        LobbyRequiresPassword ->
            [ Text "Você precisa de uma senha para entrar no jogo. Tente perguntar à pessoa que lhe convidou." ]

        YouWereKicked ->
            [ Text "Você foi chutado do jogo." ]

        -- TODO: Translate
        ScrollToTop ->
            [ Text "Scroll to the top." ]

        -- TODO: Translate
        Copy ->
            [ Text "Copy" ]

        -- Rules
        CardsAgainstHumanity ->
            [ Text "Cartas Contra a Humanidade" ]

        Rules ->
            [ Text "Como jogar." ]

        RulesHand ->
            [ Text "Cada jogador tem uma mão de ", Ref (Plural { singular = Response, amount = Nothing }), Text "." ]

        RulesCzar ->
            [ Text "O primeiro jogador começa como "
            , Ref Czar
            , Text ". O "
            , Ref Czar
            , Text " lê a pergunta ou frase para preencher na "
            , Ref Call
            , Text " em voz alta."
            ]

        RulesPlaying ->
            [ Text "Todos os outros respondem a pergunta ou preenchem o espaço em branco escolhendo uma "
            , Ref Response
            , Text " de suas mãos para jogar a partida."
            ]

        RulesJudging ->
            [ Text "As respostas são então embaralhadas e o "
            , Ref Czar
            , Text " as lê para os outros jogadores—para melhor efeito, o "
            , Ref Czar
            , Text " deveria ler novamente a "
            , Ref Call
            , Text " antes de apresentar cada resposta. O "
            , Ref Czar
            , Text " então escolhe a jogada mais engraçada, e quem a jogou recebe um "
            , Ref Point
            , Text "."
            ]

        RulesPickTitle ->
            [ Ref (Pick { numberOfCards = 2 }) ]

        RulesPick ->
            [ Text "Algumas cartas precisam de mais de uma "
            , Ref Response
            , Text " como resposta. Escolha as cartas na ordem que o "
            , Ref Czar
            , Text " deveria ler—a ordem importa."
            ]

        ExamplePickDescription ->
            [ Ref (Plural { singular = Call, amount = Nothing })
            , Text " cartas como essa precisam de mais "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text ", mas te dão mais cartas para escolher."
            ]

        RulesDraw ->
            [ Text "Algumas "
            , Ref (Plural { singular = Call, amount = Nothing })
            , Text " precisam de ainda mais "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text "—elas vão dizer "
            , Ref (Draw { numberOfCards = 2 })
            , Text " ou mais, e você ganhará essa quantidade de cartas extras antes de jogar."
            ]

        GameRulesTitle ->
            [ Text "Regras de Jogo" ]

        HouseRulesTitle ->
            [ Text "Regras da Casa" ]

        HouseRules ->
            [ Text "Você pode mudar a forma que o jogo é jogado em uma variedade de maneiras. Enquanto estiver configurando o jogo, escolha "
            , Text "quantas e qualquer regra da casa que desejar usar."
            ]

        HouseRuleReboot ->
            [ Text "Reiniciando o Universo" ]

        HouseRuleRebootDescription { cost } ->
            [ Text "Em qualquer momento, jogadores podem trocar "
            , Text (an cost)
            , Ref (Plural { singular = Point, amount = cost })
            , Text " para descartar sua mão e pegar uma nova."
            ]

        HouseRuleRebootAction { cost } ->
            [ Text "Gastar "
            , Text (asWord cost Male)
            , Text " "
            , Ref (Plural { singular = Point, amount = Just cost })
            , Text " para trocar sua mão por uma nova."
            ]

        HouseRuleRebootCost ->
            [ Text "Custo de ", Ref (Plural { singular = Point, amount = Nothing }) ]

        HouseRuleRebootCostDescription ->
            [ Text "Quantos ", Ref (Plural { singular = Point, amount = Nothing }), Text " custa para trocar as cartas." ]

        HouseRulePackingHeat ->
            [ Text "Calor da Embalagem" ]

        HouseRulePackingHeatDescription ->
            [ Text "Quaisquer "
            , Ref (Plural { singular = Call, amount = Nothing })
            , Text " com "
            , Ref (Pick { numberOfCards = 2 })
            , Text " também tem "
            , Ref (Draw { numberOfCards = 1 })
            , Text ", com isso todos tem mais opções de escolha."
            ]

        HouseRuleComedyWriter ->
            [ Text "Escritor de Comédia" ]

        HouseRuleComedyWriterDescription ->
            [ Text "Adiciona "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text " vazias onde os jogadores podem escrever respostas personalizadas."
            ]

        HouseRuleComedyWriterNumber ->
            [ Ref (Plural { singular = Response, amount = Nothing }), Text " vazias" ]

        HouseRuleComedyWriterNumberDescription ->
            [ Text "O número de "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text "vazias que estarão no joogo."
            ]

        HouseRuleComedyWriterExclusive ->
            [ Text "Apenas ", Ref (Plural { singular = Response, amount = Nothing }), Text " vazias" ]

        HouseRuleComedyWriterExclusiveDescription ->
            [ Text "Se ativado, todas as outras "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text " serão ignoradas, apenas as vazias existirão no jogo."
            ]

        HouseRuleRandoCardrissian ->
            [ Text "Rando Cardrissian" ]

        HouseRuleRandoCardrissianDescription ->
            [ Text "A cada partida, a primeira "
            , Ref Response
            , Text " no deck será jogada como uma resposta. Esta jogada pertencerá a um jogador IA chamado "
            , Text "Rando Cardrissian, e se ele vencer o jogo, todos os jogadores vão para casa em um estado de vergonha eterna."
            ]

        HouseRuleRandoCardrissianNumber ->
            [ Text "Jogadores IA" ]

        HouseRuleRandoCardrissianNumberDescription ->
            [ Text "O número de jogadores IA que estarão no jogo." ]

        MustBeMoreThanOrEqualValidationError { min } ->
            [ Text "O valor deve ser ao menos ", Text (String.fromInt min), Text "." ]

        MustBeLessThanOrEqualValidationError { max } ->
            [ Text "O valor deve estar abaixo de  ", Text (String.fromInt max), Text "." ]

        SetValue { value } ->
            [ Text "Defina o valor como ", Text (String.fromInt value), Text "." ]

        CantBeEmpty ->
            [ Text "Isto não deve estar vazio." ]

        SettingsTitle ->
            [ Text "Configurações" ]

        LanguageSetting ->
            [ Text "Idioma" ]

        MissingLanguage ->
            [ Text "Não vê seu idioma? ", Ref TranslationBeg ]

        AutonymFormat { autonym } ->
            [ Text "(", Text autonym, Text ")" ]

        TranslationBeg ->
            [ Text "Ajudar a traduzir o "
            , Ref MassiveDecks
            , Text "!"
            ]

        CardSizeSetting ->
            [ Text "Tamanho das Cartas" ]

        CardSizeExplanation ->
            [ Text "Ajuste o tamanho das cartas—isto pode ser útil em telas pequeneas para menos rolagem." ]

        AutoAdvanceSetting ->
            [ Text "Avançar partida automaticamente" ]

        AutoAdvanceExplanation ->
            [ Text "Quando uma partida acabar, automaticamente pula para a próxima ao invés de aguardar." ]

        SpeechSetting ->
            [ Text "Texto para Fala" ]

        SpeechExplanation ->
            [ Text "Ler as cartas usando texto para fala." ]

        SpeechNotSupportedExplanation ->
            [ Text "Seu navegador não suporta texto para fala, ou não tem vozes instaladas." ]

        VoiceSetting ->
            [ Text "Voz da Fala" ]

        NotificationsSetting ->
            [ Text "Notificações de Navegador" ]

        NotificationsExplanation ->
            [ Text "Alertar quando você precisar fazer algo no jogo usando as notificações do navegador." ]

        NotificationsUnsupportedExplanation ->
            [ Text "Seu navegador não suporta notificações." ]

        NotificationsBrowserPermissions ->
            [ Text "Você precisa dar permissão ao "
            , Ref MassiveDecks
            , Text " para te notificar. Isto será usado apenas quando o jogo estiver aberto você estiver com isto ativado."
            ]

        NotificationOnlyWhenHiddenSetting ->
            [ Text "Apenas Quando Oculto" ]

        NotificationsOnlyWhenHiddenExplanation ->
            [ Text "Enviar notificações apenas quando você não está olhando para a página (ex.: em outra aba ou minimizado)." ]

        NotificationsOnlyWhenHiddenUnsupportedExplanation ->
            [ Text "Seu navegador não suporta checar a visibilidade da página." ]

        -- Terms
        Czar ->
            [ Text "Czar" ]

        CzarDescription ->
            [ Text "O jogador julgando a partida." ]

        Player ->
            [ Text "Jogador" ]

        Spectator ->
            [ Text "Espectador" ]

        Call ->
            [ Text "Carta Preta" ]

        CallDescription ->
            [ Text "Uma carta preta com uma pergunta ou frase para preencher." ]

        Response ->
            [ Text "Carta Branca" ]

        ResponseDescription ->
            [ Text "Uma carta com uma frase para ser jogada nas partidas." ]

        Point ->
            [ Text "Ponto Incrível" ]

        PointDescription ->
            [ Text "Um ponto—ter mais significa vencer." ]

        GameCodeTerm ->
            [ Text "Código do Jogo" ]

        GameCodeDescription ->
            [ Text "Um código que deixa outros jogadores encontrarem e entrarem no seu jogo." ]

        GameCode { code } ->
            [ Text code ]

        GameCodeSpecificDescription ->
            [ Text "Dê este código de jogo para seus amigos e eles poderão entrar no jogo." ]

        GameCodeHowToAcquire ->
            [ Text "Pergunte a quem convidou você ao jogo o ", Ref GameCodeTerm, Text "." ]

        Deck ->
            [ Text "Deck" ]

        -- TODO: Translate
        DeckSource ->
            [ Ref Deck, Text " Source" ]

        -- TODO: Translate
        DeckLanguage { language } ->
            [ Text "in ", Ref language ]

        -- TODO: Translate
        DeckAuthor { author } ->
            [ Text "by ", Text author ]

        -- TODO: Translate
        DeckTranslator { translator } ->
            [ Text "translation by ", Text translator ]

        StillPlaying ->
            [ Text "Jogando" ]

        PlayingDescription ->
            [ Text "Este jogador está na partida, mas não enviou sua jogada." ]

        Played ->
            [ Text "Jogou" ]

        PlayedDescription ->
            [ Text "Este jogador enviou sua jogada para a partida." ]

        -- Lobby Browser
        LobbyBrowserTitle ->
            [ Text "Jogos públicos" ]

        NoPublicGames ->
            [ Text "Sem jogos públicos disponíveis." ]

        PlayingGame ->
            [ Text "Jogos que estão em andamento." ]

        SettingUpGame ->
            [ Text "Jogos que ainda não iniciaram." ]

        StartYourOwn ->
            [ Text "Começar um novo jogo?" ]

        -- Spectation
        JoinTheGame ->
            [ Text "Entre no jogo!" ]

        ToggleAdvertDescription ->
            [ Text "Alterne a notificação ao entrarem no jogo." ]

        -- Cards
        Pick numberOfCards ->
            [ Text "Escolha", Ref (NumberOfCards numberOfCards) ]

        Draw numberOfCards ->
            [ Text "Pegue", Ref (NumberOfCards numberOfCards) ]

        PickDescription { numberOfCards } ->
            [ Text "Você precisa escolher "
            , Text (asWord numberOfCards Female)
            , Text " "
            , Ref (Plural { singular = Response, amount = Just numberOfCards })
            , Text "."
            ]

        DrawDescription { numberOfCards } ->
            [ Text "Você ganha mais "
            , Text (asWord numberOfCards Female)
            , Text " "
            , Ref (Plural { singular = Response, amount = Just numberOfCards })
            , Text " antes de jogar."
            ]

        NumberOfCards { numberOfCards } ->
            [ Text (String.fromInt numberOfCards) ]

        -- Lobby
        LobbyNameLabel ->
            [ Text "Nome do Jogo" ]

        DefaultLobbyName { owner } ->
            [ Text "Jogo de ", Text owner ]

        Invite ->
            [ Text "Convide pessoas ao jogo." ]

        InviteLinkHelp ->
            [ Text "Envie este link para jogadores para convidá-los ao jogo, ou deixe-os escanear o código QR abaixo." ]

        InviteExplanation { gameCode, password } ->
            let
                extra =
                    password
                        |> Maybe.map
                            (\p ->
                                [ Text " e a senha do jogo “"
                                , Text p
                                , Text "”"
                                ]
                            )
                        |> Maybe.withDefault []
            in
            List.concat
                [ [ Text "Seu código de jogo é "
                  , Ref (GameCode { code = gameCode })
                  , Text ". Jogadores podem entrar no jogo ao carregar o "
                  , Ref MassiveDecks
                  , Text " e digitando o código"
                  ]
                , extra
                , [ Text "."
                  ]
                ]

        Cast ->
            [ Text "Transmitir na TV." ]

        CastConnecting ->
            [ Text "Conectando…" ]

        CastConnected { deviceName } ->
            [ Text "Transmitindo para ", Text deviceName, Text "." ]

        Players ->
            [ Ref (Plural { singular = Player, amount = Nothing }) ]

        PlayersDescription ->
            [ Text "Usuários jogando o jogo." ]

        Spectators ->
            [ Ref (Plural { singular = Spectator, amount = Nothing }) ]

        SpectatorsDescription ->
            [ Text "Usuários assistindo o jogo sem jogar." ]

        Left ->
            [ Text "Saíram" ]

        LeftDescription ->
            [ Text "Usuários que deixaram o jogo." ]

        Away ->
            [ Text "Ausente" ]

        AwayDescription ->
            [ Text "Este usuário está temporariamente ausente do jogo." ]

        Disconnected ->
            [ Text "Desconectado" ]

        DisconnectedDescription ->
            [ Text "Este usuário não está conectado ao jogo." ]

        Privileged ->
            [ Text "Dono" ]

        PrivilegedDescription ->
            [ Text "Este usuário pode alterar as configurações do jogo." ]

        Ai ->
            [ Text "IA" ]

        AiDescription ->
            [ Text "Este jogador é controlado por um computador." ]

        Score { total } ->
            [ Text (String.fromInt total) ]

        ScoreDescription ->
            [ Text "O número de "
            , Ref (Plural { singular = Point, amount = Nothing })
            , Text " que este jogador possui."
            ]

        Likes { total } ->
            [ Text (String.fromInt total) ]

        LikesDescription ->
            [ Text "O número de curtidas recebidas."
            ]

        ToggleUserList ->
            [ Text "Mostrar ou ocultar a lista de pontuação." ]

        GameMenu ->
            [ Text "Menu do jogo." ]

        UnknownUser ->
            [ Text "Um usuário desconhecido" ]

        InvitePlayers ->
            [ Text "Convidar Jogadores" ]

        InvitePlayersDescription ->
            [ Text "Adquira o código do jogo/link/código QR para deixar outros entrarem no jogo." ]

        SetAway ->
            [ Text "Marcar como Ausente" ]

        SetBack ->
            [ Text "Voltar a jogar" ]

        LeaveGame ->
            [ Text "Sair do jogo" ]

        LeaveGameDescription ->
            [ Text "Permanentemente sair do jogo." ]

        Spectate ->
            [ Text "Visualização de Espectador" ]

        SpectateDescription ->
            [ Text "Abrir a visualização de espectador do jogo em uma nova aba/janela." ]

        BecomeSpectator ->
            [ Text "Espectador" ]

        BecomeSpectatorDescription ->
            [ Text "Apenas assistir o jogo sem jogar." ]

        BecomePlayer ->
            [ Text "Jogar" ]

        BecomePlayerDescription ->
            [ Text "Entrar no jogo." ]

        EndGame ->
            [ Text "Finalizar Jogo" ]

        EndGameDescription ->
            [ Text "Acabar o jogo agora." ]

        ReturnViewToGame ->
            [ Text "Retornar" ]

        ReturnViewToGameDescription ->
            [ Text "Retornar para a visualização principal do jogo." ]

        ViewConfgiuration ->
            [ Text "Configurar" ]

        ViewConfgiurationDescription ->
            [ Text "Trocar para a visualização de configurações do jogo." ]

        KickUser ->
            [ Text "Chutar" ]

        Promote ->
            [ Text "Promover" ]

        Demote ->
            [ Text "Rebaixar" ]

        -- Notifications
        UserConnected { username } ->
            [ Text username, Text " reconectou ao jogo." ]

        UserDisconnected { username } ->
            [ Text username, Text " desconectou do jogo." ]

        UserJoined { username } ->
            [ Text username, Text " entrou no jogo." ]

        UserLeft { username } ->
            [ Text username, Text " saiu do jogo." ]

        UserKicked { username } ->
            [ Text username, Text " foi chutado do jogo." ]

        Dismiss ->
            [ Text "Dispensar" ]

        -- Configuration
        ConfigureTitle ->
            [ Text "Configuração do Jogo" ]

        NoDecks ->
            [ Segment [ Text "Sem decks. " ]
            , Text " "
            , Segment [ Text "Você precisa adicionar ao menos um deck ao jogo." ]
            ]

        NoDecksHint ->
            [ Text "Não tem certeza? Adicione o deck original de ", Raw CardsAgainstHumanity, Text "." ]

        WaitForDecks ->
            [ Text "Os decks devem carregar antes de que você possa iniciar o jogo." ]

        MissingCardType { cardType } ->
            [ Text "Nenhum de seus decks possui "
            , Ref (Plural { singular = cardType, amount = Nothing })
            , Text ". Você precisa de um deck que as possoa para iniciar o jogo."
            ]

        NotEnoughCardsOfType { cardType, needed, have } ->
            [ Text "Para o número de jogadores no jogo, você precisa de pelo menos "
            , Text (needed |> String.fromInt)
            , Text " "
            , Ref (Plural { singular = cardType, amount = Just needed })
            , Text ", mas você possui somente "
            , Text (have |> String.fromInt)
            , Text "."
            ]

        -- TODO: Translate
        AddBlankCards { amount } ->
            [ Text "Add "
            , amount |> String.fromInt |> Text
            , Text " blank "
            , Ref (Plural { singular = Response, amount = Just amount })
            ]

        AddDeck ->
            [ Text "Adicionar deck." ]

        RemoveDeck ->
            [ Text "Remover deck." ]

        SourceNotFound { source } ->
            [ Ref source, Text " não reconhece o deck pedido. Cheque se os detalhes que você forneceu estão corretos." ]

        SourceServiceFailure { source } ->
            [ Ref source, Text " falhou ao providenciar o deck. Por favor tente novamente com outra fonte." ]

        Cardcast ->
            [ Text "Cardcast" ]

        CardcastPlayCode ->
            [ Text "Código de Jogo ", Ref Cardcast ]

        CardcastEmptyPlayCode ->
            [ Text "Digite um ", Ref CardcastPlayCode, Text " para o deck que você queira adicionar." ]

        BuiltIn ->
            [ Text "Embutido" ]

        APlayer ->
            [ Text "Um jogador" ]

        DeckAlreadyAdded ->
            [ Text "Este deck já está no jogo." ]

        ConfigureDecks ->
            [ Text "Decks" ]

        ConfigureRules ->
            [ Text "Regras" ]

        ConfigureTimeLimits ->
            [ Text "Tempos Limite" ]

        ConfigurePrivacy ->
            [ Text "Privacidade" ]

        HandSize ->
            [ Text "Tamanho da mão" ]

        HandSizeDescription ->
            [ Text "O número base de cartas que cada jogador possui em suas mãos durante o jogo." ]

        ScoreLimit ->
            [ Text "Limite de ", Ref (Plural { singular = Point, amount = Nothing }) ]

        ScoreLimitDescription ->
            [ Segment
                [ Text "O número de "
                , Ref (Plural { singular = Point, amount = Nothing })
                , Text " que um jogador precisa para vencer."
                ]
            , Text " "
            , Segment [ Text "Se desativado, o jogo continua indefinidamente." ]
            ]

        UnsavedChangesWarning ->
            [ Text "Você tem alterações não salvas nas configurações, elas devem ser salvas primeiro se você deseja aplicá-las "
            , Text "ao jogo."
            ]

        SaveChanges ->
            [ Text "Salvar suas alterações." ]

        RevertChanges ->
            [ Text "Descartar suas alterações não salvas." ]

        NeedAtLeastOneDeck ->
            [ Text "Você precisa de um deck de cartas adicionado ao jogo." ]

        NeedAtLeastThreePlayers ->
            [ Text "Você precisa de pelo menos três jogadores para iniciar o jogo." ]

        NeedAtLeastOneHuman ->
            [ Text "Infelizmente jogadores IA não podem ser o "
            , Ref Czar
            , Text ", então você precisa de pelo menos um jogador humano para iniciar o jogo."
            , Text " (apesar de que só um humano seja meio chato!)"
            ]

        RandoCantWrite ->
            [ Text "Jogadores IA não podem escrever cartas." ]

        DisableComedyWriter ->
            [ Text "Desativar ", Ref HouseRuleComedyWriter ]

        DisableRando ->
            [ Text "Desativar ", Ref HouseRuleRandoCardrissian ]

        AddAnAiPlayer ->
            [ Text "Adicionar um jogador IA ao jogo." ]

        PasswordShared ->
            [ Text "Qualquer um no jogo pode ver a senha! "
            , Text "Ocultá-la acima afeta apenas você (útil em transmissões etc…)."
            ]

        PasswordNotSecured ->
            [ Text "Senhas do jogo "
            , Em [ Text "não" ]
            , Text " são armazenadas seguramente—por isso, por favor, "
            , Em [ Text "não" ]
            , Text " use senhas sérias que você usaria um outros lugares!"
            ]

        LobbyPassword ->
            [ Text "Senha do Jogo" ]

        LobbyPasswordDescription ->
            [ Text "Uma senha que os jogadores devem usar para entrar no jogo." ]

        -- TODO: Translate
        AudienceMode ->
            [ Text "Audience Mode" ]

        -- TODO: Translate
        AudienceModeDescription ->
            [ Text "If enabled, newly joining users will be spectators by default, and only you will be able to "
            , Text "make them players."
            ]

        StartGame ->
            [ Text "Iniciar Jogo" ]

        Public ->
            [ Text "Jogo Público" ]

        PublicDescription ->
            [ Text "Se ativado, o jogo será exibido na lista de jogos públicos onde qualquer um pode encontrar." ]

        ApplyConfiguration ->
            [ Text "Aplicar esta mudança." ]

        AppliedConfiguration ->
            [ Text "Salvo." ]

        InvalidConfiguration ->
            [ Text "Este valor não é válido." ]

        Automatic ->
            [ Text "Automaticamente marcar jogadores como ausentes do jogo" ]

        AutomaticDescription ->
            [ Text "Se ativado, quando o tempo limite acabar, jogadores serão marcados automaticamente como ausente do jogo. "
            , Text "De outra forma, alguém terá que apertar o botão para fazer isso."
            ]

        TimeLimit { stage } ->
            [ Text " Tempo Limite quando estiver ", Ref stage ]

        PlayingTimeLimitDescription ->
            [ Text "Quanto tempo (em segundos) os ", Ref Players, Text " terão para fazer suas jogadas." ]

        -- TODO: Translate
        PlayingAfterDescription ->
            [ Text "How long (in seconds) players have to change their play before the next stage starts." ]

        RevealingTimeLimitDescription ->
            [ Text "Quanto tempo (em segundos) o ", Ref Czar, Text " tem para revelar as cartas." ]

        -- TODO: Translate
        RevealingAfterDescription ->
            [ Text "How long (in seconds) to wait after the last card is revealed before the next stage starts." ]

        JudgingTimeLimitDescription ->
            [ Text "Quanto tempo (em segundos) o ", Ref Czar, Text " tem para julgar as cartas." ]

        CompleteTimeLimitDescription ->
            [ Text "Quanto tempo (em segundos) para esperar depois que uma partida acaba antes de começar o próximo." ]

        -- TODO: Translate
        RevealingEnabledTitle ->
            [ Text "Czar Reveals Plays" ]

        -- TODO: Translate
        RevealingEnabled ->
            [ Text "If this is enabled, the "
            , Ref Czar
            , Text " reveals one play at a time before picking a winner."
            ]

        -- TODO: Translate
        DuringTitle ->
            [ Text "Time Limit" ]

        -- TODO: Translate
        AfterTitle ->
            [ Text "After" ]

        Conflict ->
            [ Text "Conflito" ]

        ConflictDescription ->
            [ Text "Alguém fez mudanças a isso enquanto você também fazia mudanças. "
            , Text "Por favor escolha entre manter suas mudanças ou as dele(a)."
            ]

        YourChanges ->
            [ Text "Suas mudanças" ]

        TheirChanges ->
            [ Text "Mudanças dele(a)" ]

        -- TODO: Translate
        ConfigurationDisabledWhileInGame ->
            [ Text "While the game in progress, you can't change the configuration." ]

        -- TODO: Translate
        ConfigurationDisabledIfNotPrivileged ->
            [ Text "You can't change the configuration of this game." ]

        -- TODO: Translate
        ConfigureNextGame ->
            [ Text "Configure Next Game" ]

        -- Game
        SubmitPlay ->
            [ Text "Dar essas cartas ao ", Ref Czar, Text " como sua jogada da partida." ]

        TakeBackPlay ->
            [ Text "Pegar de volta suas cartas para mudar sua jogada da partida." ]

        JudgePlay ->
            [ Text "Escolher essa jogada como vencedora da partida." ]

        LikePlay ->
            [ Text "Curtir esta jogada." ]

        AdvanceRound ->
            [ Text "Próxima partida." ]

        Playing ->
            [ Text "Jogando" ]

        Revealing ->
            [ Text "Revelando" ]

        Judging ->
            [ Text "Julgando" ]

        Complete ->
            [ Text "Finalizada" ]

        ViewGameHistoryAction ->
            [ Text "Ver partidas anteriores deste jogo." ]

        ViewHelpAction ->
            [ Text "Ajuda" ]

        EnforceTimeLimitAction ->
            [ Text "Definir todos os jogadores como ausentes e pulá-los até eles retornarem." ]

        Blank ->
            [ Text "Vazia" ]

        RoundStarted ->
            [ Text "Rodada iniciada" ]

        JudgingStarted ->
            [ Text "Julgamento iniciado" ]

        Paused ->
            [ Text "O jogo foi pausado por não ter jogadores ativos suficientes."
            , Text "Quando alguém entrar ou retornar o jogo continuará automaticamente."
            ]

        ClientAway ->
            [ Text "Você está atualmente definido como ausente do jogo, e não está jogando." ]

        -- Instructions
        PlayInstruction { numberOfCards } ->
            [ Text "Você precisa escolher mais "
            , Text (asWord numberOfCards Female)
            , Ref (Plural { singular = Response, amount = Just numberOfCards })
            , Text " da sua mão nesta partida antes de enviar sua jogada."
            ]

        SubmitInstruction ->
            [ Text "Vocêprecisa enviar sua jogada para esta partida." ]

        WaitingForPlaysInstruction ->
            [ Text "Você está esperando outros jogadores enviarem suas jogadas nesta partida." ]

        CzarsDontPlayInstruction ->
            [ Text "Você é o "
            , Ref Czar
            , Text " da partida - você não envia nenhuma das "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text ". Ao invés disso, você decide o vencedor da partida quando todos enviarem suas jogadas."
            ]

        NotInRoundInstruction ->
            [ Text "Você não está nessa partida. Você jogará na próxima, exceto se estiver definido como ausente do jogo." ]

        RevealPlaysInstruction ->
            [ Text "Clique nas jogadas para exibi-las, e escolha a que você acha a melhor." ]

        WaitingForCzarInstruction ->
            [ Text "Você pode curtir jogadas enqunto aguarda o ", Ref Czar, Text " revelar as cartas e decidir o vencedor." ]

        AdvanceRoundInstruction ->
            [ Text "A próxima partida começou, você pode avançar." ]

        -- 404 Unknown
        UnknownPageTitle ->
            [ Text "Erro 404: Página desconhecida." ]

        GoBackHome ->
            [ Text "Ir para a página principal." ]

        -- Actions
        Refresh ->
            [ Text "Atualizar" ]

        -- Errors
        Error ->
            [ Text "Erro" ]

        ErrorHelp ->
            [ Text "O servidor do jogo talvez tenha caído, ou isto talvez seja um bug. Atualizar a página deve ajudar "
            , Text ". Mais detalhes podem ser encontrados abaixo."
            ]

        ErrorHelpTitle ->
            [ Text "Desculpe, algo de errado não está certo." ]

        ReportError ->
            [ Text "Reportar Bug" ]

        ReportErrorDescription ->
            [ Text "Deixe os desenvolvedores saberem sobre o bug que você encontrou para que possam consertá-lo." ]

        ReportErrorBody ->
            [ Text "Eu estava [substitua com uma explicação curta do que você estava fazendo] quando eu recebi o seguinte erro:" ]

        BadUrlError ->
            [ Text "Tentamos fazer um pedido a uma página inválida." ]

        TimeoutError ->
            [ Text "O servidor não respondeu por muito tempo. Talvez tenha caído, por favor tente novamente depois de um curto tempo." ]

        NetworkError ->
            [ Text "Sua conexão com a internet foi interrompida." ]

        ServerDownError ->
            [ Text "O servidor do jogo está atualmente offline. Tente novamente mais tarde." ]

        BadStatusError ->
            [ Text "O servidor deu uma resposta que não esperávamos." ]

        BadPayloadError ->
            [ Text "O servidor deu uma resposta que não entendemos." ]

        PatchError ->
            [ Text "O servidor deu um camnho que não podemos aplicar." ]

        VersionMismatch ->
            [ Text "O servidor deu uma mudança de configuração por uma versão diferente que esperávamos." ]

        CastError ->
            [ Text "Desculpe, algo de errado aconteceu ao tentar conectar ao jogo." ]

        ActionExecutionError ->
            [ Text "Não podemos executar esta ação." ]

        IncorrectPlayerRoleError { role, expected } ->
            [ Text "Você precisa ser um ", Ref expected, Text " para fazer isso, mas você é um ", Ref role, Text "." ]

        IncorrectUserRoleError { role, expected } ->
            [ Text "Você precisa ser um ", Ref expected, Text " para fazer isso, mas você é um ", Ref role, Text "." ]

        IncorrectRoundStageError { stage, expected } ->
            [ Text "A partida precisa estar no estado de ", Ref expected, Text " para fazer isso, mas está no estado de ", Ref stage, Text "." ]

        ConfigEditConflictError ->
            [ Text "Alguém mudou a configuração antes de você, sua mudança não foi salva." ]

        UnprivilegedError ->
            [ Text "Você não tem privilégios para fazer isso." ]

        GameNotStartedError ->
            [ Text "O jogo precisa iniciar para fazer isso." ]

        InvalidActionError { reason } ->
            [ Text "O servidor não entende um pedido do cliente. Detalhes: ", Text reason ]

        AuthenticationError ->
            [ Text "Você não pode entrar no jogo." ]

        IncorrectIssuerError ->
            [ Text "Suas credenciais para entrar no jogo estão desatualizadas, o jogo não existe mais." ]

        InvalidAuthenticationError ->
            [ Text "Suas credenciais para entrar no jogo estão corrompidas." ]

        InvalidLobbyPasswordError ->
            [ Text "A senha que você forneceu do jogo está errada. Tente digitar novamente, e se ainda não funcionar, pergunte novamente a pessoa que te convidou." ]

        AlreadyLeftError ->
            [ Text "Você já saiu do jogo." ]

        LobbyNotFoundError ->
            [ Text "Este jogo não existe." ]

        LobbyClosedError { gameCode } ->
            [ Text "O jogo que você deseja entrar (", Ref (GameCode { code = gameCode }), Text ") foi finalizado." ]

        LobbyDoesNotExistError { gameCode } ->
            [ Text "O código do jogo que você forneceu ("
            , Ref (GameCode { code = gameCode })
            , Text ") não existe. "
            , Text "Tente digitar novamente, e se ainda não funcionar, pergunte novamente a pessoa que te convidou."
            ]

        RegistrationError ->
            [ Text "Problema ao entrar no jogo." ]

        UsernameAlreadyInUseError { username } ->
            [ Text "Alguém já está usando o nome “"
            , Text username
            , Text "”—tente um diferente."
            ]

        GameError ->
            [ Text "Algo de errado aconteceu no jogo." ]

        OutOfCardsError ->
            [ Text "Não há cartas suficientes no deck para dar uma mão a todo mundo! Tente adicionar mais decks nas configurações do jogo." ]

        -- Language Names
        English ->
            [ Text "Inglês" ]

        BritishEnglish ->
            [ Text "Inglês (Britânico)" ]

        Italian ->
            [ Text "Italiano" ]

        BrazilianPortuguese ->
            [ Text "Português (Brasileiro)" ]


an : Maybe Int -> String
an amount =
    case amount of
        Just 1 ->
            "um "

        _ ->
            ""


a : Maybe Int -> String
a amount =
    case amount of
        Just 1 ->
            "um "

        _ ->
            ""


{-| The grammatical gender of a noun.
-}
type Gender
    = Male
    | Female


{-| Take a number and give back the name of that number. Falls back to the number when it gets too big.
For portuguese, one and two are gender dependent, so Male if the word refers to a male noun, and Female for a female
noun.
-}
asWord : Int -> Gender -> String
asWord number gender =
    case number of
        0 ->
            "zero"

        1 ->
            case gender of
                Male ->
                    "um"

                Female ->
                    "uma"

        2 ->
            case gender of
                Male ->
                    "dois"

                Female ->
                    "duas"

        3 ->
            "três"

        4 ->
            "quatro"

        5 ->
            "cinco"

        6 ->
            "seis"

        7 ->
            "sete"

        8 ->
            "oito"

        9 ->
            "nove"

        10 ->
            "dez"

        11 ->
            "onze"

        12 ->
            "doze"

        other ->
            String.fromInt other
