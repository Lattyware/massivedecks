import * as source from "../source";

/**
 * A source for custom cards made during the game.
 */
export interface Custom {
  source: "Custom";
}

/**
 * Get the details for a given source.
 */
export const details = (_: Custom): source.Details => ({
  name: "Custom"
});
