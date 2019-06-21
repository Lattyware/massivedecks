import { v4 as uuid } from "uuid";
import wu from "wu";
import { CreateLobby } from "../action/initial/create-lobby";
import * as serverConfig from "../config";
import { LobbyClosedError, LobbyDoesNotExistError } from "../errors/lobby";
import * as gameLobby from "../lobby";
import { Lobby } from "../lobby";
import * as lobbyGameCode from "../lobby/game-code";
import { GameCode } from "../lobby/game-code";
import { Store, Transaction } from "../store";
import * as timeout from "../timeout";
import { Timeout } from "../timeout";
import * as token from "../user/token";
import { Token } from "../user/token";

declare module "wu" {
  // Fix incorrect types.
  interface WuIterable<T> {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    spreadMap<U>(fn: (...x: any[]) => U): WuIterable<U>;
  }
}

interface TimeoutMeta {
  timeout: Timeout;
  lobby: GameCode;
  after: number;
}

/**
 * A store where the data is stored in memory.
 */
export class InMemoryStore extends Store {
  public readonly config: serverConfig.InMemory;
  private readonly _id: string;
  private readonly lobbies: Map<GameCode, Lobby>;
  private readonly timeouts: Map<timeout.Id, TimeoutMeta>;
  private nextLobby: number;

  public constructor(config: serverConfig.InMemory) {
    super();
    this.config = config;
    this._id = uuid();
    this.nextLobby = 0;
    this.lobbies = new Map();
    this.timeouts = new Map();
  }

  public id = async (): Promise<string> => this._id;

  public async exists(gameCode: string): Promise<boolean> {
    return this.lobbies.has(gameCode);
  }

  public async *lobbySummaries(): AsyncIterableIterator<gameLobby.Summary> {
    for (const summary of wu(this.lobbies.entries()).spreadMap(
      gameLobby.summary
    )) {
      yield summary;
    }
  }

  public async newLobby(
    creation: CreateLobby,
    secret: string
  ): Promise<{ gameCode: GameCode; token: Token }> {
    const lobby = gameLobby.create(creation);
    const gameCode = lobbyGameCode.encode(this.nextLobby);
    this.nextLobby += 1;
    this.lobbies.set(gameCode, lobby);
    return {
      gameCode,
      token: token.create(
        {
          gc: gameCode,
          uid: lobby.owner,
          pvg: "Privileged"
        },
        this._id,
        secret
      )
    };
  }

  private async lobby(gameCode: GameCode): Promise<Lobby> {
    const lobby = this.lobbies.get(gameCode.toUpperCase());
    if (lobby !== undefined) {
      return lobby;
    } else {
      const lobbyNumber = lobbyGameCode.decode(gameCode);
      if (lobbyNumber < this.nextLobby) {
        throw new LobbyClosedError(gameCode);
      } else {
        throw new LobbyDoesNotExistError(gameCode);
      }
    }
  }

  public async writeAndReturn<T>(
    gameCode: GameCode,
    write: (lobby: Lobby) => { transaction: Transaction; result: T }
  ): Promise<T> {
    const { transaction, result } = write(await this.lobby(gameCode));
    if (transaction.lobby !== undefined) {
      this.lobbies.set(gameCode, transaction.lobby);
    }
    if (transaction.timeouts !== undefined) {
      for (let timeout of transaction.timeouts) {
        this.timeouts.set(uuid(), {
          timeout: timeout.timeout,
          lobby: gameCode,
          after: Date.now() + timeout.after
        });
      }
    }
    if (transaction.executedTimeout !== undefined) {
      this.timeouts.delete(transaction.executedTimeout);
    }
    return result;
  }

  public async garbageCollect(): Promise<number> {
    const toRemove = new Set<GameCode>();
    for (const [gameCode, lobby] of this.lobbies.entries()) {
      // TODO: Also lobbies that have been abandoned for some time.
      // TODO: Make ended a time, wait for config minutes before deleting.
      if (gameLobby.ended(lobby)) {
        toRemove.add(gameCode);
      }
    }
    for (const gameCode of toRemove) {
      this.delete(gameCode);
    }
    return toRemove.size;
  }

  public async delete(gameCode: GameCode): Promise<void> {
    this.lobbies.delete(gameCode);
    for (const [id, meta] of this.timeouts) {
      if (meta.lobby === gameCode) {
        this.timeouts.delete(id);
      }
    }
  }

  public async *timedOut(): AsyncIterableIterator<timeout.TimedOut> {
    for (const [id, meta] of this.timeouts) {
      if (Date.now() > meta.after) {
        yield {
          id,
          timeout: meta.timeout,
          lobby: meta.lobby
        };
      }
    }
  }
}
