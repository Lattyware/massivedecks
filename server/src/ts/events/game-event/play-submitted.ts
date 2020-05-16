import * as User from "../../user";

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
