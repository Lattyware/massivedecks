import type { Lobby } from "../lobby.js";
import type { GameCode } from "../lobby/game-code.js";
import * as Logging from "../logging.js";
import type { ServerState } from "../server-state.js";
import type { Task } from "../task.js";
import { LoadDeckSummary } from "./load-deck-summary.js";
import { StartGame } from "./start-game.js";

interface Discoverable {
  discover: (gameCode: GameCode, lobby: Lobby) => Iterable<Task>;
}

/**
 * A task queue for processing tasks in the background.
 */
export class Queue {
  private static readonly tasks: Discoverable[] = [LoadDeckSummary, StartGame];
  /**
   * The maximum number of tasks that will be executed in a tick.
   */
  public readonly rateLimit: number;
  private readonly tasks: Task[];
  private startedThisTick: number;

  constructor(rateLimit: number) {
    this.rateLimit = rateLimit;
    this.startedThisTick = 0;
    this.tasks = [];
  }

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
      await server.store.read(gameCode, (lobby) => {
        for (const task of Queue.discover(gameCode, lobby)) {
          this.enqueue(server, task);
        }
        return { transaction: {}, result: undefined };
      });
    }
  }

  /**
   * Enqueue a new background task to be executed when possible.
   */
  public enqueue(server: ServerState, task: Task): void {
    if (this.startedThisTick <= this.rateLimit) {
      this.start(server, task);
    } else {
      this.tasks.unshift(task);
    }
  }

  /**
   * Process the queue, starting queued jobs.
   */
  public process(server: ServerState): void {
    this.startedThisTick = 0;
    while (this.startedThisTick <= this.rateLimit) {
      const task = this.tasks.pop();
      if (task !== undefined) {
        this.start(server, task);
      } else {
        break;
      }
    }
  }

  private start(server: ServerState, task: Task): void {
    Logging.logger.debug("Task started:", { task });
    this.startedThisTick += 1;
    task
      .handle(server)
      .catch((error) => Logging.logException("Error processing task:", error))
      .then(() => Logging.logger.info("Task complete:", { task }));
  }
}
