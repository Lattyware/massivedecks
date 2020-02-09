import wu from "wu";
import { Action } from "../../action";
import { IncorrectRoundStageError } from "../../errors/action-execution-error";
import * as User from "../../user";
import * as Util from "../../util";
import * as Card from "../cards/card";
import * as Play from "../cards/play";
import * as PublicRound from "./round/public";
import * as StoredPlay from "./round/storedPlay";

export type Round = Playing | Revealing | Judging | Complete;

export type Stage = "Playing" | "Revealing" | "Judging" | "Complete";

export type Id = number;

export abstract class Base<TStage extends Stage> {
  public abstract readonly stage: TStage;
  public abstract readonly id: Id;
  public abstract readonly czar: User.Id;
  public abstract readonly players: Set<User.Id>;
  public abstract readonly call: Card.Call;
  public abstract readonly plays: StoredPlay.StoredPlay[];
  public readonly startedAt: number = Date.now();

  /**
   * The players that need to do something before this stage can advance.
   */
  public abstract waitingFor(): Set<User.Id> | null;

  /**
   * Get the public view of the round.
   */
  public abstract public(): PublicRound.Public;

  /**
   * Verifies the user is on the right stage for this action, throwing if they
   * are not. Note that you will need to give the generic type explicitly, as
   * it can't be inferred.
   */
  public verifyStage<TRound extends Round>(
    action: Action,
    expected: TRound["stage"]
  ): this is TRound {
    if (this.stage !== expected) {
      throw new IncorrectRoundStageError(action, this.stage, expected);
    }
    return true;
  }
}

export interface Timed {
  timedOut: boolean;
}

export const isTimed = <TStage extends Stage>(
  round: Base<TStage>
): round is Base<TStage> & Timed => round.hasOwnProperty("timedOut");

export class Complete extends Base<"Complete"> {
  public get stage(): "Complete" {
    return "Complete";
  }

  public readonly id: Id;
  public readonly czar: Card.Id;

  public get players(): Set<User.Id> {
    return new Set(wu(this.plays).map(play => play.playedBy));
  }

  public readonly call: Card.Call;
  public readonly plays: StoredPlay.Revealed[];
  public readonly winner: User.Id;

  public constructor(
    id: Id,
    czar: Card.Id,
    call: Card.Call,
    plays: StoredPlay.Revealed[],
    winner: User.Id
  ) {
    super();
    this.id = id;
    this.czar = czar;
    this.call = call;
    this.plays = plays;
    this.winner = winner;
  }

  public waitingFor(): Set<User.Id> | null {
    return null;
  }

  public public(): PublicRound.Complete {
    return {
      stage: this.stage,
      id: this.id.toString(),
      czar: this.czar,
      players: Array.from(this.players),
      call: this.call,
      winner: this.winner,
      plays: this.playsObj(),
      playOrder: this.plays.map(play => play.playedBy),
      startedAt: this.startedAt
    };
  }

  public playDetails(): { [player: string]: PublicRound.PlayDetails } {
    const obj: { [player: string]: PublicRound.PlayDetails } = {};
    for (const roundPlay of this.plays) {
      obj[roundPlay.id] = {
        playedBy: roundPlay.playedBy,
        ...(roundPlay.likes.size > 0 ? { likes: roundPlay.likes.size } : {})
      };
    }
    return obj;
  }

  private playsObj(): { [player: string]: PublicRound.PlayWithLikes } {
    const obj: { [player: string]: PublicRound.PlayWithLikes } = {};
    for (const roundPlay of this.plays) {
      obj[roundPlay.playedBy] = {
        play: roundPlay.play,
        ...(roundPlay.likes.size > 0 ? { likes: roundPlay.likes.size } : {})
      };
    }
    return obj;
  }
}

export class Judging extends Base<"Judging"> implements Timed {
  public get stage(): "Judging" {
    return "Judging";
  }

  public readonly id: Id;
  public readonly czar: Card.Id;

  public get players(): Set<User.Id> {
    return new Set(wu(this.plays).map(play => play.playedBy));
  }

  public readonly call: Card.Call;
  public readonly plays: StoredPlay.Revealed[];
  public timedOut = false;

