import HttpStatus from "http-status-codes";
import * as Errors from "../errors";

export type Reason = "UsernameAlreadyInUse";

export interface Details extends Errors.Details {
  error: "Registration";
  reason: Reason;
}

abstract class RegistrationError<MoreDetails> extends Errors.MassiveDecksError<
  Details & MoreDetails
> {
  public readonly status: number = HttpStatus.CONFLICT;
  protected abstract readonly reason: Reason;

  protected constructor(message: string) {
    super(message);
    Error.captureStackTrace(this, RegistrationError);
  }

  protected abstract moreDetails(): MoreDetails;

  public details(): Details & MoreDetails {
    return {
      error: "Registration",
      reason: this.reason,
      ...this.moreDetails(),
    };
  }
}

export interface UsernameDetails {
  username: string;
}

export class UsernameAlreadyInUseError extends RegistrationError<
  UsernameDetails
> {
  protected readonly reason = "UsernameAlreadyInUse";
  private readonly username: string;

  public constructor(username: string) {
    super(`The username “${username}” is already in use.`);
    this.username = username;
  }

  protected moreDetails(): UsernameDetails {
    return {
      username: this.username,
    };
  }
}
