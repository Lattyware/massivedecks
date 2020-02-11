import * as User from "../../../user";
import * as Play from "../../cards/play";
import { Round } from "../round";

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
  round: TRound
): round is TRound & { plays: Revealed[] } => round.plays.every(isRevealed);
