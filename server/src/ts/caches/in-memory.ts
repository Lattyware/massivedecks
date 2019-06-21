import * as cache from "../cache";
import { Cache } from "../cache";
import * as config from "../config";
import * as decks from "../games/cards/decks";
import * as source from "../games/cards/source";

/**
 * An in-memory cache.
 */
export class InMemoryCache extends Cache {
  public readonly config: config.InMemoryCache;
  private readonly cache: {
    summaries: Map<[string, string], cache.Aged<source.Summary>>;
    templates: Map<[string, string], cache.Aged<decks.Templates>>;
  };

  public constructor(config: config.InMemoryCache) {
    super();
    this.config = config;
    this.cache = {
      summaries: new Map(),
      templates: new Map()
    };
  }

  private static key(source: source.Resolver): [string, string] {
    return [source.id(), source.deckId()];
  }

  public async cacheSummary(
    source: source.Resolver,
    summary: source.Summary
  ): Promise<void> {
    this.cache.summaries.set(InMemoryCache.key(source), {
      cached: summary,
      age: Date.now()
    });
  }

  public async cacheTemplates(
    source: source.Resolver,
    templates: decks.Templates
  ): Promise<void> {
    this.cache.templates.set(InMemoryCache.key(source), {
      cached: templates,
      age: Date.now()
    });
  }

  public async getCachedSummary(
    source: source.Resolver
  ): Promise<cache.Aged<source.Summary> | undefined> {
    return this.cache.summaries.get(InMemoryCache.key(source));
  }

  public async getCachedTemplates(
    source: source.Resolver
  ): Promise<cache.Aged<decks.Templates> | undefined> {
    return this.cache.templates.get(InMemoryCache.key(source));
  }
}
