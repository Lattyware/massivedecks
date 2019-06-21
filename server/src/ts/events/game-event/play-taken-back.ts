import * as user from "../../user";

/**
 * Indicates a player has taken back their play for the round.
 */
export interface PlayTakenBack {
  event: "PlayTakenBack";
  by: user.Id;
}

export const of = (by: user.Id): PlayTakenBack => ({
  event: "PlayTakenBack",
  by
});
