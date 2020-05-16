import * as Errors from "../../errors";

/**
 * An error occurred in the lobby.
 * Most errors are sent directly in response to a request, but some are less direct.
 */
export interface ErrorEncountered {
  event: "ErrorEncountered";
  error: Errors.Details;
}

export const of = (error: Errors.Details): ErrorEncountered => ({
  event: "ErrorEncountered",
  error,
});
