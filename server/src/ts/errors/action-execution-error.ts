import HttpStatus from "http-status-codes";
import { Action } from "../action";
import { GameAction } from "../action/game-action";
import { Privileged } from "../action/privileged";
import * as errors from "../errors";
import * as round from "../games/game/round";
import * as player from "../games/player";
import * as user from "../user";

abstract class ActionExecutionError extends errors.MassiveDecksError<
  errors.Details
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

  public details = (): errors.Details => ({
    error: "GameNotStarted"
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

  public details = (): errors.Details => ({
    error: "Unprivileged"
  });
}

interface IncorrectPlayerRoleDetails extends errors.Details {
  role: player.Role;
  expected: player.Role;
}

// Could happen if the round changes unexpectedly (e.g: czar leaves game).
export class IncorrectPlayerRoleError extends ActionExecutionError {
  public readonly role: player.Role;
  public readonly expected: player.Role;

  public constructor(action: Action, role: player.Role, expected: player.Role) {
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
    expected: this.expected
  });
}

interface IncorrectUserRoleDetails extends errors.Details {
  role: user.Role;
  expected: user.Role;
}

// Could happen if the user's role changes.
export class IncorrectUserRoleError extends ActionExecutionError {
  public readonly role: user.Role;
  public readonly expected: user.Role;

  public constructor(action: Action, role: user.Role, expected: user.Role) {
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
    expected: this.expected
  });
}

interface IncorrectRoundStageDetails extends errors.Details {
  stage: round.Stage;
  expected: round.Stage;
}

// Could happen if the round changes unexpectedly (e.g: czar leaves game).
export class IncorrectRoundStageError extends ActionExecutionError {
  public readonly stage: round.Stage;
  public readonly expected: round.Stage;

  public constructor(
    action: Action,
    stage: round.Stage,
    expected: round.Stage
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
    expected: this.expected
  });
}

interface ConfigEditConflictDetails extends errors.Details {
  version: string;
  expected: string;
}

// Could happen if two users edit the configuration at the same time.
export class ConfigEditConflictError extends ActionExecutionError {
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
    expected: this.expected
  });
}
