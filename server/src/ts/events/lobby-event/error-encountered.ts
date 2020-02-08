import * as errors from "../../errors";

/**
 * An error occurred in the lobby.
 * Most errors are sent directly in response to a request, but some are less direct.
 */
export interface ErrorEncountered {
  event: "ErrorEncountered";
  error: errors.Details;
}

export const of = (error: errors.Details): ErrorEncountered => ({
  event: "ErrorEncountered",
  error
});
