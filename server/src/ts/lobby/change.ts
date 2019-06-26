import * as event from "../event";
import { Lobby } from "../lobby";
import { ServerState } from "../server-state";
import { Task } from "../task";
import * as timeout from "../timeout";
import { GameCode } from "./game-code";

export interface Change {
  lobby?: Lobby;
  events?: Iterable<event.Distributor>;
  timeouts?: Iterable<timeout.TimeoutAfter>;
  tasks?: Iterable<Task>;
}

export type Handler = (lobby: Lobby) => Change;
export type HandlerWithReturnValue<T> = (
  lobby: Lobby
) => { change: Change; returnValue: T };

function internalApply(
  server: ServerState,
  gameCode: GameCode,
  originalLobby: Lobby,
  change: Change
): {
  lobby?: Lobby;
  timeouts?: Iterable<timeout.TimeoutAfter>;
  tasks?: Iterable<Task>;
} {
  let lobbyUnchanged = change.lobby === undefined;
  const lobby: Lobby =
    change.lobby !== undefined ? change.lobby : originalLobby;
  if (change.events !== undefined) {
    event.send(server.socketManager, gameCode, lobby, change.events);
  }
  let currentLobby = lobby;
  const returnTasks = change.tasks !== undefined ? [...change.tasks] : [];
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
          timeout.handler(server, timeoutAfter.timeout, gameCode, currentLobby)
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
      }
    }
  }
  const lobbyResult = lobbyUnchanged ? {} : { lobby: currentLobby };
  const timeoutResult =
    futureTimeouts.length === 0 ? {} : { timeouts: futureTimeouts };
  const tasksResult = returnTasks.length === 0 ? {} : { tasks: returnTasks };
  return { ...lobbyResult, ...timeoutResult, ...tasksResult };
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
  timeoutId?: timeout.Id
): Promise<T> {
  const [tasks, returnValue] = await server.store.writeAndReturn(
    gameCode,
    lobby => {
      const { change, returnValue } = handler(lobby);
      const result = internalApply(server, gameCode, lobby, change);
      return {
        transaction: {
          lobby: result.lobby,
          timeouts: result.timeouts,
          executedTimeout: timeoutId
        },
        result: [result.tasks, returnValue]
      };
    }
  );
  if (tasks !== undefined) {
    for (const task of tasks) {
      await server.tasks.enqueue(server, task);
    }
  }
  return returnValue;
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
  timeoutId?: timeout.Id
): Promise<void> {
  await applyAndReturn(server, gameCode, lobby => ({
    change: handler(lobby),
    returnValue: undefined
  }));
}
