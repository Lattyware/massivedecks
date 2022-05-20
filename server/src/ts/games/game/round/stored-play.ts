import type * as User from "../../../user.js";
import type * as Play from "../../cards/play.js";
import type { Round } from "../round.js";

export interface StoredPlay {
  id: Play.Id;
  playedBy: User.Id;
  play: Play.Play;
  revealed: boolean;
  likes: User.Id[];
}

export type Unrevealed = StoredPlay & { revealed: false };
export type Revealed = StoredPlay & { revealed: true };

/**
 * If a stored play is revealed.
 */
const isRevealed = (play: StoredPlay): play is Revealed => play.revealed;

/**
 * Checks if every stored play in a round is revealed or not.
 */
export const allRevealed = <TRound extends Round>(
  round: TRound & { plays: StoredPlay[] },
): round is TRound & {
  plays: Revealed[];
} => round.plays.every(isRevealed);
