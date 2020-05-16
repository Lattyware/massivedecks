import { GameEvent } from "./events/game-event";
import { LobbyEvent } from "./events/lobby-event";
import { UserEvent } from "./events/user-event";
import { Player } from "./games/player";
import { Lobby } from "./lobby";
import * as Logging from "./logging";
import * as SocketManager from "./socket-manager";
import * as User from "./user";
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
  send: (target: User.Id, payload: string, close: boolean) => void
) => void;

/**
 * Send the event to every user in the lobby.
 * @param event The event to send.
 */
export const targetAll = (event: Event): Distributor => (lobby, send) => {
  const rendered = JSON.stringify(event);
  for (const id of Object.keys(lobby.users)) {
    send(id, rendered, false);
  }
};

/**
 * Send the event to the specifically targeted users.
 * @param event The event to send.
 * @param targets The targets to send it to.
 */
export const targetOnly = (
  event: Event,
  ...targets: User.Id[]
): Distributor => (lobby, send) => {
  const rendered = JSON.stringify(event);
  const targetSet = new Set(targets);
  for (const id of Object.keys(lobby.users)) {
    if (targetSet.has(id)) {
      send(id, rendered, false);
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
  additions: Map<User.Id, Partial<T>>
): Distributor => (lobby, send) => {
  const basicRendered = JSON.stringify(event);
  for (const id of Object.keys(lobby.users)) {
    const addition = additions.get(id);
    if (addition !== undefined) {
      const full: T = { ...event, ...addition };
      send(id, JSON.stringify(full), false);
    } else {
      send(id, basicRendered, false);
    }
  }
};

/**
 * Send an event to every user in the lobby, sending some additional element if
 * the user fulfills the given condition.
 * @param event The event to send.
 * @param condition The condition to apply.
 * @param addition The addition to add if the given condition passes.
 */
export const conditionally = <T extends Event>(
  event: T,
  condition: (id: User.Id, user: User.User) => boolean,
  addition: Partial<T>
): Distributor => (lobby, send) => {
  const basicRendered = JSON.stringify(event);
  const full: T = { ...event, ...addition };
  const fullRendered = JSON.stringify(full);
  for (const [id, user] of Object.entries(lobby.users)) {
    send(id, condition(id, user) ? fullRendered : basicRendered, false);
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
  addition: (id: User.Id, user: User.User, player: Player) => U
): Distributor => (lobby, send) => {
  const basicRendered = JSON.stringify(event);
  const game = lobby.game;
  if (game === undefined) {
    for (const id of Object.keys(lobby.users)) {
      send(id, basicRendered, false);
    }
  } else {
    for (const [id, user] of Object.entries(lobby.users)) {
      const player = game.players[id];
      if (player !== undefined) {
        const toAdd = addition(id, user, player);
        const full: T = { ...event, ...toAdd };
        send(id, JSON.stringify(full), false);
      } else {
        send(id, basicRendered, false);
      }
    }
  }
};

/**
 * Send the event to every user in the lobby, closing the connection of anyone
 * matching the given predicate.
 * @param event The event to send.
 * @param close The predicate to decide if the connection should close.
 */
export const targetAllAndPotentiallyClose = (
  event: Event,
  close: (userId: User.Id) => boolean
): Distributor => (lobby, send) => {
  const rendered = JSON.stringify(event);
  for (const id of Object.keys(lobby.users)) {
    send(id, rendered, close(id));
  }
};

const sendHelper = (
  sockets: SocketManager.Sockets,
  gameCode: GameCode
): ((user: User.Id, serializedEvent: string, close: boolean) => void) => (
  user,
  serializedEvent,
  close
) => {
  try {
    const userSockets = sockets.get(gameCode, user);
    Logging.logger.debug("WebSocket send:", {
      user: user,
      event: serializedEvent,
    });
    for (const socket of userSockets) {
      socket.send(serializedEvent);
      if (close) {
        socket.close(1000, "User no longer in game.");
      }
    }
  } catch (error) {
    Logging.logException("Exception sending to WebSocket", error);
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
  sockets: SocketManager.SocketManager,
  gameCode: GameCode,
  lobby: Lobby,
  events: Iterable<Distributor>
): void {
  const sendToUser = sendHelper(sockets.sockets, gameCode);
  for (const event of events) {
    event(lobby, sendToUser);
  }
}
