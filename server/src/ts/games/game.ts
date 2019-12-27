import wu from "wu";
import * as event from "../event";
import * as gameStarted from "../events/game-event/game-started";
import * as playSubmitted from "../events/game-event/play-submitted";
import * as roundStarted from "../events/game-event/round-started";
import { ServerState } from "../server-state";
import * as timeout from "../timeout";
import * as finishedPlaying from "../timeout/finished-playing";
import * as user from "../user";
import { User } from "../user";
import * as util from "../util";
import * as card from "./cards/card";
import * as decks from "./cards/decks";
import { Decks, Templates } from "./cards/decks";
import * as play from "./cards/play";
import * as round from "./game/round";
import { Round } from "./game/round";
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
}

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

  public nextCzar(users: Map<user.Id, User>): user.Id {
    const current = this.round.czar;
    const nextIndex = this.playerOrder.findIndex(id => id === current) + 1;
    return this.czarAfter(users, nextIndex);
  }

  public static start(
    templates: Iterable<Templates>,
    users: Map<user.Id, User>,
    rules: Rules
  ): Game & { round: round.Playing } {
    const gameDecks = decks.decks(templates);
    const playerOrder = Array.from(users.keys());
    const czar = playerOrder[0];
    const playerMap = new Map(
      wu(playerOrder).map(id => [
        id,
        new Player(gameDecks.responses.draw(rules.handSize))
      ])
    );
    const [call] = gameDecks.calls.draw(1);
    const playersInRound = new Set(
      wu(playerOrder)
        .filter(id => id !== czar)
        .filter(id =>
          Game.activePlayer(users.get(id) as User, playerMap.get(id))
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

  private czarAfter(users: Map<user.Id, User>, nextIndex: number): user.Id {
    const potentialCzar = this.playerOrder[
      nextIndex >= this.playerOrder.length ? 0 : nextIndex
    ];
    return Game.canBeCzar(
      users.get(potentialCzar) as User,
      this.players.get(potentialCzar)
    )
      ? potentialCzar
      : this.czarAfter(users, nextIndex + 1);
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
      ...(this.winner === undefined ? {} : { winner: this.winner })
    };
  }
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

  return { game, events, timeouts };
};
