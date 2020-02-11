import Pg from "pg";
import uuid from "uuid/v4";
import { CreateLobby } from "../action/initial/create-lobby";
import * as Config from "../config";
import { LobbyClosedError } from "../errors/lobby";
import * as Lobby from "../lobby";
import * as GameCode from "../lobby/game-code";
import * as Logging from "../logging";
import * as Store from "../store";
import * as Timeout from "../timeout";
import * as Token from "../user/token";

const idColumn = "id";
const versionColumn = "version";

/**
 * A store where the data is stored in a PostgreSQL database.
 */
export class PostgresStore extends Store.Store {
  private static readonly version = 0;

  public readonly config: Config.PostgreSQL;
  private readonly pool: Pg.Pool;
  private readonly cachedId: string;

  public static async create(
    config: Config.PostgreSQL
  ): Promise<PostgresStore> {
    const client = await new Pg.Client(config.connection);
    try {
      client.connect();
      const exists = await client.query(
        "SELECT EXISTS (SELECT FROM information_schema.schemata WHERE schema_name = 'massivedecks');"
      );
      if (!exists.rows[0]["exists"]) {
        await client.query("CREATE SCHEMA massivedecks;");
        await client.query(
          "CREATE TABLE massivedecks.meta ( version INTEGER NOT NULL, id UUID NOT NULL );"
        );
        await client.query(`
          CREATE TABLE massivedecks.lobbies ( 
            id SERIAL PRIMARY KEY, 
            lobby JSONB NOT NULL, 
            last_access TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
          );
        `);
        await client.query(`
          CREATE TABLE massivedecks.timeouts ( 
            id SERIAL PRIMARY KEY, 
            lobby INTEGER NOT NULL REFERENCES massivedecks.lobbies(id) ON DELETE CASCADE, 
            after BIGINT NOT NULL, 
            timeout JSONB NOT NULL 
          );
        `);
        await client.query(`
          CREATE VIEW massivedecks.summaries AS SELECT 
            id, 
            lobby->'name' AS name, 
            lobby->'game' IS NULL AS started, 
            lobby->'game'->'winner' AS ended, 
            (SELECT json_object_agg(u.role, u.count) 
             FROM
              (SELECT value->>'role' AS role, count(*) 
               FROM jsonb_each(lobby->'users') GROUP BY value->>'role'
              ) u 
            ) AS users,
            lobby->'password' IS NOT NULL AS password 
          FROM massivedecks.lobbies WHERE (lobby->'config'->'public')::boolean = true;
        `);
        await client.query("INSERT INTO massivedecks.meta VALUES ($1, $2);", [
          PostgresStore.version,
          uuid()
        ]);
      }
      const rows = await client.query(
        `SELECT version, ${idColumn} FROM massivedecks.meta`
      );
      const row = rows.rows[0];
      const version = row[versionColumn];
      if (version !== PostgresStore.version) {
        // noinspection ExceptionCaughtLocallyJS
        throw new Error(
          `Database at incorrect version (expected ` +
            `"${PostgresStore.version}" got "${version}"). Please upgrade.`
        );
      }
      return new PostgresStore(row[idColumn] as string, config);
    } catch (error) {
      Logging.logException("Database is not configured correctly.", error);
      throw error;
    } finally {
      await this.destroyClient(client);
    }
  }

  private static async destroyClient(client: Pg.Client): Promise<void> {
    await client.end();
  }

  private constructor(id: string, config: Config.PostgreSQL) {
    super();
    this.cachedId = id;
    this.config = config;
    this.pool = new Pg.Pool({ ...config.connection });
  }

  public async id(): Promise<string> {
    return this.cachedId;
  }

  private async lobbyQuery<Result>(
    gameCode: GameCode.GameCode,
    f: (lobbyId: GameCode.LobbyId, client: Pg.PoolClient) => Promise<Result>
  ): Promise<Result> {
    const lobbyId = GameCode.decode(gameCode);
    const client = await this.pool.connect();
    try {
      return await f(lobbyId, client);
    } finally {
      await client.release();
    }
  }

  public async exists(gameCode: GameCode.GameCode): Promise<boolean> {
    return await this.lobbyQuery(
      gameCode,
      async (lobbyId, client) =>
        (
          await client.query(
            "SELECT EXISTS (SELECT id FROM massivedecks.lobbies WHERE id = $1)",
            [lobbyId]
          )
        ).rows[0]
    );
  }

