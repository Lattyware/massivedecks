import { GameStateError } from "../errors/game-state-error";
import * as Event from "../event";
import * as ErrorEncountered from "../events/lobby-event/error-encountered";
import { Lobby } from "../lobby";
import { ServerState } from "../server-state";
import { Task } from "../task";
import * as Timeout from "../timeout";
import { GameCode } from "./game-code";

export interface Change {
  lobby?: Lobby;
  events?: Iterable<Event.Distributor>;
  timeouts?: Iterable<Timeout.After>;
  tasks?: Iterable<Task>;
}

export type ConstrainedChange<L extends Lobby> = Change & { lobby?: L };

export type Handler = (lobby: Lobby) => Change;
export type HandlerWithReturnValue<T> = (
  lobby: Lobby
) => { change: Change; returnValue: T };

/**
 * Reduce a list of items to a single change by applying a function to each one
 * in turn.
 * @param items the items.
 * @param lobby the lobby.
 * @param toChange a function taking the lobby after the last change, and the item.
 */
export function reduce<T, L extends Lobby>(
  items: Iterable<T>,
  lobby: L,
  toChange: (lobby: L, item: T) => ConstrainedChange<L>
): ConstrainedChange<L> {
  let currentLobby = lobby;
  let lobbyChanged = false;
  const events: Event.Distributor[] = [];
  const timeouts: Timeout.After[] = [];
  const tasks: Task[] = [];
  for (const item of items) {
    const result = toChange(currentLobby, item);
    if (result.lobby !== undefined) {
      lobbyChanged = true;
      currentLobby = result.lobby;
    }
    if (result.events !== undefined) {
      events.push(...result.events);
    }
    if (result.timeouts !== undefined) {
      timeouts.push(...result.timeouts);
    }
    if (result.tasks !== undefined) {
      tasks.push(...result.tasks);
    }
  }
  return {
    ...(lobbyChanged ? { lobby: currentLobby } : {}),
    ...(events.length > 0 ? { events } : {}),
    ...(timeouts.length > 0 ? { timeouts } : {}),
    ...(tasks.length > 0 ? { tasks } : {}),
  };
}

function internalApply(
  server: ServerState,
  gameCode: GameCode,
  originalLobby: Lobby,
  change: Change
): {
  lobby?: Lobby;
  timeouts?: Iterable<Timeout.After>;
  tasks?: Iterable<Task>;
  events?: Iterable<Event.Distributor>;
} {
  let lobbyUnchanged = change.lobby === undefined;
  let currentLobby = change.lobby !== undefined ? change.lobby : originalLobby;
  const returnTasks = change.tasks !== undefined ? [...change.tasks] : [];
  const events = change.events !== undefined ? [...change.events] : [];
  const futureTimeouts = [];
  if (change.timeouts !== undefined) {
    for (const timeoutAfter of change.timeouts) {
      if (timeoutAfter.after > 0) {
        futureTimeouts.push(timeoutAfter);
      } else {
        const chained = internalApply(
          server,
          gameCode,
          currentLobby,
          Timeout.handler(server, timeoutAfter.timeout, gameCode, currentLobby)
        );
        if (chained.lobby !== undefined) {
          lobbyUnchanged = false;
        }
        currentLobby =
          chained.lobby !== undefined ? chained.lobby : currentLobby;
        if (chained.timeouts !== undefined) {
          futureTimeouts.push(...chained.timeouts);
        }
        if (chained.tasks !== undefined) {
          returnTasks.push(...chained.tasks);
        }
        if (chained.events !== undefined) {
          events.push(...chained.events);
        }
      }
    }
  }
  const lobbyResult = lobbyUnchanged ? {} : { lobby: currentLobby };
  const timeoutResult =
    futureTimeouts.length === 0 ? {} : { timeouts: futureTimeouts };
  const tasksResult = returnTasks.length === 0 ? {} : { tasks: returnTasks };
  const eventResult = events.length === 0 ? {} : { events };
  return { ...lobbyResult, ...timeoutResult, ...tasksResult, ...eventResult };
}

/**
 * Apply the given change and return a value.
 * @param server The server state.
 * @param gameCode The game code for the lobby to apply the change to.
 * @param handler The handler that gives the change.
 * @param timeoutId If given, the id of the timeout being executed.
 */
export async function applyAndReturn<T>(
  server: ServerState,
  gameCode: GameCode,
  handler: HandlerWithReturnValue<T>,
  timeoutId?: Timeout.Id
): Promise<T> {
  try {
    const [tasks, returnValue] = await server.store.writeAndReturn(
      gameCode,
      (lobby) => {
        const { change, returnValue } = handler(lobby);
        const result = internalApply(server, gameCode, lobby, change);
        if (result.events !== undefined) {
          Event.send(server.socketManager, gameCode, lobby, result.events);
        }
        return {
          transaction: {
            lobby: result.lobby,
            timeouts: result.timeouts,
            executedTimeout: timeoutId,
          },
          result: [result.tasks, returnValue],
        };
      }
    );
    if (tasks !== undefined) {
      for (const task of tasks) {
        await server.tasks.enqueue(server, task);
      }
    }
    return returnValue;
  } catch (error) {
    // If we get an error we still want to kill the timeout and potentially
    // tell the user about the error.
    await server.store.write(gameCode, (lobby) => {
      if (error instanceof GameStateError) {
        lobby.errors.push(error.details());
        Event.send(server.socketManager, gameCode, lobby, [
          Event.targetAll(ErrorEncountered.of(error.details())),
        ]);
      }
      return { lobby, executedTimeout: timeoutId };
    });
    throw error;
  }
}

/**
 * Apply the given change.
 * @param server The server state.
 * @param gameCode The game code for the lobby to apply the change to.
 * @param handler The handler that gives the change.
 * @param timeoutId If given, the id of the timeout being executed.
 */
export async function apply(
  server: ServerState,
  gameCode: GameCode,
  handler: Handler,
  timeoutId?: Timeout.Id
): Promise<void> {
  await applyAndReturn(
    server,
    gameCode,
    (lobby) => ({
      change: handler(lobby),
      returnValue: undefined,
    }),
    timeoutId
  );
}
