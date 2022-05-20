import type { Cache } from "./cache.js";
import { InMemoryCache } from "./caches/in-memory.js";
import { PostgresCache } from "./caches/postgres.js";
import type * as ServerConfig from "./config.js";

export async function from(config: ServerConfig.Cache): Promise<Cache> {
  switch (config.type) {
    case "InMemory":
      return new InMemoryCache(config);
    case "PostgreSQL":
      return await PostgresCache.create(config);
  }
}
