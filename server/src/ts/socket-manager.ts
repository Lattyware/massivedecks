import type WebSocket from "ws";

import * as Action from "./action.js";
import * as Authenticate from "./action/authenticate.js";
import { MassiveDecksError } from "./errors.js";
import { NotAuthenticatedError } from "./errors/authentication.js";
import { InvalidActionError } from "./errors/validation.js";
import * as Event from "./event.js";
import * as Sync from "./events/user-event/sync.js";
import * as Lobby from "./lobby.js";
import * as Change from "./lobby/change.js";
import type { GameCode } from "./lobby/game-code.js";
import * as Logging from "./logging.js";
import type { ServerState } from "./server-state.js";
import * as UserDisconnect from "./timeout/user-disconnect.js";
import type * as User from "./user.js";
import type * as Token from "./user/token.js";

const parseJson = (raw: string): object => {
  try {
    return JSON.parse(raw);
  } catch (e) {
    const error = e as Error;
    throw new InvalidActionError(error.message);
  }
};

export class Sockets {
  private readonly sockets: Map<GameCode, Map<User.Id, Set<WebSocket>>>;

  public constructor() {
    this.sockets = new Map();
  }

  public add(gameCode: GameCode, id: User.Id, socket: WebSocket): void {
    const maybeUsers = this.users(gameCode).get(id);
    if (maybeUsers === undefined) {
      const newSet = new Set<WebSocket>();
      newSet.add(socket);
      this.users(gameCode).set(id, newSet);
    } else {
      maybeUsers.add(socket);
    }
  }

  public *get(gameCode: GameCode, id: User.Id): Iterable<WebSocket> {
    const maybeUsers = this.users(gameCode).get(id);
    if (maybeUsers === undefined) {
      return;
    } else {
      yield* maybeUsers;
    }
  }

  /**
   * Delete the socket, and return if the user has disconnected from all sockets.
   * @param gameCode The game code for the game the user is in.
   * @param id The id of the user.
   * @param socket THe socket to delete.
   */
  public delete(gameCode: GameCode, id: User.Id, socket: WebSocket): boolean {
    const users = this.users(gameCode);
    const sockets = users.get(id);
    if (sockets !== undefined) {
      sockets.delete(socket);
      if (sockets.size < 1) {
        users.delete(id);
        if (users.size < 1) {
          this.sockets.delete(gameCode);
        }
        return true;
      }
    }
    return false;
  }

  private users(gameCode: GameCode): Map<User.Id, Set<WebSocket>> {
    const existing = this.sockets.get(gameCode);
    if (existing !== undefined) {
      return existing;
    } else {
      const created = new Map();
      this.sockets.set(gameCode, created);
      return created;
    }
  }
}

export class SocketManager {
  public readonly sockets: Sockets;

  public constructor() {
    this.sockets = new Sockets();
  }

  private readonly errorWSHandler =
    <T>(
      socket: WebSocket,
      fn: (data: WebSocket.Data) => Promise<T>,
    ): ((data: WebSocket.Data) => Promise<T | void>) =>
    async (data) => {
      try {
        return await fn(data);
      } catch (e) {
        const error = e as Error;
        try {
          const dataDescription =
            typeof data === "string" ? data : `(${typeof data})`;
          if (error instanceof MassiveDecksError) {
            const details = error.details();
            Logging.logger.warn("WebSocket bad request:", {
              data: dataDescription,
              details,
              errorMessage: error.message,
            });
            socket.send(JSON.stringify(details));
          } else {
            Logging.logException("WebSocket error:", error, dataDescription);
            socket.send(JSON.stringify({ error: "InternalServerError" }));
            socket.close();
          }
        } catch (e) {
          const error = e as Error;
          Logging.logException("Error resolving WebSocket error:", error);
        }
        return;
      }
    };

  public add(server: ServerState, gameCode: GameCode, socket: WebSocket): void {
    const sockets = this.sockets;
    let auth: Token.Claims | null = null;
    socket.on(
      "message",
      this.errorWSHandler(socket, async (data) => {
        if (typeof data !== "string") {
          throw new InvalidActionError("Invalid message.");
        }
        const validated = Action.validate(parseJson(data));
        if (auth === null) {
          if (validated.action === "Authenticate") {
            auth = await Authenticate.handle(server, validated, gameCode);
            const uid = auth.uid;
            sockets.add(auth.gc, uid, socket);
            await Change.apply(server, auth.gc, (lobby) => {
              let hand = undefined;
              let play = undefined;
              let likeDetail = undefined;
              let calls = undefined;
              if (lobby.game !== undefined) {
                const player = lobby.game.players[uid];
                if (player !== undefined) {
                  hand = player.hand;
                }
                const round = lobby.game.round;
                if (round.stage === "Revealing" || round.stage === "Judging") {
                  const liked = round.plays
                    .filter((p) => p.likes.some((l) => l === uid))
                    .map((p) => p.id);
                  const playedCard = round.plays.find(
                    (p) => p.playedBy === uid,
                  );
                  const played =
                    playedCard === undefined ? undefined : playedCard.id;
                  likeDetail = { played, liked };
                }
                if (round.stage === "Starting") {
                  calls = round.czar === uid ? round.calls : undefined;
                } else {
                  const potentialPlay = round.plays.find(
                    (play) => play.playedBy === uid,
                  );
                  if (potentialPlay !== undefined) {
                    play = potentialPlay.play.map((card) => card.id);
                  }
                }
              }

              const user = lobby.users[uid] as User.User;
              user.connection = "Connected";
              return {
                lobby,
                events: [
                  Event.targetOnly(
                    Sync.of(Lobby.censor(lobby), hand, play, likeDetail, calls),
                    uid,
                  ),
                ],
              };
            });
            Logging.logger.info("WebSocket connect:", {
              user: auth.uid,
              authenticate: validated,
            });
          } else {
            throw new NotAuthenticatedError();
          }
        } else {
          const claims = auth;
          await Change.apply(server, auth.gc, (lobby) =>
            Action.handle(claims, lobby, validated, server),
          );
          Logging.logger.info("WebSocket receive:", {
            user: auth.uid,
            action: validated,
          });
        }
      }),
    );
    socket.on(
      "close",
      this.errorWSHandler(socket, async () => {
        if (auth) {
          const uid = auth.uid;
          Logging.logger.info("WebSocket disconnect:", { user: auth.uid });
          if (sockets.delete(auth.gc, uid, socket)) {
            await Change.apply(server, auth.gc, (lobby) => ({
              lobby,
              timeouts: [
                {
                  timeout: UserDisconnect.of(uid),
                  after: server.config.timeouts.disconnectionGracePeriod,
                },
              ],
            }));
            Logging.logger.info("User disconnect:", { user: auth.uid });
          }
        }
      }),
    );
  }
}
