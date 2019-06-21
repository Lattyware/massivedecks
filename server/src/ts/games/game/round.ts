import { Action } from "../../action";
import { IncorrectRoundStageError } from "../../errors/action-execution-error";
import * as user from "../../user";
import * as card from "../cards/card";
import * as play from "../cards/play";
import { Play } from "../cards/play";
import * as publicRound from "./round/public";
import { Public as PublicRound } from "./round/public";

export type Round = Playing | Revealing | Judging | Complete;

export type Stage = "Playing" | "Revealing" | "Judging" | "Complete";

export type Id = number;

interface Base {
  stage: Stage;
  id: Id;
  czar: user.Id;
  players: Set<user.Id>;
  call: card.Call;
  plays: StoredPlay[];
}

export interface Playing extends Base {
  stage: "Playing";
}

export interface Revealing extends Base {
  stage: "Revealing";
  plays: StoredPlay[];
}

export interface Judging extends Base {
  stage: "Judging";
  plays: RevealedStoredPlay[];
}

export interface Complete extends Base {
  stage: "Complete";
  plays: RevealedStoredPlay[];
  winner: user.Id;
}

export interface StoredPlay {
  id: play.Id;
  playedBy: user.Id;
  play: Play;
  revealed: boolean;
}

export type RevealedStoredPlay = StoredPlay & { revealed: true };

function* potentiallyRevealedPlays(
  round: Revealing
): Iterable<play.PotentiallyRevealed> {
  for (const roundPlay of round.plays) {
    const potentiallyRevealed: play.PotentiallyRevealed = { id: roundPlay.id };
    if (roundPlay.revealed) {
      potentiallyRevealed.play = roundPlay.play;
    }
    yield potentiallyRevealed;
  }
}

function* revealedPlays(round: Judging): Iterable<play.Revealed> {
  for (const roundPlay of round.plays) {
    yield { id: roundPlay.id, play: roundPlay.play };
  }
}

export function playedBy(round: Complete): { [player: string]: user.Id } {
  const obj: { [player: string]: user.Id } = {};
  for (const roundPlay of round.plays) {
    obj[roundPlay.id] = roundPlay.playedBy;
  }
  return obj;
}

export function playsObj(round: Complete): { [player: string]: Play } {
  const obj: { [player: string]: Play } = {};
  for (const roundPlay of round.plays) {
    obj[roundPlay.playedBy] = roundPlay.play;
  }
  return obj;
}

export function censor(round: Playing): publicRound.Playing;
export function censor(round: Revealing): publicRound.Revealing;
export function censor(round: Judging): publicRound.Judging;
export function censor(round: Complete): publicRound.Complete;
export function censor(round: Round): PublicRound;
export function censor(round: Round): PublicRound {
  switch (round.stage) {
    case "Playing":
      return {
        stage: round.stage,
        id: round.id.toString(),
        czar: round.czar,
        players: Array.from(round.players),
        call: round.call,
        played: round.plays.map(play => play.playedBy)
      };
    case "Revealing":
      return {
        stage: round.stage,
        id: round.id.toString(),
        czar: round.czar,
        players: Array.from(round.players),
        call: round.call,
        plays: Array.from(potentiallyRevealedPlays(round))
      };
    case "Judging":
      return {
        stage: round.stage,
        id: round.id.toString(),
        czar: round.czar,
        players: Array.from(round.players),
        call: round.call,
        plays: Array.from(revealedPlays(round))
      };
    case "Complete":
      return {
        stage: round.stage,
        id: round.id.toString(),
        czar: round.czar,
        players: Array.from(round.players),
        call: round.call,
        winner: round.winner,
        plays: playsObj(round)
      };
  }
}

/**
 * Verifies the user is on the right stage for this action, throwing if they
 * are not. Note that you will need to give the generic type explicitly, as
 * it.
 * @param action
 * @param round
 * @param expected
 */
export function verifyStage<T extends Round>(
  action: Action,
  round: Round,
  expected: T["stage"]
): round is T {
  if (round.stage !== expected) {
    throw new IncorrectRoundStageError(action, round.stage, expected);
  }
  return true;
}

const storedPlayIsRevealed = (play: StoredPlay): play is RevealedStoredPlay =>
  play.revealed;

/**
 * Checks if every stored play in an array is revealed or not.
 */
export function allStoredPlaysAreRevealed(
  round: Round
): round is Round & { plays: RevealedStoredPlay[] } {
  return round.plays.every(storedPlayIsRevealed);
}
