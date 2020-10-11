module MassiveDecks.Strings exposing
    ( MdString(..)
    , Noun(..)
    , Quantity(..)
    , noun
    , nounMaybe
    , nounUnknownQuantity
    )

{-| This module deals with text that is shown to the user in the application - strings.
-}


{-| Nouns need plural translations as we talk about them as singular items but also as plurals.
-}
type Noun
    = Call -- A call card (a black card).
    | Response -- A response card (a white card).
    | Point -- A point in the game, your score is how many of these you have, and having the most is how you win.
    | Player -- A player in the game with no special role.
    | Spectator -- A user who watches the game, but doesn't play in it.


{-| An amount of a noun. Either we know how many we are talking about or we are talking about some unknown number of
the thing. In English, for example, we use the singular for `Quantity 1` and plural for everything else. Different
languages have different rules.
-}
type Quantity
    = Quantity Int
    | Unknown


noun : Noun -> Int -> MdString
noun n quantity =
    Noun { noun = n, quantity = Quantity quantity }


nounUnknownQuantity : Noun -> MdString
nounUnknownQuantity n =
    Noun { noun = n, quantity = Unknown }


nounMaybe : Noun -> Maybe Int -> MdString
nounMaybe n quantity =
    Noun { noun = n, quantity = quantity |> Maybe.map Quantity |> Maybe.withDefault Unknown }


