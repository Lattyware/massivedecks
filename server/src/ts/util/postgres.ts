import Pg from "pg";
import * as Logging from "../logging";

/**
 * A version for the database. Undefined if none exists.
 */
export type Version = number | undefined;
/**
 * Get the upgrade for the given version to take it to a future version.
 * Returns undefined if the version is current.
 * If the given version doesn't have an upgrade and isn't current, throws an
 * exception.
 */
export type Upgrades = (
  version: Version
) => Upgrade<Version, Version> | undefined;

/**
 * A helper class for working with a PostgreSQL database.
 */
export class Postgres {
  public readonly schema: string;
  private readonly pool: Pg.Pool;
  private readonly upgrades: Upgrades;

  constructor(schema: string, config: Pg.PoolConfig, upgrades: Upgrades) {
    this.schema = schema;
    this.pool = new Pg.Pool(config);
    this.upgrades = upgrades;
  }

  /**
   * Ensure the database is set up for the current version.
   */
  public async ensureCurrent(): Promise<void> {
    await this.inTransaction(async (client) => {
      let version = await this.findVersion(client);
      while (true) {
        const upgrade = this.upgrades(version);
        if (upgrade === undefined) {
          return;
        }
        const oldVersion = version;
        version = await upgrade.apply(client);
        if (oldVersion == undefined) {
          Logging.logger.info(`Created '${this.schema}' at '${version}'`);
        } else {
          Logging.logger.info(
            `Upgraded '${this.schema}' from '${oldVersion}' to '${version}'.`
          );
        }
      }
    });
  }

  /**
   * Perform the given action with a client from the pool, releasing it when
   * done.
   */
  public async withClient<Result>(
    f: (client: Pg.PoolClient) => Promise<Result>
  ): Promise<Result> {
    const client = await this.pool.connect();
    try {
      return await f(client);
    } finally {
      client.release();
    }
  }

  /**
   * Perform the given action with a client from the pool, releasing it when
   * done.
   */
  public async *withClientIterator<Result>(
    f: (client: Pg.PoolClient) => AsyncIterableIterator<Result>
  ): AsyncIterableIterator<Result> {
    const client = await this.pool.connect();
    try {
      yield* await f(client);
    } finally {
      client.release();
    }
  }

  /**
   * Try to perform the given function in a transaction, and if there is an
   * exception roll back all the database operations performed.
   * @param f the function to execute.
   */
  public async inTransaction<Result>(
    f: (client: Pg.PoolClient) => Promise<Result>
  ): Promise<Result> {
    return await this.withClient(async (client) => {
      await client.query("BEGIN;");
      try {
        const result = await f(client);
        await client.query("COMMIT;");
        return result;
      } catch (e) {
        await client.query("ROLLBACK;");
        throw e;
      }
    });
  }

  private async findVersion(client: Pg.PoolClient): Promise<Version> {
    const exists = await client.query(
      `SELECT EXISTS (SELECT FROM information_schema.schemata WHERE schema_name = '${this.schema}');`
    );
    if (exists.rows[0]["exists"]) {
      const rows = await client.query(
        `SELECT version FROM ${this.schema}.meta;`
      );
      const row = rows.rows[0];
      return row["version"];
    } else {
      return undefined;
    }
  }
}

/**
 * An upgrade describes how to upgrade from the given version to a future one.
 */
export abstract class Upgrade<From extends Version, To extends Version> {
  public readonly from: From;
  public abstract readonly to: To;

  public constructor(version: From) {
    this.from = version;
  }

  /**
   * Upgrades the database and then returns the new version.
   */
  public abstract async apply(client: Pg.PoolClient): Promise<To>;
}
