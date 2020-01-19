import * as gameRound from "../../games/game/round";
import * as publicRound from "../../games/game/round/public";
import * as user from "../../user";

/**
 * Indicates players have finished playing into the round and now the czar
 * should judge the winner.
 */
export interface RoundFinished {
  event: "RoundFinished";
  winner: user.Id;
  playDetails: { [id: string]: publicRound.PlayDetails };
}

export const of = (round: gameRound.Complete): RoundFinished => ({
  event: "RoundFinished",
  winner: round.winner,
  playDetails: round.playDetails()
});
