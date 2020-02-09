import * as Play from "../../games/cards/play";
import * as Card from "../../games/cards/card";

/**
 * Indicates players have finished playing into the round and now the czar
 * should reveal the plays.
 */
export interface StartRevealing {
  event: "StartRevealing";
  plays: Play.Id[];
  drawn?: Card.PotentiallyBlankResponse[];
}

export const of = (
  plays: Play.Id[],
  drawn?: Card.PotentiallyBlankResponse[]
): StartRevealing => ({
  event: "StartRevealing",
  plays,
  ...(drawn !== undefined ? { drawn } : {})
});
