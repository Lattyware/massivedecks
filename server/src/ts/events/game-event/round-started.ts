import * as Card from "../../games/cards/card";
import { Round } from "../../games/game/round";
import * as User from "../../user";

/**
 * Indicates a new round has started.
 */
export interface RoundStarted {
  event: "RoundStarted";
  id: string;
  czar: User.Id;
  players: User.Id[];
  call: Card.Call;
  drawn?: Card.Response[];
}

export const of = (round: Round, drawn?: Card.Response[]): RoundStarted => ({
  event: "RoundStarted",
  id: round.id.toString(),
  czar: round.czar,
  players: Array.from(round.players.keys()),
  call: round.call,
  ...(drawn === undefined ? {} : { drawn }),
});
