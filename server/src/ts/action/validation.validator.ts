/* eslint-disable */
import { default as Ajv } from "ajv";
import { default as addFormats } from "ajv-formats";

import type {
  Action,
  CheckAlive,
  CreateLobby,
  PublicConfig,
  RegisterUser,
} from "./validation.js";

export const ajv = new Ajv({
  allErrors: false,
  coerceTypes: false,
  useDefaults: true,
});
addFormats(ajv, { mode: "full" });

export { RegisterUser, CreateLobby, Action, CheckAlive, PublicConfig };
export const Schema = {
  $schema: "http://json-schema.org/draft-07/schema#",
  definitions: {
    Action: {
      anyOf: [
        {
          $ref: "#/definitions/Authenticate",
        },
        {
          $ref: "#/definitions/SetPresence",
        },
        {
          $ref: "#/definitions/Submit",
        },
        {
          $ref: "#/definitions/TakeBack",
        },
        {
          $ref: "#/definitions/Fill",
        },
        {
          $ref: "#/definitions/Discard",
        },
        {
          $ref: "#/definitions/Judge",
        },
        {
          $ref: "#/definitions/PickCall",
        },
        {
          $ref: "#/definitions/Reveal",
        },
        {
          $ref: "#/definitions/Redraw",
        },
        {
          $ref: "#/definitions/EnforceTimeLimit",
        },
        {
          $ref: "#/definitions/Like",
        },
        {
          $ref: "#/definitions/Configure",
        },
        {
          $ref: "#/definitions/StartGame",
        },
        {
          $ref: "#/definitions/SetPlayerAway",
        },
        {
          $ref: "#/definitions/SetPrivilege",
        },
        {
          $ref: "#/definitions/Kick",
        },
        {
          $ref: "#/definitions/EndGame",
        },
        {
          $ref: "#/definitions/SetUserRole",
        },
        {
          $ref: "#/definitions/Leave",
        },
      ],
    },
    AddOperation: {
      additionalProperties: false,
      description:
        'All diff* functions should return a list of operations, often empty.\n\nEach operation should be an object with two to four fields:\n`op`: the name of the operation; one of "add", "remove", "replace", "move",\n"copy", or "test".\n`path`: a JSON pointer string\n`from`: a JSON pointer string\n`value`: a JSON value\n\nThe different operations have different arguments.\n"add": [`path`, `value`]\n"remove": [`path`]\n"replace": [`path`, `value`]\n"move": [`from`, `path`]\n"copy": [`from`, `path`]\n"test": [`path`, `value`]\n\nCurrently this only really differentiates between Arrays, Objects, and\nEverything Else, which is pretty much just what JSON substantially\ndifferentiates between.',
      properties: {
        op: {
          enum: ["add"],
          type: "string",
        },
        path: {
          type: "string",
        },
        value: {},
      },
      required: ["op", "path", "value"],
      type: "object",
    },
    Array: {
      items: {
        anyOf: [
          {
            $ref: "#/definitions/AddOperation",
          },
          {
            $ref: "#/definitions/RemoveOperation",
          },
          {
            $ref: "#/definitions/ReplaceOperation",
          },
          {
            $ref: "#/definitions/MoveOperation",
          },
          {
            $ref: "#/definitions/CopyOperation",
          },
          {
            $ref: "#/definitions/TestOperation",
          },
        ],
      },
      type: "array",
    },
    Authenticate: {
      additionalProperties: false,
      description: "Authenticate with the game.",
      properties: {
        action: {
          $ref: "#/definitions/NameType",
        },
        token: {
          $ref: "#/definitions/Token",
        },
      },
      required: ["action", "token"],
      type: "object",
    },
    BuiltIn: {
      additionalProperties: false,
      description: "A source for built-in decks..",
      properties: {
        id: {
          type: "string",
        },
        source: {
          enum: ["BuiltIn"],
          type: "string",
        },
      },
      required: ["id", "source"],
      type: "object",
    },
    CheckAlive: {
      additionalProperties: false,
      description: "Previously obtained tokens to check the validity of.",
      properties: {
        tokens: {
          items: {
            type: "string",
          },
          type: "array",
        },
      },
      required: ["tokens"],
      type: "object",
    },
    ComedyWriter: {
      $ref: "#/definitions/ComedyWriter_1",
      description:
        'Configuration for the "Comedy Writer" house rule.\nThis rule adds blank cards that players write as they play them.',
    },
    ComedyWriter_1: {
      additionalProperties: false,
      description:
        'Configuration for the "Comedy Writer" house rule.\nThis rule adds blank cards that players write as they play them.',
      properties: {
        exclusive: {
          description: "If only blank cards will be used.",
          type: "boolean",
        },
        number: {
          description: "The number of blank cards to add.",
          maximum: 99999,
          minimum: 1,
          type: "number",
        },
      },
      required: ["exclusive", "number"],
      type: "object",
    },
    Configure: {
      additionalProperties: false,
      description: "An action to change the configuration of the lobby.",
      properties: {
        action: {
          enum: ["Configure"],
          type: "string",
        },
        change: {
          $ref: "#/definitions/Patch",
          description: "The changes to the config as a JSON patch.",
        },
      },
      required: ["action", "change"],
      type: "object",
    },
    CopyOperation: {
      additionalProperties: false,
      properties: {
        from: {
          type: "string",
        },
        op: {
          enum: ["copy"],
          type: "string",
        },
        path: {
          type: "string",
        },
      },
      required: ["from", "op", "path"],
      type: "object",
    },
    CreateLobby: {
      additionalProperties: false,
      description: "The details needed to create a new lobby.",
      properties: {
        name: {
          description: "The name of the lobby.",
          type: "string",
        },
        owner: {
          $ref: "#/definitions/RegisterUser",
          description: "The registration for the owner of the lobby.",
        },
      },
      required: ["name", "owner"],
      type: "object",
    },
    CzarChoices: {
      $ref: "#/definitions/CzarChoices_1",
      description:
        'Configuration for the "Czar Choices" house rule.\nAt the beginning of the round, the Czar draws multiple calls and chooses one of them.',
    },
    CzarChoices_1: {
      additionalProperties: false,
      description:
        'Configuration for the "Czar Choices" house rule.\nAt the beginning of the round, the Czar draws multiple calls and chooses one of them.',
      properties: {
        custom: {
          description:
            "If set, allows the czar to write a custom call rather than picking one of the choices.\nNote that this takes up one choice, so if `numberOfChoices` is `1`, then the czar *must* write the call.",
          type: "boolean",
        },
        numberOfChoices: {
          description:
            "The number of choices to give the czar to pick between.",
          maximum: 10,
          minimum: 1,
          type: "number",
        },
      },
      required: ["numberOfChoices"],
      type: "object",
    },
    Details: {
      additionalProperties: false,
      description: "More information that can be looked up given a source.",
      properties: {
        author: {
          description: "The name of the author of the deck.",
          type: "string",
        },
        language: {
          description: "The language tag for the language the deck is in.",
          type: "string",
        },
        name: {
          description: "A name for the source.",
          type: "string",
        },
        translator: {
          description: "The name of the translator of the deck.",
          type: "string",
        },
        url: {
          description: "A link to more information about the source.",
          type: "string",
        },
      },
      required: ["name"],
      type: "object",
    },
    Discard: {
      additionalProperties: false,
      description: "Indicates the user is discarding their hand.",
      properties: {
        action: {
          enum: ["Discard"],
          type: "string",
        },
        card: {
          $ref: "#/definitions/Id",
        },
      },
      required: ["action", "card"],
      type: "object",
    },
    EndGame: {
      additionalProperties: false,
      description: "End the current game.",
      properties: {
        action: {
          enum: ["EndGame"],
          type: "string",
        },
      },
      required: ["action"],
      type: "object",
    },
    EnforceTimeLimit: {
      additionalProperties: false,
      description: "A player asks to enforce the soft time limit for the game.",
      properties: {
        action: {
          enum: ["EnforceTimeLimit"],
          type: "string",
        },
        round: {
          type: "string",
        },
        stage: {
          $ref: "#/definitions/Stage",
        },
      },
      required: ["action", "round", "stage"],
      type: "object",
    },
    External: {
      anyOf: [
        {
          $ref: "#/definitions/ManyDecks",
        },
        {
          $ref: "#/definitions/JsonAgainstHumanity",
        },
        {
          $ref: "#/definitions/BuiltIn",
        },
      ],
      description: "An external source for a card or deck.",
    },
    FailReason: {
      description: "The reason a deck could not be loaded.",
      enum: ["NotFound", "SourceFailure"],
      type: "string",
    },
    FailedSource: {
      additionalProperties: false,
      description: "A deck source that has failed to load.",
      properties: {
        failure: {
          $ref: "#/definitions/FailReason",
        },
        source: {
          $ref: "#/definitions/External",
        },
      },
      required: ["failure", "source"],
      type: "object",
    },
    Fill: {
      additionalProperties: false,
      description:
        "Indicates the user has changed the value of a blank card in their hand.",
      properties: {
        action: {
          enum: ["Fill"],
          type: "string",
        },
        card: {
          $ref: "#/definitions/Id",
        },
        text: {
          type: "string",
        },
      },
      required: ["action", "card", "text"],
      type: "object",
    },
    HappyEnding: {
      $ref: "#/definitions/HappyEnding_1",
      description:
        "Configuration for the \"Happy Ending\" house rule.\nWhen the game ends, the final round is a 'Make a Haiku' black card.",
    },
    HappyEnding_1: {
      additionalProperties: false,
      description:
        "Configuration for the \"Happy Ending\" house rule.\nWhen the game ends, the final round is a 'Make a Haiku' black card.",
      properties: {
        inFinalRound: {
          type: "boolean",
        },
      },
      type: "object",
    },
    Id: {
      description: "A unique id for an instance of a card.",
      type: "string",
    },
    Id_1: {
      description: "A unique id for a user.",
      type: "string",
    },
    JsonAgainstHumanity: {
      additionalProperties: false,
      description: "From JSON Against Humanity (https://crhallberg.com/cah/)",
      properties: {
        id: {
          type: "string",
        },
        source: {
          enum: ["JAH"],
          type: "string",
        },
      },
      required: ["id", "source"],
      type: "object",
    },
    Judge: {
      additionalProperties: false,
      description: "A user declares the winning play for a round.",
      properties: {
        action: {
          enum: ["Judge"],
          type: "string",
        },
        winner: {
          $ref: "#/definitions/Id",
        },
      },
      required: ["action", "winner"],
      type: "object",
    },
    Kick: {
      additionalProperties: false,
      description: "A player asks to leave the game.",
      properties: {
        action: {
          enum: ["Kick"],
          type: "string",
        },
        user: {
          $ref: "#/definitions/Id",
        },
      },
      required: ["action", "user"],
      type: "object",
    },
    Leave: {
      additionalProperties: false,
      description: "A player asks to leave the game.",
      properties: {
        action: {
          enum: ["Leave"],
          type: "string",
        },
      },
      required: ["action"],
      type: "object",
    },
    Like: {
      additionalProperties: false,
      description: "A player or spectator likes a play.",
      properties: {
        action: {
          enum: ["Like"],
          type: "string",
        },
        play: {
          $ref: "#/definitions/Id",
        },
      },
      required: ["action", "play"],
      type: "object",
    },
    ManyDecks: {
      additionalProperties: false,
      description: "A source that just tries to load an arbitrary URL.",
      properties: {
        deckCode: {
          type: "string",
        },
        source: {
          enum: ["ManyDecks"],
          type: "string",
        },
      },
      required: ["deckCode", "source"],
      type: "object",
    },
    MoveOperation: {
      additionalProperties: false,
      properties: {
        from: {
          type: "string",
        },
        op: {
          enum: ["move"],
          type: "string",
        },
        path: {
          type: "string",
        },
      },
      required: ["from", "op", "path"],
      type: "object",
    },
    Name: {
      description: "The name the user goes by.",
      maxLength: 100,
      minLength: 1,
      type: "string",
    },
    NameType: {
      enum: ["Authenticate"],
      type: "string",
    },
    NeverHaveIEver: {
      $ref: "#/definitions/NeverHaveIEver_1",
      description:
        'Configuration for the "Never Have I Ever" house rule.\nThis rule allows players to discard cards, but everyone else in the game can see the discarded card.',
    },
    NeverHaveIEver_1: {
      additionalProperties: false,
      description:
        'Configuration for the "Never Have I Ever" house rule.\nThis rule allows players to discard cards, but everyone else in the game can see the discarded card.',
      type: "object",
    },
    PackingHeat: {
      $ref: "#/definitions/PackingHeat_1",
      description: 'Configuration for the "Packing Heat" house rule.',
    },
    PackingHeat_1: {
      additionalProperties: false,
      description: 'Configuration for the "Packing Heat" house rule.',
      type: "object",
    },
    Patch: {
      $ref: "#/definitions/Array",
    },
    PickCall: {
      additionalProperties: false,
      description: "A czar picks a call for a round.",
      properties: {
        action: {
          enum: ["PickCall"],
          type: "string",
        },
        call: {
          $ref: "#/definitions/Id",
        },
        fill: {
          items: {
            items: {
              anyOf: [
                {
                  $ref: "#/definitions/Slot",
                },
                {
                  $ref: "#/definitions/Styled",
                },
                {
                  type: "string",
                },
              ],
            },
            type: "array",
          },
          type: "array",
        },
      },
      required: ["action", "call"],
      type: "object",
    },
    Presence: {
      description:
        "If the player is active in the game or has been marked as away.",
      enum: ["Active", "Away"],
      type: "string",
    },
    Privilege: {
      description: "The level of privilege a user has.",
      enum: ["Privileged", "Unprivileged"],
      type: "string",
    },
    Public: {
      additionalProperties: false,
      properties: {
        handSize: {
          description: "The number of cards in each player's hand.",
          maximum: 50,
          minimum: 3,
          type: "number",
        },
        houseRules: {
          $ref: "#/definitions/Public_1",
        },
        scoreLimit: {
          description:
            "The score threshold for the game - when a player hits this they win.\nIf not set, then there is end - the game goes on infinitely.",
          maximum: 10000,
          minimum: 1,
          type: "number",
        },
        stages: {
          $ref: "#/definitions/Stages",
        },
      },
      required: ["handSize", "houseRules", "stages"],
      type: "object",
    },
    PublicConfig: {
      additionalProperties: false,
      properties: {
        audienceMode: {
          type: "boolean",
        },
        decks: {
          items: {
            anyOf: [
              {
                $ref: "#/definitions/SummarisedSource",
              },
              {
                $ref: "#/definitions/FailedSource",
              },
            ],
          },
          type: "array",
        },
        name: {
          description: "The name of the lobby.",
          maxLength: 100,
          minLength: 1,
          type: "string",
        },
        password: {
          description: "The password for the lobby.",
          maxLength: 100,
          type: "string",
        },
        public: {
          type: "boolean",
        },
        rules: {
          $ref: "#/definitions/Public",
        },
        version: {
          type: "string",
        },
      },
      required: ["decks", "name", "rules", "version"],
      type: "object",
    },
    Public_1: {
      additionalProperties: false,
      description: "The public view of the internal model.",
      properties: {
        comedyWriter: {
          $ref: "#/definitions/ComedyWriter",
        },
        czarChoices: {
          $ref: "#/definitions/CzarChoices",
        },
        happyEnding: {
          $ref: "#/definitions/HappyEnding",
        },
        neverHaveIEver: {
          $ref: "#/definitions/NeverHaveIEver",
        },
        packingHeat: {
          $ref: "#/definitions/PackingHeat",
        },
        rando: {
          $ref: "#/definitions/Public_2",
        },
        reboot: {
          $ref: "#/definitions/Reboot",
        },
        winnersPick: {
          $ref: "#/definitions/WinnersPick",
        },
      },
      type: "object",
    },
    Public_2: {
      $ref: "#/definitions/Public_3",
      description: "The public view of the Rando house rule.",
    },
    Public_3: {
      additionalProperties: false,
      description: "The public view of the Rando house rule.",
      properties: {
        number: {
          description: "The number of AI players to add to the game.",
          maximum: 10,
          minimum: 1,
          type: "number",
        },
      },
      required: ["number"],
      type: "object",
    },
    Reboot: {
      $ref: "#/definitions/Reboot_1",
      description:
        'Configuration for the "Reboot the Universe" house rule.\nThis rule allows players to draw a new hand by sacrificing a given number\nof points.',
    },
    Reboot_1: {
      additionalProperties: false,
      description:
        'Configuration for the "Reboot the Universe" house rule.\nThis rule allows players to draw a new hand by sacrificing a given number\nof points.',
      properties: {
        cost: {
          description: "The cost to redrawing.",
          maximum: 50,
          minimum: 1,
          type: "number",
        },
      },
      required: ["cost"],
      type: "object",
    },
    Redraw: {
      additionalProperties: false,
      description: "A player plays a white card into a round.",
      properties: {
        action: {
          enum: ["Redraw"],
          type: "string",
        },
      },
      required: ["action"],
      type: "object",
    },
    RegisterUser: {
      additionalProperties: false,
      description: "The details to register a new user for a lobby.",
      properties: {
        name: {
          $ref: "#/definitions/Name",
          description: "The name the user wishes to use.",
          maxLength: 100,
          minLength: 1,
          type: "string",
        },
        password: {
          description:
            "The lobby password, if there is one, this must be given and correct.",
          maxLength: 100,
          minLength: 1,
          type: "string",
        },
      },
      required: ["name"],
      type: "object",
    },
    RemoveOperation: {
      additionalProperties: false,
      properties: {
        op: {
          enum: ["remove"],
          type: "string",
        },
        path: {
          type: "string",
        },
      },
      required: ["op", "path"],
      type: "object",
    },
    ReplaceOperation: {
      additionalProperties: false,
      properties: {
        op: {
          enum: ["replace"],
          type: "string",
        },
        path: {
          type: "string",
        },
        value: {},
      },
      required: ["op", "path", "value"],
      type: "object",
    },
    Reveal: {
      additionalProperties: false,
      description: "A user judges the winning play for a round.",
      properties: {
        action: {
          enum: ["Reveal"],
          type: "string",
        },
        play: {
          $ref: "#/definitions/Id",
        },
      },
      required: ["action", "play"],
      type: "object",
    },
    Role: {
      description: "If the user is a spectator or a player.",
      enum: ["Player", "Spectator"],
      type: "string",
    },
    SetPlayerAway: {
      additionalProperties: false,
      description: "A privileged user asks to set a given player as away.",
      properties: {
        action: {
          enum: ["SetPlayerAway"],
          type: "string",
        },
        player: {
          $ref: "#/definitions/Id",
        },
      },
      required: ["action", "player"],
      type: "object",
    },
    SetPresence: {
      additionalProperties: false,
      description: "A player asks to set themself as away.",
      properties: {
        action: {
          enum: ["SetPresence"],
          type: "string",
        },
        presence: {
          $ref: "#/definitions/Presence",
        },
      },
      required: ["action", "presence"],
      type: "object",
    },
    SetPrivilege: {
      additionalProperties: false,
      description:
        "A privileged user asks to change the privilege of another user.",
      properties: {
        action: {
          enum: ["SetPrivilege"],
          type: "string",
        },
        privilege: {
          $ref: "#/definitions/Privilege",
        },
        user: {
          $ref: "#/definitions/Id",
        },
      },
      required: ["action", "privilege", "user"],
      type: "object",
    },
    SetUserRole: {
      additionalProperties: false,
      description: "A player asks to leave the game.",
      properties: {
        action: {
          enum: ["SetUserRole"],
          type: "string",
        },
        id: {
          $ref: "#/definitions/Id_1",
        },
        role: {
          $ref: "#/definitions/Role",
        },
      },
      required: ["action", "role"],
      type: "object",
    },
    Slot: {
      additionalProperties: false,
      description: "An empty slot for responses to be played into.",
      properties: {
        index: {
          type: "number",
        },
        style: {
          $ref: "#/definitions/Style",
        },
        transform: {
          description:
            "Defines a transformation over the content the slot is filled with.",
          enum: ["Capitalize", "UpperCase"],
          type: "string",
        },
      },
      type: "object",
    },
    Stage: {
      enum: ["Complete", "Judging", "Playing", "Revealing", "Starting"],
      type: "string",
    },
    Stage_1: {
      additionalProperties: false,
      description: "Rules specific to a stage of a round.",
      properties: {
        after: {
          $ref: "#/definitions/TimeLimit_1",
          description:
            "The amount of time to wait after the phase is done (for players to see what has happened, change things, etc...).",
        },
        duration: {
          $ref: "#/definitions/TimeLimit",
          description:
            "The amount of time the phase can last before action can be taken.\nIf undefined, then there will be no time limit.",
        },
      },
      required: ["after"],
      type: "object",
    },
    Stage_2: {
      $ref: "#/definitions/Stage_1",
      description: "Rules specific to a stage of a round.",
    },
    Stages: {
      additionalProperties: false,
      description:
        "How the game progresses through rounds and the various stages thereof.",
      properties: {
        judging: {
          $ref: "#/definitions/Stage_1",
          description: "The phase during which the winning play is picked.",
        },
        playing: {
          $ref: "#/definitions/Stage_1",
          description:
            "The phase during which players choose responses to fill slots in the given call.",
        },
        revealing: {
          $ref: "#/definitions/Stage_2",
          description:
            "The phase during which the plays are revealed to everyone.\nIf undefined, then this phase will be skipped.",
        },
        starting: {
          $ref: "#/definitions/TimeLimit",
          description:
            "The phase during which the czar chooses a call (only relevant when the czar choices house rule is active).",
        },
        timeLimitMode: {
          $ref: "#/definitions/TimeLimitMode",
        },
      },
      required: ["judging", "playing", "timeLimitMode"],
      type: "object",
    },
    StartGame: {
      additionalProperties: false,
      description: "Start a game in the lobby if possible.",
      properties: {
        action: {
          enum: ["StartGame"],
          type: "string",
        },
      },
      required: ["action"],
      type: "object",
    },
    Style: {
      enum: ["Em", "Strong"],
      type: "string",
    },
    Styled: {
      additionalProperties: false,
      properties: {
        style: {
          $ref: "#/definitions/Style",
        },
        text: {
          type: "string",
        },
      },
      required: ["text"],
      type: "object",
    },
    Submit: {
      additionalProperties: false,
      description: "A player plays a response into a round.",
      properties: {
        action: {
          enum: ["Submit"],
          type: "string",
        },
        play: {
          items: {
            type: "string",
          },
          type: "array",
        },
      },
      required: ["action", "play"],
      type: "object",
    },
    SummarisedSource: {
      additionalProperties: false,
      description: "A deck source that is loading or has loaded.",
      properties: {
        source: {
          $ref: "#/definitions/External",
        },
        summary: {
          $ref: "#/definitions/Summary",
        },
      },
      required: ["source"],
      type: "object",
    },
    Summary: {
      $ref: "#/definitions/Summary_1",
    },
    Summary_1: {
      additionalProperties: false,
      properties: {
        calls: {
          description: "The number of calls in the deck.",
          type: "number",
        },
        details: {
          $ref: "#/definitions/Details",
          description: "Details about the deck.",
        },
        responses: {
          description: "The number of responses in the deck.",
          type: "number",
        },
        tag: {
          $ref: "#/definitions/Tag",
          description:
            "A tag which should change if the underlying templates change.",
        },
      },
      required: ["calls", "details", "responses"],
      type: "object",
    },
    Tag: {
      description:
        "A tag is used to check if there is a need to refresh the data in the cache.",
      type: "string",
    },
    TakeBack: {
      additionalProperties: false,
      description: "A player plays a white card into a round.",
      properties: {
        action: {
          enum: ["TakeBack"],
          type: "string",
        },
      },
      required: ["action"],
      type: "object",
    },
    TestOperation: {
      additionalProperties: false,
      properties: {
        op: {
          enum: ["test"],
          type: "string",
        },
        path: {
          type: "string",
        },
        value: {},
      },
      required: ["op", "path", "value"],
      type: "object",
    },
    TimeLimit: {
      description: "The amount of time in seconds to limit to.",
      maximum: 900,
      minimum: 0,
      type: "number",
    },
    TimeLimitMode: {
      description:
        'Indicated what happens when duration time limits runs out.\n"Hard": Non-ready players are automatically set to away.\n"Soft": Ready players are given the option to set non-ready players to away.',
      enum: ["Hard", "Soft"],
      type: "string",
    },
    TimeLimit_1: {
      description: "The amount of time in seconds to limit to.",
      maximum: 900,
      minimum: 0,
      type: "number",
    },
    Token: {
      description: "A token that contains the encoded claims of a user.",
      type: "string",
    },
    WinnersPick: {
      $ref: "#/definitions/WinnersPick_1",
      description:
        'Configuration for the "Winner\'s Pick" house rule.\nThis rule makes the winner of each round the czar for the next round.',
    },
    WinnersPick_1: {
      additionalProperties: false,
      description:
        'Configuration for the "Winner\'s Pick" house rule.\nThis rule makes the winner of each round the czar for the next round.',
      type: "object",
    },
  },
};
ajv.addSchema(Schema, "Schema");
export function validate(
  typeName: "RegisterUser",
): (value: unknown) => RegisterUser;
export function validate(
  typeName: "CreateLobby",
): (value: unknown) => CreateLobby;
export function validate(typeName: "Action"): (value: unknown) => Action;
export function validate(
  typeName: "CheckAlive",
): (value: unknown) => CheckAlive;
export function validate(
  typeName: "PublicConfig",
): (value: unknown) => PublicConfig;
export function validate(typeName: string): (value: unknown) => any {
  const validator: any = ajv.getSchema(`Schema#/definitions/${typeName}`);
  return (value: unknown): any => {
    if (!validator) {
      throw new Error(
        `No validator defined for Schema#/definitions/${typeName}`,
      );
    }

    const valid = validator(value);

    if (!valid) {
      throw new Error(
        "Invalid " +
          typeName +
          ": " +
          ajv.errorsText(
            validator.errors!.filter((e: any) => e.keyword !== "if"),
            { dataVar: typeName },
          ),
      );
    }

    return value as any;
  };
}
