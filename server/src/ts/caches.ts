import * as ServerConfig from "./config";
import { Cache } from "./cache";
import { InMemoryCache } from "./caches/in-memory";
//import { PostgresStore } from "./caches/postgres";

export async function from(config: ServerConfig.Cache): Promise<Cache> {
  switch (config.type) {
    case "InMemory":
      return new InMemoryCache(config);
    case "PostgreSQL":
      throw new Error("Not Implemented");
  }
}
