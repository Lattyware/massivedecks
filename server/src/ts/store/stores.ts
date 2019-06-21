import * as serverConfig from "../config";
import { Store } from "../store";
import { InMemoryStore } from "./in-memory";
import { PostgresStore } from "./postgres";

export async function from(config: serverConfig.Storage): Promise<Store> {
  switch (config.type) {
    case "InMemory":
      return new InMemoryStore(config);
    case "PostgreSQL":
      return PostgresStore.create(config);
  }
}
