import * as Source from "../games/cards/source";
import * as Rules from "../games/rules";

/**
 * Configuration for a lobby.
 */
export interface Config {
  version: Version;
  name: string;
  rules: Rules.Rules;
  public: boolean;
  password?: string;
  audienceMode: boolean;
  decks: ConfiguredSource[];
}

export type Version = number;

export interface Public {
  version: string;
  /**
   * The name of the lobby.
   * @minLength 1
   * @maxLength 100
   */
  name: string;
  rules: Rules.Public;
  public?: boolean;
  /**
   * The password for the lobby.
   * @maxLength 100
   */
  password?: string;
  audienceMode?: boolean;
  decks: ConfiguredSource[];
}

/**
 * Default configuration values for new lobbies.
 */
export interface Defaults {
  rules: Rules.Public;
  public: boolean;
  audienceMode: boolean;
  decks: Source.External[];
}

/**
 * A deck source in the configuration.
 */
export type ConfiguredSource = SummarisedSource | FailedSource;

/**
 * A deck source that is loading or has loaded.
 */
export interface SummarisedSource {
  source: Source.External;
  summary?: Source.Summary;
}

/**
 * The reason a deck could not be loaded.
 */
export type FailReason = "SourceFailure" | "NotFound";

/**
 * A deck source that has failed to load.
 */
export interface FailedSource {
  source: Source.External;
  failure: FailReason;
}

export const isFailed = (source: ConfiguredSource): source is FailedSource =>
  source.hasOwnProperty("failure");

export const censor = (config: Config): Public => ({
  version: config.version.toString(),
  name: config.name,
  rules: Rules.censor(config.rules),
  decks: config.decks,
  ...(config.public ? { public: true } : {}),
  ...(config.audienceMode ? { audienceMode: true } : {}),
  ...(config.password !== undefined ? { password: config.password } : {}),
});
