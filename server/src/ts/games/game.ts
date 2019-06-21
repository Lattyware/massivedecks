import * as user from "../user";
import * as util from "../util";
import { Decks } from "./cards/decks";
import * as decks from "./cards/decks";
import * as round from "./game/round";
import { Round } from "./game/round";
import * as publicRound from "./game/round/public";
import { Public as PublicRound } from "./game/round/public";
import * as player from "./player";
import { Player } from "./player";
import * as rules from "./rules";
import { Rules } from "./rules";
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
  control: "Human",
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

export const nextCzar = (game: Game): user.Id => {
  const current = game.round.czar;
  const index = game.playerOrder.findIndex(id => id === current) + 1;
  return game.playerOrder[index >= game.playerOrder.length ? 0 : index];
};
