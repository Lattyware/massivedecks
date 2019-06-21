import * as play from "../../games/cards/play";

/**
 * Indicates players have finished playing into the round and now the czar
 * should reveal the plays.
 */
export interface StartRevealing {
  event: "StartRevealing";
  plays: play.Id[];
}

export const of = (plays: play.Id[]): StartRevealing => ({
  event: "StartRevealing",
  plays
});
