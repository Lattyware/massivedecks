import { Cache } from "../../cache";
import * as Util from "../../util";
import * as Source from "./source";
import * as Cardcast from "./sources/cardcast";
import * as Player from "./sources/custom";

function uncachedResolver(source: Source.External): Source.Resolver {
  switch (source.source) {
    case "Cardcast":
      return new Cardcast.Resolver(source);

    default:
      Util.assertNever(source.source);
  }
}

export class SourceNotFoundError extends Error {
  public constructor() {
    super("The given deck was not found at the source.");
  }
}
export class SourceServiceError extends Error {
  public constructor() {
    super("The given source was not available.");
  }
}

/**
 * Get the limited resolver for the given source.
 */
export const limitedResolver = (
  source: Source.External
): Source.LimitedResolver => uncachedResolver(source);

/**
 * Get the resolver for the given source.
 */
export const resolver = (
  cache: Cache,
  source: Source.External
): Source.Resolver =>
  new Source.CachedResolver(cache, uncachedResolver(source));

/**
 * Get the details for the given source.
 */
export const details = async (
  cache: Cache,
  source: Source.Source
): Promise<Source.Details> => {
  switch (source.source) {
    case "Custom":
      return Player.details(source);
    default:
      return await resolver(cache, source).details();
  }
};
