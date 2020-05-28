import * as Source from "../source";
import genericPool from "generic-pool";
import http, { AxiosInstance, AxiosRequestConfig } from "axios";
import * as Config from "../../../config";
import HttpStatus from "http-status-codes";
import {
  SourceNotFoundError,
  SourceServiceError,
} from "../../../errors/action-execution-error";
import * as Decks from "../decks";
import JSON5 from "json5";
import * as Card from "../card";

/**
 * A source that just tries to load an arbitrary URL.
 */
export interface ManyDecks {
  source: "ManyDecks";
  deckCode: string;
}

export interface ClientInfo {
  baseUrl: string;
}

export class Resolver extends Source.Resolver<ManyDecks> {
  public readonly source: ManyDecks;
  private readonly config: Config.ManyDecks;
  private readonly connectionPool: genericPool.Pool<AxiosInstance>;

  public constructor(
    source: ManyDecks,
    config: Config.ManyDecks,
    connectionPool: genericPool.Pool<AxiosInstance>
  ) {
    super();
    this.source = source;
    this.config = config;
    this.connectionPool = connectionPool;
  }

  public id(): string {
    return "ManyDecks";
  }

  public deckId(): string {
    return this.source.deckCode;
  }

  public loadingDetails(): Source.Details {
    return {
      name: `Many Decks ${this.source.deckCode}`,
    };
  }

  public equals(source: Source.External): boolean {
    return (
      source.source === "ManyDecks" && this.source.deckCode === source.deckCode
    );
  }

  public async getTag(): Promise<string | undefined> {
    return (await this.summary()).tag;
  }

  public async atLeastSummary(): Promise<Source.AtLeastSummary> {
    return await this.summaryAndTemplates();
  }

  public async atLeastTemplates(): Promise<Source.AtLeastTemplates> {
    return await this.summaryAndTemplates();
  }

  public summaryAndTemplates = async (): Promise<{
    summary: Source.Summary;
    templates: Decks.Templates;
  }> => {
    const connection = await this.connectionPool.acquire();
    try {
      const raw = (await connection.get(`api/decks/${this.source.deckCode}`))
        .data;
      const data = typeof raw === "string" ? JSON5.parse(raw) : raw;
      const summary = {
        details: {
          name: data.name,
          url: `${this.config.baseUrl}decks/${this.source.deckCode}`,
          author: data.author.name,
          translator: data.translator,
          language: data.language,
        },
        calls: data.calls.length,
        responses: data.responses.length,
      };
      return {
        summary: summary,
        templates: {
          calls: new Set(data.calls.map(this.call)),
          responses: new Set(data.responses.map(this.response)),
        },
      };
    } catch (error) {
      if (error.response) {
        const response = error.response;
        if (response.status === HttpStatus.NOT_FOUND) {
          throw new SourceNotFoundError(this.source);
        } else {
          throw new SourceServiceError(this.source);
        }
      } else {
        throw error;
      }
    } finally {
      await this.connectionPool.release(connection);
    }
  };

  private call = (call: Card.Part[][]): Card.Call => ({
    id: Card.id(),
    parts: call,
    source: this.source,
  });

  private response = (response: string): Card.Response => ({
    id: Card.id(),
    text: response,
    source: this.source,
  });
}

export class MetaResolver implements Source.MetaResolver<ManyDecks> {
  private readonly connectionPool: genericPool.Pool<AxiosInstance>;
  private readonly config: Config.ManyDecks;
  public readonly cache = true;

  public constructor(config: Config.ManyDecks) {
    this.config = config;

    const httpConfig: AxiosRequestConfig = {
      method: "GET",
      baseURL: config.baseUrl,
      timeout: config.timeout,
      responseType: "json",
    };

    this.connectionPool = genericPool.createPool(
      {
        create: async () => http.create(httpConfig),
        destroy: async (_) => {
          // Do nothing.
        },
      },
      { max: config.simultaneousConnections }
    );
  }

  public clientInfo(): ClientInfo {
    return {
      baseUrl: this.config.baseUrl,
    };
  }

  limitedResolver(source: ManyDecks): Resolver {
    return this.resolver(source);
  }

  resolver(source: ManyDecks): Resolver {
    return new Resolver(source, this.config, this.connectionPool);
  }
}

export const load = async (config: Config.ManyDecks): Promise<MetaResolver> =>
  new MetaResolver(config);
