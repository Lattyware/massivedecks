/** The rules for a standard game.*/
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
  houseRules: HouseRules;
}

export interface Public {
  handSize: number;
  scoreLimit?: number;
  houseRules: HouseRules;
}

export interface HouseRules {
  packingHeat?: PackingHeat;
  reboot?: Reboot;
  rando?: Rando;
}

/**
 * Create a default set of rules.
 */
export const create = (): Rules => ({
  handSize: 10,
  scoreLimit: 25,
  houseRules: {}
});

/**
 * Configuration for the "Packing Heat" house rule.
 */
// eslint-disable-next-line @typescript-eslint/no-empty-interface
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

export interface Rando {
  /**
   * The number of AI players to add to the game.
   * @TJS-type integer
   * @minimum 1
   * @maximum 10
   */
  number: number;
}

export const censor = (rules: Rules): Public => ({
  ...rules
});

export interface ChangeBase<Name extends string, HouseRule> {
  houseRule: Name;
  settings?: HouseRule;
}

export type ChangePackingHeat = ChangeBase<"PackingHeat", PackingHeat>;
export type ChangeRando = ChangeBase<"Rando", Rando>;
export type ChangeReboot = ChangeBase<"Reboot", Reboot>;

export type Change = ChangePackingHeat | ChangeRando | ChangeReboot;
