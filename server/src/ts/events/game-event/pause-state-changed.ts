/**
 * Events that indicate that the pause state of the game has changed.
 */
export type PauseStateChanged = Paused | Continued;

/**
 * Indicated a game has paused because there are not enough players to continue.
 */
export interface Paused {
  event: "Paused";
}

export const paused: Paused = {
  event: "Paused",
};

/**
 * Indicated a game has continued because there are enough players to do so.
 */
export interface Continued {
  event: "Continued";
}

export const continued: Continued = {
  event: "Continued",
};
