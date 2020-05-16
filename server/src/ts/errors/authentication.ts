import HttpStatus from "http-status-codes";
import * as Errors from "../errors";

export type Reason =
  | "IncorrectIssuer"
  | "NotAuthenticated"
  | "AlreadyAuthenticated"
  | "InvalidAuthentication"
  | "InvalidLobbyPassword"
  | "AlreadyLeftError";

export interface Details extends Errors.Details {
  error: "AuthenticationFailure";
  reason: Reason;
}

abstract class AuthenticationFailureError extends Errors.MassiveDecksError<
  Details
> {
  public readonly status = HttpStatus.FORBIDDEN;
  abstract readonly reason: Reason;

  protected constructor(reason: string) {
    super(`Could not authenticate for the game, ${reason}.`);
    Error.captureStackTrace(this, AuthenticationFailureError);
  }

  public details = (): Details => ({
    error: "AuthenticationFailure",
    reason: this.reason,
  });
}

// Could happen if the server database is lost.
export class IncorrectIssuerError extends AuthenticationFailureError {
  public readonly reason = "IncorrectIssuer";

  public constructor() {
    super(
      "the authentication was not for this server or the server data store " +
        "has been wiped"
    );
    Error.captureStackTrace(this, IncorrectIssuerError);
  }
}

export class NotAuthenticatedError extends AuthenticationFailureError {
  public readonly reason = "NotAuthenticated";

  public constructor() {
    super("the player is not authenticated");
    Error.captureStackTrace(this, NotAuthenticatedError);
  }
}

export class AlreadyAuthenticatedError extends AuthenticationFailureError {
  public readonly reason = "AlreadyAuthenticated";

  public constructor() {
    super("the player is already authenticated");
    Error.captureStackTrace(this, AlreadyAuthenticatedError);
  }
}

// Could happen if the server database is lost.
export class InvalidAuthenticationError extends AuthenticationFailureError {
  public readonly reason = "InvalidAuthentication";

  public constructor(reason: string) {
    super(`the given authentication was not valid (${reason})`);
    Error.captureStackTrace(this, InvalidAuthenticationError);
  }
}

// If the user already left the game.
export class AlreadyLeftError extends AuthenticationFailureError {
  public readonly reason = "AlreadyLeftError";

  public constructor() {
    super("the user has already left the game");
    Error.captureStackTrace(this, AlreadyLeftError);
  }
}

// If the user gets the password wrong.
export class InvalidLobbyPasswordError extends AuthenticationFailureError {
  public readonly reason = "InvalidLobbyPassword";

  public constructor() {
    super("the given lobby password was wrong");
    Error.captureStackTrace(this, InvalidLobbyPasswordError);
  }
}
