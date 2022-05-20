import type * as Card from "../../games/cards/card.js";
import type * as Round from "../../games/game/round.js";

/**
 * If there was a Starting phase, this is used to advance to the playing phase.
 */
export interface PlayingStarted {
  event: "PlayingStarted";
  id: string;
  call: Card.Call;
  drawn?: Card.Response[];
}

export const of = (
  round: Round.Playing,
  drawn?: Card.Response[],
): PlayingStarted => ({
  event: "PlayingStarted",
  id: round.id.toString(),
  call: round.call,
  ...(drawn === undefined ? {} : { drawn }),
});
