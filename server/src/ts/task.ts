import { Lobby } from "./lobby";
import * as change from "./lobby/change";
import { Change } from "./lobby/change";
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
  protected abstract resolve(lobby: Lobby, work: T): Change;

  public async handle(server: ServerState): Promise<void> {
    const work = await this.begin(server);
    await change.apply(server, this.gameCode, lobby =>
      this.resolve(lobby, work)
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
