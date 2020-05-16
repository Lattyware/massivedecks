import * as Play from "../../games/cards/play";

/**
 * Indicates the czar revealed a play for the round.
 */
export interface PlayRevealed {
  event: "PlayRevealed";
  id: Play.Id;
  play: Play.Play;
}

export const of = (id: Play.Id, play: Play.Play): PlayRevealed => ({
  event: "PlayRevealed",
  id,
  play,
});
