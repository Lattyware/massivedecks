import WebSocket from "ws";
import * as action from "./action";
import * as authenticate from "./action/authenticate";
import { MassiveDecksError } from "./errors";
import { NotAuthenticatedError } from "./errors/authentication";
import { InvalidActionError } from "./errors/validation";
import * as event from "./event";
import * as sync from "./events/user-event/sync";
import * as gameLobby from "./lobby";
import * as change from "./lobby/change";
import { GameCode } from "./lobby/game-code";
import * as logging from "./logging";
import { ServerState } from "./server-state";
import * as userDisconnect from "./timeout/user-disconnect";
import * as user from "./user";
import { User } from "./user";
import * as token from "./user/token";

const parseJson = (raw: string): object => {
  try {
    return JSON.parse(raw);
  } catch (error) {
    throw new InvalidActionError(error.message);
  }
};

export class Sockets {
  private readonly sockets: Map<GameCode, Map<user.Id, Set<WebSocket>>>;

  public constructor() {
    this.sockets = new Map();
  }

  public add(gameCode: GameCode, id: user.Id, socket: WebSocket): void {
    const maybeUsers = this.users(gameCode).get(id);
    if (maybeUsers === undefined) {
      const newSet = new Set<WebSocket>();
      newSet.add(socket);
      this.users(gameCode).set(id, newSet);
    } else {
      maybeUsers.add(socket);
    }
  }

  public *get(gameCode: GameCode, id: user.Id): Iterable<WebSocket> {
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
  public delete(gameCode: GameCode, id: user.Id, socket: WebSocket): boolean {
    const users = this.users(gameCode);
    const sockets = users.get(id);
    const didDelete = sockets !== undefined ? sockets.delete(socket) : false;
    if (didDelete && sockets !== undefined && sockets.size < 1) {
      users.delete(id);
      if (users.size < 1) {
        this.sockets.delete(gameCode);
      }
      return true;
    }
    return false;
  }

  private users(gameCode: GameCode): Map<user.Id, Set<WebSocket>> {
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

  private readonly errorWSHandler = <T>(
    socket: WebSocket,
    fn: (data: WebSocket.Data) => Promise<T>
  ): ((data: WebSocket.Data) => Promise<T | void>) => async data => {
    try {
      return await fn(data);
    } catch (error) {
      const dataDescription =
        typeof data === "string" ? data : `(${typeof data})`;
      if (error instanceof MassiveDecksError) {
        const details = error.details();
        logging.logger.warn("WebSocket bad request:", {
          data: dataDescription,
          details,
          errorMessage: error.message
        });
        socket.send(JSON.stringify(details));
      } else {
        logging.logException("WebSocket error:", error, dataDescription);
        socket.send(JSON.stringify({ error: "InternalServerError" }));
        socket.close();
      }
      return;
    }
  };

  public add(server: ServerState, gameCode: GameCode, socket: WebSocket): void {
    const sockets = this.sockets;
    let auth: token.Claims | null = null;
    socket.on(
      "message",
      this.errorWSHandler(socket, async data => {
        if (typeof data !== "string") {
          throw new InvalidActionError("Invalid message.");
        }
        const validated = action.validate(parseJson(data));
        if (auth === null) {
          if (validated.action === "Authenticate") {
            auth = await authenticate.handle(server, validated, gameCode);
            const uid = auth.uid;
            sockets.add(auth.gc, uid, socket);
            await change.apply(server, auth.gc, lobby => {
              let hand = undefined;
              let play = undefined;
              if (lobby.game !== undefined) {
                const player = lobby.game.players.get(uid);
                if (player !== undefined) {
                  hand = player.hand;
                }
                const potentialPlay = lobby.game.round.plays.find(
                  play => play.playedBy === uid
                );
                if (potentialPlay !== undefined) {
                  play = potentialPlay.play.map(card => card.id);
                }
              }

              const user = lobby.users.get(uid) as User;
              user.connection = "Connected";
              return {
                lobby,
                events: [
                  event.targetOnly(
                    sync.of(gameLobby.censor(lobby), hand, play),
                    uid
                  )
                ]
              };
            });
            logging.logger.info("WebSocket connect:", {
              user: auth.uid,
              authenticate: validated
            });
          } else {
            throw new NotAuthenticatedError();
          }
        } else {
          const claims = auth;
          await change.apply(server, auth.gc, lobby =>
            action.handle(claims, lobby, validated, server)
          );
          logging.logger.info("WebSocket receive:", {
            user: auth.uid,
            action: validated
          });
        }
      })
    );
    socket.on("close", async () => {
      if (auth) {
        const uid = auth.uid;
        logging.logger.info("WebSocket disconnect:", { user: auth.uid });
        if (sockets.delete(auth.gc, uid, socket)) {
          await change.apply(server, auth.gc, lobby => ({
            lobby,
            timeouts: [
              {
                timeout: userDisconnect.of(uid),
                after: server.config.timeouts.disconnectionGracePeriod
              }
            ]
          }));
          logging.logger.info("User disconnect:", { user: auth.uid });
        }
      }
    });
  }
}
