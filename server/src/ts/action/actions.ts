import wu from "wu";
import { Action } from "../action";
import { InvalidActionError } from "../errors/validation";
import { Lobby } from "../lobby";
import { Change } from "../lobby/change";
import { ServerState } from "../server-state";
import * as Token from "../user/token";
import * as Handler from "./handler";

export interface Actions<Parent extends Action, ParentLobby extends Lobby> {
  is: (action: Action) => boolean;

  tryHandle: (
    auth: Token.Claims,
    lobby: ParentLobby,
    action: Parent,
    server: ServerState
  ) => Change | undefined;
}

export abstract class Implementation<
  ParentType extends Action,
  Type extends ParentType & { action: Name },
  Name extends string,
  ParentLobby extends Lobby
> implements Actions<ParentType, ParentLobby> {
  protected abstract readonly name: Name;

  // Should be Action, broken due to https://github.com/microsoft/TypeScript/pull/37195
  // TODO: Better fix.
  public is(action: unknown): action is Type {
    return (action as Action).action === this.name;
  }

  // Should be Type, broken due to https://github.com/microsoft/TypeScript/pull/37195
  // TODO: Better fix.
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  protected abstract handle: Handler.Custom<any, ParentLobby>;

  public tryHandle(
    auth: Token.Claims,
    lobby: ParentLobby,
    action: Action,
    server: ServerState
  ): Change | undefined {
    if (this.is(action)) {
      return this.handle(auth, lobby, action, server);
    }
    return undefined;
  }
}

/**
 * A group of actions that shares a common type and limited applicable game state.
 */
export abstract class Group<
  ParentType extends Action,
  Type extends ParentType,
  ParentLobby extends Lobby,
  LimitedLobby extends ParentLobby
> implements Actions<ParentType, LimitedLobby> {
  private readonly childActions: Actions<Type, LimitedLobby>[];

  protected constructor(...childActions: Actions<Type, LimitedLobby>[]) {
    this.childActions = childActions;
  }

  is(action: Action): action is Type {
    return wu(this.childActions).some((child) => child.is(action));
  }

  abstract limit(
    auth: Token.Claims,
    lobby: ParentLobby,
    action: Type,
    server: ServerState
  ): lobby is LimitedLobby;

  tryHandle(
    auth: Token.Claims,
    lobby: ParentLobby,
    action: Action,
    server: ServerState
  ): Change | undefined {
    if (this.is(action)) {
      if (this.limit(auth, lobby, action, server)) {
        for (const child of this.childActions) {
          const change = child.tryHandle(auth, lobby, action, server);
          if (change !== undefined) {
            return change;
          }
        }
        throw new Error(`Unhandled action ${action} in ${this}.`);
      } else {
        throw new InvalidActionError("Game state not valid for action.");
      }
    }
    return undefined;
  }
}

/**
 * A group that doesn't limit down the game state.
 */
export class PassThroughGroup<
  Type extends Action,
  ParentLobby extends Lobby
> extends Group<Type, Type, ParentLobby, ParentLobby> {
  constructor(...childActions: Actions<Type, ParentLobby>[]) {
    super(...childActions);
  }

  public limit(
    auth: Token.Claims,
    lobby: ParentLobby,
    action: Type,
    server: ServerState
  ): lobby is ParentLobby {
    return true;
  }
}
