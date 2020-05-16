import { CreateLobby } from "./action/initial/create-lobby";
import * as ServerConfig from "./config";
import * as Lobby from "./lobby";
import { GameCode } from "./lobby/game-code";
import * as Timeout from "./timeout";
import { Token } from "./user/token";
import { Task } from "./task";
import * as LobbyConfig from "./lobby/config";

/**
 * Represents a chunk of data that should be written as a single transaction,
 * so if the server was restarted either all are applied or none are.
 */
export interface Transaction {
  /**
   * New lobby data that should replace what is currently in the store.
   */
  lobby?: Lobby.Lobby;
  /**
   * If given, timeouts that should be added to the store.
   */
  timeouts?: Iterable<Timeout.After>;
  /**
   * If given, the id of the timeout that this resolves, and so should be
   * removed from the store.
   */
  executedTimeout?: Timeout.Id;
}

export type ReadOnlyTransaction = Transaction & {
  lobby?: undefined;
  timeouts?: Iterable<Timeout.After & { after: Exclude<number, 0> }>;
};

export abstract class Store {
  /**
   * The configuration for this store.
   */
  public abstract readonly config: ServerConfig.Storage;

  /**
   * A unique id for the store - this *must* be unique to the store, otherwise
   * there is a chance reused lobby codes could be incorrectly accessed by users
   * using old tokens. When this changes, it makes all previously issued tokens
   * invalid, but if there is any security concern, change the application
   * secret, not this. That will have the same effect securely.
   */
  public abstract async id(): Promise<string>;

  /**
   * Returns if the given lobby exists.
   */
  public abstract async exists(gameCode: GameCode): Promise<boolean>;

  /** Create a new lobby.
   * @return The game code for the new lobby and the user id for the owner.
   */
  public abstract async newLobby(
    creation: CreateLobby,
    secret: string,
    defaults: LobbyConfig.Defaults
  ): Promise<{ gameCode: GameCode; token: Token; tasks: Iterable<Task> }>;

  /**
   * An operation that doesn't make any changes to the lobby.
   * @param gameCode The game code for the lobby to modify.
   * @param read The operation to perform.
   */
  public async read<T>(
    gameCode: GameCode,
    read: (
      lobby: Lobby.Lobby
    ) => { transaction: ReadOnlyTransaction; result: T }
  ): Promise<T> {
    return this.writeAndReturn(gameCode, read);
  }

  /**
   * Perform a write operation on a lobby.
   * If you make changes to the object as given, you must return it.
   * @param gameCode The game code for the lobby to modify.
   * @param write The operation to perform.
   */
  public async write(
    gameCode: GameCode,
    write: (lobby: Lobby.Lobby) => Transaction
  ): Promise<void> {
    await this.writeAndReturn(gameCode, (lobby: Lobby.Lobby) => ({
      transaction: write(lobby),
      result: undefined,
    }));
  }

  public abstract async writeAndReturn<T>(
    gameCode: GameCode,
    write: (lobby: Lobby.Lobby) => { transaction: Transaction; result: T }
  ): Promise<T>;

  /** Get a list of summaries for all the public lobbies in the store.*/
  public abstract lobbySummaries(): AsyncIterableIterator<Lobby.Summary>;

  /**
   * Get all timed out timeouts from the store.
   */
  public abstract timedOut(): AsyncIterableIterator<Timeout.TimedOut>;

  /**
   * Delete the given lobby and all associated timeouts.
   */
  public abstract async delete(gameCode: GameCode): Promise<void>;

  /**
   * Remove lobbies where the game is finished or everyone has been
   * disconnected for some time.
   * This should also clean up the cache as appropriate.
   */
  public abstract async garbageCollect(): Promise<number>;
}
