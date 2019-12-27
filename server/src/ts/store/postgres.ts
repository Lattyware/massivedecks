// import { Client } from "ts-postgres/src/client";
import { CreateLobby } from "../action/initial/create-lobby";
import * as config from "../config";
import * as lobby from "../lobby";
import { Lobby } from "../lobby";
import { GameCode } from "../lobby/game-code";
import * as store from "../store";
import { Store } from "../store";
import * as timeout from "../timeout";
import { Token } from "../user/token";

// const idColumn = "id";
// const versionColumn = "version";

/**
 * A store where the data is stored in a PostgreSQL database.
 */
export class PostgresStore extends Store {
  private static readonly version = 0;

  public readonly config: config.PostgreSQL;
  // private readonly pool: Pool<Client>;
  private readonly cachedId: string;

  public static async create(
    config: config.PostgreSQL
  ): Promise<PostgresStore> {
    throw new Error();
    // const client = await this.newClient(config.connection);
    // try {
    //   const rows = client.query(
    //     `SELECT version, ${idColumn} FROM massivedecks.meta`
    //   );
    //   const row = await rows.one();
    //   const version = row.get(versionColumn);
    //   if (version !== PostgresStore.version) {
    //     // noinspection ExceptionCaughtLocallyJS
    //     throw new Error(
    //       `Database at incorrect version (expected ` +
    //         `"${PostgresStore.version}" got "${version}"). Please upgrade.`
    //     );
    //   }
    //   return new PostgresStore(row.get(idColumn) as string, config);
    // } catch (error) {
    //   logging.logger.error("Database is not configured correctly.");
    //   throw error;
    // } finally {
    //   this.destroyClient(client);
    // }
  }
  //
  // // Only use statically, use the pool instead internally.
  // private static async newClient(
  //   connection: config.PostgreSqlConnection
  // ): Promise<Client> {
  //   // const client = new Client(connection);
  //   // await client.connect();
  //   // client.on("error", error =>
  //   //   logging.logger.error("Error from database client: ", error.message)
  //   // );
  //   // return client;
  // }
  //
  // private static async destroyClient(client: Client): Promise<void> {
  //   await client.end();
  // }
  //
  private constructor(id: string, config: config.PostgreSQL) {
    super();
    this.cachedId = id;
    this.config = config;
    // this.pool = genericPool.createPool(
    //   {
    //     create: async () =>
    //       await PostgresStore.newClient(this.config.connection),
    //     destroy: PostgresStore.destroyClient,
    //     validate: async (client: Client) => !client.closed
    //   },
    //   { testOnBorrow: true }
    // );
  }

  public async id(): Promise<string> {
    return this.cachedId;
  }

  public async exists(gameCode: string): Promise<boolean> {
    return false;
  }

  public async delete(gameCode: string): Promise<void> {
    // TODO: Impl.
    return;
  }

  public async garbageCollect(): Promise<number> {
    // TODO: Impl.
    return 0;
  }

  public async *lobbySummaries(): AsyncIterableIterator<lobby.Summary> {
    // // TODO: Caching.
    // const client = await this.pool.acquire();
    // try {
    //   return;
    // } finally {
    //   this.pool.release(client);
    // }
  }

  public async newLobby(
    creation: CreateLobby,
    secret: string
  ): Promise<{ gameCode: GameCode; token: Token }> {
    // const client = await this.pool.acquire();
    // try {
    return { gameCode: "", token: "" };
    // } finally {
    //   this.pool.release(client);
    // }
  }

  public async *timedOut(): AsyncIterableIterator<timeout.TimedOut> {
    // const client = await this.pool.acquire();
    // try {
    //   return;
    // } finally {
    //   this.pool.release(client);
    // }
  }

  public async writeAndReturn<T>(
    gameCode: string,
    write: (lobby: Lobby) => { transaction: store.Transaction; result: T }
  ): Promise<T> {
    // const client = await this.pool.acquire();
    // try {
    //   const { result } = write((undefined as unknown) as Lobby);
    //   return result;
    // } finally {
    //   this.pool.release(client);
    // }
    throw new Error();
  }
}
