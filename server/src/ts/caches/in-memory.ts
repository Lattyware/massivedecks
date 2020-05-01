import * as Cache from "../cache";
import * as Config from "../config";
import * as Decks from "../games/cards/decks";
import * as Source from "../games/cards/source";

/**
 * An in-memory cache.
 */
export class InMemoryCache extends Cache.Cache {
  public readonly config: Config.InMemoryCache;
  private readonly cache: {
    summaries: Map<[string, string], Cache.Aged<Source.Summary>>;
    templates: Map<[string, string], Cache.Aged<Decks.Templates>>;
  };

  public constructor(config: Config.InMemoryCache) {
    super();
    this.config = config;
    this.cache = {
      summaries: new Map(),
      templates: new Map(),
    };
  }

  private static key(
    source: Source.Resolver<Source.External>
  ): [string, string] {
    return [source.id(), source.deckId()];
  }

  public async cacheSummary(
    source: Source.Resolver<Source.External>,
    summary: Source.Summary
  ): Promise<void> {
    this.cache.summaries.set(InMemoryCache.key(source), {
      cached: summary,
      age: Date.now(),
    });
  }

  public async cacheTemplates(
    source: Source.Resolver<Source.External>,
    templates: Decks.Templates
  ): Promise<void> {
    this.cache.templates.set(InMemoryCache.key(source), {
      cached: templates,
      age: Date.now(),
    });
  }

  public async getCachedSummary(
    source: Source.Resolver<Source.External>
  ): Promise<Cache.Aged<Source.Summary> | undefined> {
    return this.cache.summaries.get(InMemoryCache.key(source));
  }

  public async getCachedTemplates(
    source: Source.Resolver<Source.External>
  ): Promise<Cache.Aged<Decks.Templates> | undefined> {
    return this.cache.templates.get(InMemoryCache.key(source));
  }
}
