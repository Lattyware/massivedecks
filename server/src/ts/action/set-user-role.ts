import type { Action } from "../action.js";
import { UnprivilegedError } from "../errors/action-execution-error.js";
import * as Event from "../event.js";
import * as UserRoleChanged from "../events/lobby-event/user-role-changed.js";
import * as Player from "../games/player.js";
import type * as Lobby from "../lobby.js";
import type * as Timeout from "../timeout.js";
import type * as User from "../user.js";
import * as Actions from "./actions.js";
import type * as Handler from "./handler.js";
import type { Privileged } from "./privileged.js";

/**
 * A player asks to leave the game.
 */
export interface SetUserRole {
  action: "SetUserRole";
  id?: User.Id;
  role: User.Role;
}

class SetUserRoleActions extends Actions.Implementation<
  Action,
  SetUserRole,
  "SetUserRole",
  Lobby.Lobby
> {
  protected readonly name = "SetUserRole";

  protected handle: Handler.Custom<SetUserRole, Lobby.Lobby> = (
    auth,
    lobby,
    action,
    server,
  ) => {
    const userId = action.id === undefined ? auth.uid : action.id;
    const targetUser = lobby.users[userId] as User.User;
    const oldRole = targetUser.role;
    const newRole = action.role;
    const additionalMap = new Map();

    const allEvents: Event.Distributor[] = [];
    const allTimeouts: Timeout.After[] = [];

    const addResult = (eventsAndTimeouts: {
      events?: Iterable<Event.Distributor>;
      timeouts?: Iterable<Timeout.After>;
    }): void => {
      const { events, timeouts } = eventsAndTimeouts;
      if (events) {
        allEvents.push(...events);
      }
      if (timeouts) {
        allTimeouts.push(...timeouts);
      }
    };

    if (
      lobby.users[auth.uid]?.privilege !== "Privileged" &&
      (userId !== auth.uid || lobby.config.audienceMode)
    ) {
      throw new UnprivilegedError(action as unknown as Privileged);
    }

    if (oldRole !== newRole) {
      targetUser.role = newRole;
      if (lobby.game !== undefined) {
        const game = lobby.game;
        if (newRole === "Spectator") {
          if (game.round.players.has(userId)) {
            addResult(game.removeFromRound(userId, server));
          }
          if (game.round.czar === userId) {
            addResult(game.startNewRound(server, lobby));
          }
          const player = game.players[userId];
          if (player !== undefined) {
            game.decks.responses.discard(player.hand);
            delete game.players[userId];
          }
        }
        if (newRole === "Player") {
          if (!Object.hasOwn(game.players, userId)) {
            const hand = game.decks.responses.draw(game.rules.handSize);
            additionalMap.set(auth.uid, { hand });
            game.players[userId] = Player.initial(hand);
          }
        }
      }
      return {
        lobby,
        events: [
          Event.additionally(
            UserRoleChanged.of(userId, action.role),
            additionalMap,
          ),
          ...allEvents,
        ],
        timeouts: allTimeouts,
      };
    } else {
      return {};
    }
  };
}

export const actions = new SetUserRoleActions();
