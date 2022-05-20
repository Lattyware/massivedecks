import wu from "wu";

import type { Action } from "../../action.js";
import { IncorrectRoundStageError } from "../../errors/action-execution-error.js";
import { InvalidActionError } from "../../errors/validation.js";
import * as Event from "../../event.js";
import * as StartJudging from "../../events/game-event/start-judging.js";
import * as StartRevealing from "../../events/game-event/start-revealing.js";
import type { ServerState } from "../../server-state.js";
import type * as Timeout from "../../timeout.js";
import * as RoundStageTimerDone from "../../timeout/round-stage-timer-done.js";
import type * as User from "../../user.js";
import * as Util from "../../util.js";
import type { Part } from "../cards/card.js";
import * as Card from "../cards/card.js";
import type { Decks } from "../cards/decks.js";
import type * as Play from "../cards/play.js";
import type * as Game from "../game.js";
import type * as Rules from "../rules.js";
import * as CzarChoices from "../rules/czar-choices.js";
import type * as PublicRound from "./round/public.js";
import * as StoredPlay from "./round/stored-play.js";

export type Round = Starting | Playing | Revealing | Judging | Complete;

export type Stage =
  | "Starting"
  | "Playing"
  | "Revealing"
  | "Judging"
  | "Complete";

export type Id = number;

export abstract class Base<TStage extends Stage> {
  public abstract readonly stage: TStage;
  public abstract readonly id: Id;
  public abstract readonly czar: User.Id;
  public abstract readonly players: Set<User.Id>;
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
    ...expected: TRound["stage"][]
  ): this is TRound {
    if (this.isInStage(action, ...expected)) {
      return true;
    } else {
      throw new IncorrectRoundStageError(action, this.stage, ...expected);
    }
  }

  public isInStage<TRound extends Round>(
    action: Action,
    ...expected: TRound["stage"][]
  ): this is TRound {
    return expected.some((n) => n == this.stage);
  }
}

export interface Timed {
  timedOut: boolean;
}

export const isTimed = <TStage extends Stage>(
  round: Base<TStage>,
): round is Base<TStage> & Timed => Object.hasOwn(round, "timedOut");

export class Complete extends Base<"Complete"> {
  public get stage(): "Complete" {
    return "Complete";
  }

  public readonly id: Id;
  public readonly czar: User.Id;

  public get players(): Set<User.Id> {
    return new Set(wu(this.plays).map((play) => play.playedBy));
  }

  public readonly call: Card.Call;
  public readonly plays: StoredPlay.Revealed[];
  public readonly winner: User.Id;

  public constructor(
    id: Id,
    czar: User.Id,
    call: Card.Call,
    plays: StoredPlay.Revealed[],
    winner: User.Id,
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
      playOrder: this.plays.map((play) => play.playedBy),
      startedAt: this.startedAt,
    };
  }

  public playDetails(): { [player: string]: PublicRound.PlayDetails } {
    const obj: { [player: string]: PublicRound.PlayDetails } = {};
    for (const roundPlay of this.plays) {
      obj[roundPlay.id] = {
        playedBy: roundPlay.playedBy,
        ...(roundPlay.likes.length > 0
          ? { likes: roundPlay.likes.length }
          : {}),
      };
    }
    return obj;
  }

  private playsObj(): { [player: string]: PublicRound.PlayWithDetails } {
    const obj: { [player: string]: PublicRound.PlayWithDetails } = {};
    for (const roundPlay of this.plays) {
      obj[roundPlay.playedBy] = {
        play: roundPlay.play,
        playedBy: roundPlay.playedBy,
        ...(roundPlay.likes.length > 0
          ? { likes: roundPlay.likes.length }
          : {}),
      };
    }
    return obj;
  }

  toJSON(): object {
    return {
      stage: this.stage,
      id: this.id,
      czar: this.czar,
      call: this.call,
      plays: this.plays,
      winner: this.winner,
    };
  }
}

export class Judging extends Base<"Judging"> implements Timed {
  public get stage(): "Judging" {
    return "Judging";
  }

