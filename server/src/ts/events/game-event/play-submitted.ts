import type * as User from "../../user.js";

/**
 * Indicates a player has submitted a play for the round.
 */
export interface PlaySubmitted {
  event: "PlaySubmitted";
  by: User.Id;
}

export const of = (by: User.Id): PlaySubmitted => ({
  event: "PlaySubmitted",
  by,
});
