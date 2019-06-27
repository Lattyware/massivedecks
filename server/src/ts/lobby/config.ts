import * as source from "../games/cards/source";
import { Rules } from "../games/rules";
import * as rules from "../games/rules";

/**
 * Configuration for a lobby.
 */
export interface Config {
  version: Version;
  rules: Rules;
  public: boolean;
  password?: string;
  decks: SummarisedSource[];
}

export type Version = number;

export interface Public {
  version: string;
  rules: rules.Public;
  public?: boolean;
  password?: string;
  decks: SummarisedSource[];
}

export interface SummarisedSource {
  source: source.External;
  summary?: source.Summary;
}

export const censor = (config: Config): Public => ({
  version: config.version.toString(),
  rules: rules.censor(config.rules),
  decks: config.decks,
  ...(config.public ? { public: true } : {}),
  ...(config.password !== undefined ? { password: config.password } : {})
});

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
