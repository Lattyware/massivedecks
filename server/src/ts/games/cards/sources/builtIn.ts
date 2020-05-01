import * as Source from "../source";
import * as Decks from "../decks";
import JSON5 from "json5";
import { promises as fs } from "fs";
import * as Config from "../../../config";
import * as path from "path";
import { Part } from "../card";
import * as Card from "../card";
import {
  SourceNotFoundError,
  SourceServiceError,
} from "../../../errors/action-execution-error";

const extension = ".deck.json5";

interface BuiltInDeck {
  name: string;
  calls: Part[][][];
  responses: string[];
}

/**
 * A source for built-in decks..
 */
export interface BuiltIn {
  source: "BuiltIn";
  id: string;
}

export interface ClientInfo {
  decks: { name: string; id: string }[];
}

export class Resolver extends Source.Resolver<BuiltIn> {
  public readonly source: BuiltIn;
  private config: Config.BuiltIn;
  /**
   * Can be undefined because we want to error out later if the deck doesn't exist for nicer errors.
   */
  private readonly storedSummary?: Source.Summary;

  public constructor(
    config: Config.BuiltIn,
    source: BuiltIn,
    summary?: Source.Summary
  ) {
    super();
    this.config = config;
    this.source = source;
    this.storedSummary = summary;
  }

  public id(): string {
    return "BuiltIn";
  }

  public deckId(): string {
    return this.source.id;
  }

  public loadingDetails(): Source.Details {
    if (this.storedSummary !== undefined) {
      return this.storedSummary.details;
    }
    return { name: "Deck Not Found" };
  }

  public equals(source: Source.External): boolean {
    return source.source === "BuiltIn" && this.source.id == source.id;
  }

  public async getTag(): Promise<string | undefined> {
    return undefined;
  }

  public async atLeastSummary(): Promise<Source.AtLeastSummary> {
    if (this.storedSummary === undefined) {
      throw new SourceNotFoundError(this.source);
    }
    return {
      summary: this.storedSummary,
    };
  }

  public async atLeastTemplates(): Promise<Source.AtLeastTemplates> {
    return this.summaryAndTemplates();
  }

  public summaryAndTemplates = async (): Promise<{
    summary: Source.Summary;
    templates: Decks.Templates;
  }> => {
    if (this.storedSummary === undefined) {
      throw new SourceNotFoundError(this.source);
    }
    try {
      const rawDeck = JSON5.parse(
        (
          await fs.readFile(
            path.join(this.config.basePath, this.source.id + extension)
          )
        ).toString()
      ) as BuiltInDeck;
      return {
        summary: this.storedSummary,
        templates: {
          calls: new Set(rawDeck.calls.map(this.call)),
          responses: new Set(rawDeck.responses.map(this.response)),
        },
      };
    } catch (error) {
      throw new SourceServiceError(this.source);
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

export class MetaResolver implements Source.MetaResolver<BuiltIn> {
  private readonly config: Config.BuiltIn;
  private readonly summaries: Map<string, Source.Summary>;

  public constructor(
    config: Config.BuiltIn,
    summaries: Map<string, Source.Summary>
  ) {
    this.config = config;
    this.summaries = summaries;
  }

  limitedResolver(source: BuiltIn): Source.LimitedResolver<BuiltIn> {
    return this.resolver(source);
  }

  resolver(source: BuiltIn): Resolver {
    const summary = this.summaries.get(source.id);
    return new Resolver(this.config, source, summary);
  }

  public clientInfo(): ClientInfo {
    return {
      decks: this.config.decks.map((id) => ({
        name: (this.summaries.get(id) as Source.Summary).details.name,
        id,
      })),
    };
  }
}

export async function load(config: Config.BuiltIn): Promise<MetaResolver> {
  const summaries = new Map<string, Source.Summary>();

  for (const id of config.decks) {
    const rawDeck = JSON5.parse(
      (await fs.readFile(path.join(config.basePath, id + extension))).toString()
    ) as BuiltInDeck;
    summaries.set(id, {
      details: {
        name: rawDeck.name,
      },
      calls: rawDeck.calls.length,
      responses: rawDeck.responses.length,
    });
  }

  return new MetaResolver(config, summaries);
}
