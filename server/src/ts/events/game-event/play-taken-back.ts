import * as User from "../../user";

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
