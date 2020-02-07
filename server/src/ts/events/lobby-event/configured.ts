import jsonPatch from "rfc6902";

/**
 * A change was made to the configuration for the lobby.
 */
export interface Configured {
  event: "Configured";
  /**
   * The change to make to the configuration.
   */
  change: jsonPatch.Patch;
}

export const of = (change: jsonPatch.Patch): Configured => ({
  event: "Configured",
  change
});
