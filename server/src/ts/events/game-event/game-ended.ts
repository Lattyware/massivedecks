import type * as User from "../../user.js";

/**
 * Indicated a game has ended.
 */
export interface GameEnded {
  event: "GameEnded";
  winner: string[];
}

export const of = (...winner: User.Id[]): GameEnded => ({
  event: "GameEnded",
  winner: winner.map((w) => w.toString()),
});
