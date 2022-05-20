import type { Cache } from "./cache.js";
import * as caches from "./caches.js";
import type * as Config from "./config.js";
import { Sources } from "./games/cards/sources.js";
import { SocketManager } from "./socket-manager.js";
import type { Store } from "./store.js";
import * as Stores from "./store/stores.js";
import * as Tasks from "./task/tasks.js";

export interface ServerState {
  config: Config.Parsed;
  sources: Sources;
  store: Store;
  cache: Cache;
  socketManager: SocketManager;
  tasks: Tasks.Queue;
}

export async function create(config: Config.Parsed): Promise<ServerState> {
  const sources = await Sources.from(config.sources);
  const store = await Stores.from(config.storage);
  const cache = await caches.from(config.cache);
  const socketManager = new SocketManager();
  const tasks = new Tasks.Queue(config.tasks.rateLimit);

  return {
    sources,
    config,
    store,
    cache,
    socketManager,
    tasks,
  };
}
