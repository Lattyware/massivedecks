import * as serverConfig from "./config";
import * as decks from "./games/cards/decks";
import * as deckSource from "./games/cards/source";
import * as logging from "./logging";

/**
 * A tag is used to check if there is a need to refresh the data in the cache.
 */
export type Tag = string;

/**
 * A type that can have a tag attached to indicate freshness.
 */
export interface Tagged {
  /**
   * A tag which should change if the underlying templates change.
   */
  tag?: Tag;
}

/**
 * The age of the cached value.
 */
export type Age = number;

/**
 * A cached item with it's age.
 */
export interface Aged<T> {
  cached: T;
  age: Age;
}

/**
 * A cache for data that is stored for efficiency, but can be retrieved again.
 */
export abstract class Cache {
  /**
   * The configuration for this cache.
   */
  public abstract readonly config: serverConfig.Cache;

  private async get<Always extends Tagged, Sometimes extends Tagged, Result>(
    source: deckSource.Resolver,
    getCachedAlways: (
      source: deckSource.Resolver
    ) => Promise<Aged<Always> | undefined>,
    cacheAlways: (source: deckSource.Resolver, value: Always) => Promise<void>,
    cacheSometimes: (
      source: deckSource.Resolver,
      value: Sometimes
    ) => Promise<void>,
    extract: (result: Result) => [Always, Sometimes | undefined],
    miss: () => Promise<Result>
  ): Promise<Always> {
    const cached = await getCachedAlways(source);
    if (cached !== undefined && !(await this.cacheExpired(source, cached))) {
      return cached.cached;
    } else {
      const [always, sometimes] = extract(await miss());
      await cacheAlways(source, always);
      if (sometimes !== undefined) {
        cacheSometimes(source, sometimes).catch(error =>
          logging.logException("Error while caching:", error)
        );
      }
      return always;
    }
  }

  private async cacheExpired(
    source: deckSource.Resolver,
    cached: Aged<Tagged>
  ): Promise<boolean> {
    if (
      cached.age >= Date.now() + this.config.checkAfter &&
      cached.cached.tag !== undefined
    ) {
      return (await source.getTag()) !== cached.cached.tag;
    }
    return false;
  }

  /**
   * Get the summary from the cache, using the miss function to populate the
   * cache if missing.
   * @param source The resolver for the source being cached.
   * @param miss The function to actively get the summary from the source.
   *             Note this function can also give the templates if efficient
   *             to do so.
   */
  public async getSummary(
    source: deckSource.Resolver,
    miss: () => Promise<deckSource.AtLeastSummary>
  ): Promise<deckSource.Summary> {
    return this.get(
      source,
      s => this.getCachedSummary(s),
      (s, summary) => this.cacheSummary(s, summary),
      (s, templates: decks.Templates) => this.cacheTemplates(s, templates),
      result => [result.summary, result.templates],
      miss
    );
  }

  /**
   * Get the templates from the cache, using the miss function to populate the
   * cache if missing.
   * @param source The resolver for the source being cached.
   * @param miss The function to actively get the templates from the source.
   *             Note this function can also give the summary if efficient
   *             to do so.
   */
  public async getTemplates(
    source: deckSource.Resolver,
    miss: () => Promise<deckSource.AtLeastTemplates>
  ): Promise<decks.Templates> {
    return this.get(
      source,
      s => this.getCachedTemplates(s),
      (s, templates) => this.cacheTemplates(s, templates),
      (s, summary: deckSource.Summary) => this.cacheSummary(s, summary),
      result => [result.templates, result.summary],
      miss
    );
  }

  /**
   * Get the given summary from the cache.
   */
  public abstract async getCachedSummary(
    source: deckSource.Resolver
  ): Promise<Aged<deckSource.Summary> | undefined>;

  /**
   * Store the given summary in the cache.
   */
  public abstract async cacheSummary(
    source: deckSource.Resolver,
    summary: deckSource.Summary
  ): Promise<void>;

  /**
   * Get the given deck templates from the cache.
   */
  public abstract async getCachedTemplates(
    source: deckSource.Resolver
  ): Promise<Aged<decks.Templates> | undefined>;

  /**
   * Store the given deck templates in the cache.
   */
  public abstract async cacheTemplates(
    source: deckSource.Resolver,
    templates: decks.Templates
  ): Promise<void>;
}
