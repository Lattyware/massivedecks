import * as Card from "../cards/card.js";

/**
 * Configuration for the "Czar Choices" house rule.
 * At the beginning of the round, the Czar draws multiple calls and chooses one of them.
 */
export interface CzarChoices {
  /**
   * The number of choices to give the czar to pick between.
   * @TJS-type integer
   * @minimum 1
   * @maximum 10
   */
  numberOfChoices: number;

  /**
   * If set, allows the czar to write a custom call rather than picking one of the choices.
   * Note that this takes up one choice, so if `numberOfChoices` is `1`, then the czar *must* write the call.
   */
  custom?: boolean;
}

/**
 * Generate a blank custom call to use.
 */
export const customCall = (): Card.CustomCard<Card.Call> => ({
  id: Card.id(),
  source: { source: "Custom" },
  parts: [[{}]],
});
