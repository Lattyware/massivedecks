import * as uuid from "uuid";
import wu from "wu";
import { CreateLobby } from "../action/initial/create-lobby";
import * as ServerConfig from "../config";
import { LobbyClosedError, LobbyDoesNotExistError } from "../errors/lobby";
import * as Lobby from "../lobby";
import * as GameCode from "../lobby/game-code";
import { Store, Transaction } from "../store";
import * as Timeout from "../timeout";
import * as Token from "../user/token";
import * as LobbyConfig from "../lobby/config";
import { Task } from "../task";

declare module "wu" {
  // Fix incorrect types.
  // noinspection JSUnusedGlobalSymbols
  interface WuIterable<T> {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    spreadMap<U>(fn: (...x: any[]) => U): WuIterable<U>;
  }
}

interface TimeoutMeta {
  timeout: Timeout.Timeout;
  lobby: GameCode.GameCode;
  after: number;
}

interface LobbyMeta {
  lobby: Lobby.Lobby;
  lastWrite: number;
}

/**
 * A store where the data is stored in memory.
 */
export class InMemoryStore extends Store {
  public readonly config: ServerConfig.InMemory;
  private readonly _id: string;
  private readonly lobbies: Map<GameCode.GameCode, LobbyMeta>;
  private readonly timeouts: Map<Timeout.Id, TimeoutMeta>;
  private nextLobby: number;

  public constructor(config: ServerConfig.InMemory) {
    super();
    this.config = config;
    this._id = uuid.v4();
    this.nextLobby = 0;
    this.lobbies = new Map();
    this.timeouts = new Map();
  }

  public id = async (): Promise<string> => this._id;

  public async exists(gameCode: string): Promise<boolean> {
    return this.lobbies.has(gameCode);
  }

  public async *lobbySummaries(): AsyncIterableIterator<Lobby.Summary> {
    const publicSummaries = wu(this.lobbies.entries())
      .filter(([_, { lobby }]) => lobby.config.public)
      .map(([gameCode, { lobby }]) => Lobby.summary(gameCode, lobby));
    for (const summary of publicSummaries) {
      yield summary;
    }
  }

  public async newLobby(
    creation: CreateLobby,
    secret: string,
    defaults: LobbyConfig.Defaults
  ): Promise<{
    gameCode: GameCode.GameCode;
    token: Token.Token;
    tasks: Iterable<Task>;
  }> {
    const gameCode = GameCode.encode(this.nextLobby);
    const { lobby, tasks } = Lobby.create(gameCode, creation, defaults);
    this.nextLobby += 1;
    this.lobbies.set(gameCode, { lobby, lastWrite: Date.now() });
    return {
      gameCode,
      token: Token.create(
        {
          gc: gameCode,
          uid: lobby.owner,
        },
        this._id,
        secret
      ),
      tasks,
    };
  }

  private async lobby(gameCode: GameCode.GameCode): Promise<Lobby.Lobby> {
    const lobby = this.lobbies.get(gameCode.toUpperCase());
    if (lobby !== undefined) {
      return lobby.lobby;
    } else {
      const lobbyNumber = GameCode.decode(gameCode);
      if (lobbyNumber < this.nextLobby) {
        throw new LobbyClosedError(gameCode);
      } else {
        throw new LobbyDoesNotExistError(gameCode);
      }
    }
  }

  public async writeAndReturn<T>(
    gameCode: GameCode.GameCode,
    write: (lobby: Lobby.Lobby) => { transaction: Transaction; result: T }
  ): Promise<T> {
    const { transaction, result } = write(await this.lobby(gameCode));
    if (transaction.lobby !== undefined) {
      this.lobbies.set(gameCode, {
        lobby: transaction.lobby,
        lastWrite: Date.now(),
      });
    }
    if (transaction.timeouts !== undefined) {
      for (const timeout of transaction.timeouts) {
        this.timeouts.set(uuid.v4(), {
          timeout: timeout.timeout,
          lobby: gameCode,
          after: Date.now() + timeout.after,
        });
      }
    }
    if (transaction.executedTimeout !== undefined) {
      this.timeouts.delete(transaction.executedTimeout);
    }
    return result;
  }

  public async garbageCollect(): Promise<number> {
    const toRemove = new Set<GameCode.GameCode>();
    for (const [gameCode, { lobby, lastWrite }] of this.lobbies.entries()) {
      if (
        lastWrite + this.config.abandonedTime < Date.now() ||
        wu(Object.values(lobby.users)).every(
          (u) => u.control === "Computer" || u.presence === "Left"
        )
      ) {
        toRemove.add(gameCode);
      }
    }
    for (const gameCode of toRemove) {
      await this.delete(gameCode);
    }
    return toRemove.size;
  }

  public async delete(gameCode: GameCode.GameCode): Promise<void> {
    this.lobbies.delete(gameCode);
    for (const [id, meta] of this.timeouts) {
      if (meta.lobby === gameCode) {
        this.timeouts.delete(id);
      }
    }
  }

  public async *timedOut(): AsyncIterableIterator<Timeout.TimedOut> {
    const done = [];
    for (const [id, meta] of this.timeouts) {
      if (Date.now() > meta.after) {
        yield {
          id,
          timeout: meta.timeout,
          lobby: meta.lobby,
        };
        done.push(id);
      }
    }
    for (const id of done) {
      this.timeouts.delete(id);
    }
  }
}