  public constructor(
    id: Id,
    czar: Card.Id,
    call: Card.Call,
    plays: StoredPlay.Revealed[]
  ) {
    super();
    this.id = id;
    this.czar = czar;
    this.call = call;
    this.plays = plays;
  }

  public advance(winner: User.Id): Complete {
    return new Complete(this.id, this.czar, this.call, this.plays, winner);
  }

  public waitingFor(): Set<User.Id> | null {
    return new Set(this.czar);
  }

  public public(): PublicRound.Judging {
    return {
      stage: this.stage,
      id: this.id.toString(),
      czar: this.czar,
      players: Array.from(this.players),
      call: this.call,
      plays: Array.from(this.revealedPlays()),
      ...(this.timedOut ? { timedOut: true } : {}),
      startedAt: this.startedAt
    };
  }

  private *revealedPlays(): Iterable<Play.Revealed> {
    for (const roundPlay of this.plays) {
      yield {
        id: roundPlay.id,
        play: roundPlay.play
      };
    }
  }
}

export class Revealing extends Base<"Revealing"> implements Timed {
  public get stage(): "Revealing" {
    return "Revealing";
  }

  public readonly id: Id;
  public readonly czar: Card.Id;

  public get players(): Set<User.Id> {
    return new Set(wu(this.plays).map(play => play.playedBy));
  }

  public readonly call: Card.Call;
  public readonly plays: StoredPlay.StoredPlay[];
  public timedOut = false;

  public constructor(
    id: Id,
    czar: Card.Id,
    call: Card.Call,
    plays: StoredPlay.StoredPlay[]
  ) {
    super();
    this.id = id;
    this.czar = czar;
    this.call = call;
    this.plays = plays;
  }

  public advance(): Judging | null {
    if (StoredPlay.allRevealed(this)) {
      return new Judging(this.id, this.czar, this.call, this.plays);
    } else {
      return null;
    }
  }

  public waitingFor(): Set<User.Id> | null {
    return new Set(this.czar);
  }

  public public(): PublicRound.Revealing {
    return {
      stage: this.stage,
      id: this.id.toString(),
      czar: this.czar,
      players: Array.from(this.players),
      call: this.call,
      plays: Array.from(this.potentiallyRevealedPlays()),
      ...(this.timedOut ? { timedOut: true } : {}),
      startedAt: this.startedAt
    };
  }

  private *potentiallyRevealedPlays(): Iterable<Play.PotentiallyRevealed> {
    for (const roundPlay of this.plays) {
      const potentiallyRevealed: Play.PotentiallyRevealed = {
        id: roundPlay.id
      };
      if (roundPlay.revealed) {
        potentiallyRevealed.play = roundPlay.play;
      }
      yield potentiallyRevealed;
    }
  }
}

export class Playing extends Base<"Playing"> implements Timed {
  public get stage(): "Playing" {
    return "Playing";
  }

  public readonly id: Id;
  public readonly czar: Card.Id;
  public readonly players: Set<User.Id>;
  public readonly call: Card.Call;
  public readonly plays: StoredPlay.Unrevealed[];
  public timedOut = false;

  public constructor(
    id: Id,
    czar: Card.Id,
    players: Set<User.Id>,
    call: Card.Call
  ) {
    super();
    this.id = id;
    this.czar = czar;
    this.players = players;
    this.call = call;
    this.plays = [];
  }

  public advance(): Revealing {
    return new Revealing(
      this.id,
      this.czar,
      this.call,
      Util.shuffled(this.plays)
    );
  }

  public waitingFor(): Set<User.Id> | null {
    const done = new Set(
      wu(this.players).filter(p => !this.hasPlayed().has(p))
    );
    return done.size > 0 ? done : null;
  }

  private hasPlayed(): Set<User.Id> {
    return new Set(wu(this.plays).map(play => play.playedBy));
  }

  public public(): PublicRound.Playing {
    return {
      stage: this.stage,
      id: this.id.toString(),
      czar: this.czar,
      players: Array.from(this.players),
      call: this.call,
      played: this.plays.map(play => play.playedBy),
      ...(this.timedOut ? { timedOut: true } : {}),
      startedAt: this.startedAt
    };
  }
}
