import moment from "moment";
import * as util from "./util";

type Duration = UnparsedDuration | ParsedDuration;
type UnparsedDuration = string;
type ParsedDuration = number;

const environmental: (keyof EnvironmentalConfig)[] = [
  "secret",
  "listenOn",
  "basePath",
  "version",
  "touchOnStart"
];

export interface EnvironmentalConfig {
  secret: string;
  listenOn: number | string; // Port or unix socket path.
  basePath: string;
  version: string;
  touchOnStart: string;
}

export interface Config<D extends Duration> extends EnvironmentalConfig {
  timeouts: Timeouts<D>;
  storage: BaseStorage<D>;
  cache: BaseCache<D>;
}

export type Parsed = Config<ParsedDuration>;
export type Unparsed = Config<UnparsedDuration>;

type Timeouts<D extends Duration> = {
  timeoutCheckFrequency: D;
  disconnectionGracePeriod: D;
  finishedPlayingDelay: D;
} & { [key: string]: D };

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
export type PostgreSQLCache = BasePostgreSQL<ParsedDuration>;

const parseDuration = (unparsed: UnparsedDuration): ParsedDuration =>
  moment.duration(unparsed).asMilliseconds();

export const parseStorage = (
  storage: BaseStorage<UnparsedDuration>
): BaseStorage<ParsedDuration> => ({
  ...storage,
  garbageCollectionFrequency: parseDuration(storage.garbageCollectionFrequency)
});

export const parseCache = (
  cache: BaseCache<UnparsedDuration>
): BaseCache<ParsedDuration> => ({
  ...cache,
  checkAfter: parseDuration(cache.checkAfter)
});

export const parseTimeouts = (
  timeouts: Timeouts<UnparsedDuration>
): Timeouts<ParsedDuration> =>
  util.mapObjectValues(timeouts, (key: string, value: UnparsedDuration) =>
    parseDuration(value)
  );

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
    timeouts: parseTimeouts(config.timeouts),
    storage: parseStorage(config.storage),
    cache: parseCache(config.cache)
  });
