import type * as Cache from "../../cache.js";
import type * as Decks from "./decks.js";
import type { BuiltIn } from "./sources/builtIn.js";
import type { Custom } from "./sources/custom.js";
import type { Generated } from "./sources/generated.js";
import type { JsonAgainstHumanity } from "./sources/json-against-humanity.js";
import type { ManyDecks } from "./sources/many-decks.js";

/**
 * A source for a card or deck.
 */
export type Source = External | Custom | Generated;

/**
 * An external source for a card or deck.
 */
export type External = BuiltIn | ManyDecks | JsonAgainstHumanity;

/**
 * More information that can be looked up given a source.
 */
export interface Details {
  /**
   * A name for the source.
   */
  name: string;
  /**
   * A link to more information about the source.
   */
  url?: string;
  /**
   * The name of the author of the deck.
   */
  author?: string;
  /**
   * The language tag for the language the deck is in.
   */
  language?: string;
  /**
   * The name of the translator of the deck.
   */
  translator?: string;
}

export interface Summary extends Cache.Tagged {
  /**
   * Details about the deck.
   */
  details: Details;
  /**
   * The number of calls in the deck.
   * @TJS-type integer
   */
  calls: number;
  /**
   * The number of responses in the deck.
   * @TJS-type integer
   */
  responses: number;
}

export interface AtLeastSummary {
  summary: Summary;
  templates?: Decks.Templates;
}

export interface AtLeastTemplates {
  templates: Decks.Templates;
  summary?: Summary;
}

/**
 * A resolver that only allows access to properties that don't require store
 * access.
 */
export interface LimitedResolver {
  id: () => string;
  deckId: () => string;
  loadingDetails: () => Details;
  equals: (source: External) => boolean;
}

/**
 * Resolve information about the given source.
 */
export abstract class Resolver<S extends External> implements LimitedResolver {
  /**
   * The source in question.
   */
  public abstract source: S;

  /**
   * A unique id for the source as a whole.
   */
  public abstract id(): string;

  /**
   * A unique id for the deck.
   */
  public abstract deckId(): string;

  /**
   * The temporary details to use for the source while loading.
   */
  public abstract loadingDetails(): Details;

  /**
   * If the given source represents the same deck.
   */
  public abstract equals(source: External): boolean;

  /**
   * Go to the remote source to get a tag for the source, if possible.
   * Note that if you have a fresh summary, you should check if that has a
   * tag first.
   */
  public abstract getTag(): Promise<Cache.Tag | undefined>;

  /**
   * The summary for the source, and potentially the templates if efficient to
   * return both.
   */
  public abstract atLeastSummary(): Promise<AtLeastSummary>;

  /**
   * The summary for the source.
   */
  public async summary(): Promise<Summary> {
    return (await this.atLeastSummary()).summary;
  }

  /**
   * The details for the source.
   */
  public async details(): Promise<Details> {
    return (await this.summary()).details;
  }

  /**
   * The deck templates for the source, and potentially the summary if
   * efficient to return both.
   */
  public abstract atLeastTemplates(): Promise<AtLeastTemplates>;

  /**
   * The deck templates for the source.
   */
  public async templates(): Promise<Decks.Templates> {
    return (await this.atLeastTemplates()).templates;
  }

  /**
   * Get both the summary and templates efficiently. This will issue two
   * separate requests if necessary, but only one if possible.
   */
  public abstract summaryAndTemplates(): Promise<{
    summary: Summary;
    templates: Decks.Templates;
  }>;
}

/**
 * A resolver that caches expensive responses in the store.
 */
export class CachedResolver<S extends External> extends Resolver<S> {
  private readonly resolver: Resolver<S>;
  private readonly cache: Cache.Cache;

  public constructor(cache: Cache.Cache, resolver: Resolver<S>) {
    super();
    this.cache = cache;
    this.resolver = resolver;
  }

  public get source(): S {
    return this.resolver.source;
  }

  public id(): string {
    return this.resolver.id();
  }

  public deckId(): string {
    return this.resolver.deckId();
  }

  public loadingDetails(): Details {
    return this.resolver.loadingDetails();
  }

  public equals(source: External): boolean {
    return this.resolver.equals(source);
  }

  public async getTag(): Promise<Cache.Tag | undefined> {
    // Caching the tag here would defy the point.
    return this.resolver.getTag();
  }

  public async atLeastSummary(): Promise<AtLeastSummary> {
    return {
      summary: await this.cache.getSummary(
        this.resolver,
        async () => await this.resolver.atLeastSummary(),
      ),
    };
  }

  public async atLeastTemplates(): Promise<AtLeastTemplates> {
    return {
      templates: await this.cache.getTemplates(
        this.resolver,
        async () => await this.resolver.atLeastTemplates(),
      ),
    };
  }

  public async summaryAndTemplates(): Promise<{
    summary: Summary;
    templates: Decks.Templates;
  }> {
    const cachedSummary = await this.cache.getCachedSummary(this.resolver);
    const cachedTemplates = await this.cache.getCachedTemplates(this.resolver);
    if (cachedSummary === undefined && cachedTemplates === undefined) {
      const result = await this.resolver.summaryAndTemplates();
      this.cache.cacheSummaryBackground(this.resolver, result.summary);
      this.cache.cacheTemplatesBackground(this.resolver, result.templates);
      return result;
    } else {
      return {
        summary:
          cachedSummary !== undefined
            ? cachedSummary.cached
            : await this.summary(),
        templates:
          cachedTemplates !== undefined
            ? cachedTemplates.cached
            : await this.templates(),
      };
    }
  }
}

/**
 * Get resolvers for the given source type.
 */
export interface MetaResolver<S extends External> {
  /**
   * If the source should be cached.
   */
  readonly cache: boolean;
  limitedResolver(source: S): LimitedResolver;
  resolver(source: S): Resolver<S>;
}
