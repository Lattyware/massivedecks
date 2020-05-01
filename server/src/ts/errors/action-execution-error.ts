import HttpStatus from "http-status-codes";
import { Action } from "../action";
import { GameAction } from "../action/game-action";
import { Privileged } from "../action/privileged";
import * as Errors from "../errors";
import * as Round from "../games/game/round";
import * as Player from "../games/player";
import * as User from "../user";
import * as Source from "../games/cards/source";

abstract class ActionExecutionError extends Errors.MassiveDecksError<
  Errors.Details
> {
  public readonly status: number = HttpStatus.BAD_REQUEST;
  public readonly action: Action;

  protected constructor(message: string, action: Action) {
    super(message);
    this.action = action;
    Error.captureStackTrace(this, ActionExecutionError);
  }
}

// Could happen if the game ends.
export class GameNotStartedError extends ActionExecutionError {
  public constructor(action: GameAction) {
    super(
      `The game must be started for this action:\n ${JSON.stringify(action)}`,
      action
    );
    Error.captureStackTrace(this, GameNotStartedError);
  }

  public details = (): Errors.Details => ({
    error: "GameNotStarted",
  });
}

// Could happen if the user has privileges removed.
export class UnprivilegedError extends ActionExecutionError {
  public readonly status = HttpStatus.FORBIDDEN;

  public constructor(action: Privileged) {
    super(
      `The user does not have the privilege to perform this action:\n` +
        `${JSON.stringify(action)}`,
      action
    );
    Error.captureStackTrace(this, UnprivilegedError);
  }

  public details = (): Errors.Details => ({
    error: "Unprivileged",
  });
}

interface IncorrectPlayerRoleDetails extends Errors.Details {
  role: Player.Role | null;
  expected: Player.Role;
}

// Could happen if the round changes unexpectedly (e.g: czar leaves game).
export class IncorrectPlayerRoleError extends ActionExecutionError {
  public readonly role: Player.Role | null;
  public readonly expected: Player.Role;

  public constructor(
    action: Action,
    role: Player.Role | null,
    expected: Player.Role
  ) {
    super(
      `For this action the player must be ${expected} but is ${role}:\n` +
        `${JSON.stringify(action)}`,
      action
    );
    this.role = role;
    this.expected = expected;
    Error.captureStackTrace(this, UnprivilegedError);
  }

  public details = (): IncorrectPlayerRoleDetails => ({
    error: "IncorrectPlayerRole",
    role: this.role,
    expected: this.expected,
  });
}

interface IncorrectUserRoleDetails extends Errors.Details {
  role: User.Role;
  expected: User.Role;
}

// Could happen if the user's role changes.
export class IncorrectUserRoleError extends ActionExecutionError {
  public readonly role: User.Role;
  public readonly expected: User.Role;

  public constructor(action: Action, role: User.Role, expected: User.Role) {
    super(
      `For this action the user must be ${expected} but is ${role}:\n` +
        `${JSON.stringify(action)}`,
      action
    );
    this.role = role;
    this.expected = expected;
    Error.captureStackTrace(this, IncorrectUserRoleError);
  }

  public details = (): IncorrectUserRoleDetails => ({
    error: "IncorrectUserRole",
    role: this.role,
    expected: this.expected,
  });
}

interface IncorrectRoundStageDetails extends Errors.Details {
  stage: Round.Stage;
  expected: Round.Stage[];
}

// Could happen if the round changes unexpectedly (e.g: czar leaves game).
export class IncorrectRoundStageError extends ActionExecutionError {
  public readonly stage: Round.Stage;
  public readonly expected: Round.Stage[];

  public constructor(
    action: Action,
    stage: Round.Stage,
    ...expected: Round.Stage[]
  ) {
    super(
      `For this action the round must be in the ${expected} stage but is in ` +
        `the ${stage} stage:\n ${JSON.stringify(action)}`,
      action
    );
    this.stage = stage;
    this.expected = expected;
    Error.captureStackTrace(this, IncorrectRoundStageError);
  }

  public details = (): IncorrectRoundStageDetails => ({
    error: "IncorrectRoundStage",
    stage: this.stage,
    expected: this.expected,
  });
}

interface ConfigEditConflictDetails extends Errors.Details {
  version: string;
  expected: string;
}

// Could happen if two users edit the configuration at the same time.
export class ConfigEditConflictError extends ActionExecutionError {
  public readonly status: number = HttpStatus.CONFLICT;
  public readonly version: string;
  public readonly expected: string;

  public constructor(action: Action, version: string, expected: string) {
    super(
      `The configuration is at version ${expected}, but the client's edit ` +
        `was made to version ${version}:\n ${JSON.stringify(action)}`,
      action
    );
    this.version = version;
    this.expected = expected;
    Error.captureStackTrace(this, ConfigEditConflictError);
  }

  public details = (): ConfigEditConflictDetails => ({
    error: "ConfigEditConflict",
    version: this.version,
    expected: this.expected,
  });
}

interface SourceErrorDetails extends Errors.Details {
  source: Source.External;
}

// Happens if the user asks for a deck that doesn't exist.
export class SourceNotFoundError extends ActionExecutionError {
  public readonly source: Source.External;

  public constructor(source: Source.External) {
    super(
      `The given deck (${source}) was not found at the source.`,
      (undefined as unknown) as Action
    );
    this.source = source;
    Error.captureStackTrace(this, SourceNotFoundError);
  }

  public details = (): SourceErrorDetails => ({
    error: "SourceServiceError",
    source: this.source,
  });
}

// Happens if the deck service is down.
export class SourceServiceError extends ActionExecutionError {
  public readonly source: Source.External;

  public constructor(source: Source.External) {
    super(
      `The given deck source (${source.source}) was not available.`,
      (undefined as unknown) as Action
    );
    this.source = source;
    Error.captureStackTrace(this, SourceServiceError);
  }

  public details = (): SourceErrorDetails => ({
    error: "SourceServiceError",
    source: this.source,
  });
}
