import type * as User from "../../user.js";

/**
 * Indicates a player has taken back their play for the round.
 */
export interface PlayTakenBack {
  event: "PlayTakenBack";
  by: User.Id;
}

export const of = (by: User.Id): PlayTakenBack => ({
  event: "PlayTakenBack",
  by,
});
