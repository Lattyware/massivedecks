import * as user from "../../../user";
import * as play from "../../cards/play";
import { Play } from "../../cards/play";
import { Round } from "../round";

export interface StoredPlay {
  id: play.Id;
  playedBy: user.Id;
  play: Play;
  revealed: boolean;
  likes: Set<user.Id>;
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
  round: TRound
): round is TRound & { plays: Revealed[] } => round.plays.every(isRevealed);
