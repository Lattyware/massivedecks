import wu from "wu";

import { InvalidActionError } from "../errors/validation.js";
import * as Event from "../event.js";
import * as GameStarted from "../events/game-event/game-started.js";
import * as PauseStateChanged from "../events/game-event/pause-state-changed.js";
import * as PlaySubmitted from "../events/game-event/play-submitted.js";
import * as PlayingStarted from "../events/game-event/playing-started.js";
import * as RoundStarted from "../events/game-event/round-started.js";
import type { Lobby } from "../lobby.js";
import type { ServerState } from "../server-state.js";
import type * as Timeout from "../timeout.js";
import * as FinishedPlaying from "../timeout/finished-playing.js";
import * as RoundStageTimerDone from "../timeout/round-stage-timer-done.js";
import type * as User from "../user.js";
import * as Util from "../util.js";
import * as Card from "./cards/card.js";
import * as Decks from "./cards/decks.js";
import * as Play from "./cards/play.js";
import * as Round from "./game/round.js";
import type * as PublicRound from "./game/round/public.js";
import type { StoredPlay } from "./game/round/stored-play.js";
import * as Player from "./player.js";
import * as Rules from "./rules.js";
import * as HappyEnding from "./rules/happy-ending.js";

export interface Public {
  round: PublicRound.Public;
  history: PublicRound.Complete[];
  playerOrder: User.Id[];
  players: { [id: string]: Player.Public };
  rules: Rules.Public;
  winner?: string[];
  paused?: boolean;
}

/**
 * The state of a game.
 */
export class Game {
  public round: Round.Round;
  public readonly history: PublicRound.Complete[];
  public readonly playerOrder: User.Id[];
  public readonly players: { [id: string]: Player.Player };
  public readonly decks: Decks.Decks;
  public readonly rules: Rules.Rules;
  public winner?: User.Id[];
  public paused: boolean;

  private constructor(
    round: Round.Round,
    playerOrder: User.Id[],
    players: { [id: string]: Player.Player },
    decks: Decks.Decks,
    rules: Rules.Rules,
    paused = false,
    history: PublicRound.Complete[] | undefined = undefined,
    winner: User.Id[] | undefined = undefined,
  ) {
    this.round = round;
    this.history = history === undefined ? [] : history;
    this.playerOrder = playerOrder;
    this.players = players;
    this.decks = decks;
    this.rules = rules;
    this.paused = paused;
    this.winner = winner;
  }

  public toJSON(): object {
    return {
      round: this.round,
      playerOrder: this.playerOrder,
      players: this.players,
      decks: this.decks,
      rules: this.rules,
      paused: this.paused,
      history: this.history,
      winner: this.winner,
    };
  }

  public static fromJSON = (game: Game): Game =>
    new Game(
      Round.fromJSON(game.round),
      game.playerOrder,
      game.players,
      {
        responses: Decks.Responses.fromJSON(game.decks.responses),
        calls: Decks.Calls.fromJSON(game.decks.calls),
      },
      game.rules,
      game.paused,
      game.history,
      game.winner,
    );

  private static activePlayer(
    user: User.User,
    player?: Player.Player,
  ): boolean {
    return (
      user.presence === "Joined" &&
      user.role === "Player" &&
      player !== undefined &&
      player.presence === "Active"
    );
  }

  private static canBeCzar(
    user: User.User | undefined,
    player?: Player.Player | undefined,
  ): boolean {
    if (user === undefined) {
      return false;
    }
    return user.control !== "Computer" && Game.activePlayer(user, player);
  }

  public nextCzar(users: { [id: string]: User.User }): User.Id | undefined {
    const roundWinner = this.rules.houseRules.winnersPick?.roundWinner;
    if (
      roundWinner !== undefined &&
      Game.canBeCzar(users[roundWinner], this.players[roundWinner])
    ) {
      return roundWinner;
    } else {
      const current = this.round.czar;
      const playerOrder = this.playerOrder;
      const currentIndex = playerOrder.findIndex((id) => id === current);
      return Game.internalNextCzar(
        currentIndex,
        users,
        this.players,
        playerOrder,
      );
    }
  }

  public static internalNextCzar(
    currentIndex: number,
    users: { [id: string]: User.User },
    players: { [id: string]: Player.Player },
    playerOrder: User.Id[],
  ): User.Id | undefined {
    let nextIndex = currentIndex;
    function incrementIndex(): void {
      nextIndex += 1;
      nextIndex = nextIndex >= playerOrder.length ? 0 : nextIndex;
    }
    let triedEveryone = false;
    incrementIndex();
    while (!triedEveryone) {
      if (nextIndex === currentIndex) {
        triedEveryone = true;
      }
      const potentialCzar = playerOrder[nextIndex] as string;
      if (Game.canBeCzar(users[potentialCzar], players[potentialCzar])) {
        return potentialCzar;
      }
      incrementIndex();
    }
    return undefined;
  }

