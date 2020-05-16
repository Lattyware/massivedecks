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
  language: string;
  author: string;
  translator?: string;
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
  decks: {
    name: string;
    language: string;
    author: string;
    translator?: string;
    id: string;
  }[];
}

export class Resolver extends Source.Resolver<BuiltIn> {
  public readonly source: BuiltIn;
  private config: Config.BuiltIn;
  /**
   * Can be undefined because we want to error out later if the deck doesn't exist for nicer errors.
   */
  private readonly storedSummary?: Source.Summary;
  /**
   * Can be undefined because we want to error out later if the deck doesn't exist for nicer errors.
   */
  private readonly storedDeck?: BuiltInDeck;

  public constructor(
    config: Config.BuiltIn,
    source: BuiltIn,
    summary?: Source.Summary,
    deck?: BuiltInDeck
  ) {
    super();
    this.config = config;
    this.source = source;
    this.storedSummary = summary;
    this.storedDeck = deck;
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
    if (this.storedSummary === undefined || this.storedDeck === undefined) {
      throw new SourceNotFoundError(this.source);
    }
    try {
      return {
        summary: this.storedSummary,
        templates: {
          calls: new Set(this.storedDeck.calls.map(this.call)),
          responses: new Set(this.storedDeck.responses.map(this.response)),
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
  private readonly decks: Map<string, BuiltInDeck>;
  public readonly cache = false;

  public constructor(
    config: Config.BuiltIn,
    summaries: Map<string, Source.Summary>,
    decks: Map<string, BuiltInDeck>
  ) {
    this.config = config;
    this.summaries = summaries;
    this.decks = decks;
  }

  limitedResolver(source: BuiltIn): Source.LimitedResolver<BuiltIn> {
    return this.resolver(source);
  }

  resolver(source: BuiltIn): Resolver {
    const summary = this.summaries.get(source.id);
    const deck = this.decks.get(source.id);
    return new Resolver(this.config, source, summary, deck);
  }

  public clientInfo(): ClientInfo {
    return {
      decks: this.config.decks.map((id) => {
        const deck = this.decks.get(id);
        if (deck === undefined) {
          throw new Error(`Deck in configuration not found: '${id}'.`);
        }
        return {
          name: deck.name,
          author: deck.author,
          language: deck.language,
          translator: deck.translator,
          id,
        };
      }),
    };
  }
}

export async function load(config: Config.BuiltIn): Promise<MetaResolver> {
  const summaries = new Map<string, Source.Summary>();
  const decks = new Map<string, BuiltInDeck>();

  for (const id of config.decks) {
    const rawDeck = JSON5.parse(
      (await fs.readFile(path.join(config.basePath, id + extension))).toString()
    ) as BuiltInDeck;
    summaries.set(id, {
      details: {
        name: rawDeck.name,
        author: rawDeck.author,
        translator: rawDeck.translator,
        language: rawDeck.language,
      },
      calls: rawDeck.calls.length,
      responses: rawDeck.responses.length,
    });
    decks.set(id, rawDeck);
  }

  return new MetaResolver(config, summaries, decks);
}