  public readonly id: Id;
  public readonly czar: User.Id;

  public get players(): Set<User.Id> {
    return new Set(wu(this.plays).map((play) => play.playedBy));
  }

  public readonly call: Card.Call;
  public readonly plays: StoredPlay.Revealed[];
  public timedOut: boolean;

  public constructor(
    id: Id,
    czar: User.Id,
    call: Card.Call,
    plays: StoredPlay.Revealed[],
    timedOut = false,
  ) {
    super();
    this.id = id;
    this.czar = czar;
    this.call = call;
    this.plays = plays;
    this.timedOut = timedOut;
  }

  public start(
    rules: Rules.Rules,
    previouslyRevealed: boolean,
    newCardsAndPlayedByPlayer: Map<User.Id, StartRevealing.AfterPlaying>,
  ): {
    timeouts?: Iterable<Timeout.After>;
    events?: Iterable<Event.Distributor>;
  } {
    const timeout = RoundStageTimerDone.ifEnabled(this, rules.stages);
    const plays = previouslyRevealed
      ? undefined
      : Array.from(this.revealedPlays());
    const event = Event.additionally(
      StartJudging.of(plays),
      newCardsAndPlayedByPlayer,
    );
    return {
      timeouts: Util.asOptionalIterable(timeout),
      events: Util.asOptionalIterable(event),
    };
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
      startedAt: this.startedAt,
    };
  }

  private *revealedPlays(): Iterable<Play.Revealed> {
    for (const roundPlay of this.plays) {
      yield {
        id: roundPlay.id,
        play: roundPlay.play,
      };
    }
  }

  toJSON(): object {
    return {
      stage: this.stage,
      id: this.id,
      czar: this.czar,
      call: this.call,
      plays: this.plays,
      timedOut: this.timedOut,
    };
  }
}

export class Revealing extends Base<"Revealing"> implements Timed {
  public get stage(): "Revealing" {
    return "Revealing";
  }

  public readonly id: Id;
  public readonly czar: User.Id;

  public get players(): Set<User.Id> {
    return new Set(wu(this.plays).map((play) => play.playedBy));
  }

  public readonly call: Card.Call;
  public readonly plays: StoredPlay.StoredPlay[];
  public timedOut: boolean;

  public constructor(
    id: Id,
    czar: User.Id,
    call: Card.Call,
    plays: StoredPlay.StoredPlay[],
    timedOut = false,
  ) {
    super();
    this.id = id;
    this.czar = czar;
    this.call = call;
    this.plays = plays;
    this.timedOut = timedOut;
  }

  public start(game: Game.Game): {
    events?: Iterable<Event.Distributor>;
    timeouts?: Iterable<Timeout.After>;
  } {
    const playsToBeRevealed = Array.from(wu(this.plays).map((play) => play.id));
    const events = Util.asOptionalIterable(
      Event.additionally(
        StartRevealing.of(playsToBeRevealed),
        this.getAfterPlayingDetails(game),
      ),
    );
    const timeouts = Util.asOptionalIterable(
      RoundStageTimerDone.ifEnabled(this, game.rules.stages),
    );
    return { events, timeouts };
  }

  public advance(
    game: Game.Game,
    previouslyRevealed: boolean,
  ):
    | {
        round: Judging;
        events?: Iterable<Event.Distributor>;
        timeouts?: Iterable<Timeout.After>;
      }
    | undefined {
    if (StoredPlay.allRevealed(this)) {
      const judging = new Judging(this.id, this.czar, this.call, this.plays);
      const start = judging.start(
        game.rules,
        previouslyRevealed,
        previouslyRevealed ? new Map() : this.getAfterPlayingDetails(game),
      );
      return {
        round: judging,
        ...start,
      };
    } else {
      return undefined;
    }
  }

