import * as user from "../../user";

/**
 * Indicated a game has ended.
 */
export interface GameEnded {
  event: "GameEnded";
  winner: string[];
}

export const of = (...winner: user.Id[]): GameEnded => ({
  event: "GameEnded",
  winner: winner.map(w => w.toString())
});
