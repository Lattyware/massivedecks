import http, { AxiosRequestConfig } from "axios";
import * as genericPool from "generic-pool";
import * as card from "../card";
import { Slot } from "../card";
import * as decks from "../decks";
import * as source from "../source";

interface CCSummary {
  name: string;
  code: string;
  description: string;
  unlisted: boolean;
  created_at: string;
  updated_at: string;
  external_copyright: boolean;
  copyright_holder_url: string;
  category: string | null;
  call_count: string;
  response_count: string;
  author: {
    id: string;
    username: string;
  };
  rating: string;
}

interface CCDeck {
  calls: CCCard[];
  responses: CCCard[];
}

interface CCCard {
  id: string;
  text: string[];
  created_at: string;
  nsfw: boolean;
}

const config: AxiosRequestConfig = {
  method: "GET",
  baseURL: "https://api.cardcastgame.com/v1/",
  timeout: 10000,
  responseType: "json"
};

/**
 * We pool requests to cardcast to stop us hitting them too hard (on top of
 * caching). We only allow two simultaneous requests.
 */
const connectionPool = genericPool.createPool(
  {
    create: async () => http.create(config),
    destroy: async _ => {}
  },
  { max: 2 }
);

const summaryUrl = (playCode: PlayCode): string => `decks/${playCode}`;
const deckUrl = (playCode: PlayCode): string => `${summaryUrl(playCode)}/cards`;
const humanViewUrl = (playCode: PlayCode): string =>
  `https://www.cardcastgame.com/browse/deck/${playCode}`;

/**
 * A source for Cardcast.
 */
export interface Cardcast {
  source: "Cardcast";
  playCode: PlayCode;
}

/**
 * A Cardcast play code for a deck.
 */
export type PlayCode = string;

const nextWordShouldBeCapitalizedRegex = /[.?!]\s*$/;
const nextWordShouldBeCapitalized = (previously: string): boolean =>
  previously.match(nextWordShouldBeCapitalizedRegex) !== null;

/**
 * Get the parts from Cardcast's representation. As Cardcast doesn't offer as
 * much flexibility as we do, we use heuristics to try and do the right thing.
 */
// TODO: We probably want to offer some control over these heuristics.
function* parts(call: CCCard): Iterable<card.Part> {
  let upper: Slot = call.text.every(text => text === text.toUpperCase())
    ? { transform: "UpperCase" }
    : {};
  let first = true;
  let previous: string | null = null;
  for (const text of call.text) {
    if (previous !== null) {
      let capitalize: Slot =
        nextWordShouldBeCapitalized(previous) || first
          ? { transform: "Capitalize" }
          : {};
      yield { ...capitalize, ...upper };
    }
    if (text !== "") {
      yield text;
    }
    previous = text;
    if (first && (text !== "" || previous !== null)) {
      first = false;
    }
  }
}

const call = (source: Cardcast, call: CCCard): card.Call => ({
  id: card.id(),
  parts: [Array.from(parts(call))],
  source: source
});

const response = (source: Cardcast, response: CCCard): card.Response => ({
  id: card.id(),
  text: response.text[0],
  source: source
});

export class Resolver extends source.Resolver {
  public readonly source: Cardcast;

  public constructor(source: Cardcast) {
    super();
    this.source = source;
  }

  public id(): string {
    return "Cardcast";
  }

  public deckId(): string {
    return this.source.playCode;
  }

  public loadingDetails(): source.Details {
    return {
      name: `Cardcast ${this.source.playCode}`,
      url: humanViewUrl(this.source.playCode)
    };
  }

  public equals(source: source.External): boolean {
    return (
      source.source === "Cardcast" &&
      this.source.playCode.toUpperCase() === source.playCode.toUpperCase()
    );
  }

  public async getTag(): Promise<string | undefined> {
    return (await this.summary()).tag;
  }

  public async atLeastSummary(): Promise<source.AtLeastSummary> {
    const summary = (await Resolver.get(
      summaryUrl(this.source.playCode)
    )) as CCSummary;
    try {
      return {
        summary: {
          details: {
            name: summary.name,
            url: humanViewUrl(this.source.playCode)
          },
          calls: Number.parseInt(summary.call_count, 10),
          responses: Number.parseInt(summary.response_count, 10),
          tag: summary.updated_at
        }
      };
    } catch (error) {
      // TODO: Error wrapper for unexpected response shape.
      throw error;
    }
  }

  public async atLeastTemplates(): Promise<source.AtLeastTemplates> {
    const deck = (await Resolver.get(deckUrl(this.source.playCode))) as CCDeck;
    try {
      return {
        templates: {
          calls: new Set(deck.calls.map(c => call(this.source, c))),
          responses: new Set(deck.responses.map(r => response(this.source, r)))
        }
      };
    } catch (error) {
      // TODO: Error wrapper for unexpected response shape.
      throw error;
    }
  }

  private static async get<T>(url: string): Promise<object> {
    const connection = await connectionPool.acquire();
    try {
      return (await connection.get(url)).data;
    } catch (error) {
      // TODO: Error wrapper for connection to Cardcast.
      throw error;
    } finally {
      connectionPool.release(connection);
    }
  }

  public summaryAndTemplates = (): {
    summary: Promise<source.Summary>;
    templates: Promise<decks.Templates>;
  } => ({
    summary: this.summary(),
    templates: this.templates()
  });
}
