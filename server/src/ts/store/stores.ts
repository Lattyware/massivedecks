import type * as ServerConfig from "../config.js";
import type { Store } from "../store.js";
import { InMemoryStore } from "./in-memory.js";
import { PostgresStore } from "./postgres.js";

export async function from(config: ServerConfig.Storage): Promise<Store> {
  switch (config.type) {
    case "InMemory":
      return new InMemoryStore(config);
    case "PostgreSQL":
      return PostgresStore.create(config);
  }
}
