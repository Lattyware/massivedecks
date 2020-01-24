import * as play from "../../games/cards/play";
import * as card from "../../games/cards/card";

/**
 * Indicates players have finished playing into the round and now the czar
 * should reveal the plays.
 */
export interface StartRevealing {
  event: "StartRevealing";
  plays: play.Id[];
  drawn?: card.PotentiallyBlankResponse[];
}

export const of = (
  plays: play.Id[],
  drawn?: card.PotentiallyBlankResponse[]
): StartRevealing => ({
  event: "StartRevealing",
  plays,
  ...(drawn !== undefined ? { drawn } : {})
});
