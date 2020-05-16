import { Lobby } from "./lobby";
import * as Change from "./lobby/change";
import { GameCode } from "./lobby/game-code";
import { ServerState } from "./server-state";

/**
 * A good base implementation of a task.
 */
export abstract class TaskBase<T> implements Task {
  private readonly gameCode: GameCode;

  protected constructor(gameCode: GameCode) {
    this.gameCode = gameCode;
  }

  protected abstract async begin(server: ServerState): Promise<T>;

  protected abstract resolve(
    lobby: Lobby,
    work: T,
    server: ServerState
  ): Change.Change;
  protected resolveError(
    lobby: Lobby,
    error: Error,
    server: ServerState
  ): Change.Change {
    throw error;
  }

  public async handle(server: ServerState): Promise<void> {
    let work: T;
    try {
      work = await this.begin(server);
    } catch (error) {
      await Change.apply(server, this.gameCode, (lobby) =>
        this.resolveError(lobby, error, server)
      );
      return;
    }
    await Change.apply(server, this.gameCode, (lobby) =>
      this.resolve(lobby, work, server)
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
