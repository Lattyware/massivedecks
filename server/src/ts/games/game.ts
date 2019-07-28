import * as event from "../event";
import * as gameStarted from "../events/game-event/game-started";
import * as playSubmitted from "../events/game-event/play-submitted";
import * as roundStarted from "../events/game-event/round-started";
import { ServerState } from "../server-state";
import * as finishedPlaying from "../timeout/finished-playing";
import { User } from "../user";
import * as user from "../user";
import * as util from "../util";
import * as card from "./cards/card";
import { Decks } from "./cards/decks";
import * as decks from "./cards/decks";
import * as play from "./cards/play";
import * as round from "./game/round";
import { Round } from "./game/round";
import * as publicRound from "./game/round/public";
import { Public as PublicRound } from "./game/round/public";
import * as player from "./player";
import { Player } from "./player";
import * as rules from "./rules";
import { Rules } from "./rules";
import * as lobby from "../lobby";
import * as timeout from "../timeout";
import wu from "wu";

/**
 * The state of a game.
 */
export interface Game {
  round: Round;
  history: round.Complete[];
  playerOrder: user.Id[];
  players: Map<user.Id, Player>;
  decks: Decks;
  rules: Rules;
  winner?: user.Id;
}

export interface Public {
  round: PublicRound;
  history: publicRound.Complete[];
  playerOrder: user.Id[];
  players: { [id: string]: player.Public };
  rules: rules.Public;
  winner?: user.Id;
}

export const censor: (game: Game) => Public = game => ({
  round: round.censor(game.round),
  history: game.history.map(complete => round.censor(complete)),
  playerOrder: game.playerOrder,
  players: util.mapObjectValues(util.mapToObject(game.players), player.censor),
  rules: rules.censor(game.rules),
  ...(game.winner === undefined ? {} : { winner: game.winner })
});

const newPlayerForUser = (decks: Decks, rules: Rules): Player => ({
  hand: decks.responses.draw(rules.handSize),
  score: 0
});

export const start = (
  templates: Iterable<decks.Templates>,
  players: Iterable<user.Id>,
  rules: Rules
): Game & { round: round.Playing } => {
  const gameDecks = decks.decks(templates);
  const playerOrder = Array.from(players);
  const czar = playerOrder[0];
  const playerMap = new Map(
    wu(playerOrder).map(id => [id, newPlayerForUser(gameDecks, rules)])
  );
  const [call] = gameDecks.calls.draw(1);
  const playersInRound = new Set(wu(playerOrder).filter(id => id !== czar));
  return {
    round: {
      stage: "Playing",
      id: 0,
      czar,
      players: playersInRound,
      call,
      plays: []
    },
    history: [],
    playerOrder,
    players: playerMap,
    decks: gameDecks,
    rules
  };
};

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
      if (player.role(game, id) === "Player") {
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
  const timeout = finishedPlaying.ifNeeded(game.round);
  if (timeout !== undefined) {
    timeouts.push({
      timeout: timeout,
      after: server.config.timeouts.finishedPlayingDelay
    });
  }

  return { game, events, timeouts };
};

const canBeCzar = (user: User): boolean =>
  user.control !== "Computer" &&
  user.presence === "Joined" &&
  user.role === "Player";

const czarAfter = (lobby: lobby.WithActiveGame, nextIndex: number): user.Id => {
  const game = lobby.game;
  const potentialCzar =
    game.playerOrder[nextIndex >= game.playerOrder.length ? 0 : nextIndex];
  return canBeCzar(lobby.users.get(potentialCzar) as User)
    ? potentialCzar
    : czarAfter(lobby, nextIndex + 1);
};

export const nextCzar = (lobby: lobby.WithActiveGame): user.Id => {
  const game = lobby.game;
  const current = game.round.czar;
  const nextIndex = game.playerOrder.findIndex(id => id === current) + 1;
  return czarAfter(lobby, nextIndex);
};
