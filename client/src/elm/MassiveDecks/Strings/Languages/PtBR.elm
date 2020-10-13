module MassiveDecks.Strings.Languages.PtBR exposing (pack)

{-| Brazilian Portuguese localization.

Contributors:

  - Fittl3 <https://github.com/Fittl3>

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
        { lang = PtBR
        , code = "pt-BR"
        , name = BrazilianPortuguese
        , translate = translate
        , recommended = "cah-base-ptbr" |> BuiltIn.hardcoded |> Source.BuiltIn
        }



{- Private -}


raw : MdString -> Translation.Result never
raw =
    Raw Nothing


ref : MdString -> Translation.Result never
ref =
    Ref Nothing


{-| The Brazilian Portuguese translation
-}
translate : Maybe Never -> MdString -> List (Translation.Result Never)
translate _ mdString =
    case mdString of
        -- General
        MassiveDecks ->
            [ Text "Massive Decks" ]

        Close ->
            [ Text "Fechar" ]

        -- Special
        Noun { noun, quantity } ->
            case quantity of
                Quantity 1 ->
                    case noun of
                        Call ->
                            [ Text "Carta Preta" ]

                        Response ->
                            [ Text "Carta Branca" ]

                        Point ->
                            [ Text "Ponto Incrível" ]

                        Player ->
                            [ Text "Jogador" ]

                        Spectator ->
                            [ Text "Espectador" ]

                _ ->
                    case noun of
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

        -- Start screen.
        Version { versionNumber } ->
            [ Text "Versão “", Text versionNumber, Text "”" ]

        ShortGameDescription ->
            [ Text "Um jogo de festa de comédia." ]

        WhatIsThis ->
            [ Text "O que é ", ref MassiveDecks, Text "?" ]

        GameDescription ->
            [ ref MassiveDecks
            , Text " é um jogo de festa de comédia baseado em "
            , ref CardsAgainstHumanity
            , Text ", desenvolvido pela "
            , ref RereadGames
            , Text " e outros contribuidores—o jogo é código aberto sobre a "
            , ref License
            , Text ", então você pode ajudar a melhorar o jogo, acessar o código fonte, ou apenas descobrir mais no "
            , ref MDProject
            , Text "."
            ]

        NewGame ->
            [ Text "Novo" ]

        NewGameDescription ->
            [ Text "Começar um novo jogo de ", ref MassiveDecks, Text "." ]

        FindPublicGame ->
            [ Text "Procurar" ]

        JoinPrivateGame ->
            [ Text "Entrar" ]

        JoinPrivateGameDescription ->
            [ Text "Entre num jogo que alguém te convidou." ]

        PlayGame ->
            [ Text "Jogar" ]

        AboutTheGame ->
            [ Text "Sobre" ]

        AboutTheGameDescription ->
            [ Text "Descubra mais sobre ", ref MassiveDecks, Text " e como é desenvolvido." ]

        MDLogoDescription ->
            [ Text "Uma ", ref (noun Call 1), Text " e uma ", ref (noun Response 1), Text " marcados com um “M” e um “D”." ]

        RereadLogoDescription ->
            [ Text "Um livro rodeado por uma flecha de reciclagem." ]

        MDProject ->
            [ Text "projeto GitHub" ]

        License ->
            [ Text "licença AGPLv3" ]

        DevelopedByReread ->
            [ Text "Desenvolvido por ", ref RereadGames, Text "." ]

        RereadGames ->
            [ Text "Reread Games" ]

        NameLabel ->
            [ Text "Seu Nome" ]

        NameInUse ->
            [ Text "Alguém está usando esse nome no jogo—por favor tente usar um nome diferente." ]

        RejoinTitle ->
            [ Text "Entrar novamente" ]

        RejoinGame { code } ->
            [ Text "Entrar novamente em “", GameCode { code = code } |> ref, Text "”." ]

        LobbyRequiresPassword ->
            [ Text "Você precisa de uma senha para entrar no jogo. Tente perguntar à pessoa que lhe convidou." ]

        YouWereKicked ->
            [ Text "Você foi chutado do jogo." ]

        ScrollToTop ->
            [ Text "Rolar para o topo." ]

        Copy ->
            [ Text "Copiar" ]

        -- Rules
        CardsAgainstHumanity ->
            [ Text "Cartas Contra a Humanidade" ]

        Rules ->
            [ Text "Como jogar." ]

        RulesHand ->
            [ Text "Cada jogador terá uma mão de ", ref (nounUnknownQuantity Response), Text "." ]

        RulesCzar ->
            [ Text "O primeiro jogador começa como "
            , ref Czar
            , Text ". O "
            , ref Czar
            , Text " lê a pergunta ou frase para preencher na "
            , ref (noun Call 1)
            , Text " em voz alta."
            ]

        RulesPlaying ->
            [ Text "Todos os outros respondem a pergunta ou preenchem o espaço em branco escolhendo uma "
            , ref (noun Response 1)
            , Text " de suas mãos para jogar a partida."
            ]

        RulesJudging ->
            [ Text "As respostas são então embaralhadas e o "
            , ref Czar
            , Text " as lê para os outros jogadores—para melhor efeito, o "
            , ref Czar
            , Text " deveria ler novamente a "
            , ref (noun Call 1)
            , Text " antes de apresentar cada resposta. O "
            , ref Czar
            , Text " então escolhe a jogada mais engraçada, e quem a jogou recebe um "
            , ref (noun Point 1)
            , Text "."
            ]

        RulesPickTitle ->
            [ ref (Pick { numberOfCards = 2 }) ]

        RulesPick ->
            [ Text "Algumas cartas precisam de mais de uma "
            , ref (noun Response 1)
            , Text " como resposta. Escolha as cartas na ordem que o "
            , ref Czar
            , Text " deveria ler—a ordem importa."
            ]

        ExamplePickDescription ->
            [ ref (nounUnknownQuantity Call)
            , Text " como essa precisam de mais "
            , ref (nounUnknownQuantity Response)
            , Text " como resposta, mas te dão mais opções para escolher."
            ]

        RulesDraw ->
            [ Text "Algumas "
            , ref (nounUnknownQuantity Call)
            , Text " precisam de mais de uma "
            , ref (nounUnknownQuantity Response)
            , Text " como resposta—elas também vão dizer "
            , ref (Draw { numberOfCards = 2 })
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
            , ref (nounMaybe Point cost)
            , Text " para descartar sua mão e pegar uma nova."
            ]

        HouseRuleRebootAction { cost } ->
            [ Text "Gastar "
            , Text (asWord cost Male)
            , Text " "
            , ref (noun Point cost)
            , Text " para trocar sua mão por uma nova."
            ]

        HouseRuleRebootCost ->
            [ Text "Custo de ", ref (nounUnknownQuantity Point) ]

        HouseRuleRebootCostDescription ->
            [ Text "Quantos ", ref (nounUnknownQuantity Point), Text " custam para trocar as cartas." ]

        HouseRulePackingHeat ->
            [ Text "Calor da Embalagem" ]

        HouseRulePackingHeatDescription ->
            [ Text "Quaisquer "
            , ref (nounUnknownQuantity Call)
            , Text " com "
            , ref (Pick { numberOfCards = 2 })
            , Text " também vem com "
            , ref (Draw { numberOfCards = 1 })
            , Text ", com isso todos terão mais opções de escolha."
            ]

        HouseRuleComedyWriter ->
            [ Text "Escritor de Comédia" ]

        HouseRuleComedyWriterDescription ->
            [ Text "Adiciona "
            , ref (nounUnknownQuantity Response)
            , Text " vazias onde os jogadores podem escrever respostas personalizadas."
            ]

        HouseRuleComedyWriterNumber ->
            [ ref (nounUnknownQuantity Response), Text " vazias" ]

        HouseRuleComedyWriterNumberDescription ->
            [ Text "O número de "
            , ref (nounUnknownQuantity Response)
            , Text " vazias que estarão no jogo."
            ]

        HouseRuleComedyWriterExclusive ->
            [ Text "Apenas ", ref (nounUnknownQuantity Response), Text " vazias" ]

        HouseRuleComedyWriterExclusiveDescription ->
            [ Text "Se ativado, todas as outras "
            , ref (nounUnknownQuantity Response)
            , Text " serão ignoradas, apenas as vazias existirão no jogo."
            ]

        HouseRuleRandoCardrissian ->
            [ Text "Rando Cardrissian" ]

        HouseRuleRandoCardrissianDescription ->
            [ Text "A cada partida, a primeira "
            , ref (noun Response 1)
            , Text " no deck será jogada como uma resposta. Esta jogada pertencerá a um jogador IA chamado "
            , Text "Rando Cardrissian, e se ele vencer o jogo, todos os jogadores vão para casa em um estado de vergonha eterna."
            ]

        HouseRuleRandoCardrissianNumber ->
            [ Text "Jogadores IA" ]

        HouseRuleRandoCardrissianNumberDescription ->
            [ Text "O número de jogadores IA que estarão no jogo." ]

        HouseRuleNeverHaveIEver ->
            [ Text "Eu Nunca" ]

        HouseRuleNeverHaveIEverDescription ->
            [ Text "A qualquer momento, um jogador pode descartar as cartas que ele não entende, porém, ele deve confessar sua "
            , Text "ignorância: a carta é compartilhada publicamente."
            ]

        HouseRuleHappyEnding ->
            [ Text "Final Feliz" ]

        HouseRuleHappyEndingDescription ->
            [ Text "Quando o jogo termina, a rodada final é uma ", ref (noun Call 1), Text " dizendo “Faça um Haiku”." ]

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
            [ Text "Não vê seu idioma? ", ref TranslationBeg ]

        AutonymFormat { autonym } ->
            [ Text "(", Text autonym, Text ")" ]

        TranslationBeg ->
            [ Text "Ajudar a traduzir o "
            , ref MassiveDecks
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
            [ Text "Seu navegador não suporta texto para fala, ou não possui vozes instaladas." ]

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
            , ref MassiveDecks
            , Text " para te notificar. Isto será usado apenas quando o jogo estiver aberto e você estiver com isto ativado."
            ]

        NotificationOnlyWhenHiddenSetting ->
            [ Text "Apenas Quando Oculto" ]

        NotificationsOnlyWhenHiddenExplanation ->
            [ Text "Enviar notificações apenas quando você não está olhando para a página (ex.: em outra aba ou minimizado)." ]

        NotificationsOnlyWhenHiddenUnsupportedExplanation ->
            [ Text "Seu navegador não suporta a checagem de visibilidade da página." ]

        -- Terms
        Czar ->
            [ Text "Czar" ]

        CzarDescription ->
            [ Text "O jogador julgando a partida." ]

        CallDescription ->
            [ Text "Uma carta preta com uma pergunta ou frase para preencher." ]

        ResponseDescription ->
            [ Text "Uma carta com uma frase para ser jogada nas partidas." ]

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
            [ Text "Pergunte a quem convidou você ao jogo o ", ref GameCodeTerm, Text "." ]

        Deck ->
            [ Text "Deck" ]

        DeckSource ->
            [ Text "Fonte do ", ref Deck ]

        DeckLanguage { language } ->
            [ Text "em ", Text language ]

        DeckAuthor { author } ->
            [ Text "de ", Text author ]

        DeckTranslator { translator } ->
            [ Text "traduzido por ", Text translator ]

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
            [ Text "Escolha", ref (NumberOfCards numberOfCards) ]

        Draw numberOfCards ->
            [ Text "Pegue", ref (NumberOfCards numberOfCards) ]

        PickDescription { numberOfCards } ->
            [ Text "Você precisa escolher "
            , Text (asWord numberOfCards Female)
            , Text " "
            , ref (noun Response numberOfCards)
            , Text "."
            ]

        DrawDescription { numberOfCards } ->
            [ Text "Você ganha mais "
            , Text (asWord numberOfCards Female)
            , Text " "
            , ref (noun Response numberOfCards)
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
                  , ref (GameCode { code = gameCode })
                  , Text ". Jogadores podem entrar no jogo ao carregar o "
                  , ref MassiveDecks
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
            [ ref (nounUnknownQuantity Player) ]

        PlayersDescription ->
            [ Text "Usuários jogando o jogo." ]

        Spectators ->
            [ ref (nounUnknownQuantity Spectator) ]

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
            , ref (nounUnknownQuantity Point)
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

        ViewConfiguration ->
            [ Text "Configurar" ]

        ViewConfigurationDescription ->
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
            [ Text "Não tem certeza? Adicione o deck original de ", raw CardsAgainstHumanity, Text "." ]

        WaitForDecks ->
            [ Text "Os decks devem carregar antes de que você possa iniciar o jogo." ]

        MissingCardType { cardType } ->
            [ Text "Nenhum de seus decks possui "
            , ref (nounUnknownQuantity cardType)
            , Text ". Você precisa de um deck que as possoa para iniciar o jogo."
            ]

        NotEnoughCardsOfType { cardType, needed, have } ->
            [ Text "Para o número de jogadores no jogo, você precisa de pelo menos "
            , Text (needed |> String.fromInt)
            , Text " "
            , ref (noun cardType needed)
            , Text ", mas você possui somente "
            , Text (have |> String.fromInt)
            , Text "."
            ]

        AddBlankCards { amount } ->
            [ Text "Adicionar "
            , amount |> String.fromInt |> Text
            , ref (noun Response amount)
            , Text " vazias."
            ]

        AddDeck ->
            [ Text "Adicionar deck." ]

        RemoveDeck ->
            [ Text "Remover deck." ]

        SourceNotFound { source } ->
            [ ref source, Text " não reconhece o deck pedido. Cheque se os detalhes que você forneceu estão corretos." ]

        SourceServiceFailure { source } ->
            [ ref source, Text " falhou ao providenciar o deck. Por favor tente novamente com outra fonte." ]

        ManyDecks ->
            [ Text "Many Decks" ]

        ManyDecksDeckCodeTitle ->
            [ Text "Código do Deck" ]

        ManyDecksDeckCodeShort ->
            [ Text "Um código de deck deve ser de pelo menos cinco caracteres." ]

        ManyDecksWhereToGet ->
            [ Text "Você pode criar decks para jogar usando o ", ref ManyDecks, Text "." ]

        JsonAgainstHumanity ->
            [ Text "JSON Against Humanity" ]

        JsonAgainstHumanityAbout ->
            [ Text "Decks fornecidos por ", ref JsonAgainstHumanity ]

        BuiltIn ->
            [ Text "Embutido" ]

        APlayer ->
            [ Text "Um jogador" ]

        Generated { by } ->
            [ Text "Gerado por ", ref by ]

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
            [ Text "Limite de ", ref (nounUnknownQuantity Point) ]

        ScoreLimitDescription ->
            [ Segment
                [ Text "O número de "
                , ref (nounUnknownQuantity Point)
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
            , ref Czar
            , Text ", então você precisa de pelo menos um jogador humano para iniciar o jogo."
            , Text " (apesar de que só um humano seja meio chato!)"
            ]

        RandoCantWrite ->
            [ Text "Jogadores IA não podem escrever cartas." ]

        DisableComedyWriter ->
            [ Text "Desativar ", ref HouseRuleComedyWriter ]

        DisableRando ->
            [ Text "Desativar ", ref HouseRuleRandoCardrissian ]

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

        AudienceMode ->
            [ Text "Modo Audiência" ]

        AudienceModeDescription ->
            [ Text "Se ativado, novos usuários serão colocados como espectadores por padrão, e apenas você será capaz de "
            , Text "transformá-los em jogadores."
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
            [ Text " Tempo Limite quando estiver ", ref stage ]

        PlayingTimeLimitDescription ->
            [ Text "Quanto tempo (em segundos) os ", ref Players, Text " terão para fazer suas jogadas." ]

        PlayingAfterDescription ->
            [ Text "Quanto tempo (em segundos) os ", ref Players, Text " terão para mudar suas jogadas antes de começar o próximo estágio." ]

        RevealingTimeLimitDescription ->
            [ Text "Quanto tempo (em segundos) o ", ref Czar, Text " terá para revelar as cartas." ]

        RevealingAfterDescription ->
            [ Text "Quanto tempo (em segundos) para aguardar após a última carta ser revelada antes de começar o próximo estágio." ]

        JudgingTimeLimitDescription ->
            [ Text "Quanto tempo (em segundos) o ", ref Czar, Text " terá para julgar as cartas." ]

        CompleteTimeLimitDescription ->
            [ Text "Quanto tempo (em segundos) para esperar depois que uma partida acaba antes de começar a próxima." ]

        RevealingEnabledTitle ->
            [ raw Czar, Text " Revela Jogadas" ]

        RevealingEnabled ->
            [ Text "Se isto estiver ativado, o "
            , ref Czar
            , Text " revela uma jogada por vez antes de escolher o vencedor."
            ]

        DuringTitle ->
            [ Text "Tempo Limite" ]

        AfterTitle ->
            [ Text "Após" ]

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

        ConfigurationDisabledWhileInGame ->
            [ Text "Enquanto o jogo estiver em andamento, você não pode alterar a configuração." ]

        ConfigurationDisabledIfNotPrivileged ->
            [ Text "Você não pode mudar a configuração desse jogo." ]

        ConfigureNextGame ->
            [ Text "Configurar Próximo Jogo" ]

        -- Game
        SubmitPlay ->
            [ Text "Dar essas cartas ao ", ref Czar, Text " como sua jogada da partida." ]

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

        Discard ->
            [ Text "Descartar a carta selecionada, revelando para outros usuários do jogo." ]

        Discarded { player } ->
            [ Text player
            , Text " descartou a seguinte carta:"
            ]

        -- Instructions
        PlayInstruction { numberOfCards } ->
            [ Text "Você precisa escolher mais "
            , Text (asWord numberOfCards Female)
            , ref (noun Response numberOfCards)
            , Text " da sua mão nesta partida antes de enviar sua jogada."
            ]

        SubmitInstruction ->
            [ Text "Vocêprecisa enviar sua jogada para esta partida." ]

        WaitingForPlaysInstruction ->
            [ Text "Você está esperando outros jogadores enviarem suas jogadas nesta partida." ]

        CzarsDontPlayInstruction ->
            [ Text "Você é o "
            , ref Czar
            , Text " da partida - você não envia nenhuma das "
            , ref (nounUnknownQuantity Response)
            , Text ". Ao invés disso, você decide o vencedor da partida quando todos enviarem suas jogadas."
            ]

        NotInRoundInstruction ->
            [ Text "Você não está nessa partida. Você jogará na próxima, exceto se estiver definido como ausente do jogo." ]

        RevealPlaysInstruction ->
            [ Text "Clique nas jogadas para exibi-las, e escolha a que você acha a melhor." ]

        WaitingForCzarInstruction ->
            [ Text "Você pode curtir jogadas enqunto aguarda o ", ref Czar, Text " revelar as cartas e decidir o vencedor." ]

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

        Accept ->
            [ Text "OK" ]

        -- Errors
        Error ->
            [ Text "Erro" ]

        ErrorHelp ->
            [ Text "O servidor do jogo talvez tenha caído, ou isto talvez seja um bug. Atualizar a página deve ajudar "
            , Text ". Mais detalhes podem ser encontrados abaixo."
            ]

        ErrorHelpTitle ->
            [ Text "Desculpe, algo de errado não está certo." ]

        ErrorCheckOutOfBand ->
            [ Text "Por favor verifique ", ref TwitterHandle, Text " para atualizações e status de serviço. O servidor do jogo irá cair por um breve tempo quando uma nova versão for lançada, então se você ver uma atualização recente, tente novamente em alguns minutos." ]

        TwitterHandle ->
            [ Text "@Massive_Decks" ]

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
            [ Text "Você precisa ser um ", ref expected, Text " para fazer isso, mas você é um ", ref role, Text "." ]

        IncorrectUserRoleError { role, expected } ->
            [ Text "Você precisa ser um ", ref expected, Text " para fazer isso, mas você é um ", ref role, Text "." ]

        IncorrectRoundStageError { stage, expected } ->
            [ Text "A partida precisa estar no estado de ", ref expected, Text " para fazer isso, mas está no estado de ", ref stage, Text "." ]

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
            [ Text "O jogo que você deseja entrar (", ref (GameCode { code = gameCode }), Text ") foi finalizado." ]

        LobbyDoesNotExistError { gameCode } ->
            [ Text "O código do jogo que você forneceu ("
            , ref (GameCode { code = gameCode })
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

        German ->
            [ Text "Alemão (formal)" ]

        GermanInformal ->
            [ Text "Alemão (informal)" ]

        Polish ->
            [ Text "Polonês" ]

        Indonesian ->
            [ Text "Indonésio" ]


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
