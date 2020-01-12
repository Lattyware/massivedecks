import wu from "wu";
import { InvalidActionError } from "../errors/validation";
import * as event from "../event";
import * as gameStarted from "../events/game-event/game-started";
import * as pauseStateChanged from "../events/game-event/pause-state-changed";
import * as playSubmitted from "../events/game-event/play-submitted";
import * as roundStarted from "../events/game-event/round-started";
import { Lobby } from "../lobby";
import { ServerState } from "../server-state";
import * as timeout from "../timeout";
import * as finishedPlaying from "../timeout/finished-playing";
import * as roundStageTimerDone from "../timeout/round-stage-timer-done";
import * as user from "../user";
import { User } from "../user";
import * as util from "../util";
import * as card from "./cards/card";
import * as decks from "./cards/decks";
import { Decks, Templates } from "./cards/decks";
import * as play from "./cards/play";
import * as round from "./game/round";
import { Playing, Round, Stage } from "./game/round";
import * as publicRound from "./game/round/public";
import { Public as PublicRound } from "./game/round/public";
import * as player from "./player";
import { Player } from "./player";
import * as rules from "./rules";
import { Rules } from "./rules";

export interface Public {
  round: PublicRound;
  history: publicRound.Complete[];
  playerOrder: user.Id[];
  players: { [id: string]: player.Public };
  rules: rules.Public;
  winner?: user.Id;
  paused?: boolean;
}

export const atStartOfRound = (
  server: ServerState,
  first: boolean,
  game: Game & { round: round.Playing }
): {
  game: Game & { round: round.Playing };
  events?: Iterable<event.Distributor>;
  timeouts?: Iterable<timeout.TimeoutAfter>;
} => {
  const slotCount = card.slotCount(game.round.call);

  const events = [];
  if (
    slotCount > 2 ||
    (slotCount === 2 && game.rules.houseRules.packingHeat !== undefined)
  ) {
    const responseDeck = game.decks.responses;
    const drawnByPlayer = new Map();
    for (const [id, playerState] of game.players) {
      if (Player.role(id, game) === "Player") {
        const drawn = responseDeck.draw(slotCount - 1);
        drawnByPlayer.set(id, { drawn });
        playerState.hand.push(...drawn);
      }
    }
    if (!first) {
      events.push(
        event.additionally(roundStarted.of(game.round), drawnByPlayer)
      );
    }
  } else {
    if (!first) {
      events.push(event.targetAll(roundStarted.of(game.round)));
    }
  }

  if (first) {
    events.push(
      event.playerSpecificAddition(
        gameStarted.of(game.round),
        (id, user, player) => ({
          hand: player.hand
        })
      )
    );
  }

  const ais = game.rules.houseRules.rando.current;
  for (const ai of ais) {
    const player = game.players.get(ai) as Player;
    const plays = game.round.plays;
    const playId = play.id();
    plays.push({
      id: playId,
      play: player.hand.slice(0, slotCount),
      playedBy: ai,
      revealed: false
    });
    events.push(event.targetAll(playSubmitted.of(ai)));
  }

  const timeouts = [];
  const finishedTimeout = finishedPlaying.ifNeeded(game.round);
  if (finishedTimeout !== undefined) {
    timeouts.push({
      timeout: finishedTimeout,
      after: server.config.timeouts.finishedPlayingDelay
    });
  }

  const timer = roundStageTimerDone.ifEnabled(
    game.round,
    game.rules.timeLimits
  );
  if (timer !== undefined) {
    timeouts.push(timer);
  }

  return { game, events, timeouts };
};

/**
 * The state of a game.
 */
export class Game {
  public round: Round;
  public readonly history: publicRound.Complete[];
  public readonly playerOrder: user.Id[];
  public readonly players: Map<user.Id, Player>;
  public readonly decks: Decks;
  public readonly rules: Rules;
  public winner?: user.Id;
  public paused: boolean;

  private constructor(
    round: Round,
    playerOrder: user.Id[],
    players: Map<user.Id, Player>,
    decks: Decks,
    rules: Rules
  ) {
    this.round = round;
    this.history = [];
    this.playerOrder = playerOrder;
    this.players = players;
    this.decks = decks;
    this.rules = rules;
    this.paused = false;
  }

  private static activePlayer(user: User, player?: Player): boolean {
    return (
      user.presence === "Joined" &&
      user.role === "Player" &&
      player !== undefined &&
      player.presence === "Active"
    );
  }

