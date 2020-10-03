import * as Source from "../source";

/**
 * A source for cards generated during the game for reasons such as house rules.
 */
export interface Generated {
  source: "Generated";
}

/**
 * Get the details for a given source.
 */
export const details = (_: Generated): Source.Details => ({
  name: "Generated",
});
