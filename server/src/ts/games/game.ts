import wu from "wu";
import { InvalidActionError } from "../errors/validation";
import * as Event from "../event";
import * as GameStarted from "../events/game-event/game-started";
import * as PauseStateChanged from "../events/game-event/pause-state-changed";
import * as PlaySubmitted from "../events/game-event/play-submitted";
import * as RoundStarted from "../events/game-event/round-started";
import { Lobby } from "../lobby";
import { ServerState } from "../server-state";
import * as Timeout from "../timeout";
import * as FinishedPlaying from "../timeout/finished-playing";
import * as RoundStageTimerDone from "../timeout/round-stage-timer-done";
import * as User from "../user";
import * as Util from "../util";
import * as Card from "./cards/card";
import * as Decks from "./cards/decks";
import * as Play from "./cards/play";
import * as Round from "./game/round";
import * as PublicRound from "./game/round/public";
import { StoredPlay } from "./game/round/storedPlay";
import * as Player from "./player";
import * as Rules from "./rules";
import { happyEndingCall } from "./rules/happyEnding";

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
    winner: User.Id[] | undefined = undefined
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
      game.winner
    );

  private static activePlayer(
    user: User.User,
    player?: Player.Player
  ): boolean {
    return (
      user.presence === "Joined" &&
      user.role === "Player" &&
      player !== undefined &&
      player.presence === "Active"
    );
  }

  private static canBeCzar(user: User.User, player?: Player.Player): boolean {
    return user.control !== "Computer" && Game.activePlayer(user, player);
  }

  public nextCzar(users: { [id: string]: User.User }): User.Id | undefined {
    const current = this.round.czar;
    const playerOrder = this.playerOrder;
    const currentIndex = playerOrder.findIndex((id) => id === current);
    return Game.internalNextCzar(
      currentIndex,
      users,
      this.players,
      playerOrder
    );
  }

  public static internalNextCzar(
    currentIndex: number,
    users: { [id: string]: User.User },
    players: { [id: string]: Player.Player },
    playerOrder: User.Id[]
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
      const potentialCzar = playerOrder[nextIndex];
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
    rules: Rules.Rules
  ): Game & { round: Round.Playing } {
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
          }))
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
        ])
    );
    const czar = Game.internalNextCzar(0, users, playerMap, playerOrder);
    if (czar === undefined) {
      throw new Error(
        "Game was allowed to start with too few players to have a czar."
      );
    }
    const [call] = gameDecks.calls.draw(1);
    const playersInRound = new Set(
      wu(playerOrder).filter((id) =>
        Game.isPlayerInRound(czar, playerMap, id, users[id])
      )
    );
    return new Game(
      new Round.Playing(0, czar, playersInRound, call),
      playerOrder,
      playerMap,
      gameDecks,
      rules
    ) as Game & { round: Round.Playing };
  }

  public public(): Public {
    return {
      round: this.round.public(),
      history: this.history,
      playerOrder: this.playerOrder,
      players: Util.mapObjectValues(this.players, (p: Player.Player) =>
        Player.censor(p)
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
    lobby: Lobby
  ): {
    events?: Iterable<Event.Distributor>;
    timeouts?: Iterable<Timeout.After>;
  } {
    const czar = this.nextCzar(lobby.users);
    const events = [];
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
    const [call] = this.decks.calls.replace(this.round.call);
    const roundId = this.round.id + 1;
    const playersInRound = new Set(
      wu(this.playerOrder).filter((id) =>
        Game.isPlayerInRound(czar, this.players, id, lobby.users[id])
      )
    );
    const plays: StoredPlay[] = this.round.plays;
    this.decks.responses.discard(plays.flatMap((play) => play.play));
    this.round = new Round.Playing(roundId, czar, playersInRound, call);
    if (this.rules.houseRules.happyEnding?.inFinalRound) {
      this.round = new Round.Playing(
        roundId,
        czar,
        playersInRound,
        happyEndingCall
      );
    }
    const updatedGame = this as Game & { round: Round.Playing };
    const atStart = Game.atStartOfRound(server, false, updatedGame);
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
    server: ServerState
  ): { timeouts?: Iterable<Timeout.After> } {
    const player = this.players[toRemove];
    if (player !== undefined) {
      const play = this.round.plays.find((p) => p.playedBy === toRemove);
      if (play === undefined) {
        this.round.players.delete(toRemove);
        if (this.round.stage === "Playing") {
          return {
            timeouts: Util.asOptionalIterable(
              FinishedPlaying.ifNeeded(this.rules, this.round)
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
    user: User.User
  ): boolean {
    if (playerId === czar || user.role !== "Player") {
      return false;
    }
    const player = players[playerId];
    return Game.activePlayer(user, player);
  }

  static atStartOfRound(
    server: ServerState,
    first: boolean,
    game: Game & { round: Round.Playing }
  ): {
    game: Game & { round: Round.Playing };
    events?: Iterable<Event.Distributor>;
    timeouts?: Iterable<Timeout.After>;
  } {
    const slotCount = Card.slotCount(game.round.call);

    const events = [];
    if (
      slotCount > 2 ||
      (slotCount === 2 && game.rules.houseRules.packingHeat !== undefined)
    ) {
      const responseDeck = game.decks.responses;
      const drawnByPlayer = new Map();
      for (const [id, playerState] of Object.entries(game.players)) {
        if (Player.role(id, game) === "Player") {
          const drawn = responseDeck.draw(slotCount - 1);
          drawnByPlayer.set(id, { drawn });
          playerState.hand.push(...drawn);
        }
      }
      if (!first) {
        events.push(
          Event.additionally(RoundStarted.of(game.round), drawnByPlayer)
        );
      }
    } else {
      if (!first) {
        events.push(Event.targetAll(RoundStarted.of(game.round)));
      }
    }

    if (first) {
      events.push(
        Event.playerSpecificAddition(
          GameStarted.of(game.round),
          (id, user, player) => ({
            hand: player.hand,
          })
        )
      );
    }

    const ais = game.rules.houseRules.rando.current;
    for (const ai of ais) {
      const player = game.players[ai] as Player.Player;
      const plays = game.round.plays;
      const playId = Play.id();
      plays.push({
        id: playId,
        play: player.hand.slice(0, slotCount) as Card.Response[],
        playedBy: ai,
        revealed: false,
        likes: [],
      });
      events.push(Event.targetAll(PlaySubmitted.of(ai)));
    }

    const timeouts = [];
    const finishedTimeout = FinishedPlaying.ifNeeded(game.rules, game.round);
    if (finishedTimeout !== undefined) {
      timeouts.push(finishedTimeout);
    }

    const timer = RoundStageTimerDone.ifEnabled(game.round, game.rules.stages);
    if (timer !== undefined) {
      timeouts.push(timer);
    }

    return { game, events, timeouts };
  }
}
