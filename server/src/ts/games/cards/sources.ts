import { Cache } from "../../cache";
import * as deckSource from "./source";
import { Source } from "./source";
import * as cardcast from "./sources/cardcast";
import * as player from "./sources/player";
import * as util from "../../util";

function uncachedResolver(source: deckSource.External): deckSource.Resolver {
  switch (source.source) {
    case "Cardcast":
      return new cardcast.Resolver(source);

    default:
      util.assertNever(source.source);
  }
}

/**
 * Get the limited resolver for the given source.
 */
export const limitedResolver = (
  source: deckSource.External
): deckSource.LimitedResolver => uncachedResolver(source);

/**
 * Get the resolver for the given source.
 */
export const resolver = (
  cache: Cache,
  source: deckSource.External
): deckSource.Resolver =>
  new deckSource.CachedResolver(cache, uncachedResolver(source));

/**
 * Get the details for the given source.
 */
export const details = async (
  cache: Cache,
  source: Source
): Promise<deckSource.Details> =>
  source.source === "Player"
    ? player.details(source)
    : await resolver(cache, source).details();