  private getAfterPlayingDetails(
    game: Game.Game,
  ): Map<User.Id, StartRevealing.AfterPlaying> {
    const slotCount = Card.slotCount(this.call);
    const extraCards =
      slotCount > 2 ||
      (slotCount === 2 && game.rules.houseRules.packingHeat !== undefined)
        ? slotCount - 1
        : 0;
    const newCardsAndPlayedByPlayer = new Map<
      User.Id,
      StartRevealing.AfterPlaying
    >();
    for (const play of this.plays) {
      const idSet = new Set(play.play.map((c) => c.id));
      const player = game.players[play.playedBy];
      if (player !== undefined) {
        player.hand = player.hand.filter((card) => !idSet.has(card.id));
        const toDraw = play.play.length - extraCards;
        const drawn = game.decks.responses.draw(toDraw);
        newCardsAndPlayedByPlayer.set(play.playedBy, {
          drawn,
          played: play.id,
        });
        player.hand.push(...drawn);
      }
    }
    return newCardsAndPlayedByPlayer;
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
      startedAt: this.startedAt,
    };
  }

  private *potentiallyRevealedPlays(): Iterable<Play.PotentiallyRevealed> {
    for (const roundPlay of this.plays) {
      const potentiallyRevealed: Play.PotentiallyRevealed = {
        id: roundPlay.id,
      };
      if (roundPlay.revealed) {
        potentiallyRevealed.play = roundPlay.play;
      }
      yield potentiallyRevealed;
    }
  }

  toJSON(): object {
    return {
      stage: this.stage,
      id: this.id,
      czar: this.czar,
      call: this.call,
      plays: this.plays,
      timedOut: this.timedOut,
    };
  }
}

export class Playing extends Base<"Playing"> implements Timed {
  public get stage(): "Playing" {
    return "Playing";
  }

  public readonly id: Id;
  public readonly czar: User.Id;
  public readonly players: Set<User.Id>;
  public readonly call: Card.Call;
  public readonly plays: StoredPlay.Unrevealed[];
  public timedOut: boolean;

  public constructor(
    id: Id,
    czar: User.Id,
    players: Set<User.Id>,
    call: Card.Call,
    plays: StoredPlay.Unrevealed[] | undefined = undefined,
    timedOut = false,
  ) {
    super();
    this.id = id;
    this.czar = czar;
    this.players = players;
    this.call = call;
    this.plays = plays === undefined ? [] : plays;
    this.timedOut = timedOut;
  }

  public advance(
    game: Game.Game,
    doNotStart = false,
  ):
    | {
        round: Revealing;
        events?: Iterable<Event.Distributor>;
        timeouts?: Iterable<Timeout.After>;
      }
    | undefined {
    const revealing = new Revealing(
      this.id,
      this.czar,
      this.call,
      Util.shuffled(this.plays),
    );
    if (revealing.plays.length === 0) {
      return undefined;
    }
    game.round = revealing;
    return {
      round: revealing,
      ...(doNotStart ? {} : revealing.start(game)),
    };
  }

  public skipToJudging(game: Game.Game):
    | {
        round: Judging;
        timeouts?: Iterable<Timeout.After>;
        events?: Iterable<Event.Distributor>;
      }
    | undefined {
    const advanceRevealing = this.advance(game, true);
    if (advanceRevealing === undefined) {
      return undefined;
    }
    for (const play of advanceRevealing.round.plays) {
      play.revealed = true;
    }
    const advanceJudging = advanceRevealing.round.advance(game, false);
    if (advanceJudging === undefined) {
      throw new Error("All plays should have been revealed automatically.");
    }
    return advanceJudging;
  }

  public waitingFor(): Set<User.Id> | null {
    const done = new Set(
      wu(this.players).filter((p) => !this.hasPlayed().has(p)),
    );
    return done.size > 0 ? done : null;
  }

  private hasPlayed(): Set<User.Id> {
    return new Set(wu(this.plays).map((play) => play.playedBy));
  }

  public public(): PublicRound.Playing {
    return {
      stage: this.stage,
      id: this.id.toString(),
      czar: this.czar,
      players: Array.from(this.players),
      call: this.call,
      played: this.plays.map((play) => play.playedBy),
      ...(this.timedOut ? { timedOut: true } : {}),
      startedAt: this.startedAt,
    };
  }

