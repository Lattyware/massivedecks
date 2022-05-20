import type { Lobby } from "./lobby.js";
import * as Change from "./lobby/change.js";
import type { GameCode } from "./lobby/game-code.js";
import type { ServerState } from "./server-state.js";

/**
 * A good base implementation of a task.
 */
export abstract class TaskBase<T> implements Task {
  private readonly gameCode: GameCode;

  protected constructor(gameCode: GameCode) {
    this.gameCode = gameCode;
  }

  protected abstract begin(server: ServerState): Promise<T>;

  protected abstract resolve(
    lobby: Lobby,
    work: T,
    server: ServerState,
  ): Change.Change;
  protected resolveError(
    _lobby: Lobby,
    error: Error,
    _server: ServerState,
  ): Change.Change {
    throw error;
  }

  public async handle(server: ServerState): Promise<void> {
    let work: T;
    try {
      work = await this.begin(server);
    } catch (e) {
      const error = e as Error;
      await Change.apply(server, this.gameCode, (lobby) =>
        this.resolveError(lobby, error, server),
      );
      return;
    }
    await Change.apply(server, this.gameCode, (lobby) =>
      this.resolve(lobby, work, server),
    );
  }
}

/**
 * A task is a long-running process for a lobby.
 * It must be discoverable by inspecting the state of the lobby, as they are not
 * stored in the store, but will be discovered on restart.
 */
export interface Task {
  handle: (server: ServerState) => Promise<void>;
}
