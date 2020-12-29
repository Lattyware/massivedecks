import * as Card from "../../games/cards/card";
import * as Round from "../../games/game/round";
import * as User from "../../user";

export interface Base {
  event: "RoundStarted";
  id: string;
  czar: User.Id;
  players: User.Id[];
  drawn?: Card.Response[];
}

export type Call = { calls?: Card.Call[] } | { call: Card.Call };

/**
 * Indicates a new round has started.
 */
export type RoundStarted = Base & Call;

export const of = (
  round: Round.Round,
  drawn?: Card.Response[]
): RoundStarted => ({
  event: "RoundStarted",
  id: round.id.toString(),
  czar: round.czar,
  players: Array.from(round.players.keys()),
  ...(drawn === undefined ? {} : { drawn }),
});
