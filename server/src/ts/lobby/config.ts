import * as source from "../games/cards/source";
import { Rules } from "../games/rules";
import * as rules from "../games/rules";
import * as token from "../user/token";

/**
 * Configuration for a lobby.
 */
export interface Config {
  version: Version;
  rules: Rules;
  password?: string;
  decks: SummarisedSource[];
}

export type Version = number;

export interface Public {
  version: string;
  rules: rules.Public;
  /**
   * @maxLength 100
   * @minLength 1
   */
  password?: boolean | string;
  decks: SummarisedSource[];
}

export interface SummarisedSource {
  source: source.External;
  summary?: source.Summary;
}

export function censor(config: Config, auth: token.Claims): Public {
  const privilegedPart: {} =
    auth !== undefined && auth.pvg === "Privileged"
      ? config.password === undefined
        ? {}
        : { password: config.password }
      : { password: config.password !== undefined };
  return {
    version: config.version.toString(),
    rules: rules.censor(config.rules),
    decks: config.decks,
    ...privilegedPart
  };
}

/**
 * The way in which the decks configuration is changed.
 */
export type DeckChange = PlayerDriven | Load | Fail;

export type PlayerDriven = "Add" | "Remove";

/**
 * Signifies the given deck was successfully loaded.
 */
export interface Load {
  change: "Load";
  summary: source.Summary;
}

/**
 * The reason a deck could not be loaded.
 */
export type FailReason = "SourceFailure" | "NotFound";

/**
 * Signifies the given deck could not be loaded.
 */
export interface Fail {
  change: "Fail";
  reason: FailReason;
}
