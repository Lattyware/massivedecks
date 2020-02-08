import { Cache } from "./cache";
import * as caches from "./caches";
import * as config from "./config";
import { SocketManager } from "./socket-manager";
import { Store } from "./store";
import * as stores from "./store/stores";
import * as backgroundTasks from "./task/tasks";

export interface ServerState {
  config: config.Parsed;
  store: Store;
  cache: Cache;
  socketManager: SocketManager;
  tasks: backgroundTasks.Queue;
}

export async function create(config: config.Parsed): Promise<ServerState> {
  const store = await stores.from(config.storage);
  const cache = await caches.from(config.cache);
  const socketManager = new SocketManager();
  const tasks = new backgroundTasks.Queue(config.tasks.rateLimit);

  return {
    config,
    store,
    cache,
    socketManager,
    tasks
  };
}
