import * as Play from "../../games/cards/play";
import * as Card from "../../games/cards/card";

/**
 * Indicates players have finished playing into the round and now the czar
 * should reveal the plays.
 */
export interface StartRevealing {
  event: "StartRevealing";
  plays: Play.Id[];
  drawn?: Card.Response[];
}

export const of = (
  plays: Play.Id[],
  drawn?: Card.Response[]
): StartRevealing => ({
  event: "StartRevealing",
  plays,
  ...(drawn !== undefined ? { drawn } : {}),
});
