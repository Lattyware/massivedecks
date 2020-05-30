import Moment from "moment";
import * as Util from "./util";
import * as LobbyConfig from "./lobby/config";

type Duration = UnparsedDuration | ParsedDuration;
type UnparsedDuration = string;
type ParsedDuration = number;

const environmental: (keyof EnvironmentalConfig)[] = [
  "secret",
  "listenOn",
  "basePath",
  "version",
  "touchOnStart",
];

export interface EnvironmentalConfig {
  secret: string;
  listenOn: number | string; // Port or unix socket path.
  basePath: string;
  version: string;
  touchOnStart: string;
}

export interface Config<D extends Duration> extends EnvironmentalConfig {
  sources: BaseSources<D>;
  timeouts: Timeouts<D>;
  tasks: Tasks<D>;
  storage: BaseStorage<D>;
  cache: BaseCache<D>;
  defaults: LobbyConfig.Defaults;
}

export type Parsed = Config<ParsedDuration>;
export type Unparsed = Config<UnparsedDuration>;

type Timeouts<D extends Duration> = {
  timeoutCheckFrequency: D;
  disconnectionGracePeriod: D;
} & { [key: string]: D };

type Tasks<D extends Duration> = {
  rateLimit: number;
  processTickFrequency: D;
};

export interface BuiltIn {
  basePath: string;
  decks: string[];
}

interface BaseManyDecks<D extends Duration> {
  baseUrl: string;
  timeout: D;
  simultaneousConnections: number;
}
export type ManyDecks = BaseManyDecks<ParsedDuration>;

export interface JsonAgainstHumanity {
  aboutUrl: string;
  url: string;
}

interface BaseSources<D extends Duration> {
  builtIn?: BuiltIn;
  manyDecks?: BaseManyDecks<D>;
  jsonAgainstHumanity?: JsonAgainstHumanity;
}
export type Sources = BaseSources<ParsedDuration>;

type BaseStorage<D extends Duration> = BaseInMemory<D> | BasePostgreSQL<D>;
export type Storage = BaseStorage<ParsedDuration>;

export interface PostgreSqlConnection {
  host?: string;
  port?: number;
  user?: string;
  database?: string;
  password?: string;
  keepAlive?: boolean;
}

interface StorageBase<D extends Duration> {
  type: string;
  abandonedTime: D;
  garbageCollectionFrequency: D;
}

interface BaseInMemory<D extends Duration> extends StorageBase<D> {
  type: "InMemory";
}
export type InMemory = BaseInMemory<ParsedDuration>;

interface BasePostgreSQL<D extends Duration> extends StorageBase<D> {
  type: "PostgreSQL";
  connection: PostgreSqlConnection;
}
export type PostgreSQL = BasePostgreSQL<ParsedDuration>;

type BaseCache<D extends Duration> =
  | BaseInMemoryCache<D>
  | BasePostgreSQLCache<D>;
export type Cache = BaseCache<ParsedDuration>;

interface CacheBase<D extends Duration> {
  type: string;
  checkAfter: D;
}

interface BaseInMemoryCache<D extends Duration> extends CacheBase<D> {
  type: "InMemory";
}
export type InMemoryCache = BaseInMemoryCache<ParsedDuration>;

interface BasePostgreSQLCache<D extends Duration> extends CacheBase<D> {
  type: "PostgreSQL";
  connection: PostgreSqlConnection;
}
export type PostgreSQLCache = BasePostgreSQLCache<ParsedDuration>;

const parseDuration = (unparsed: UnparsedDuration): ParsedDuration =>
  Moment.duration(unparsed).asMilliseconds();

export const parseStorage = (
  storage: BaseStorage<UnparsedDuration>
): BaseStorage<ParsedDuration> => ({
  ...storage,
  abandonedTime: parseDuration(storage.abandonedTime),
  garbageCollectionFrequency: parseDuration(storage.garbageCollectionFrequency),
});

export const parseCache = (
  cache: BaseCache<UnparsedDuration>
): BaseCache<ParsedDuration> => ({
  ...cache,
  checkAfter: parseDuration(cache.checkAfter),
});

export const parseTimeouts = (
  timeouts: Timeouts<UnparsedDuration>
): Timeouts<ParsedDuration> =>
  Util.mapObjectValues(timeouts, (key: string, value: UnparsedDuration) =>
    parseDuration(value)
  );

export const parseTasks = (
  tasks: Tasks<UnparsedDuration>
): Tasks<ParsedDuration> => ({
  ...tasks,
  processTickFrequency: parseDuration(tasks.processTickFrequency),
});

const parseManyDecks = (
  manyDecks: BaseManyDecks<UnparsedDuration>
): ManyDecks => ({
  ...manyDecks,
  baseUrl: manyDecks.baseUrl.endsWith("/")
    ? manyDecks.baseUrl
    : manyDecks.baseUrl + "/",
  timeout: parseDuration(manyDecks.timeout),
});

const parseSources = (sources: BaseSources<UnparsedDuration>): Sources => ({
  ...(sources.builtIn !== undefined ? { builtIn: sources.builtIn } : {}),
  ...(sources.manyDecks !== undefined
    ? { manyDecks: parseManyDecks(sources.manyDecks) }
    : {}),
  ...(sources.jsonAgainstHumanity !== undefined
    ? { jsonAgainstHumanity: sources.jsonAgainstHumanity }
    : {}),
});

export const pullFromEnvironment = (config: Parsed): Parsed => {
  for (const name of environmental) {
    const envName = `MD_${name
      .split(/(?=[A-Z])/)
      .join("_")
      .toUpperCase()}`;
    const value = process.env[envName];
    if (value !== undefined) {
      config[name] = value;
    }
  }
  return config;
};

export const parse = (config: Unparsed): Parsed =>
  pullFromEnvironment({
    ...config,
    sources: parseSources(config.sources),
    timeouts: parseTimeouts(config.timeouts),
    tasks: parseTasks(config.tasks),
    storage: parseStorage(config.storage),
    cache: parseCache(config.cache),
  });
