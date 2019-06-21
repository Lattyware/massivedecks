import * as card from "../../games/cards/card";
import * as user from "../../user";
import * as round from "../../games/game/round";

/**
 * Indicates a new round has started.
 */
export interface RoundStarted {
  event: "RoundStarted";
  id: string;
  czar: user.Id;
  players: user.Id[];
  call: card.Call;
  drawn?: card.Response[];
}

export const of = (
  id: round.Id,
  czar: user.Id,
  players: user.Id[],
  call: card.Call,
  drawn?: card.Response[]
): RoundStarted => ({
  event: "RoundStarted",
  id: id.toString(),
  czar,
  players,
  call,
  ...(drawn === undefined ? {} : { drawn })
});
