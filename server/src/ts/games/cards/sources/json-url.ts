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
export interface JsonUrl {
  source: "JsonUrl";
  url: string;
}

export class Resolver extends Source.Resolver<JsonUrl> {
  public readonly source: JsonUrl;
  private readonly connectionPool: genericPool.Pool<AxiosInstance>;

  public constructor(
    source: JsonUrl,
    connectionPool: genericPool.Pool<AxiosInstance>
  ) {
    super();
    this.source = source;
    this.connectionPool = connectionPool;
  }

  public id(): string {
    return "JsonUrl";
  }

  public deckId(): string {
    return this.source.url;
  }

  public loadingDetails(): Source.Details {
    return {
      name: `From ${this.source.url}`,
    };
  }

  public equals(source: Source.External): boolean {
    return source.source === "JsonUrl" && this.source.url === source.url;
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
      const raw = (await connection.get(this.source.url)).data;
      const data = typeof raw === "string" ? JSON5.parse(raw) : raw;
      const summary = {
        details: {
          name: data.name,
          author: data.author,
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

export class MetaResolver implements Source.MetaResolver<JsonUrl> {
  private readonly connectionPool: genericPool.Pool<AxiosInstance>;
  public readonly cache = true;

  public constructor(config: Config.JsonUrl) {
    const httpConfig: AxiosRequestConfig = {
      method: "GET",
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

  limitedResolver(source: JsonUrl): Resolver {
    return this.resolver(source);
  }

  resolver(source: JsonUrl): Resolver {
    return new Resolver(source, this.connectionPool);
  }
}

export const load = async (config: Config.JsonUrl): Promise<MetaResolver> =>
  new MetaResolver(config);
