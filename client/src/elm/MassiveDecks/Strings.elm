module MassiveDecks.Strings exposing (MdString(..))

{-| This module deals with text that is shown to the user in the application - strings.
-}

import MassiveDecks.Pages.Lobby.GameCode as GameCode exposing (GameCode)



{- Translator notes

    This file contains a list of every string in the game, along with a description to help translators.
    Please reference it while translating.

   Adding to the game:

       The first note is that adding the translation to the game itself is somewhat technical, if you struggle with it,
       please feel free to make a bug and get a developer to help you - you can do the translation itself more simply
       and a developer can do the work of adding the translation, and skip this section.

      The best way to get started is to copy the "Languages/En.elm" translation. Add the language to the lists in both
      "Languages/Model.elm" and "Languages.elm" (at the top and at the bottom in "pick").

       e.g: Adding English (Great Britain). The IETF language tag for this is en-GB, so we'll use EnGB as the name.

       In "Languages/Model.elm":
           type Language
               = En
               ...
               | EnGB -- Add this line.

       In "Languages.elm":
           languages : List Language
           languages =
               [ En
               ...
               , EnGB -- Add this line.
               ]

           ...

           pack : Language -> Translation.Pack
           pack language =
               case language of
                   En ->
                       EnLang.pack

                   ...

                   EnGB -> -- Add this line.
                       EnGBLang.pack -- Add this line.

       This should result in a new language that works exactly as English does. You can now start changing the metadata.

       In "Languages/EnGB.elm" (replacing EnGB with your language):
           pack : Translation.Pack
           pack =
               { code = "en-GB" -- Change this to the IETF language tag for the language.
               , name = English
               , translate = translate
               }

       You will notice that we also need a string describing the language. You can do this in this file.

       In this file:
           -- Language Names
           | English -- The name of the English language (no specific dialect).
           ...
           | BritishEnglish -- Add this line.

       Note that once you do this, you'll need to add a translation for this to every other language as well.

       In "Languages/EnGB.elm" (replacing EnGB with your language):
          pack : Translation.Pack
          pack =
               { code = "en-GB"
               , name = BritishEnglish -- Change this to your new string.
               , translate = translate
               }

       You can now start changing the actual strings. These are created either from raw text or references to other
       strings:
           MassiveDecks ->
               [ Text "Massive Decks" ]

           WhatIsThis ->
               [ Text "What is ", Ref MassiveDecks, Text "?" ]

       This will render was "What is Massive Decks?", but if you changed "MassiveDecks" to "Test", it would result in
       "What is Test?". This allows you to avoid translating the same thing many times and allows the text to be
       enhanced with things like links automatically.

       In general, you should be able to just translate the raw text in quotes and shuffle things around. The more
       complex parts should pretty much remain as-is.

       Note that some strings take arguments:
          UserConnected { username } ->
               [ Text username, Text " has reconnected to the game." ]

       Note that some arguments are numbers, and these have to be converted to strings:
           Score { total } ->
               [ Text (String.fromInt total) ]

       Note this is code, rather than configuration, so complex operations can be performed. "Plural" is an example
       of this, as is "asWord". If you are not a programmer, these may be awkward - please feel free to explain the
       behaviour you need in a bug to get a developer to help out for awkward cases like different grammar rules for
       plurals, etc...

   Terminology:

       Note the difference between "Players" and "Users". Players play the game, users includes both players and
       spectators, and is the more general term.

       A play code is a Cardcast-specific thing that specifies a deck on their platform, and is not the same thing
       as a game code, which allows a user to join a game in Massive Decks.

   Other Notes:

       Please use unicode characters as appropriate. E.g: the em-dash (—) (which is particularly awkward to notice
       in monospaced fonts, real quotes (“”), apostrophes (’) and ellipsis (…).

       Likewise, unicode offers us valuable hinting tools to control hyphenation and line breaking:
            A unicode soft hyphen (\u{00AD}) indicated a good point in a word to break it if needed.
            A unicode zero-width space (\u{200B}) can do the same thing without a hyphen (hyphens should be preferred,
            however, ).
            For the reverse (no line breaking between words), use a unicode non-breaking space (\u{00A0}).

-}


{-| Each type represents a message that may be shown to the user. Some have arguments that are variable but should be
included in some form in the message.
-}
type MdString
    = MassiveDecks -- The name of the game.
    | Close -- Close a dialog window.
      -- Special
      {- Plural only makes sense for nouns, other results will be nonsense. If the amount is not given, it's an unknown
         quantity. If the value is `1`, then it should be singular.
      -}
    | Plural { singular : MdString, amount : Maybe Int } -- The plural version of the given string.
      -- Start screen.
    | Version { versionNumber : String } -- The version of the game being played.
    | ShortGameDescription -- A one-line description of the game.
    | WhatIsThis -- A title for a section describing the game.
    | GameDescription -- A long description of the game.
    | NewGame -- The action of creating a new game. (Short, ideally one word).
    | FindPublicGame -- The action of finding a public game to join. (Short, ideally one word).
    | JoinPrivateGame -- The action of joining a private game the user was invited to. (Short, ideally one word).
    | PlayGame -- The action of joining a game to play it. (Short, ideally one word).
    | AboutTheGame -- The action of finding out more information about the game. (Short, ideally one word).
    | MDLogoDescription -- A description of the Massive Decks logo (e.g: for blind users).
    | RereadLogoDescription -- A description of the Reread Games logo (e.g: for blind users).
    | MDProject -- A description of the action of visiting the development project for Massive Decks.
    | License -- A description of the license the game is made available under.
    | DevelopedByReread -- A description of the fact that the game was developed by Reread.
    | RereadGames -- The name of "Reread Games" (https://www.rereadgames.com/).
    | NameLabel -- A label for a user name text field.
    | NameInUse -- An error indicating the name the user asked for is already in use and they should try another.
    | RejoinTitle -- A title for a list of games the user was previously in and might be able to rejoin.
    | RejoinGame { code : GameCode } -- A description of the action of attempting to rejoin a game the user was previously in.
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
    | HouseRuleRebootCost -- A description of the cost of redrawing your hand.
    | HouseRuleRebootCostDescription --
    | HouseRulePackingHeat -- The name of the "Packing Heat" house rule.
    | HouseRulePackingHeatDescription -- A description of the "Packing Heat" house rule.
      -- Note that the below name is a pun on the Star Wars character "Lando Calrissian" and the words "Random" and
      -- "Card". It may be better to be more literal, or make an alternative reference. This is essentially adding
      -- a computer player that just plays a random card.
    | HouseRuleRandoCardrissian -- The name of the "Rando Cardrissian" house rule.
    | HouseRuleRandoCardrissianDescription -- A description of the "Rando Cardrissian" house rule.
    | HouseRuleRandoCardrissianNumber -- A name of the setting for the number of bots added to the game.
    | HouseRuleRandoCardrissianNumberDescription -- A description of the setting for the number of bots added to the game.
      -- Settings
    | SettingsTitle -- The title for the settings panel.
    | LanguageSetting -- The label for the "Language" setting.
    | MissingLanguage -- A question asking if the user doesn't see the language they want.
    | TranslationBeg -- A request for help translating the game.
    | CompactCardsSetting -- The label for the "Compact Cards" setting.
    | CompactCardsExplanation -- An explanation of what compact cards does (makes cards square).
    | SpeechSetting -- The label for the speech setting.
    | SpeechExplanation -- An explanation of what the speech setting does (enables TTS on cards).
    | NotificationsSetting -- The label for the notifications setting.
    | NotificationsExplanation -- An explanation of what the notifications setting does (enables browser notifications).
    | NotificationsBrowserPermissions -- An explanation that the user will need to give the game permission for notifications.
      -- Terms
    | Czar -- The name for the "Card Czar" (the player that judges the round).
    | CzarDescription -- A short description of what the czar does.
    | Call -- The name for a call card (a black card).
    | CallDescription -- A short description of what a call is.
    | Response -- The name for a response card (a white card).
    | ResponseDescription -- A short description of what a response is.
    | Point -- The name for a point in the game.
    | PointDescription -- A short description of what a point is.
    | GameCodeTerm -- The term for a unique code for a game that allows a user to find the game easily.
    | GameCodeDescription -- A short description of what a game code is.
    | GameCode { code : GameCode } -- Render a game code.
    | GameCodeSpecificDescription -- A short description of what a specific game code and how to use it.
    | GameCodeHowToAcquire -- A short description of how to get a game code.
    | Deck -- The name for a deck of cards.
    | Playing -- A term for a person who is in a round, but has not yet submitted a play.
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
      -- Cards
    | Pick { numberOfCards : Int } -- The word describing the action of picking a card from their hand to play. Use NumberOfCards for the number.
    | Draw { numberOfCards : Int } -- The word describing the action of drawing a card from the deck to their hand. Use NumberOfCards for the number.
    | PickDescription { numberOfCards : Int } -- A description of game rules where the user must pick a given number of cards.
    | DrawDescription { numberOfCards : Int } -- A description of game rules where the user gets to draw more cards.
    | NumberOfCards { numberOfCards : Int } -- A number of cards as a single-digit number. This will be enhanced to render specially as a circle with the number in.
      -- Lobby
    | Invite -- A description of the action of inviting players to the game.
    | InviteExplanation { gameCode : GameCode, password : Maybe String } -- An explanation of how players can join the game using the given game code and, potentially, password.
    | InviteLinkHelp -- An explanation that the users can send the link to people to invite them to the game.
    | Cast -- A description of the action of casting a view of the game to another device (e.g: a TV).
    | CastConnecting -- A description of trying to connect to the casting device.
    | CastConnected { deviceName : String } -- A description of being connected to the named casting device.
    | Players -- A short term for a group of users who are playing in the game.
    | PlayersDescription -- A description of a group of users who are playing in the game.
    | Spectators -- A short term for a group of users who are only spectating the game.
    | SpectatorsDescription -- A description of a group of users who are only spectating the game.
    | Privileged -- The short term for a player who has privileges over the game.
    | PrivilegedDescription --  A description of a player who has privileges over the game (e.g: can change settings)
    | Ai -- The short term for a player who is controlled by the computer.
    | AiDescription -- A description of a player who is controlled by the computer.
    | Score { total : Int } -- A display of a score.
    | ScoreDescription -- A description of a player's score.
    | ToggleUserList -- A description of the action of showing or hiding the user list.
    | GameMenu -- A description of the game menu.
    | UnknownUser -- A name for a user that doesn't have a known name.
    | InvitePlayers -- A short term for inviting players to the game.
    | SetAway -- A short term for leaving the game temporarily.
    | LeaveGame -- A short term for the action of leaving the game permanently.
    | KickUser -- A short term for the action of forcing a user to leave the game permanently.
    | Promote -- A short term for the action of allowing a user to edit the game configuration.
      -- Notifications
    | UserJoined { username : String } -- A notification that a user has joined the game.
    | UserLeft { username : String } -- A notification that a user has left the game.
    | UserConnected { username : String } -- A notification that a user has reconnected to the game.
    | UserDisconnected { username : String } -- A notification that a user has disconnected from the game.
    | Dismiss -- The action of dismissing a notification.
      -- Configure
    | ConfigureTitle -- A title for the game configuration screen.
    | NoDecks -- A description of the situation where the user has no decks added to the game configuration.
    | NoDecksHint -- A hint explaining that the user needs to add at least one deck, and offering the CaH deck.
    | WaitForDecks -- A hint that the user has to wait for decks to load before starting the game.
    | MissingCardType { cardType : MdString } -- An error explaining that the user needs a deck with the given type of card (call/response).
    | AddDeck -- A description of the action of adding a deck to the game configuration.
    | RemoveDeck -- A description of the action of removing a deck from the game configuration.
    | CardcastPlayCode -- A term referring to the play code that identifies a deck on Cardcast.
    | CardcastEmptyPlayCode -- A description of the problem of the entered Cardcast play code being empty.
    | DeckAlreadyAdded -- A description of the problem of the deck already being added to the game configuration.
    | ConfigureDecks -- A name for the section of the configuration screen for changing the decks for the game.
    | ConfigureRules -- A name for the section of the configuration screen for changing the rules for the game.
    | ConfigureGame -- A name for the section of the configuration screen for changing the settings for the game.
    | HandSize -- The name of the rule defining how many cards a player can hold in their hand.
    | HandSizeDescription -- The description of the above rule.
    | ScoreLimit -- The name of the rule defining how many points a player has to accumulate to win the game.
    | ScoreLimitDescription -- The description of the above rule.
    | NeedAtLeastOneDeck -- A description of the problem that the game needs at least one deck to start.
    | NeedAtLeastThreePlayers -- A description of the problem that the game needs at least three players to start.
    | PasswordNotSecured -- A warning that game passwords are not stored securely and should not be used elsewhere.
    | GamePassword -- A short label for the game password.
    | GamePasswordDescription -- A description of a password to stop random people entering your game.
    | StartGame -- A short description of the action of starting the game.
      -- Game
    | SubmitPlay -- A description of the action of submitting the play for the czar to judge.
    | TakeBackPlay -- A description of the action of taking back a previously submitted play.
    | JudgePlay -- A description of the action of choosing a play to win the round.
    | LikePlay -- A description of the action of liking a play.
      -- Instructions
    | PlayInstruction { numberOfCards : Int } -- Instruction to the player on how to play cards.
    | SubmitInstruction -- Instruction to the player on how to submit their play.
    | WaitingForPlaysInstruction -- Instruction to the player that they need to wait for other players to play.
    | CzarsDontPlayInstruction -- Instruction to the player that as Czar they don't play into the round.
    | RevealPlaysInstruction -- Instruction to reveal plays for the round.
    | WaitingForCzarInstruction -- Instruction to wait for the czar to reveal plays and pick a winner.
      -- 404 Unknown
    | UnknownPageTitle -- A title explaining the page the user tried to go to doesn't exist.
    | GoBackHome -- The action to go back to the main page of the application.
      -- Actions
    | Refresh -- The action to refresh the page with newer information.
      -- Errors
    | Error -- A title for a generic error (something having gone wrong).
    | ErrorHelp -- A message telling the user that an error has occurred and what to do.
    | ErrorHelpTitle -- A title saying something went wrong.
    | ReportError -- The action to report an error with the application to a developer.
    | ReportErrorBody -- An explanation of how to report an error to the developer.
    | BadUrlError -- An error where the server url wasn't valid.
    | TimeoutError -- An error where the server didn't respond for a long time.
    | NetworkError -- An error where the user's internet connection failed.
    | ServerDownError -- An error where the game server wasn't available.
    | BadStatusError -- An error where the server gave a response we didn't expect.
    | BadPayloadError -- An error where the server gave a response we didn't understand.
    | CastError -- An error where we the cast device couldn't connect to the game.
      -- Language Names
    | English -- The name of the English language (no specific dialect).
    | BritishEnglish -- The name of the British dialect of the English language.