  public async delete(gameCode: GameCode.GameCode): Promise<void> {
    await this.lobbyQuery(
      gameCode,
      async (lobbyId, client) =>
        await client.query("DELETE FROM massivedecks.lobbies WHERE id = $1", [
          lobbyId
        ])
    );
  }

  public async garbageCollect(): Promise<number> {
    const client = await this.pool.connect();
    try {
      const result = await client.query(
        `
          DELETE FROM massivedecks.lobbies WHERE
            (last_access + $1::interval) < CURRENT_TIMESTAMP OR
            (SELECT bool_and(value->>'control' = 'Computer' OR value->>'Presence' = 'Left') FROM jsonb_each(lobby->'users'));
        `,
        [`${this.config.abandonedTime} milliseconds`]
      );
      return result.rowCount;
    } finally {
      await client.release();
    }
  }

  public async *lobbySummaries(): AsyncIterableIterator<Lobby.Summary> {
    const client = await this.pool.connect();
    try {
      const result = await client.query("SELECT * FROM massivedecks.summaries");
      for (const { id, name, started, ended, users, password } of result.rows) {
        yield {
          gameCode: GameCode.encode(id),
          name,
          state: !started || ended ? "SettingUp" : "Playing",
          users: {
            players: users["Player"] || 0,
            spectators: users["Spectator"] || 0
          },
          password
        };
      }
    } finally {
      await client.release();
    }
  }

  public async newLobby(
    creation: CreateLobby,
    secret: string
  ): Promise<{ gameCode: GameCode.GameCode; token: Token.Token }> {
    const client = await this.pool.connect();
    try {
      const lobby = Lobby.create(creation);
      const result = await client.query(
        "INSERT INTO massivedecks.lobbies VALUES (DEFAULT, $1) RETURNING id",
        [lobby]
      );
      const gameCode = GameCode.encode(result.rows[0]["id"]);
      return {
        gameCode,
        token: Token.create(
          {
            gc: gameCode,
            uid: lobby.owner
          },
          await this.id(),
          secret
        )
      };
    } finally {
      await client.release();
    }
  }

  public async *timedOut(): AsyncIterableIterator<Timeout.TimedOut> {
    const client = await this.pool.connect();
    try {
      const result = await client.query(
        "SELECT * FROM massivedecks.timeouts WHERE after < $1",
        [Date.now()]
      );
      for (const row of result.rows) {
        yield {
          id: row["id"],
          lobby: GameCode.encode(row["lobby"]),
          timeout: row["timeout"]
        };
      }
    } finally {
      await client.release();
    }
  }

  public async writeAndReturn<T>(
    gameCode: string,
    write: (lobby: Lobby.Lobby) => { transaction: Store.Transaction; result: T }
  ): Promise<T> {
    return await this.lobbyQuery(gameCode, async (lobbyId, client) => {
      await client.query("BEGIN;");
      let error = false;
      try {
        const get = await client.query(
          "SELECT lobby FROM massivedecks.lobbies WHERE id = $1;",
          [lobbyId]
        );
        if (get.rowCount < 1) {
          throw new LobbyClosedError(gameCode);
        }
        const { transaction, result } = write(
          Lobby.fromJSON(get.rows[0]["lobby"] as Lobby.Lobby)
        );
        if (transaction.lobby) {
          await client.query(
            "UPDATE massivedecks.lobbies SET lobby=$2, last_access=CURRENT_TIMESTAMP WHERE id = $1;",
            [lobbyId, transaction.lobby]
          );
        }
        if (transaction.timeouts !== undefined) {
          for (const timeout of transaction.timeouts) {
            await client.query(
              "INSERT INTO massivedecks.timeouts VALUES (DEFAULT, $1, $2, $3)",
              [lobbyId, Date.now() + timeout.after, timeout.timeout]
            );
          }
        }
        if (transaction.executedTimeout !== undefined) {
          await client.query(
            "DELETE FROM massivedecks.timeouts WHERE id = $1",
            [transaction.executedTimeout]
          );
        }
        return result;
      } catch (e) {
        error = true;
        throw e;
      } finally {
        if (error) {
          await client.query("ROLLBACK;");
        } else {
          await client.query("COMMIT;");
        }
      }
    });
  }
}
