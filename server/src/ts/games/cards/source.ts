import * as cache from "../../cache";
import { Cache } from "../../cache";
import * as logging from "../../logging";
import * as decks from "./decks";
import { Cardcast } from "./sources/cardcast";
import { Custom } from "./sources/custom";

/**
 * A source for a card or deck.
 */
export type Source = External | Custom;

/**
 * An external source for a card or deck.
 */
export type External = Cardcast;

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
}

export interface Summary extends cache.Tagged {
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
  templates?: decks.Templates;
}

export interface AtLeastTemplates {
  templates: decks.Templates;
  summary?: Summary;
}

/**
 * Resolve information about the given source.
 */
export abstract class Resolver implements LimitedResolver {
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
  public abstract async getTag(): Promise<cache.Tag | undefined>;

  /**
   * The summary for the source, and potentially the templates if efficient to
   * return both.
   */
  public abstract async atLeastSummary(): Promise<AtLeastSummary>;

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
  public abstract async atLeastTemplates(): Promise<AtLeastTemplates>;

  /**
   * The deck templates for the source.
   */
  public async templates(): Promise<decks.Templates> {
    return (await this.atLeastTemplates()).templates;
  }

  /**
   * Get both the summary and templates efficiently. This will issue two
   * separate requests if necessary, but only one if possible.
   */
  public abstract summaryAndTemplates(): {
    summary: Promise<Summary>;
    templates: Promise<decks.Templates>;
  };
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
 * A resolver that caches expensive responses in the store.
 */
export class CachedResolver extends Resolver {
  private readonly resolver: Resolver;
  private readonly cache: Cache;

  public constructor(cache: Cache, resolver: Resolver) {
    super();
    this.cache = cache;
    this.resolver = resolver;
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

  public async getTag(): Promise<cache.Tag | undefined> {
    // Caching the tag here would defy the point.
    return this.resolver.getTag();
  }

  public async atLeastSummary(): Promise<AtLeastSummary> {
    return {
      summary: await this.cache.getSummary(this.resolver, () =>
        this.resolver.atLeastSummary()
      )
    };
  }

  public async atLeastTemplates(): Promise<AtLeastTemplates> {
    return {
      templates: await this.cache.getTemplates(this.resolver, () =>
        this.resolver.atLeastTemplates()
      )
    };
  }

  public summaryAndTemplates(): {
    summary: Promise<Summary>;
    templates: Promise<decks.Templates>;
  } {
    const promise = this.internalSummaryAndTemplates();
    return {
      summary: promise.then(async value => await value.summary),
      templates: promise.then(async value => await value.templates)
    };
  }

  private async internalSummaryAndTemplates(): Promise<{
    summary: Promise<Summary>;
    templates: Promise<decks.Templates>;
  }> {
    return this.internalSummaryAndTemplatesContent(
      await this.cache.getCachedSummary(this.resolver),
      await this.cache.getCachedTemplates(this.resolver)
    );
  }

  private internalSummaryAndTemplatesContent(
    cachedSummary?: cache.Aged<Summary>,
    cachedTemplates?: cache.Aged<decks.Templates>
  ): {
    summary: Promise<Summary>;
    templates: Promise<decks.Templates>;
  } {
    if (cachedSummary === undefined && cachedTemplates === undefined) {
      const result = this.resolver.summaryAndTemplates();
      result.summary
        .then(async s => await this.cache.cacheSummary(this.resolver, s))
        .catch(CachedResolver.logError);
      result.templates
        .then(async t => await this.cache.cacheTemplates(this.resolver, t))
        .catch(CachedResolver.logError);
      return result;
    } else {
      return {
        summary:
          cachedSummary !== undefined
            ? Promise.resolve(cachedSummary.cached)
            : this.summary(),
        templates:
          cachedTemplates !== undefined
            ? Promise.resolve(cachedTemplates.cached)
            : this.templates()
      };
    }
  }

  private static logError(error: Error): void {
    logging.logException("Error while caching:", error);
  }
}
