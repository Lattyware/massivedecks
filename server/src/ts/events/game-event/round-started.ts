import * as card from "../../games/cards/card";
import { Round } from "../../games/game/round";
import * as user from "../../user";

/**
 * Indicates a new round has started.
 */
export interface RoundStarted {
  event: "RoundStarted";
  id: string;
  czar: user.Id;
  players: user.Id[];
  call: card.Call;
  drawn?: card.PotentiallyBlankResponse[];
}

export const of = (
  round: Round,
  drawn?: card.PotentiallyBlankResponse[]
): RoundStarted => ({
  event: "RoundStarted",
  id: round.id.toString(),
  czar: round.czar,
  players: Array.from(round.players.keys()),
  call: round.call,
  ...(drawn === undefined ? {} : { drawn })
});
