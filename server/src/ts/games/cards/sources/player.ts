import * as source from "../source";

/**
 * A source for custom cards made during the game.
 */
export interface Player {
  source: "Player";
}

/**
 * Get the details for a given source.
 */
export const details = (_: Player): source.Details => ({
  name: "A Player"
});
