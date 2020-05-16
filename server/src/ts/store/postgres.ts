import Pg from "pg";
import * as uuid from "uuid";
import { CreateLobby } from "../action/initial/create-lobby";
import * as Config from "../config";
import { LobbyClosedError } from "../errors/lobby";
import * as Lobby from "../lobby";
import * as GameCode from "../lobby/game-code";
import * as Store from "../store";
import * as Timeout from "../timeout";
import * as Token from "../user/token";
import * as Postgres from "../util/postgres";
import * as LobbyConfig from "../lobby/config";
import { LoadDeckSummary } from "../task/load-deck-summary";
import * as Task from "../task";

class To0 extends Postgres.Upgrade<undefined, 0> {
  public readonly to = 0;

  public async apply(client: Pg.PoolClient): Promise<0> {
    await client.query("CREATE SCHEMA massivedecks;");
    await client.query(
      "CREATE TABLE massivedecks.meta ( version INTEGER NOT NULL, id UUID NOT NULL );"
    );
    await client.query(`
          CREATE TABLE massivedecks.lobbies ( 
            id SERIAL PRIMARY KEY, 
            lobby JSONB NOT NULL, 
            last_access TIMESTAMP DEFAULT NOW() 
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
      this.to,
      uuid.v4(),
    ]);
    return this.to;
  }
}

const upgrades: Postgres.Upgrades = (version) => {
  switch (version) {
    case undefined:
      return new To0(version);

    case 0:
      return undefined;

    default:
      throw new Error("Database is on unsupported version, can't upgrade.");
  }
};

/**
 * A store where the data is stored in a PostgreSQL database.
 */
export class PostgresStore extends Store.Store {
  public readonly config: Config.PostgreSQL;
  private readonly cachedId: string;
  private readonly pg: Postgres.Postgres;

  public static async create(
    config: Config.PostgreSQL
  ): Promise<PostgresStore> {
    const pg = new Postgres.Postgres(
      "massivedecks",
      config.connection,
      upgrades
    );
    await pg.ensureCurrent();
    return await pg.withClient(async (client) => {
      const rows = await client.query(`SELECT id FROM massivedecks.meta`);
      return new PostgresStore(rows.rows[0]["id"], config, pg);
    });
  }

  private constructor(
    id: string,
    config: Config.PostgreSQL,
    pg: Postgres.Postgres
  ) {
    super();
    this.cachedId = id;
    this.config = config;
    this.pg = pg;
  }

  public async id(): Promise<string> {
    return this.cachedId;
  }

  public async exists(gameCode: GameCode.GameCode): Promise<boolean> {
    const lobbyId = GameCode.decode(gameCode);
    return await this.pg.withClient(
      async (client) =>
        (
          await client.query(
            "SELECT EXISTS (SELECT id FROM massivedecks.lobbies WHERE id = $1)",
            [lobbyId]
          )
        ).rows[0].exists
    );
  }

  public async delete(gameCode: GameCode.GameCode): Promise<void> {
    const lobbyId = GameCode.decode(gameCode);
    await this.pg.withClient(
      async (client) =>
        await client.query("DELETE FROM massivedecks.lobbies WHERE id = $1", [
          lobbyId,
        ])
    );
  }

  public async garbageCollect(): Promise<number> {
    return await this.pg.withClient(async (client) => {
      const result = await client.query(
        `
          DELETE FROM massivedecks.lobbies WHERE
            ((last_access + $1::interval ) < NOW()) OR
            (SELECT bool_and(value->>'control' = 'Computer' OR value->>'presence' = 'Left') FROM jsonb_each(lobby->'users'));
        `,
        [`${this.config.abandonedTime} milliseconds`]
      );
      return result.rowCount;
    });
  }

  public async *lobbySummaries(): AsyncIterableIterator<Lobby.Summary> {
    yield* this.pg.withClientIterator(
      PostgresStore.lobbySummariesInternal.bind(this)
    );
  }

  private static async *lobbySummariesInternal(
    client: Pg.PoolClient
  ): AsyncIterableIterator<Lobby.Summary> {
    const result = await client.query("SELECT * FROM massivedecks.summaries");
    for (const { id, name, started, ended, users, password } of result.rows) {
      yield {
        gameCode: GameCode.encode(id),
        name,
        state: !started || ended ? "SettingUp" : "Playing",
        users: {
          players: users["Player"] || 0,
          spectators: users["Spectator"] || 0,
        },
        password,
      };
    }
  }

  public async newLobby(
    creation: CreateLobby,
    secret: string,
    defaults: LobbyConfig.Defaults
  ): Promise<{
    gameCode: GameCode.GameCode;
    token: Token.Token;
    tasks: Iterable<Task.Task>;
  }> {
    return await this.pg.withClient(async (client) => {
      const { lobby, tasks } = Lobby.create(
        "fake-game-code",
        creation,
        defaults
      );
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
            uid: lobby.owner,
          },
          await this.id(),
          secret
        ),
        tasks: tasks.map((task) => new LoadDeckSummary(gameCode, task.source)),
      };
    });
  }

  public async *timedOut(): AsyncIterableIterator<Timeout.TimedOut> {
    yield* this.pg.withClientIterator(PostgresStore.timedOutInternal);
  }

  private static async *timedOutInternal(
    client: Pg.PoolClient
  ): AsyncIterableIterator<Timeout.TimedOut> {
    const result = await client.query(
      "SELECT * FROM massivedecks.timeouts WHERE after < $1;",
      [Date.now()]
    );
    for (const row of result.rows) {
      yield {
        id: row["id"],
        lobby: GameCode.encode(row["lobby"]),
        timeout: row["timeout"],
      };
    }
  }

  public async writeAndReturn<T>(
    gameCode: string,
    write: (lobby: Lobby.Lobby) => { transaction: Store.Transaction; result: T }
  ): Promise<T> {
    const lobbyId = GameCode.decode(gameCode);
    return await this.pg.inTransaction(async (client) => {
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
          "UPDATE massivedecks.lobbies SET lobby=$2, last_access=NOW() WHERE id = $1;",
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
        await client.query("DELETE FROM massivedecks.timeouts WHERE id = $1", [
          transaction.executedTimeout,
        ]);
      }
      return result;
    });
  }
}
