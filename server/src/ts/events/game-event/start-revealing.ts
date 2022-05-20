import type * as Card from "../../games/cards/card.js";
import type * as Play from "../../games/cards/play.js";

/**
 * Indicates players have finished playing into the round and now the czar
 * should reveal the plays.
 */
export interface StartRevealing extends AfterPlaying {
  event: "StartRevealing";
  plays: Play.Id[];
}

/**
 * Details in an event after finishing playing.
 */
export interface AfterPlaying {
  /**
   * The id of the play the user receiving this event played, if they did play one.
   */
  played?: Play.Id;
  /**
   * The cards drawn by the player receiving this event.
   */
  drawn?: Card.Response[];
}

export const of = (
  plays: Play.Id[],
  played?: Play.Id,
  drawn?: Card.Response[],
): StartRevealing => ({
  event: "StartRevealing",
  plays,
  played,
  drawn,
});
