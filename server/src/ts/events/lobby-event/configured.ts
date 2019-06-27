import { DecksChanged } from "./configured/decks-changed";
import { HandSizeSet } from "./configured/hand-size-set";
import { HouseRuleChanged } from "./configured/house-rule-changed";
import { PasswordSet } from "./configured/password-set";
import { PublicSet } from "./configured/public-set";
import { ScoreLimitSet } from "./configured/score-limit-set";

/**
 * An event for when connection state for a user changes.
 */
export type Configured =
  | PasswordSet
  | HandSizeSet
  | ScoreLimitSet
  | DecksChanged
  | HouseRuleChanged
  | PublicSet;

export interface Base {
  event: string;
  /**
   * The version the config is at once this change is applied.
   */
  version: string;
}
