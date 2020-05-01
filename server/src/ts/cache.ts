import * as ServerConfig from "./config";
import * as Decks from "./games/cards/decks";
import * as Source from "./games/cards/source";
import * as Logging from "./logging";

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
  public abstract readonly config: ServerConfig.Cache;

  private async get<
    Always extends Tagged,
    Sometimes extends Tagged,
    Resolver extends Source.Resolver<Source.External>,
    Result
  >(
    source: Resolver,
    getCachedAlways: (source: Resolver) => Promise<Aged<Always> | undefined>,
    cacheAlways: (source: Resolver, value: Always) => void,
    cacheSometimes: (source: Resolver, value: Sometimes) => void,
    extract: (result: Result) => [Always, Sometimes | undefined],
    miss: () => Promise<Result>
  ): Promise<Always> {
    const cached = await getCachedAlways(source);
    if (cached !== undefined && !(await this.cacheExpired(source, cached))) {
      return cached.cached;
    } else {
      const [always, sometimes] = extract(await miss());
      cacheAlways(source, always);
      if (sometimes !== undefined) {
        cacheSometimes(source, sometimes);
      }
      return always;
    }
  }

  private async cacheExpired(
    source: Source.Resolver<Source.External>,
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
    source: Source.Resolver<Source.External>,
    miss: () => Promise<Source.AtLeastSummary>
  ): Promise<Source.Summary> {
    return this.get(
      source,
      this.getCachedSummary.bind(this),
      this.cacheSummaryBackground.bind(this),
      this.cacheTemplatesBackground.bind(this),
      (result) => [result.summary, result.templates],
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
    source: Source.Resolver<Source.External>,
    miss: () => Promise<Source.AtLeastTemplates>
  ): Promise<Decks.Templates> {
    return this.get(
      source,
      this.getCachedTemplates.bind(this),
      this.cacheTemplatesBackground.bind(this),
      this.cacheSummaryBackground.bind(this),
      (result) => [result.templates, result.summary],
      miss
    );
  }

  /**
   * Get the given summary from the cache.
   */
  public abstract async getCachedSummary(
    source: Source.Resolver<Source.External>
  ): Promise<Aged<Source.Summary> | undefined>;

  /**
   * Store the given summary in the cache.
   */
  public abstract async cacheSummary(
    source: Source.Resolver<Source.External>,
    summary: Source.Summary
  ): Promise<void>;

  public cacheSummaryBackground(
    source: Source.Resolver<Source.External>,
    summary: Source.Summary
  ): void {
    this.cacheSummary(source, summary).catch(Cache.logError);
  }

  /**
   * Get the given deck templates from the cache.
   */
  public abstract async getCachedTemplates(
    source: Source.Resolver<Source.External>
  ): Promise<Aged<Decks.Templates> | undefined>;

  /**
   * Store the given deck templates in the cache.
   */
  public abstract async cacheTemplates(
    source: Source.Resolver<Source.External>,
    templates: Decks.Templates
  ): Promise<void>;

  public cacheTemplatesBackground(
    source: Source.Resolver<Source.External>,
    templates: Decks.Templates
  ): void {
    this.cacheTemplates(source, templates).catch(Cache.logError);
  }

  private static logError = (error: Error): void => {
    Logging.logException("Error while caching.", error);
  };
}
