import * as GameRound from "../../games/game/round";
import * as PublicRound from "../../games/game/round/public";
import * as User from "../../user";

/**
 * Indicates players have finished playing into the round and now the czar
 * should judge the winner.
 */
export interface RoundFinished {
  event: "RoundFinished";
  winner: User.Id;
  playDetails: { [id: string]: PublicRound.PlayDetails };
}

export const of = (round: GameRound.Complete): RoundFinished => ({
  event: "RoundFinished",
  winner: round.winner,
  playDetails: round.playDetails(),
});
