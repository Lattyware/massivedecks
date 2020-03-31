module MassiveDecks.Strings.Languages.En exposing (pack)

{-| General English-language translation.
This is the primary language, strings here are the canonical representation, and are suitable to translate from.
-}

import MassiveDecks.Strings exposing (MdString(..))
import MassiveDecks.Strings.Translation as Translation exposing (Result(..))


pack : Translation.Pack
pack =
    { code = "en"
    , name = English
    , translate = translate
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
            [ Text "Close" ]

        -- Special
        Plural { singular, amount } ->
            if amount == Just 1 then
                [ Raw singular ]

            else
                [ Raw singular, Text "s" ]

        -- Start screen.
        Version { versionNumber } ->
            [ Text "Version “", Text versionNumber, Text "”" ]

        ShortGameDescription ->
            [ Text "A comedy party game." ]

        WhatIsThis ->
            [ Text "What is ", Ref MassiveDecks, Text "?" ]

        GameDescription ->
            [ Ref MassiveDecks
            , Text " is a comedy party game based on "
            , Ref CardsAgainstHumanity
            , Text ", developed by "
            , Ref RereadGames
            , Text " and other contributors—the game is open source under "
            , Ref License
            , Text ", so you can help improve the game, access the source code, or just find out more at "
            , Ref MDProject
            , Text "."
            ]

        NewGame ->
            [ Text "New" ]

        FindPublicGame ->
            [ Text "Find" ]

        JoinPrivateGame ->
            [ Text "Join" ]

        PlayGame ->
            [ Text "Play" ]

        AboutTheGame ->
            [ Text "About" ]

        AboutTheGameDescription ->
            [ Text "Find out about ", Ref MassiveDecks, Text " and how it is developed." ]

        MDLogoDescription ->
            [ Text "A ", Ref Call, Text " and a ", Ref Response, Text " marked with an “M” and a “D”." ]

        RereadLogoDescription ->
            [ Text "A book circled by a recycling arrow." ]

        MDProject ->
            [ Text "the GitHub project" ]

        License ->
            [ Text "the AGPLv3 license" ]

        DevelopedByReread ->
            [ Text "Developed by ", Ref RereadGames, Text "." ]

        RereadGames ->
            [ Text "Reread Games" ]

        NameLabel ->
            [ Text "Your Name" ]

        NameInUse ->
            [ Text "Someone else is using this name in the game—please try a different one." ]

        RejoinTitle ->
            [ Text "Rejoin Game" ]

        RejoinGame { code } ->
            [ Text "Rejoin “", GameCode { code = code } |> Ref, Text "”." ]

        LobbyRequiresPassword ->
            [ Text "You need a password to join this game. Try asking the person that invited you." ]

        YouWereKicked ->
            [ Text "You were kicked from the game." ]

        -- Rules
        CardsAgainstHumanity ->
            [ Text "Cards Against Humanity" ]

        Rules ->
            [ Text "How to play." ]

        RulesHand ->
            [ Text "Each player has a hand of ", Ref (Plural { singular = Response, amount = Nothing }), Text "." ]

        RulesCzar ->
            [ Text "The first player begins as the "
            , Ref Czar
            , Text ". the "
            , Ref Czar
            , Text " reads the question or fill-in-the-blank phrase on the "
            , Ref Call
            , Text " out loud."
            ]

        RulesPlaying ->
            [ Text "Everyone else answers the question or fills in the blank by choosing a "
            , Ref Response
            , Text " from their hand to play for the round."
            ]

        RulesJudging ->
            [ Text "The answers are then shuffled and the "
            , Ref Czar
            , Text " reads them out to the other players—for full effect, the "
            , Ref Czar
            , Text " should usually re-read the "
            , Ref Call
            , Text " before presenting each answer. The "
            , Ref Czar
            , Text " then picks the funniest play, and whoever played it gets one "
            , Ref Point
            , Text "."
            ]

        RulesPickTitle ->
            [ Ref (Pick { numberOfCards = 2 }) ]

        RulesPick ->
            [ Text "Some cards will need more than one "
            , Ref Response
            , Text " as an answer. Play the cards in the order the "
            , Ref Czar
            , Text " should read them—the order matters."
            ]

        ExamplePickDescription ->
            [ Ref (Plural { singular = Call, amount = Nothing })
            , Text " like this will require picking more "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text ", but give you more to pick from."
            ]

        RulesDraw ->
            [ Text "Some "
            , Ref (Plural { singular = Call, amount = Nothing })
            , Text " will need even more "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text "—these will say "
            , Ref (Draw { numberOfCards = 2 })
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
            , Ref (Plural { singular = Point, amount = cost })
            , Text " to discard their hand and draw a new one."
            ]

        HouseRuleRebootAction { cost } ->
            [ Text "Spend "
            , Text (asWord cost)
            , Text " "
            , Ref (Plural { singular = Point, amount = Just cost })
            , Text " to discard your hand and draw a new one."
            ]

        HouseRuleRebootCost ->
            [ Ref Point, Text " Cost" ]

        HouseRuleRebootCostDescription ->
            [ Text "How many ", Ref (Plural { singular = Point, amount = Nothing }), Text " it costs to redraw." ]

        HouseRulePackingHeat ->
            [ Text "Packing Heat" ]

        HouseRulePackingHeatDescription ->
            [ Text "Any "
            , Ref (Plural { singular = Call, amount = Nothing })
            , Text " with "
            , Ref (Pick { numberOfCards = 2 })
            , Text " also get "
            , Ref (Draw { numberOfCards = 1 })
            , Text ", so everyone has more options."
            ]

        HouseRuleComedyWriter ->
            [ Text "Comedy Writer" ]

        HouseRuleComedyWriterDescription ->
            [ Text "Add blank "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text " where players can write custom responses."
            ]

        HouseRuleComedyWriterNumber ->
            [ Text "Blank ", Ref (Plural { singular = Response, amount = Nothing }) ]

        HouseRuleComedyWriterNumberDescription ->
            [ Text "The number of Blank "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text "that will be in the game."
            ]

        HouseRuleComedyWriterExclusive ->
            [ Text "Only Blank ", Ref (Plural { singular = Response, amount = Nothing }) ]

        HouseRuleComedyWriterExclusiveDescription ->
            [ Text "If enabled, all other "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text " will be ignored, only blank ones will exist in-game."
            ]

        HouseRuleRandoCardrissian ->
            [ Text "Rando Cardrissian" ]

        HouseRuleRandoCardrissianDescription ->
            [ Text "Every round, the first "
            , Ref Response
            , Text " in the deck will be played as an answer. This play belongs to an AI player named "
            , Text "Rando Cardrissian, and if he wins the game, all players go home in a state of everlasting shame."
            ]

        HouseRuleRandoCardrissianNumber ->
            [ Text "AI Players" ]

        HouseRuleRandoCardrissianNumberDescription ->
            [ Text "The number of AI players that will be in the game." ]

        MustBeMoreThanOrEqualValidationError { min } ->
            [ Text "The value must be at least ", Text (String.fromInt min), Text "." ]

        MustBeLessThanOrEqualValidationError { max } ->
            [ Text "The value must be at most  ", Text (String.fromInt max), Text "." ]

        SetValue { value } ->
            [ Text "Set the value to ", Text (String.fromInt value), Text "." ]

        CantBeEmpty ->
            [ Text "This can't be empty." ]

        SettingsTitle ->
            [ Text "Settings" ]

        LanguageSetting ->
            [ Text "Language" ]

        MissingLanguage ->
            [ Text "Don’t see your language? ", Ref TranslationBeg ]

        TranslationBeg ->
            [ Text "Help translate "
            , Ref MassiveDecks
            , Text "!"
            ]

        CardSizeSetting ->
            [ Text "Compact Cards" ]

        CardSizeExplanation ->
            [ Text "Adjust how big cards are—this can be useful on small screens to scroll less." ]

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
            , Ref MassiveDecks
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

        Player ->
            [ Text "Player" ]

        Spectator ->
            [ Text "Spectator" ]

        Call ->
            [ Text "Black Card" ]

        CallDescription ->
            [ Text "A black card with a question or fill-in-the-blank phrase." ]

        Response ->
            [ Text "White Card" ]

        ResponseDescription ->
            [ Text "A white card with a phrase played into rounds." ]

        Point ->
            [ Text "Awesome Point" ]

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
            [ Text "Ask the person who invited you for the game’s ", Ref GameCodeTerm, Text "." ]

        Deck ->
            [ Text "Deck" ]

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
            [ Text "Pick", Ref (NumberOfCards numberOfCards) ]

        Draw numberOfCards ->
            [ Text "Draw", Ref (NumberOfCards numberOfCards) ]

        PickDescription { numberOfCards } ->
            [ Text "You need to play "
            , Text (asWord numberOfCards)
            , Text " "
            , Ref (Plural { singular = Response, amount = Just numberOfCards })
            , Text "."
            ]

        DrawDescription { numberOfCards } ->
            [ Text "You get "
            , Text (asWord numberOfCards)
            , Text " extra "
            , Ref (Plural { singular = Response, amount = Just numberOfCards })
            , Text " before playing."
            ]

        NumberOfCards { numberOfCards } ->
            [ Text (String.fromInt numberOfCards) ]

        -- Lobby
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
                  , Ref (GameCode { code = gameCode })
                  , Text ". Players can join the game by loading "
                  , Ref MassiveDecks
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
            [ Ref (Plural { singular = Player, amount = Nothing }) ]

        PlayersDescription ->
            [ Text "Users playing the game." ]

        Spectators ->
            [ Ref (Plural { singular = Spectator, amount = Nothing }) ]

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
            , Ref (Plural { singular = Point, amount = Nothing })
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
            [ Text "Return" ]

        ReturnViewToGameDescription ->
            [ Text "Return to the main game view." ]

        ViewConfgiuration ->
            [ Text "Configure" ]

        ViewConfgiurationDescription ->
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
            [ Text "Not sure? Add the original ", Raw CardsAgainstHumanity, Text " deck." ]

        WaitForDecks ->
            [ Text "The decks must load before you can start the game." ]

        MissingCardType { cardType } ->
            [ Text "None of your decks contain any "
            , Ref (Plural { singular = cardType, amount = Nothing })
            , Text ". You need a deck that does to start the game."
            ]

        NotEnoughCardsOfType { cardType, needed, have } ->
            [ Text "For the number of players in the game, you need at least "
            , Text (needed |> String.fromInt)
            , Text " "
            , Ref (Plural { singular = cardType, amount = Just needed })
            , Text " but you only have "
            , Text (have |> String.fromInt)
            , Text "."
            ]

        AddDeck ->
            [ Text "Add deck." ]

        RemoveDeck ->
            [ Text "Remove deck." ]

        SourceNotFound { source } ->
            [ Ref source, Text " doesn't recognise the deck you asked for. Check the details you gave are correct." ]

        SourceServiceFailure { source } ->
            [ Ref source, Text " failed to provide the deck. Please try again later or try another source." ]

        Cardcast ->
            [ Text "Cardcast" ]

        CardcastPlayCode ->
            [ Ref Cardcast, Text " Play Code" ]

        CardcastEmptyPlayCode ->
            [ Text "Enter a ", Ref CardcastPlayCode, Text " for the deck you want to add." ]

        APlayer ->
            [ Text "A Player" ]

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
            [ Ref Point, Text " Limit" ]

        ScoreLimitDescription ->
            [ Segment
                [ Text "The number of "
                , Ref (Plural { singular = Point, amount = Nothing })
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
            , Ref Czar
            , Text ", so you need at least one human player to start the game."
            , Text " (Although only one human might be a bit boring!)"
            ]

        RandoCantWrite ->
            [ Text "Computer players can't write their own cards." ]

        DisableComedyWriter ->
            [ Text "Disable ", Ref HouseRuleComedyWriter ]

        DisableRando ->
            [ Text "Disable ", Ref HouseRuleRandoCardrissian ]

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
            [ Text "A password to users must enter before they can join the game." ]

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
            [ Ref stage, Text " Time Limit" ]

        PlayingTimeLimitDescription ->
            [ Text "How long (in seconds) the ", Ref Players, Text " have to make their plays." ]

        RevealingTimeLimitDescription ->
            [ Text "How long (in seconds) the ", Ref Czar, Text " has to reveal the plays." ]

        JudgingTimeLimitDescription ->
            [ Text "How long (in seconds) the ", Ref Czar, Text " has to judge the plays." ]

        CompleteTimeLimitDescription ->
            [ Text "How much time (in seconds) to wait after one round ends before starting the next one." ]

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

        -- Game
        SubmitPlay ->
            [ Text "Give these cards to the ", Ref Czar, Text " as your play for the round." ]

        TakeBackPlay ->
            [ Text "Take back your cards to change your play for the round." ]

        JudgePlay ->
            [ Text "Pick this play as the winner for the round." ]

        LikePlay ->
            [ Text "Add a like to this play." ]

        AdvanceRound ->
            [ Text "Next round." ]

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

        -- Instructions
        PlayInstruction { numberOfCards } ->
            [ Text "You need to choose "
            , Text (asWord numberOfCards)
            , Text " more "
            , Ref (Plural { singular = Response, amount = Just numberOfCards })
            , Text " from your hand into this round before you can submit your play."
            ]

        SubmitInstruction ->
            [ Text "You need to submit your play for this round." ]

        WaitingForPlaysInstruction ->
            [ Text "You are waiting for other players to play into the round." ]

        CzarsDontPlayInstruction ->
            [ Text "You are the "
            , Ref Czar
            , Text " for the round - you don't submit any "
            , Ref (Plural { singular = Response, amount = Nothing })
            , Text ". Instead you choose the winner once everyone else has submitted theirs."
            ]

        NotInRoundInstruction ->
            [ Text "You are not in this round. You will play in the next one unless you are set to away." ]

        RevealPlaysInstruction ->
            [ Text "Click on the plays to flip them, then pick the one you think is best." ]

        WaitingForCzarInstruction ->
            [ Text "You can like plays while you wait for the ", Ref Czar, Text " to reveal the plays and pick a winner for the round." ]

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

        -- Errors
        Error ->
            [ Text "Error" ]

        ErrorHelp ->
            [ Text "The game server might be down, or this might be a bug. Refreshing the page should get you going "
            , Text "again. More details can be found below."
            ]

        ErrorHelpTitle ->
            [ Text "Sorry, something went wrong." ]

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
            [ Text "You need to be a ", Ref expected, Text " to do that, but you are a ", Ref role, Text "." ]

        IncorrectUserRoleError { role, expected } ->
            [ Text "You need to be a ", Ref expected, Text " to do that, but you are a ", Ref role, Text "." ]

        IncorrectRoundStageError { stage, expected } ->
            [ Text "The round needs to be at the ", Ref expected, Text " stage to do that, but it is at the ", Ref stage, Text " stage." ]

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
            [ Text "The game you wish to join (", Ref (GameCode { code = gameCode }), Text ") has ended." ]

        LobbyDoesNotExistError { gameCode } ->
            [ Text "The game code you entered ("
            , Ref (GameCode { code = gameCode })
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
