import * as HouseRules from "./rules/houseRules";

/** The rules for a standard game.
 */
export interface Rules {
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
  houseRules: HouseRules.HouseRules;
  timeLimits: RoundTimeLimits;
}

export interface Public {
  handSize: number;
  scoreLimit?: number;
  houseRules: HouseRules.Public;
  timeLimits: RoundTimeLimits;
}

/**
 * Indicated what happens when the time limit runs out.
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
 * The time limits for the stages of a round.
 */
export interface RoundTimeLimits {
  mode: TimeLimitMode;
  /**
   * The time limit for players to make their play.
   */
  playing?: TimeLimit;
  /**
   * The time limit for the judge  to reveal the plays.
   */
  revealing?: TimeLimit;
  /**
   * The time limit for the judge to pick a winner.
   */
  judging?: TimeLimit;
  /**
   * The amount of time in seconds after one round completes the next one
   * starts.
   */
  complete: TimeLimit;
}

export const defaultTimeLimits = (): RoundTimeLimits => ({
  mode: "Soft",
  playing: 60,
  revealing: 30,
  judging: 30,
  complete: 2
});

/**
 * Create a default set of rules.
 */
export const create = (): Rules => ({
  handSize: 10,
  scoreLimit: 25,
  houseRules: HouseRules.create(),
  timeLimits: defaultTimeLimits()
});

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

export const censor = (rules: Rules): Public => ({
  ...rules,
  houseRules: HouseRules.censor(rules.houseRules)
});
