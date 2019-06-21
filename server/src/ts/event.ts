import WebSocket from "ws";
import wu from "wu";
import { GameEvent } from "./events/game-event";
import { LobbyEvent } from "./events/lobby-event";
import { UserEvent } from "./events/user-event";
import { Game } from "./games/game";
import * as player from "./games/player";
import { Lobby } from "./lobby";
import * as logging from "./logging";
import { SocketManager } from "./socket-manager";
import * as user from "./user";
import { User } from "./user";
import * as util from "./util";

/**
 * An event send to clients to update them on the state of the game.
 */
export type Event = LobbyEvent | UserEvent | GameEvent;

/**
 * An event with who it should be sent to.
 */
export interface Targeted {
  targets?: Set<user.Id> | ((id: user.Id, user: User) => boolean);
  event: Event;
}

/**
 * Give the event a target of all users in the lobby that fulfil the given
 * targeting predicate. If the predicate is not given, it will be sent to all.
 * @param event The event.
 * @param targets The function that determines if the event will be sent to
 * a given user.
 */
export const target = (
  event: Event,
  targets?: (id: user.Id, user: User) => boolean
): Targeted => ({ targets, event });

/**
 * Give the event a target of the given users.
 * @param event The event.
 * @param targets The users to send the event to.
 */
export const targetSpecifically = (
  event: Event,
  ...targets: user.Id[]
): Targeted => ({ targets: new Set(targets), event });

/**
 * Target the given event by privilege. Sending only the event as given to
 * privileged users, and optionally a censored version to unprivileged users.
 * @param event
 * @param censor
 */
export function* targetByPrivilege<T extends Event>(
  event: T,
  censor?: (event: T) => T
): Iterable<Targeted> {
  yield target(event, (_, user) => user.privilege === "Privileged");
  if (censor !== undefined) {
    yield target(censor(event), (_, user) => user.privilege === "Unprivileged");
  }
}

/**
 * Target the given event by player role. Sending only the event as given to
 * the czar, and optionally a censored version to other players.
 * @param game The game at hand.
 * @param event The event to send to the czar.
 * @param censor The function to censor the event for players.
 */
export function* targetByPlayerRole<T extends Event>(
  game: Game,
  event: T,
  censor?: (event: T) => T
): Iterable<Targeted> {
  yield target(event, (id, _) => player.role(game, id) === "Czar");
  if (censor !== undefined) {
    yield target(event, (id, _) => player.role(game, id) === "Player");
  }
}

/**
 * Target the given event to only one player, but send a censored version to
 * everyone else.
 * @param player The player to send the initial event to.
 * @param event The event to send.
 * @param censor The function to censor the event for others.
 */
export function* targetByPlayer<T extends Event, U extends Event>(
  player: user.Id,
  event: T,
  censor: (event: T) => U
): Iterable<Targeted> {
  yield targetSpecifically(event, player);
  if (censor !== undefined) {
    yield target(event, (id, _) => id !== player);
  }
}

function sendHelper(
  sockets: Map<user.Id, WebSocket>,
  serializedEvent: string,
  event: Event
): (user: user.Id) => void {
  return user => {
    try {
      const socket = sockets.get(user);
      if (socket) {
        socket.send(serializedEvent);
        logging.logger.info("WebSocket send:", {
          user: user,
          event: event
        });
      }
    } catch (error) {}
  };
}

/**
 * Send the given events to the targets given with them.
 * @param sockets The sockets to send with.
 * @param lobby The lobby as context to send the events in.
 * @param firstEvent The first event to send (there must be at least one).
 * @param restEvents Any further events to send.
 */
export function send(
  sockets: SocketManager,
  lobby: Lobby,
  firstEvent: Targeted,
  ...restEvents: Targeted[]
): void;
/**
 * Send the given events to the targets given with them.
 * @param sockets The sockets to send with.
 * @param lobby The lobby as context to send the events in.
 * @param events An iterable of events with targets.
 */
export function send(
  sockets: SocketManager,
  lobby: Lobby,
  events: Iterable<Targeted>
): void;
export function send(
  sockets: SocketManager,
  lobby: Lobby,
  firstEvent: Targeted | Iterable<Targeted>,
  ...restEvents: Targeted[]
): void {
  const events = util.isIterable(firstEvent)
    ? firstEvent
    : [firstEvent, ...restEvents];
  for (const event of events) {
    const sendToUser = sendHelper(
      sockets.sockets,
      JSON.stringify(event.event),
      event.event
    );
    const targets = event.targets;
    (targets === undefined
      ? wu(lobby.users.keys())
      : targets instanceof Function
      ? wu(lobby.users.entries())
          .filter(([id, user]) => targets(id, user))
          .map(([id]) => id)
      : targets
    ).forEach(sendToUser);
  }
}
