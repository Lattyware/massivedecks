import * as Card from "../../games/cards/card";
import * as Round from "../../games/game/round";
import * as PublicRound from "../../games/game/round/public";

/**
 * Indicated a game has started in the lobby.
 */
export interface GameStarted {
  event: "GameStarted";
  round: PublicRound.Playing;
  hand?: Card.PotentiallyBlankResponse[];
}

export const of = (
  startedRound: Round.Playing,
  hand?: Card.PotentiallyBlankResponse[]
): GameStarted => ({
  event: "GameStarted",
  round: startedRound.public(),
  ...(hand !== undefined ? { hand } : {})
});
