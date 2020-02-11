import { PostgresCache } from "./caches/postgres";
import * as ServerConfig from "./config";
import { Cache } from "./cache";
import { InMemoryCache } from "./caches/in-memory";

export async function from(config: ServerConfig.Cache): Promise<Cache> {
  switch (config.type) {
    case "InMemory":
      return new InMemoryCache(config);
    case "PostgreSQL":
      return await PostgresCache.create(config);
  }
}
