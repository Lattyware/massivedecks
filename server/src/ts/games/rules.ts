import * as HouseRules from "./rules/houseRules";
import * as Rando from "./rules/rando";
import * as HappyEnding from "./rules/happyEnding";

/** The rules for a standard game.
 */
export interface Rules {
  handSize: number;
  scoreLimit?: number;
  houseRules: HouseRules.HouseRules;
  stages: Stages;
}

export interface Public {
  /**
   * The number of cards in each player's hand.
   * @TJS-type integer
   * @minimum 3
   * @maximum 50
   */
  handSize: number;
  /**
   * The score threshold for the game - when a player hits this they win.
   * If not set, then there is end - the game goes on infinitely.
   * @TJS-type integer, undefined
   * @minimum 1
   * @maximum 10000
   */
  scoreLimit?: number;
  houseRules: HouseRules.Public;
  stages: Stages;
}

/**
 * Indicated what happens when duration time limits runs out.
 * "Hard": Non-ready players are automatically set to away.
 * "Soft": Ready players are given the option to set non-ready players to away.
 */
export type TimeLimitMode = "Hard" | "Soft";

/**
 * The amount of time in seconds to limit to.
 * @TJS-type integer
 * @minimum 0
 * @maximum 900
 */
export type TimeLimit = number;

/**
 * Rules specific to a stage of a round.
 */
export interface Stage {
  /**
   * The amount of time the phase can last before action can be taken.
   * If undefined, then there will be no time limit.
   */
  duration?: TimeLimit;
  /**
   * The amount of time to wait after the phase is done (for players to see what has happened, change things, etc...).
   */
  after: TimeLimit;
}

/**
 * How the game progresses through rounds and the various stages thereof.
 */
export interface Stages {
  timeLimitMode: TimeLimitMode;

  /**
   * The phase during which players choose responses to fill slots in the given call.
   */
  playing: Stage;

  /**
   * The phase during which the plays are revealed to everyone.
   * If undefined, then this phase will be skipped.
   */
  revealing?: Stage;

  /**
   * The phase during which the winning play is picked.
   */
  judging: Stage;
}

/**
 * Configuration for the "Packing Heat" house rule.
 */
export interface PackingHeat {}

/**
 * Configuration for the "Reboot the Universe" house rule.
 * This rule allows players to draw a new hand by sacrificing a given number
 * of points.
 */
export interface Reboot {
  /**
   * The cost to redrawing.
   * @TJS-type integer
   * @minimum 1
   * @maximum 50
   */
  cost: number;
}

/**
 * Configuration for the "Comedy Writer" house rule.
 * This rule adds blank cards that players write as they play them.
 */
export interface ComedyWriter {
  /**
   * The number of blank cards to add.
   * @TJS-type integer
   * @minimum 1
   * @maximum 99999
   */
  number: number;
  /**
   * If only blank cards will be used.
   */
  exclusive: boolean;
}

/**
 * Configuration for the "Never Have I Ever" house rule.
 * This rule allows players to discard cards, but everyone else in the game can see the discarded card.
 */
export interface NeverHaveIEver {}

export const censor = (rules: Rules): Public => ({
  ...rules,
  houseRules: HouseRules.censor(rules.houseRules),
});

/**
 * Create rules from some defaults.
 * Importantly this doesn't correctly set up the rando house rule, use Rando.create after-the-fact.
 */
export const fromDefaults = (rules: Public): Rules => ({
  ...rules,
  houseRules: {
    ...rules.houseRules,
    rando: Rando.empty(),
  },
});
