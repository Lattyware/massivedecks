import * as play from "../../games/cards/play";
import { Play } from "../../games/cards/play";

/**
 * Indicates the czar revealed a play for the round.
 */
export interface PlayRevealed {
  event: "PlayRevealed";
  id: play.Id;
  play: Play;
}

export const of = (id: play.Id, play: Play): PlayRevealed => ({
  event: "PlayRevealed",
  id,
  play
});
