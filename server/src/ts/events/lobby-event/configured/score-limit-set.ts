import * as configured from "../configured";

/**
 * The score limit in the rules for the lobby is (un)set.
 */
export interface ScoreLimitSet extends configured.Base {
  event: "ScoreLimitSet";
  scoreLimit?: number;
}
