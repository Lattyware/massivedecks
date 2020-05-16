import HttpStatus from "http-status-codes";
import * as Errors from "../errors";
import { GameCode } from "../lobby/game-code";

export type Reason = "Closed" | "DoesNotExist";

export interface Details extends Errors.Details {
  reason: Reason;
  gameCode: GameCode;
}

// Could happen on user typo.
export abstract class LobbyNotFoundError extends Errors.MassiveDecksError<
  Details
> {
  abstract readonly reason: Reason;
  public readonly gameCode: GameCode;

  protected constructor(gameCode: GameCode, reason: string) {
    super(`The lobby "${gameCode}" could not be found, ${reason}.`);
    this.gameCode = gameCode;
    Error.captureStackTrace(this, LobbyNotFoundError);
  }

  public details: () => Details = () => ({
    error: "LobbyNotFound",
    gameCode: this.gameCode,
    reason: this.reason,
  });
}

// Could happen on user trying to come back to old game.
export class LobbyClosedError extends LobbyNotFoundError {
  public readonly status = HttpStatus.GONE;
  public readonly reason = "Closed";

  public constructor(gameCode: GameCode) {
    super(gameCode, "the lobby has been closed");
    Error.captureStackTrace(this, LobbyClosedError);
  }
}

export class LobbyDoesNotExistError extends LobbyNotFoundError {
  public readonly status = HttpStatus.NOT_FOUND;
  public readonly reason = "DoesNotExist";

  public constructor(gameCode: GameCode) {
    super(gameCode, "the lobby never existed");
    Error.captureStackTrace(this, LobbyDoesNotExistError);
  }
}
