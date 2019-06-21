import * as user from "../../user";

/**
 * Indicates a player has submitted a play for the round.
 */
export interface PlaySubmitted {
  event: "PlaySubmitted";
  by: user.Id;
}

export const of = (by: user.Id): PlaySubmitted => ({
  event: "PlaySubmitted",
  by
});