{-| Each type represents a message that may be shown to the user. Some have arguments that are variable but should be
included in some form in the message.
-}
type MdString
    = MassiveDecks -- The name of the game.
    | Close -- Close a dialog window.
      -- Special
    | Noun { noun : Noun, quantity : Quantity } -- The given noun, described in the given quantity and context.
      -- Start screen.
    | Version { versionNumber : String } -- The version of the game being played.
    | ShortGameDescription -- A one-line description of the game.
    | WhatIsThis -- A title for a section describing the game.
    | GameDescription -- A long description of the game.
    | NewGame -- The action of creating a new game. (Short, ideally one word).
    | NewGameDescription -- A description of starting a new game.
    | FindPublicGame -- The action of finding a public game to join. (Short, ideally one word).
    | JoinPrivateGame -- The action of joining a private game the user was invited to. (Short, ideally one word).
    | JoinPrivateGameDescription -- A description of joining a private game the user was invited to.
    | PlayGame -- The action of joining a game to play it. (Short, ideally one word).
    | AboutTheGame -- The action of finding out more information about the game. (Short, ideally one word).
    | AboutTheGameDescription -- A description of the action of finding out about the game.
    | MDLogoDescription -- A description of the Massive Decks logo (e.g: for blind users).
    | RereadLogoDescription -- A description of the Reread Games logo (e.g: for blind users).
    | MDProject -- A description of the action of visiting the development project for Massive Decks.
    | License -- A description of the license the game is made available under.
    | DevelopedByReread -- A description of the fact that the game was developed by Reread.
    | RereadGames -- The name of "Reread Games" (https://www.rereadgames.com/).
    | NameLabel -- A label for a user name text field.
    | NameInUse -- An error indicating the name the user asked for is already in use and they should try another.
    | RejoinTitle -- A title for a list of games the user was previously in and might be able to rejoin.
    | RejoinGame { code : String } -- A description of the action of attempting to rejoin a game the user was previously in.
    | LobbyRequiresPassword -- An explanation that the given lobby requires a password to join.
    | YouWereKicked -- An explanation that the player was kicked from the lobby they were in.
    | ScrollToTop -- A description of the action of scrolling to the top of a screen.
    | Copy -- A description of the action of copying something (i.e: copy and paste).
      -- Rules
    | CardsAgainstHumanity -- The name of "Cards Against Humanity" (https://cardsagainsthumanity.com/).
    | Rules -- The title for a DESCRIPTION of the rules.
    | RulesHand -- The rules for the game about the player's hand.
    | RulesCzar -- The rules for the game about being the czar.
    | RulesPlaying -- The rules for the game about playing answers.
    | RulesJudging -- The rules for the game about judging a round as czar.
    | RulesPickTitle -- The title for the rules for calls with more than one slot.
    | RulesPick -- The rules for calls with more than one slot.
    | ExamplePickDescription -- The description for the example card showing the Pick mechanics.
    | RulesDraw -- The rules for calls with lots of slots that let your draw additional cards.
    | GameRulesTitle -- The title for the section on the core game rules.
    | HouseRulesTitle -- The title for the section about house rules.
    | HouseRules -- A description of what house rules are.
    | HouseRuleReboot -- The name of the "Rebooting the Universe" house rule.
    | HouseRuleRebootDescription { cost : Maybe Int } -- A description of the "Rebooting the Universe" house rule.
    | HouseRuleRebootAction { cost : Int } -- A description of the action of spending cost points to redraw your hand.
    | HouseRuleRebootCost -- A description of the cost of redrawing your hand.
    | HouseRuleRebootCostDescription --
    | HouseRulePackingHeat -- The name of the "Packing Heat" house rule.
    | HouseRulePackingHeatDescription -- A description of the "Packing Heat" house rule.
    | HouseRuleComedyWriter -- The name of the "Comedy Writer" house rule.
    | HouseRuleComedyWriterDescription -- A description of the "Comedy Writer" house rule.
    | HouseRuleComedyWriterNumber -- A name of the setting for the number of blank cards added to the game.
    | HouseRuleComedyWriterNumberDescription -- A description of the setting for the number of blank cards added to the game.
    | HouseRuleComedyWriterExclusive -- A name of the setting for exclusively having blank cards in the game.
    | HouseRuleComedyWriterExclusiveDescription -- A description of the setting for exclusively having blank cards in the game.
      -- Note that the below name is a pun on the Star Wars character "Lando Calrissian" and the words "Random" and
      -- "Card". It may be better to be more literal, or make an alternative reference. This is essentially adding
      -- a computer player that just plays a random card.
    | HouseRuleRandoCardrissian -- The name of the "Rando Cardrissian" house rule.
    | HouseRuleRandoCardrissianDescription -- A description of the "Rando Cardrissian" house rule.
    | HouseRuleRandoCardrissianNumber -- A name of the setting for the number of bots added to the game.
    | HouseRuleRandoCardrissianNumberDescription -- A description of the setting for the number of bots added to the game.
    | HouseRuleNeverHaveIEver -- The name of the house rule where players can discard cards, sharing the discarded card.
    | HouseRuleNeverHaveIEverDescription -- A description of the house rule where players can discard cards, sharing the discarded card.
    | HouseRuleHappyEnding -- The name of the house rule where the game ends with the haiku card.
    | HouseRuleHappyEndingDescription -- A description of the house rule where the game ends with the haiku card.
    | MustBeMoreThanOrEqualValidationError { min : Int } -- An error when a configuration value must be more than or equal to the given value.
    | MustBeLessThanOrEqualValidationError { max : Int } -- An error when a configuration value must be less than or equal to the given value.
    | SetValue { value : Int } -- A description of the action of resolving a problem by setting the value to the given one.
    | CantBeEmpty -- An error when a configuration value must be non-empty.
      -- Settings
    | SettingsTitle -- The title for the settings panel.
    | LanguageSetting -- The label for the "Language" setting.
    | MissingLanguage -- A question asking if the user doesn't see the language they want.
    | AutonymFormat { autonym : String } -- How to format the name for a language in that language (e.g: in brackets).
    | TranslationBeg -- A request for help translating the game.
    | CardSizeSetting -- The label for the "Card Size" setting.
    | CardSizeExplanation -- An explanation of what the card size does (changes the size of the card).
    | AutoAdvanceSetting -- The label for the "Automatically Advance Round" setting.
    | AutoAdvanceExplanation -- An explanation of what the auto advance setting does (automatically advances past the completed round screen to the new round).
    | SpeechSetting -- The label for the speech setting.
    | SpeechExplanation -- An explanation of what the speech setting does (enables TTS on cards).
    | SpeechNotSupportedExplanation -- An explanation that speech can't be enabled because the user's browser doesn't support it.
    | VoiceSetting -- The label for the voice setting.
    | NotificationsSetting -- The label for the notifications setting.
    | NotificationsExplanation -- An explanation of what the notifications setting does (enables browser notifications).
    | NotificationsBrowserPermissions -- An explanation that the user will need to give the game permission for notifications.
    | NotificationsUnsupportedExplanation -- An explanation that notifications are not supported by the user's browser.
    | NotificationOnlyWhenHiddenSetting -- The label for the only when hidden setting.
    | NotificationsOnlyWhenHiddenExplanation -- An explanation of what the only when hidden setting does (only sends notifications when on another tab or minimised).
    | NotificationsOnlyWhenHiddenUnsupportedExplanation -- An explanation that page visibility checking is not supported by the user's browser.
      -- Terms
    | Czar -- The name for the "Card Czar" (the player that judges the round).
    | CzarDescription -- A short description of what the czar does.
    | CallDescription -- A short description of what a call is.
    | ResponseDescription -- A short description of what a response is.
    | PointDescription -- A short description of what a point is.
    | GameCodeTerm -- The term for a unique code for a game that allows a user to find the game easily.
    | GameCodeDescription -- A short description of what a game code is.
    | GameCode { code : String } -- Render a game code.
    | GameCodeSpecificDescription -- A short description of what a specific game code and how to use it.
    | GameCodeHowToAcquire -- A short description of how to get a game code.
    | Deck -- The name for a deck of cards.
    | DeckSource -- The name for a source of decks of cards.
    | DeckLanguage { language : String } -- A description of what language a deck is in.
    | DeckAuthor { author : String } -- A description of who created the deck.
    | DeckTranslator { translator : String } -- A description of who translated the deck.
    | StillPlaying -- A term for a person who is in a round, but has not yet submitted a play.
    | PlayingDescription -- A description of a person who is in a round, but has not yet submitted a play.
    | Played -- A term for a person who is in a round, and has submitted a play.
    | PlayedDescription -- A description of a person who is in a round, and has submitted a play.
      -- Lobby Browser
    | LobbyBrowserTitle -- A description of a tool to browse public games.
    | NoPublicGames -- An explanation that there are no public games available to the user.
    | PlayingGame -- A description of a game that is in-progress.
    | SettingUpGame -- A description of a game that has not started yet.
    | StartYourOwn -- A question asking if the player wants to start a new game.
      -- Spectation
    | JoinTheGame -- A short phrase encouraging a player to join the game using information that follows.
    | ToggleAdvertDescription -- A description of the action of toggling showing the info on how to join the game.
      -- Cards
    | Pick { numberOfCards : Int } -- The word describing the action of picking a card from their hand to play. Use NumberOfCards for the number.
    | Draw { numberOfCards : Int } -- The word describing the action of drawing a card from the deck to their hand. Use NumberOfCards for the number.
    | PickDescription { numberOfCards : Int } -- A description of game rules where the user must pick a given number of cards.
    | DrawDescription { numberOfCards : Int } -- A description of game rules where the user gets to draw more cards.
    | NumberOfCards { numberOfCards : Int } -- A number of cards as a single-digit number. This will be enhanced to render specially as a circle with the number in.
      -- Lobby
    | LobbyNameLabel -- A label for a lobby name field.
    | DefaultLobbyName { owner : String } -- The string that is used for the name of a new game by default, given the owner's username.
    | Invite -- A description of the action of inviting players to the game.
    | InviteExplanation { gameCode : String, password : Maybe String } -- An explanation of how players can join the game using the given game code and, potentially, password.
    | InviteLinkHelp -- An explanation that the users can send the link to people to invite them to the game.
    | Cast -- A description of the action of casting a view of the game to another device (e.g: a TV).
    | CastConnecting -- A description of trying to connect to the casting device.
    | CastConnected { deviceName : String } -- A description of being connected to the named casting device.
    | Players -- A short term for a group of users who are playing in the game.
    | PlayersDescription -- A description of a group of users who are playing in the game.
    | Spectators -- A short term for a group of users who are only spectating the game.
    | SpectatorsDescription -- A description of a group of users who are only spectating the game.
    | Left -- A short term for a group of users who have left the game.
    | LeftDescription -- A description of a group of users who have left the game.
    | Away -- A short term for a player who is temporarily away from the game.
    | AwayDescription -- A description for a player who is temporarily away from the game.
    | Disconnected -- A short term for a player who is temporarily disconnected from the game.
    | DisconnectedDescription -- A description of a player who is temporarily disconnected from the game.
    | Privileged -- The short term for a player who has privileges over the game.
    | PrivilegedDescription --  A description of a player who has privileges over the game (e.g: can change settings)
    | Ai -- The short term for a player who is controlled by the computer.
    | AiDescription -- A description of a player who is controlled by the computer.
    | Score { total : Int } -- A display of a score.
    | ScoreDescription -- A description of a player's score.
    | Likes { total : Int } -- A display of a number of likes.
    | LikesDescription -- A description of the number of likes a play received or a player has recieved.
    | ToggleUserList -- A description of the action of showing or hiding the user list.
    | GameMenu -- A description of the game menu.
    | UnknownUser -- A name for a user that doesn't have a known name.
    | InvitePlayers -- A short term for inviting players to the game.
    | InvitePlayersDescription -- A description of what inviting players to the game means.
    | SetAway -- A short term for leaving the game temporarily.
    | SetBack -- A short term for returning to the game after being away.
    | LeaveGame -- A short term for the action of leaving the game permanently.
    | LeaveGameDescription -- A description of what leaving the game means.
    | Spectate -- A short term for spectating the game.
    | SpectateDescription -- A description of the action of spectating the game.
    | BecomeSpectator -- A short term for becoming soley a spectator of the game, rather than an active player.
    | BecomeSpectatorDescription -- A description of becoming soley a spectator of the game, rather than an active player.
    | BecomePlayer -- A short term for becoming an active player of the game, rather than a spectator.
    | BecomePlayerDescription -- A description of becoming an active player of the game, rather than a spectator.
    | EndGame -- A short term for the action of ending the game early.
    | EndGameDescription -- A description of the action of ending the game early.
    | ReturnViewToGame -- A short term for the action of viewing the in-progress game.
    | ReturnViewToGameDescription -- A description of the action of viewing the in-progress game.
    | ViewConfiguration -- A short term for the action of viewing the configuration for the game.
    | ViewConfigurationDescription -- A description of the action of viewing the configuration for the game.
    | KickUser -- A short term for the action of forcing a user to leave the game permanently.
    | Promote -- A short term for the action of allowing a user to edit the game configuration.
    | Demote -- A short term for the action of no longer allowing a user to edit the game configuration.
      -- Notifications
    | UserJoined { username : String } -- A notification that a user has joined the game.
    | UserLeft { username : String } -- A notification that a user has left the game.
    | UserKicked { username : String } -- A notification that a user was kicked from the game.
    | UserConnected { username : String } -- A notification that a user has reconnected to the game.
    | UserDisconnected { username : String } -- A notification that a user has disconnected from the game.
    | Dismiss -- The action of dismissing a notification.
      -- Configure
    | ConfigureTitle -- A title for the game configuration screen.
    | NoDecks -- A description of the situation where the user has no decks added to the game configuration.
    | NoDecksHint -- A hint explaining that the user needs to add at least one deck, and offering the CaH deck.
    | WaitForDecks -- A hint that the user has to wait for decks to load before starting the game.
    | MissingCardType { cardType : Noun } -- An error explaining that the user needs a deck with the given type of card (call/response).
    | NotEnoughCardsOfType { cardType : Noun, needed : Int, have : Int } -- An error explaining that the user needs to add more cards of the given type for the number of players.
    | AddBlankCards { amount : Int } -- A description of the action of adding the given number of blank cards to the game.
    | AddDeck -- A description of the action of adding a deck to the game configuration.
    | RemoveDeck -- A description of the action of removing a deck from the game configuration.
    | SourceNotFound { source : MdString } -- An explanation that the deck didn't load because it doesn't exist on the source service.
    | SourceServiceFailure { source : MdString } -- An explanation that the deck didn't load because the source service is currently failing.
    | ManyDecks -- The name of the Many Decks source.
    | ManyDecksDeckCodeTitle -- A term referring to a deck code for Many Decks.
    | ManyDecksDeckCodeShort -- A description of the problem where a deck code must be at least five characters.
    | ManyDecksWhereToGet -- A description of how to get deck codes from Many Decks.
    | JsonAgainstHumanity -- The name of the JSON Against Humanity source.
    | JsonAgainstHumanityAbout -- A short description of the JSON Against Humanity source.
    | BuiltIn -- A term referring to decks of cards that are provided by this instance of the game.
    | APlayer -- A short description of a generic player in the game in the context of being the author of a card.
    | Generated { by : MdString } -- A short description of a card generated by something during the game.
    | DeckAlreadyAdded -- A description of the problem of the deck already being added to the game configuration.
    | ConfigureDecks -- A name for the section of the configuration screen for changing the decks for the game.
    | ConfigureRules -- A name for the section of the configuration screen for changing the rules for the game.
    | ConfigureTimeLimits -- A name for the section of the configuration screen for changing the time limits for the game.
    | ConfigurePrivacy -- A name for the section of the configuration screen for changing the settings for the game.
    | HandSize -- The name of the rule defining how many cards a player can hold in their hand.
    | HandSizeDescription -- The description of the above rule.
    | ScoreLimit -- The name of the rule defining how many points a player has to accumulate to win the game.
    | ScoreLimitDescription -- The description of the above rule.
    | UnsavedChangesWarning -- A warning to the user that they have unsaved changes to the configuration.
    | SaveChanges -- The action of saving changes to the configuration.
    | RevertChanges -- The action of discarding unsaved changes to the configuration.
    | NeedAtLeastOneDeck -- A description of the problem that the game needs at least one deck to start.
    | NeedAtLeastThreePlayers -- A description of the problem that the game needs at least three players to start.
    | NeedAtLeastOneHuman -- A description of the problem that the game needs at least one human player.
    | RandoCantWrite -- A description of the problem that the AI players can't use blank cards.
    | DisableRando -- A description of disabling the "Rando Cardrissian" house rule.
    | DisableComedyWriter -- A description of disabling the "Comedy Writer" house rule.
    | AddAnAiPlayer -- A description of adding an AI player to the game.
    | PasswordShared -- A warning that game passwords are visible to anyone else in the game.
    | PasswordNotSecured -- A warning that game passwords are not stored securely and should not be used elsewhere.
    | LobbyPassword -- A short label for the lobby password.
    | LobbyPasswordDescription -- A description of a password to stop random people entering your lobby.
    | AudienceMode -- A short label for a setting that means users can only play if a privileged user lets them.
    | AudienceModeDescription -- A description of the setting that means users can only play if a privileged user lets them.
    | StartGame -- A short description of the action of starting the game.
    | Public -- The name of the setting for making the lobby public.
    | PublicDescription -- A description of what the public setting does (makes the game visible in the lobby browser).
    | ApplyConfiguration -- A description of applying a configuration change to the game.
    | AppliedConfiguration -- A description of the fact that a configuration value is applied to the game.
    | InvalidConfiguration -- A description of the fact that a configuration value is invalid and can't be applied.
    | Automatic -- A name of the setting for setting players as away automatically if they don't act in the time limit.
    | AutomaticDescription -- A description of what the automatic setting does (sets players as away automatically if they don't act in the time limit).
    | TimeLimit { stage : MdString } -- A name of the setting for the time limit on a given stage.
    | PlayingTimeLimitDescription -- A description of the setting for the time limit on the playing stage.
    | PlayingAfterDescription -- A description of the setting for the time after the playing stage.
    | RevealingTimeLimitDescription -- A description of the setting for the time limit on the revealing stage.
    | RevealingAfterDescription -- A description of the setting for the time after the revealing stage.
    | JudgingTimeLimitDescription -- A description of the setting for the time limit on the judging stage.
    | CompleteTimeLimitDescription -- A description of the setting for the time limit on the complete stage.
    | RevealingEnabledTitle -- A title for the setting that enabled or disables the revealing stage of the round.
    | RevealingEnabled -- A description of the setting that enabled or disables the revealing stage of the round.
    | DuringTitle -- The name of the time limit that determines how long a user can take during a stage of a round.
    | AfterTitle -- The name of the time after a stage of a round is over to wait before starting the next.
    | Conflict -- A title for a section showing conflicting configuration changes.
    | ConflictDescription -- An explanation of what a conflict is.
    | YourChanges -- A title for a section showing changes tot he configuration by the user.
    | TheirChanges -- A title for a section showing changes to the configuration by someone else.
    | ConfigurationDisabledWhileInGame -- A message explaining that the configuration can't be changed while the game is in-progress.
    | ConfigurationDisabledIfNotPrivileged -- A message explaining that the configuration can't be changed if the user isn't privileged.
    | ConfigureNextGame -- A description of the action of configuring the next game for the lobby after the current one finished.
      -- Game
    | SubmitPlay -- A description of the action of submitting the play for the czar to judge.
    | TakeBackPlay -- A description of the action of taking back a previously submitted play.
    | JudgePlay -- A description of the action of choosing a play to win the round.
    | LikePlay -- A description of the action of liking a play.
    | AdvanceRound -- A description of the action of finishing looking at the winner and advancing to the next round.
    | Playing -- A description of the stage of the round where players are playing responses into the round.
    | Revealing -- A description of the stage of the round where the czar is revealing the plays.
    | Judging -- A description of the stage of the round where the czar is picking a winner.
    | Complete -- A description of the stage of the round where it is finished.
    | ViewGameHistoryAction -- A description of the action of viewing the history of the game.
    | ViewHelpAction -- A description of the action of viewing contextual help on what is happening in the game.
    | EnforceTimeLimitAction -- A description of the action of enforcing the lime limit, skipping players who are slow.
    | Blank -- A term used in speech to denote a blank "slot" on a card the player will give a value to fill.
    | RoundStarted -- A title for the round having started.
    | JudgingStarted -- A title for judging having started.
    | Paused -- A message explaining that the game has been paused due to too few active players.
    | ClientAway -- A message explaining that the player is set to "away" from the game.
    | Discard -- A short description of the act of discarding a card.
    | Discarded { player : String } -- A message explaining that the given player discarded the card being shown.
      -- Instructions
    | PlayInstruction { numberOfCards : Int } -- Instruction to the player on how to play cards.
    | SubmitInstruction -- Instruction to the player on how to submit their play.
    | WaitingForPlaysInstruction -- Instruction to the player that they need to wait for other players to play.
    | CzarsDontPlayInstruction -- Instruction to the player that as Czar they don't play into the round.
    | NotInRoundInstruction -- Instruction to the player that they aren't in the round and so won't make a play.
    | RevealPlaysInstruction -- Instruction to reveal plays for the round.
    | WaitingForCzarInstruction -- Instruction to wait for the czar to reveal plays and pick a winner.
    | AdvanceRoundInstruction -- Instruction that the next round is ready and they can advance.
      -- 404 Unknown
    | UnknownPageTitle -- A title explaining the page the user tried to go to doesn't exist.
    | GoBackHome -- The action to go back to the main page of the application.
      -- Actions
    | Refresh -- The action to refresh the page with newer information.
    | Accept -- A term for accepting something.
      -- Errors
    | Error -- A title for a generic error (something having gone wrong).
    | ErrorHelp -- A message telling the user that an error has occurred and what to do.
    | ErrorHelpTitle -- A title saying something went wrong.
    | ErrorCheckOutOfBand -- A message to check the twitter account for more information on the service's status.
    | TwitterHandle -- A description of the twitter account.
    | ReportError -- The action to report an error with the application to a developer.
    | ReportErrorDescription -- A description of the action of reporting an error to a developer.
    | ReportErrorBody -- An explanation of how to report an error to the developer.
    | BadUrlError -- An error where the server url wasn't valid.
    | TimeoutError -- An error where the server didn't respond for a long time.
    | NetworkError -- An error where the user's internet connection failed.
    | ServerDownError -- An error where the game server wasn't available.
    | BadStatusError -- An error where the server gave a response we didn't expect.
    | BadPayloadError -- An error where the server gave a response we didn't understand.
    | PatchError -- An error where the patch from the server can't be applied.
    | VersionMismatch -- An error where we are out of sync with the config change.
    | CastError -- An error where we the cast device couldn't connect to the game.
    | ActionExecutionError -- A short title for an error where the user can't do the thing they asked to do.
    | IncorrectPlayerRoleError { role : MdString, expected : MdString } -- An error where the player tries to do something when they don't have the right role (czar/player).
    | IncorrectUserRoleError { role : MdString, expected : MdString } -- An error where the user tries to do something when they don't have the right role (player/spectator).
    | IncorrectRoundStageError { stage : MdString, expected : MdString } -- An error where the user tries to do something when it doesn't make sense given the stage of the game.
    | ConfigEditConflictError -- An error where the user tries to make a change to the configuration, but someone else changed it first.
    | UnprivilegedError -- An error where the user doesn't have the privileges to perform the action they are trying to do.
    | GameNotStartedError -- An error where the game hasn't started and the user tries to do something that needs to be done in a game.
    | InvalidActionError { reason : String } -- An error where the client has sent an error the server doesn't accept.
    | AuthenticationError -- A short title for an error where the user can't authenticate.
    | IncorrectIssuerError -- An error where the user tries to authenticate using credentials that are out of date.
    | InvalidAuthenticationError -- An error where the user tries to authenticate using credentials that are corrupted.
    | InvalidLobbyPasswordError -- An error where the user tries to join a game with the wrong lobby password.
    | AlreadyLeftError -- An error where the user tries to join a game they have already left.
    | LobbyNotFoundError -- A short title for an error where the user tries to join a lobby that doesn't exist.
    | LobbyClosedError { gameCode : String } -- An error where the user tries to join a game that has finished.
    | LobbyDoesNotExistError { gameCode : String } -- An error where the user tries to join a game that never existed.
    | RegistrationError -- A short title for an error where the user can't join the game as they asked.
    | UsernameAlreadyInUseError { username : String } -- An error when the user tries to join a game with the same name as a user already in the game.
    | GameError -- A short title for an error where the something has gone wrong in the game.
    | OutOfCardsError -- An error where there weren't enough cards in the deck to deal cards that were needed, even after shuffling discards.
      -- Language Names
    | English -- The name of the English language (no specific dialect).
    | BritishEnglish -- The name of the British dialect of the English language.
    | Italian -- The name of the Italian language.
    | BrazilianPortuguese -- The name of the Brazilian dialect of the Portuguese language.
    | German -- The name of the German formal language (Formal).
    | GermanInformal -- The name of the german informal language (Informal).
    | Polish -- The name of the Polish language.
    | Indonesian -- The name of the Indonesian language.