  public static start(
    templates: Iterable<Decks.Templates>,
    users: { [id: string]: User.User },
    rules: Rules.Rules,
  ): Game & { round: Round.Starting | Round.Playing } {
    let allTemplates: Iterable<Decks.Templates>;
    const cw = rules.houseRules.comedyWriter;
    if (cw !== undefined) {
      const blanks: Decks.Templates = {
        calls: new Set(),
        responses: new Set(
          wu.repeat({}, cw.number).map(() => ({
            id: Card.id(),
            source: { source: "Custom" },
            text: "",
          })),
        ),
      };
      allTemplates = [
        ...(cw.exclusive
          ? wu(templates).map((t) => ({
              calls: t.calls,
              responses: new Set<Card.Response>(),
            }))
          : templates),
        blanks,
      ];
    } else {
      allTemplates = templates;
    }
    const gameDecks = Decks.decks(allTemplates);
    const playerOrder = wu(Object.entries(users))
      .map(([id, _]) => id)
      .toArray();
    const playerMap = Object.fromEntries(
      wu(Object.entries(users))
        .filter(([_, user]) => user.role === "Player")
        .map(([id, _]) => [
          id,
          Player.initial(gameDecks.responses.draw(rules.handSize)),
        ]),
    );
    const czar = Game.internalNextCzar(0, users, playerMap, playerOrder);
    if (czar === undefined) {
      throw new Error(
        "Game was allowed to start with too few players to have a czar.",
      );
    }
    const playersInRound = new Set(
      wu(playerOrder).filter((id) =>
        Game.isPlayerInRound(czar, playerMap, id, users[id] as User.User),
      ),
    );
    let round: Round.Starting | Round.Playing;
    if (rules.houseRules.czarChoices === undefined) {
      const [call] = gameDecks.calls.draw(1);
      round = new Round.Playing(0, czar, playersInRound, call);
    } else {
      round = Round.Starting.forGivenChoices(
        0,
        czar,
        playersInRound,
        rules.houseRules.czarChoices,
        gameDecks,
      );
    }
    return new Game(round, playerOrder, playerMap, gameDecks, rules) as Game & {
      round: Round.Playing;
    };
  }

  public public(): Public {
    return {
      round: this.round.public(),
      history: this.history,
      playerOrder: this.playerOrder,
      players: Util.mapObjectValues(this.players, (p: Player.Player) =>
        Player.censor(p),
      ),
      rules: Rules.censor(this.rules),
      ...(this.winner === undefined ? {} : { winner: this.winner }),
      ...(this.paused ? { paused: true } : {}),
    };
  }

  /**
   * Forcibly start a new round, regardless of the current state.
   * @param server the server context this game is in.
   * @param lobby the lobby this game is in.
   */
  public startNewRound(
    server: ServerState,
    lobby: Lobby,
  ): {
    events?: Iterable<Event.Distributor>;
    timeouts?: Iterable<Timeout.After>;
  } {
    // General
    const events = [];

    // Try Advance Czar
    const czar = this.nextCzar(lobby.users);
    if (czar === undefined) {
      if (!this.paused) {
        this.paused = true;
        return { events: [Event.targetAll(PauseStateChanged.paused)] };
      } else {
        return {};
      }
    } else if (this.paused) {
      this.paused = false;
      events.push(Event.targetAll(PauseStateChanged.continued));
    }

    // Discard what is left over from the last round.
    const round = this.round;
    if (round.stage === "Starting") {
      this.decks.calls.discard(
        // We destroy custom calls by not discarding them because we don't want them back in rotation.
        round.calls.filter((card) => !Card.isCustom(card)),
      );
    } else {
      // We destroy custom calls by not discarding them because we don't want them back in rotation.
      if (!Card.isCustom(round.call)) {
        this.decks.calls.discard([round.call]);
      }
      const plays: StoredPlay[] = round.plays;
      this.decks.responses.discard(plays.flatMap((play) => play.play));
    }

    // Set up the new round.
    const roundId = round.id + 1;
    const playersInRound = new Set(
      wu(this.playerOrder).filter((id) =>
        Game.isPlayerInRound(
          czar,
          this.players,
          id,
          lobby.users[id] as User.User,
        ),
      ),
    );
    if (this.rules.houseRules.happyEnding?.inFinalRound) {
      this.round = new Round.Playing(
        roundId,
        czar,
        playersInRound,
        HappyEnding.call,
      );
    } else {
      const czarChoices = this.rules.houseRules.czarChoices;
      if (czarChoices === undefined) {
        const [call] = this.decks.calls.draw(1);
        this.round = new Round.Playing(roundId, czar, playersInRound, call);
      } else {
        this.round = Round.Starting.forGivenChoices(
          roundId,
          czar,
          playersInRound,
          czarChoices,
          this.decks,
        );
      }
    }
    const atStart = this.startRound(server, false, this.round);
    return {
      events: [
        ...events,
        ...(atStart.events !== undefined ? atStart.events : []),
      ],
      timeouts: atStart.timeouts,
    };
  }

