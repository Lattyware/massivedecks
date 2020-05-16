import Rfc6902 from "rfc6902";

/**
 * A change was made to the configuration for the lobby.
 */
export interface Configured {
  event: "Configured";
  /**
   * The change to make to the configuration.
   */
  change: Rfc6902.Patch;
}

export const of = (change: Rfc6902.Patch): Configured => ({
  event: "Configured",
  change,
});
