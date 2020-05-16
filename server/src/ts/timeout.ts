import { Lobby } from "./lobby";
import * as Change from "./lobby/change";
import { GameCode } from "./lobby/game-code";
import { ServerState } from "./server-state";
import * as FinishedPlaying from "./timeout/finished-playing";
import * as RoundStageTimerDone from "./timeout/round-stage-timer-done";
import * as RoundStart from "./timeout/round-start";
import * as UserDisconnect from "./timeout/user-disconnect";
import * as Logging from "./logging";
import * as FinishedRevealing from "./timeout/finished-revealing";

/**
 * A timeout represents something that must happen after a delay in-game.
 */
export type Timeout =
  | UserDisconnect.UserDisconnect
  | RoundStart.RoundStart
  | FinishedPlaying.FinishedPlaying
  | RoundStageTimerDone.RoundStageTimerDone
  | FinishedRevealing.FinishedRevealing;

export type Id = string;

export interface TimedOut {
  id: Id;
  timeout: Timeout;
  lobby: GameCode;
}

export interface After {
  timeout: Timeout;
  after: number;
}

export const handler: Handler<Timeout> = (server, timeout, gameCode, lobby) => {
  switch (timeout.timeout) {
    case "UserDisconnect":
      return UserDisconnect.handle(server, timeout, gameCode, lobby);
    case "RoundStart":
      return RoundStart.handle(server, timeout, gameCode, lobby);
    case "FinishedPlaying":
      return FinishedPlaying.handle(server, timeout, gameCode, lobby);
    case "RoundStageTimerDone":
      return RoundStageTimerDone.handle(server, timeout, gameCode, lobby);
    case "FinishedRevealing":
      return FinishedRevealing.handle(server, timeout, gameCode, lobby);
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
    Logging.logger.debug(
      `Timeout executing: ${id} (${JSON.stringify(timeout)}) in ${lobby}`
    );
    await Change.apply(
      server,
      lobby,
      (lobbyState) => handler(server, timeout, lobby, lobbyState),
      id
    );
  }
}

export type Handler<T extends Timeout> = (
  server: ServerState,
  timeout: T,
  gameCode: GameCode,
  lobby: Lobby
) => Change.Change;
