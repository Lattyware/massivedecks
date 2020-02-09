import * as Source from "../source";

/**
 * A source for custom cards made during the game.
 */
export interface Player {
  source: "Player";
}

/**
 * Get the details for a given source.
 */
export const details = (_: Player): Source.Details => ({
  name: "A Player"
});
