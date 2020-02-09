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

/**
 * A game lobby.
 */
export interface Lobby {
  name: string;
  public: boolean;
  nextUserId: number;
  users: Map<User.Id, User.User>;
  owner: User.Id;
  config: Config.Config;
  game?: Game.Game;
  errors: Errors.Details[];
}

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
  name: string;
  public: boolean;
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
 */
export const defaultConfig = (): Config.Config => ({
  version: 0,
  rules: Rules.create(),
  decks: [],
  public: false
});

/**
 * Create a new lobby.
 * @param creation The details of the lobby to create.
 */
export function create(creation: CreateLobby): Lobby {
  const id = (0).toString();
  return {
    name: creation.name ? creation.name : `${creation.owner.name}'s Game`,
    public: false,
    nextUserId: 1,
    users: new Map([[id, User.create(creation.owner, "Privileged")]]),
    owner: id,
    config: defaultConfig(),
    errors: []
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
  name: lobby.name,
  gameCode: gameCode,
  state: state(lobby),
  users: Util.counts(Object.values(lobby.users), {
    players: User.isPlaying,
    spectators: User.isSpectating
  }),
  ...(lobby.config.password !== undefined ? { password: true } : {})
});

function usersObj(lobby: Lobby): { [id: string]: User.Public } {
  const obj: { [id: string]: User.Public } = {};
  for (const [id, lobbyUser] of lobby.users.entries()) {
    obj[id] = User.censor(lobbyUser);
  }
  return obj;
}

export const censor = (lobby: Lobby): Public => ({
  name: lobby.name,
  public: lobby.public,
  users: usersObj(lobby),
  owner: lobby.owner,
  config: Config.censor(lobby.config),
  ...(lobby.game === undefined ? {} : { game: lobby.game.public() }),
  ...(lobby.errors.length === 0 ? {} : { errors: lobby.errors })
});

export const addUser = (
  lobby: Lobby,
  registration: RegisterUser,
  change?: (user: User.User) => User.User
): {
  user: User.Id;
  events: Iterable<Event.Distributor>;
} => {
  const newUser = User.create(registration);
  const changedUser = change === undefined ? newUser : change(newUser);
  const id = lobby.nextUserId.toString();
  lobby.nextUserId += 1;
  lobby.users.set(id, changedUser);
  return {
    user: id,
    events: [Event.targetAll(PresenceChanged.joined(id, changedUser))]
  };
};
