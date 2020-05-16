import { Cache } from "../../cache";
import * as Util from "../../util";
import * as Source from "./source";
import * as Player from "./sources/custom";
import * as Config from "../../config";
import * as BuiltIn from "./sources/builtIn";
import { SourceNotFoundError } from "../../errors/action-execution-error";
import * as JsonUrl from "./sources/json-url";

async function loadIfEnabled<Config, MetaResolver>(
  config: Config | undefined,
  load: (value: Config) => Promise<MetaResolver>
): Promise<MetaResolver | undefined> {
  if (config === undefined) {
    return undefined;
  } else {
    return await load(config);
  }
}

export interface ClientInfo {
  builtIn?: BuiltIn.ClientInfo;
  cardcast?: boolean;
}

export class Sources {
  public readonly builtIn?: BuiltIn.MetaResolver;
  public readonly jsonUrl?: JsonUrl.MetaResolver;

  public constructor(
    builtIn?: BuiltIn.MetaResolver,
    jsonUrl?: JsonUrl.MetaResolver
  ) {
    if (builtIn === undefined && jsonUrl === undefined) {
      throw new Error("At least one source must be enabled.");
    }
    this.builtIn = builtIn;
    this.jsonUrl = jsonUrl;
  }

  public clientInfo(): ClientInfo {
    return {
      ...(this.builtIn !== undefined
        ? {
            builtIn: this.builtIn.clientInfo(),
          }
        : {}),
      ...(this.jsonUrl !== undefined ? { jsonUrl: true } : {}),
    };
  }

  private metaResolverIfConfigured(
    source: Source.External
  ): Source.MetaResolver<Source.External> | undefined {
    switch (source.source) {
      case "BuiltIn":
        return this.builtIn;

      case "JsonUrl":
        return this.jsonUrl;

      default:
        Util.assertNever(source);
    }
  }

  private metaResolver(
    source: Source.External
  ): Source.MetaResolver<Source.External> {
    const metaResolver = this.metaResolverIfConfigured(source);
    if (metaResolver === undefined) {
      throw new SourceNotFoundError(source);
    } else {
      return metaResolver;
    }
  }

  /**
   * Get the limited resolver for the given source.
   */
  public limitedResolver(
    source: Source.External
  ): Source.Resolver<Source.External> {
    return this.metaResolver(source).resolver(source);
  }

  /**
   * Get the resolver for the given source.
   */
  public resolver(
    cache: Cache,
    source: Source.External
  ): Source.Resolver<Source.External> {
    const metaResolver = this.metaResolver(source);
    const resolver = metaResolver.resolver(source);
    return metaResolver.cache
      ? new Source.CachedResolver(cache, resolver)
      : resolver;
  }

  /**
   * Get the details for the given source.
   */
  details = async (
    cache: Cache,
    source: Source.Source
  ): Promise<Source.Details> => {
    switch (source.source) {
      case "Custom":
        return Player.details(source);

      default:
        return await this.resolver(cache, source).details();
    }
  };

  public static async from(config: Config.Sources): Promise<Sources> {
    const [builtInMeta, jsonUrlMeta] = await Promise.all<
      BuiltIn.MetaResolver | undefined,
      JsonUrl.MetaResolver | undefined
    >([
      loadIfEnabled(config.builtIn, BuiltIn.load),
      loadIfEnabled(config.jsonUrl, JsonUrl.load),
    ]);
    return new Sources(builtInMeta, jsonUrlMeta);
  }
}
