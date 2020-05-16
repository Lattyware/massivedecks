import Pg from "pg";
import * as Cache from "../cache";
import * as Config from "../config";
import * as Decks from "../games/cards/decks";
import * as Source from "../games/cards/source";
import * as Postgres from "../util/postgres";
import * as Card from "../games/cards/card";
import * as uuid from "uuid";

class To1 extends Postgres.Upgrade<0, 1> {
  public readonly to = 1;

  public async apply(client: Pg.PoolClient): Promise<1> {
    await client.query(`
      ALTER TABLE mdcache.summaries ADD COLUMN author TEXT;
      ALTER TABLE mdcache.summaries ADD COLUMN language TEXT;
      ALTER TABLE mdcache.summaries ADD COLUMN translator TEXT;
    `);
    await client.query("UPDATE mdcache.meta SET version = $1;", [this.to]);
    return this.to;
  }
}

class To0 extends Postgres.Upgrade<undefined, 0> {
  public readonly to = 0;

  public async apply(client: Pg.PoolClient): Promise<0> {
    await client.query("CREATE SCHEMA mdcache;");
    await client.query(
      "CREATE TABLE mdcache.meta ( version INTEGER NOT NULL );"
    );
    await client.query(`
      CREATE TABLE mdcache.decks (
        source TEXT NOT NULL, 
        id TEXT NOT NULL,
        cards_updated BIGINT,
        cards_tag TEXT,
        PRIMARY KEY (source, id)
      );
    `);
    await client.query(`
      CREATE TABLE mdcache.summaries (
        source TEXT NOT NULL, 
        deck TEXT NOT NULL,
        name TEXT NOT NULL,
        url TEXT,
        calls INTEGER NOT NULL,
        responses INTEGER NOT NULL,
        updated BIGINT NOT NULL,
        tag TEXT,
        FOREIGN KEY (source, deck) REFERENCES mdcache.decks (source, id) ON DELETE CASCADE
      );
    `);
    await client.query(`
      CREATE TABLE mdcache.responses ( 
        id SERIAL PRIMARY KEY,
        source TEXT NOT NULL,
        deck TEXT NOT NULL,
        text TEXT NOT NULL,
        FOREIGN KEY (source, deck) REFERENCES mdcache.decks (source, id) ON DELETE CASCADE
      );
    `);
    await client.query(`
      CREATE TABLE mdcache.calls ( 
        id SERIAL PRIMARY KEY,
        source TEXT NOT NULL,
        deck TEXT NOT NULL,
        parts JSONB NOT NULL,
        FOREIGN KEY (source, deck) REFERENCES mdcache.decks (source, id) ON DELETE CASCADE
      );
    `);
    await client.query("INSERT INTO mdcache.meta VALUES ($1);", [this.to]);
    return this.to;
  }
}

const upgrades: Postgres.Upgrades = (version) => {
  switch (version) {
    case undefined:
      return new To0(version);

    case 0:
      return new To1(version);

    case 1:
      return undefined;

    default:
      throw new Error("Database is on unsupported version, can't upgrade.");
  }
};

const nullToUndefined = <T>(value: T | null): T | undefined =>
  value === null ? undefined : value;

/**
 * A PostgreSQL database backed cache.
 */
export class PostgresCache extends Cache.Cache {
  public readonly config: Config.PostgreSQLCache;
  private readonly pg: Postgres.Postgres;

  public static async create(
    config: Config.PostgreSQLCache
  ): Promise<PostgresCache> {
    const pg = new Postgres.Postgres("mdcache", config.connection, upgrades);
    await pg.ensureCurrent();
    return new PostgresCache(config, pg);
  }

  private constructor(config: Config.PostgreSQLCache, pg: Postgres.Postgres) {
    super();
    this.config = config;
    this.pg = pg;
  }