  /**
   * Remove the player from the round if we are waiting on them.
   * @param toRemove The id of the player.
   * @param server The server context.
   */
  public removeFromRound(
    toRemove: User.Id,
    _server: ServerState,
  ): { timeouts?: Iterable<Timeout.After> } {
    const player = this.players[toRemove];
    if (player !== undefined && this.round.stage !== "Starting") {
      const play = this.round.plays.find((p) => p.playedBy === toRemove);
      if (play === undefined) {
        this.round.players.delete(toRemove);
        if (this.round.stage === "Playing") {
          return {
            timeouts: Util.asOptionalIterable(
              FinishedPlaying.ifNeeded(this.rules, this.round),
            ),
          };
        }
      }
      return {};
    } else {
      throw new InvalidActionError("User must be a player.");
    }
  }

  private static isPlayerInRound(
    czar: User.Id,
    players: { [id: string]: Player.Player },
    playerId: User.Id,
    user: User.User,
  ): boolean {
    if (playerId === czar || user.role !== "Player") {
      return false;
    }
    const player = players[playerId];
    return Game.activePlayer(user, player);
  }

  public startRound(
    server: ServerState,
    first: boolean,
    round: Round.Starting | Round.Playing,
  ): {
    events?: Iterable<Event.Distributor>;
    timeouts?: Iterable<Timeout.After>;
  } {
    switch (round.stage) {
      case "Starting":
        return this.startStarting(round, first);
      case "Playing":
        return this.startPlaying(server, first, round, false);
      default:
        throw new Error("Unexpected type of round here.");
    }
  }

  public startStarting(
    round: Round.Starting,
    first: boolean,
  ): {
    events?: Iterable<Event.Distributor>;
    timeouts?: Iterable<Timeout.After>;
  } {
    const timer = RoundStageTimerDone.ifEnabled(round, this.rules.stages);

    return {
      events: [
        first
          ? Event.playerSpecificAddition(
              GameStarted.ofStarting(round),
              (id, user, player) => ({
                hand: player.hand,
                calls: id === round.czar ? round.calls : undefined,
              }),
            )
          : Event.playerSpecificAddition(RoundStarted.of(round), (id) =>
              id === round.czar ? { calls: round.calls } : {},
            ),
      ],
      timeouts: Util.asOptionalIterable(timer),
    };
  }

  public startPlaying(
    server: ServerState,
    first: boolean,
    round: Round.Playing,
    previouslyStarted: boolean,
  ): {
    events?: Iterable<Event.Distributor>;
    timeouts?: Iterable<Timeout.After>;
  } {
    if (first && previouslyStarted) {
      throw new Error(
        "Can't be both the game start, and have had a starting phase already.",
      );
    }

    const additionallyByPlayer = new Map();
    const slotCount = Card.slotCount(round.call);
    if (
      slotCount > 2 ||
      (slotCount === 2 && this.rules.houseRules.packingHeat !== undefined)
    ) {
      const responseDeck = this.decks.responses;
      for (const [id, playerState] of Object.entries(this.players)) {
        if (Player.role(id, this) === "Player") {
          const drawn = responseDeck.draw(slotCount - 1);
          if (!first) {
            additionallyByPlayer.set(id, { drawn });
          }
          playerState.hand.push(...drawn);
        }
      }
    }

    const events = [
      first
        ? Event.playerSpecificAddition(
            GameStarted.ofPlaying(round),
            (id, user, player) => ({
              hand: player.hand,
            }),
          )
        : Event.additionally(
            previouslyStarted
              ? PlayingStarted.of(round)
              : RoundStarted.of(round),
            additionallyByPlayer,
          ),
    ];

    const plays = round.plays;
    const ais = this.rules.houseRules.rando.current;
    for (const ai of ais) {
      const player = this.players[ai] as Player.Player;
      plays.push({
        id: Play.id(),
        play: player.hand.slice(0, slotCount) as Card.Response[],
        playedBy: ai,
        revealed: false,
        likes: [],
      });
      events.push(Event.targetAll(PlaySubmitted.of(ai)));
    }

    const timeouts = [];
    const finishedTimeout = FinishedPlaying.ifNeeded(this.rules, round);
    if (finishedTimeout !== undefined) {
      timeouts.push(finishedTimeout);
    }

    const timer = RoundStageTimerDone.ifEnabled(round, this.rules.stages);
    if (timer !== undefined) {
      timeouts.push(timer);
    }

    return { events, timeouts };
  }
}
