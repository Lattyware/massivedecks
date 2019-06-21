import { Lobby } from "./lobby";
import * as change from "./lobby/change";
import { Change } from "./lobby/change";
import { GameCode } from "./lobby/game-code";
import { ServerState } from "./server-state";
import * as finishedPlaying from "./timeout/finished-playing";
import { FinishedPlaying } from "./timeout/finished-playing";
import * as roundStart from "./timeout/round-start";
import { RoundStart } from "./timeout/round-start";
import * as userDisconnect from "./timeout/user-disconnect";
import { UserDisconnect } from "./timeout/user-disconnect";

/**
 * A timeout represents something that must happen after a delay in-game.
 */
export type Timeout = UserDisconnect | RoundStart | FinishedPlaying;

export type Id = string;

export interface TimedOut {
  id: Id;
  timeout: Timeout;
  lobby: GameCode;
}

export interface TimeoutAfter {
  timeout: Timeout;
  after: number;
}

export const handler: Handler<Timeout> = (server, timeout, lobby) => {
  switch (timeout.timeout) {
    case "UserDisconnect":
      return userDisconnect.handle(server, timeout, lobby);
    case "RoundStart":
      return roundStart.handle(server, timeout, lobby);
    case "FinishedPlaying":
      return finishedPlaying.handle(server, timeout, lobby);
  }
};

/**
 * Handle all timeouts in the store that are timed out.
 * Note that this will result in writing to the lobby, so it must not be called
 * inside another write.
 * @param server The server state.
 */
export async function handle(server: ServerState): Promise<void> {
  for await (const { id, lobby, timeout } of server.store.timedOut()) {
    await change.apply(
      server,
      lobby,
      lobby => handler(server, timeout, lobby),
      id
    );
  }
}

export type Handler<T extends Timeout> = (
  server: ServerState,
  timeout: T,
  lobby: Lobby
) => Change;