  public async cacheSummary(
    source: Source.Resolver<Source.External>,
    summary: Source.Summary
  ): Promise<void> {
    await this.pg.inTransaction(async (client) => {
      await client.query(
        `
          INSERT INTO mdcache.decks (source, id) VALUES (
            $1, $2
          ) ON CONFLICT (source, id) DO NOTHING; 
        `,
        [source.id(), source.deckId()]
      );
      const details = summary.details;
      await client.query(
        `
          INSERT INTO mdcache.summaries 
            (source, deck, name, url, author, language, translator, calls, responses, updated, tag) 
          VALUES (
            $1, $2, $3, $4, $5, $6, $7, $8
          );
        `,
        [
          source.id(),
          source.deckId(),
          details.name,
          details.url,
          details.author,
          details.language,
          details.translator,
          summary.calls,
          summary.responses,
          Date.now(),
          summary.tag,
        ]
      );
    });
  }

  public async cacheTemplates(
    source: Source.Resolver<Source.External>,
    templates: Decks.Templates
  ): Promise<void> {
    await this.pg.inTransaction(async (client) => {
      await client.query(
        `
          INSERT INTO mdcache.decks (source, id, cards_updated, cards_tag) VALUES (
            $1, $2, $3, $4
          ) ON CONFLICT (source, id) DO UPDATE SET cards_updated=$3, cards_tag=$4; 
        `,
        [source.id(), source.deckId(), Date.now(), templates.tag]
      );

      for (const call of templates.calls) {
        await client.query(
          `
            INSERT INTO mdcache.calls (source, deck, parts) VALUES (
              $1, $2, $3
            )
          `,
          [source.id(), source.deckId(), JSON.stringify(call.parts)]
        );
      }

      for (const response of templates.responses) {
        if (Card.isCustomResponse(response)) {
          throw Error("Can't have blank cards in a cached deck.");
        }
        await client.query(
          `
            INSERT INTO mdcache.responses (source, deck, text) VALUES (
              $1, $2, $3
            )
          `,
          [source.id(), source.deckId(), response.text]
        );
      }
    });
  }

  public async getCachedSummary(
    source: Source.Resolver<Source.External>
  ): Promise<Cache.Aged<Source.Summary> | undefined> {
    return await this.pg.withClient(async (client) => {
      const result = await client.query(
        `
          SELECT name, url, author, language, translator, calls, responses, updated 
          FROM mdcache.summaries WHERE source = $1 AND deck = $2
        `,
        [source.id(), source.deckId()]
      );
      if (result.rowCount > 0) {
        const row = result.rows[0];
        return {
          cached: {
            details: {
              name: row["name"],
              url: nullToUndefined(row["url"]),
              author: nullToUndefined(row["author"]),
              language: nullToUndefined(row["language"]),
              translator: nullToUndefined(row["translator"]),
            },
            calls: row["calls"],
            responses: row["responses"],
          },
          age: row["updated"],
        };
      } else {
        return undefined;
      }
    });
  }

  public async getCachedTemplates(
    source: Source.Resolver<Source.External>
  ): Promise<Cache.Aged<Decks.Templates> | undefined> {
    return await this.pg.withClient(async (client) => {
      const about = await client.query(
        `
          SELECT cards_updated, cards_tag FROM mdcache.decks WHERE source = $1 AND id = $2
        `,
        [source.id(), source.deckId()]
      );
      if (about.rowCount > 0 && about.rows[0]["cards_updated"] !== undefined) {
        const calls = new Set<Card.Call>();
        const responses = new Set<Card.Response>();

        const callsResult = await client.query(
          `
            SELECT parts FROM mdcache.calls WHERE source = $1 AND deck = $2
          `,
          [source.id(), source.deckId()]
        );

        for (const c of callsResult.rows) {
          calls.add({
            id: uuid.v4(),
            source: source.source,
            parts: c["parts"],
          });
        }

        const responsesResult = await client.query(
          `
            SELECT text FROM mdcache.responses WHERE source = $1 AND deck = $2
          `,
          [source.id(), source.deckId()]
        );

        for (const r of responsesResult.rows) {
          responses.add({
            id: uuid.v4(),
            source: source.source,
            text: r["text"],
          });
        }

        const aboutRow = about.rows[0];
        return {
          cached: {
            calls,
            responses,
            tag: aboutRow["cards_tag"],
          },
          age: aboutRow["cards_updated"],
        };
      } else {
        return undefined;
      }
    });
  }
}
