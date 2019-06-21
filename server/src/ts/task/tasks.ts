import { Lobby } from "../lobby";
import { GameCode } from "../lobby/game-code";
import * as logging from "../logging";
import { ServerState } from "../server-state";
import { Task } from "../task";
import { LoadDeckSummary } from "./load-deck-summary";
import { StartGame } from "./start-game";

interface Discoverable {
  discover: (gameCode: GameCode, lobby: Lobby) => Iterable<Task>;
}

/**
 * A task queue for processing tasks in the background.
 */
export class Queue {
  private static readonly tasks: Discoverable[] = [LoadDeckSummary, StartGame];

  /**
   * Discover tasks that need to be run for the given lobby state.
   */
  private static *discover(gameCode: GameCode, lobby: Lobby): Iterable<Task> {
    for (const task of Queue.tasks) {
      yield* task.discover(gameCode, lobby);
    }
  }

  /**
   * Search the store for lobbies and start any tasks necessary given their
   * current state.
   */
  public async loadFromStore(server: ServerState): Promise<void> {
    for await (const { gameCode } of server.store.lobbySummaries()) {
      await server.store.read(gameCode, lobby => {
        for (const task of Queue.discover(gameCode, lobby)) {
          this.enqueue(server, task);
        }
        return { transaction: {}, result: undefined };
      });
    }
  }

  // TODO: Real queuing.
  // Probably not a huge deal, but we might go a bit nuts at startup in some
  // cases.
  /**
   * Start a new background task.
   */
  public enqueue(server: ServerState, task: Task): void {
    logging.logger.info("Task queued:", { task });
    task
      .handle(server)
      .catch(error => logging.logException("Error processing task:", error))
      .then(() => logging.logger.info("Task complete:", { task }));
  }
}
