import http, { AxiosRequestConfig } from "axios";
import genericPool from "generic-pool";
import HttpStatus from "http-status-codes";
import * as Card from "../card";
import { Slot } from "../card";
import * as Decks from "../decks";
import * as Source from "../source";
import { SourceNotFoundError, SourceServiceError } from "../sources";

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
    destroy: async _ => {
      // Do nothing.
    }
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
  previously === "" ||
  previously.match(nextWordShouldBeCapitalizedRegex) !== null;

/**
 * Get the parts from Cardcast's representation. As Cardcast doesn't offer as
 * much flexibility as we do, we use heuristics to try and do the right thing.
 */
// TODO: We probably want to offer some control over these heuristics.
function* parts(call: CCCard): Iterable<Card.Part> {
  const upper: Slot = call.text.every(text => text === text.toUpperCase())
    ? { transform: "UpperCase" }
    : {};
  let first = true;
  let previous: string | null = null;
  for (const text of call.text) {
    if (previous !== null) {
      const capitalize: Slot =
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

const call = (source: Cardcast, call: CCCard): Card.Call => ({
  id: Card.id(),
  parts: [Array.from(parts(call))],
  source: source
});

const response = (source: Cardcast, response: CCCard): Card.Response => ({
  id: Card.id(),
  text: response.text[0],
  source: source
});

export class Resolver extends Source.Resolver {
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

  public loadingDetails(): Source.Details {
    return {
      name: `Cardcast ${this.source.playCode}`,
      url: humanViewUrl(this.source.playCode)
    };
  }

  public equals(source: Source.External): boolean {
    return (
      source.source === "Cardcast" &&
      this.source.playCode.toUpperCase() === source.playCode.toUpperCase()
    );
  }

  public async getTag(): Promise<string | undefined> {
    return (await this.summary()).tag;
  }

  public async atLeastSummary(): Promise<Source.AtLeastSummary> {
    const summary = await Resolver.get<CCSummary>(
      summaryUrl(this.source.playCode)
    );
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
  }

  public async atLeastTemplates(): Promise<Source.AtLeastTemplates> {
    const deck = await Resolver.get<CCDeck>(deckUrl(this.source.playCode));
    return {
      templates: {
        calls: new Set(deck.calls.map(c => call(this.source, c))),
        responses: new Set(deck.responses.map(r => response(this.source, r)))
      }
    };
  }

  private static async get<T>(url: string): Promise<T> {
    const connection = await connectionPool.acquire();
    try {
      return (await connection.get(url)).data;
    } catch (error) {
      if (error.response) {
        const response = error.response;
        if (response.status === HttpStatus.NOT_FOUND) {
          throw new SourceNotFoundError();
        } else {
          throw new SourceServiceError();
        }
      } else {
        throw error;
      }
    } finally {
      await connectionPool.release(connection);
    }
  }

  public summaryAndTemplates = async (): Promise<{
    summary: Source.Summary;
    templates: Decks.Templates;
  }> => ({
    summary: await this.summary(),
    templates: await this.templates()
  });
}