  private static canBeCzar(user: User, player?: Player): boolean {
    return user.control !== "Computer" && Game.activePlayer(user, player);
  }

  public nextCzar(users: Map<user.Id, User>): user.Id | undefined {
    const current = this.round.czar;
    const playerOrder = this.playerOrder;
    const currentIndex = playerOrder.findIndex(id => id === current);

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
      if (
        Game.canBeCzar(
          users.get(potentialCzar) as User,
          this.players.get(potentialCzar)
        )
      ) {
        return potentialCzar;
      }
      incrementIndex();
    }
    return undefined;
  }

  public static start(
    templates: Iterable<Templates>,
    users: Map<user.Id, User>,
    rules: Rules
  ): Game & { round: round.Playing } {
    const gameDecks = decks.decks(templates);
    const playerOrder = wu(users.entries())
      .filter(([_, user]) => user.role === "Player")
      .map(([id, _]) => id)
      .toArray();
    const czar = playerOrder[0];
    const playerMap = new Map(
      wu(playerOrder).map(id => [
        id,
        new Player(gameDecks.responses.draw(rules.handSize))
      ])
    );
    const [call] = gameDecks.calls.draw(1);
    const playersInRound = new Set(
      wu(playerOrder).filter(id =>
        Game.isPlayerInRound(czar, playerMap, id, users.get(id) as User)
      )
    );
    return new Game(
      new round.Playing(0, czar, playersInRound, call),
      playerOrder,
      playerMap,
      gameDecks,
      rules
    ) as Game & { round: round.Playing };
  }

  public public(): Public {
    return {
      round: this.round.public(),
      history: this.history,
      playerOrder: this.playerOrder,
      players: util.mapObjectValues(
        util.mapToObject(this.players),
        (p: Player) => p.public()
      ),
      rules: rules.censor(this.rules),
      ...(this.winner === undefined ? {} : { winner: this.winner }),
      ...(this.paused ? { paused: true } : {})
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
    events?: Iterable<event.Distributor>;
    timeouts?: Iterable<timeout.TimeoutAfter>;
  } {
    const czar = this.nextCzar(lobby.users);
    const events = [];
    if (czar === undefined) {
      if (!this.paused) {
        this.paused = true;
        return { events: [event.targetAll(pauseStateChanged.paused)] };
      } else {
        return {};
      }
    } else if (this.paused) {
      this.paused = false;
      events.push(event.targetAll(pauseStateChanged.continued));
    }
    const [call] = this.decks.calls.replace(this.round.call);
    const roundId = this.round.id + 1;
    const playersInRound = new Set(
      wu(this.playerOrder).filter(id =>
        Game.isPlayerInRound(
          czar,
          this.players,
          id,
          lobby.users.get(id) as User
        )
      )
    );
    this.decks.responses.discard(
      (this.round as round.Base<Stage>).plays.flatMap(play => play.play)
    );
    this.round = new Playing(roundId, czar, playersInRound, call);
    const updatedGame = this as Game & { round: Playing };
    const atStart = atStartOfRound(server, false, updatedGame);
    return {
      events: [
        ...events,
        ...(atStart.events !== undefined ? atStart.events : [])
      ],
      timeouts: atStart.timeouts
    };
  }

  /**
   * Remove the player from the round if we are waiting on them.
   * @param toRemove The id of the player.
   * @param server The server context.
   */
  public removeFromRound(
    toRemove: user.Id,
    server: ServerState
  ): { timeouts?: Iterable<timeout.TimeoutAfter> } {
    const player = this.players.get(toRemove);
    if (player !== undefined) {
      const play = this.round.plays.find(p => p.playedBy === toRemove);
      if (play === undefined) {
        this.round.players.delete(toRemove);
        const timeouts = [];
        const timeout = finishedPlaying.ifNeeded(this.round as round.Playing);
        if (timeout !== undefined) {
          timeouts.push({
            timeout: timeout,
            after: server.config.timeouts.finishedPlayingDelay
          });
        }
        return { timeouts };
      }
      return {};
    } else {
      throw new InvalidActionError("User must be a player.");
    }
  }

  private static isPlayerInRound(
    czar: user.Id,
    players: Map<user.Id, Player>,
    playerId: user.Id,
    user: User
  ): boolean {
    if (playerId === czar) {
      return false;
    }
    const player = players.get(playerId);
    return Game.activePlayer(user, player);
  }
}
