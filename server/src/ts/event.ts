import { GameEvent } from "./events/game-event";
import { LobbyEvent } from "./events/lobby-event";
import { UserEvent } from "./events/user-event";
import { Player } from "./games/player";
import { Lobby } from "./lobby";
import * as logging from "./logging";
import { SocketManager } from "./socket-manager";
import * as socketManager from "./socket-manager";
import * as user from "./user";
import { User } from "./user";
import { GameCode } from "./lobby/game-code";

/**
 * An event send to clients to update them on the state of the game.
 */
export type Event = LobbyEvent | UserEvent | GameEvent;

/**
 * Defines how to distribute an event efficiently.
 */
export type Distributor = (
  lobby: Lobby,
  send: (target: user.Id, payload: string) => void
) => void;

/**
 * Send the event to every user in the lobby.
 * @param event The event to send.
 */
export const targetAll = (event: Event): Distributor => (lobby, send) => {
  const rendered = JSON.stringify(event);
  for (const id of lobby.users.keys()) {
    send(id, rendered);
  }
};

/**
 * Send the event to the specifically targeted users.
 * @param event The event to send.
 * @param targets The targets to send it to.
 */
export const targetOnly = (
  event: Event,
  ...targets: user.Id[]
): Distributor => (lobby, send) => {
  const rendered = JSON.stringify(event);
  const targetSet = new Set(targets);
  for (const id of lobby.users.keys()) {
    if (targetSet.has(id)) {
      send(id, rendered);
    }
  }
};

/**
 * Send an event to every user in the lobby, sending some additional data to
 * the users represented in the given map.
 * @param event The event to send.
 * @param additions The additions by user.
 */
export const additionally = <T extends Event>(
  event: T,
  additions: Map<user.Id, Partial<T>>
): Distributor => (lobby, send) => {
  const basicRendered = JSON.stringify(event);
  for (const id of lobby.users.keys()) {
    const addition = additions.get(id);
    if (addition !== undefined) {
      const full: T = { ...event, ...addition };
      send(id, JSON.stringify(full));
    } else {
      send(id, basicRendered);
    }
  }
};

/**
 * Send an event to every user in the lobby, sending some edditional element if
 * the user fulfills the given condition.
 * @param event The event to send.
 * @param condition The condition to apply.
 * @param addition The addition to add if the given condition passes.
 */
export const conditionally = <T extends Event>(
  event: T,
  condition: (id: user.Id, user: User) => boolean,
  addition: Partial<T>
): Distributor => (lobby, send) => {
  const basicRendered = JSON.stringify(event);
  const full: T = { ...event, ...addition };
  const fullRendered = JSON.stringify(full);
  for (const [id, user] of lobby.users.entries()) {
    send(id, condition(id, user) ? fullRendered : basicRendered);
  }
};

/**
 * Send an event to every user in the lobby, sending some additional element to
 * each player.
 * @param event The event to send.
 * @param addition A function to get the addition to send to the given player.
 */
export const playerSpecificAddition = <T extends Event, U extends Partial<T>>(
  event: T,
  addition: (id: user.Id, user: User, player: Player) => U
): Distributor => (lobby, send) => {
  const basicRendered = JSON.stringify(event);
  const game = lobby.game;
  if (game === undefined) {
    for (const id of lobby.users.keys()) {
      send(id, basicRendered);
    }
  } else {
    for (const [id, user] of lobby.users.entries()) {
      const player = game.players.get(id);
      if (player !== undefined) {
        const toAdd = addition(id, user, player);
        const full: T = { ...event, ...toAdd };
        send(id, JSON.stringify(full));
      }
    }
  }
};

const sendHelper = (
  sockets: socketManager.Sockets,
  gameCode: GameCode
): ((user: user.Id, serializedEvent: string) => void) => (
  user,
  serializedEvent
) => {
  try {
    const socket = sockets.get(gameCode, user);
    if (socket) {
      socket.send(serializedEvent);
      logging.logger.info("WebSocket send:", {
        user: user,
        event: serializedEvent
      });
    }
  } catch (error) {
    logging.logException("Exception sending to WebSocket", error);
  }
};

/**
 * Send the given events to the targets given with them.
 * @param sockets The sockets to send with.
 * @param gameCode The game code for the lobby being sent in.
 * @param lobby The lobby as context to send the events in.
 * @param events An iterable of events with targets.
 */
export function send(
  sockets: SocketManager,
  gameCode: GameCode,
  lobby: Lobby,
  events: Iterable<Distributor>
): void {
  const sendToUser = sendHelper(sockets.sockets, gameCode);
  for (const event of events) {
    event(lobby, sendToUser);
  }
}
