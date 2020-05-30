import { CreateLobby } from "./action/initial/create-lobby";
import { RegisterUser } from "./action/initial/register-user";
import * as Errors from "./errors";
import * as Event from "./event";
import * as PresenceChanged from "./events/lobby-event/presence-changed";
import * as Game from "./games/game";
import * as Rules from "./games/rules";
import * as Config from "./lobby/config";
import { GameCode } from "./lobby/game-code";
import * as User from "./user";
import * as Util from "./util";
import { LoadDeckSummary } from "./task/load-deck-summary";
import * as Rando from "./games/rules/rando";

/**
 * A game lobby.
 */
export interface Lobby {
  nextUserId: number;
  users: { [id: string]: User.User };
  owner: User.Id;
  config: Config.Config;
  game?: Game.Game;
  errors: Errors.Details[];
}

export const fromJSON = (object: Lobby): Lobby =>
  ({
    ...object,
    ...(object.game !== undefined
      ? { game: Game.Game.fromJSON(object.game) }
      : {}),
  } as Lobby);

/**
 * A lobby with an active game.
 */
export type WithActiveGame = Lobby & { game: Game.Game };

/**
 * Return if the given lobby has an active game.
 */
export const hasActiveGame = (lobby: Lobby): lobby is WithActiveGame =>
  lobby.game !== undefined;

/**
 * A game lobby containing only state all users can see.
 */
export interface Public {
  users: { [id: string]: User.Public };
  owner: User.Id;
  config: Config.Public;
  game?: Game.Public;
  errors?: Errors.Details[];
}

/**
 * The state of a lobby.
 */
export type State = "Playing" | "SettingUp";

/**
 * A summary of a lobby.
 */
export interface Summary {
  name: string;
  gameCode: GameCode;
  state: State;
  users: { players: number; spectators: number };
  password?: boolean;
}

/**
 * Create a config with default values.
 * Importantly this doesn't correctly set up the rando house rule, use Rando.create after-the-fact.
 */
export const fromDefaults = (
  gameCode: GameCode,
  name: string,
  defaults: Config.Defaults
): {
  config: Config.Config;
  tasks: LoadDeckSummary[];
} => {
  const tasks = defaults.decks.map(
    (source) => new LoadDeckSummary(gameCode, source)
  );
  return {
    config: {
      version: 0,
      name,
      rules: Rules.fromDefaults(defaults.rules),
      public: defaults.public,
      audienceMode: defaults.audienceMode,
      decks: defaults.decks.map((d) => ({
        source: d,
      })),
    },
    tasks: tasks,
  };
};

/**
 * Create a new lobby.
 * @param gameCode The game code for the lobby when it is created.
 * @param creation The details of the lobby to create.
 * @param defaults The defaults to use.
 */
export function create(
  gameCode: GameCode,
  creation: CreateLobby,
  defaults: Config.Defaults
): {
  lobby: Lobby;
  tasks: LoadDeckSummary[];
} {
  const ownerId = (0).toString();
  const { config, tasks } = fromDefaults(gameCode, creation.name, defaults);
  const lobby = {
    nextUserId: 1,
    users: { [ownerId]: User.create(creation.owner, "Player", "Privileged") },
    owner: ownerId,
    config: config,
    errors: [],
  };
  config.rules.houseRules.rando = Rando.create(
    lobby,
    defaults.rules.houseRules.rando
  );
  return {
    lobby,
    tasks,
  };
}

/**
 * The state of the given lobby.
 */
export const state = (lobby: Lobby): State =>
  lobby.game === null ? "SettingUp" : "Playing";

/**
 * Get a summary of the given lobby.
 * @param gameCode The game code for the lobby.
 * @param lobby The lobby.
 */
export const summary = (gameCode: GameCode, lobby: Lobby): Summary => ({
  name: lobby.config.name,
  gameCode: gameCode,
  state: state(lobby),
  users: Util.counts(Object.values(lobby.users), {
    players: User.isPlaying,
    spectators: User.isSpectating,
  }),
  ...(lobby.config.password !== undefined ? { password: true } : {}),
});

function usersObj(lobby: Lobby): { [id: string]: User.Public } {
  const obj: { [id: string]: User.Public } = {};
  for (const [id, lobbyUser] of Object.entries(lobby.users)) {
    obj[id] = User.censor(lobbyUser);
  }
  return obj;
}

export const censor = (lobby: Lobby): Public => ({
  users: usersObj(lobby),
  owner: lobby.owner,
  config: Config.censor(lobby.config),
  ...(lobby.game === undefined ? {} : { game: lobby.game.public() }),
  ...(lobby.errors.length === 0 ? {} : { errors: lobby.errors }),
});

export const addUser = (
  lobby: Lobby,
  registration: RegisterUser,
  role: User.Role,
  change?: (user: User.User) => User.User
): {
  user: User.Id;
  events: Iterable<Event.Distributor>;
} => {
  const newUser = User.create(registration, role);
  const changedUser = change === undefined ? newUser : change(newUser);
  const id = lobby.nextUserId.toString();
  lobby.nextUserId += 1;
  lobby.users[id] = changedUser;
  return {
    user: id,
    events: [Event.targetAll(PresenceChanged.joined(id, changedUser))],
  };
};