  toJSON(): object {
    return {
      stage: this.stage,
      id: this.id,
      czar: this.czar,
      players: Array.from(this.players),
      call: this.call,
      plays: this.plays,
      timedOut: this.timedOut,
    };
  }
}

export class Starting extends Base<"Starting"> implements Timed {
  public get stage(): "Starting" {
    return "Starting";
  }

  public readonly id: Id;
  public readonly czar: User.Id;
  public readonly players: Set<User.Id>;
  public readonly calls: Card.Call[];
  public timedOut: boolean;

  public constructor(
    id: Id,
    czar: User.Id,
    players: Set<User.Id>,
    calls: Card.Call[],
    timedOut = false,
  ) {
    super();
    this.id = id;
    this.czar = czar;
    this.players = players;
    this.calls = calls;
    this.timedOut = timedOut;
  }

  public static forGivenChoices(
    id: Id,
    czar: User.Id,
    players: Set<User.Id>,
    czarChoices: CzarChoices.CzarChoices,
    decks: Decks,
  ) {
    const first = czarChoices.custom ? [CzarChoices.customCall()] : [];
    const cards = [
      ...first,
      ...decks.calls.draw(czarChoices.numberOfChoices - first.length),
    ];
    return new this(id, czar, players, cards);
  }

  public waitingFor(): Set<User.Id> | null {
    return new Set(this.czar);
  }

  public advance(
    server: ServerState,
    game: Game.Game,
    chosen: Card.Id,
    fill: Part[][] | undefined,
  ): {
    round: Playing;
    timeouts?: Iterable<Timeout.After>;
    events?: Iterable<Event.Distributor>;
  } {
    const call = this.calls.find((call) => call.id === chosen);
    if (call === undefined) {
      throw new InvalidActionError(
        "The given call doesn't exist or wasn't in the given options.",
      );
    }
    if (Card.isCustom(call)) {
      if (fill === undefined) {
        throw new InvalidActionError("Custom calls must be filled to be used.");
      }
      if (Card.slotCount(fill) < 1) {
        throw new InvalidActionError("Must have at least one slot.");
      }
      call.parts = fill;
    } else {
      if (fill !== undefined) {
        throw new InvalidActionError("Only custom calls can be filled.");
      }
    }
    game.decks.calls.discard(
      // We destroy custom calls by not discarding them because we don't want them back in rotation.
      this.calls.filter((card) => !Card.isCustom(card) && card.id !== chosen),
    );
    const round = new Playing(this.id, this.czar, this.players, call);
    const eventsAndTimeouts = game.startPlaying(server, false, round, true);
    return { round, ...eventsAndTimeouts };
  }

  public public(): PublicRound.Starting {
    return {
      stage: this.stage,
      id: this.id.toString(),
      czar: this.czar,
      players: Array.from(this.players),
      ...(this.timedOut ? { timedOut: true } : {}),
      startedAt: this.startedAt,
    };
  }

  toJSON(): object {
    return {
      stage: this.stage,
      id: this.id,
      czar: this.czar,
      players: Array.from(this.players),
      calls: this.calls,
      timedOut: this.timedOut,
    };
  }
}

export const fromJSON = (r: Round): Round => {
  switch (r.stage) {
    case "Starting":
      return new Starting(
        r.id,
        r.czar,
        new Set(r.players),
        r.calls,
        r.timedOut,
      );
    case "Playing":
      return new Playing(
        r.id,
        r.czar,
        new Set(r.players),
        r.call,
        r.plays,
        r.timedOut,
      );
    case "Revealing":
      return new Revealing(r.id, r.czar, r.call, r.plays, r.timedOut);
    case "Judging":
      return new Judging(r.id, r.czar, r.call, r.plays, r.timedOut);
    case "Complete":
      return new Complete(r.id, r.czar, r.call, r.plays, r.winner);
  }
};
