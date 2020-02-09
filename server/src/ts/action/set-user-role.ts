import { Action } from "../action";
import * as Event from "../event";
import * as UserRoleChanged from "../events/lobby-event/user-role-changed";
import * as Player from "../games/player";
import * as Lobby from "../lobby";
import * as Timeout from "../timeout";
import * as User from "../user";
import * as Actions from "./actions";
import * as Handler from "./handler";

/**
 * A player asks to leave the game.
 */
export interface SetUserRole {
  action: "SetUserRole";
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
    server
  ) => {
    const userId = auth.uid;
    const callingUser = lobby.users.get(userId) as User.User;
    const oldRole = callingUser.role;
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

    if (oldRole !== newRole) {
      callingUser.role = newRole;
      if (lobby.game !== undefined) {
        const game = lobby.game;
        if (newRole === "Spectator") {
          if (game.round.players.has(userId)) {
            addResult(game.removeFromRound(userId, server));
          }
          if (game.round.czar === userId) {
            addResult(game.startNewRound(server, lobby));
          }
          const player = game.players.get(userId);
          if (player !== undefined) {
            game.decks.responses.discard(player.hand);
            game.players.delete(userId);
          }
        }
        if (newRole === "Player") {
          if (!game.players.has(userId)) {
            const hand = game.decks.responses.draw(game.rules.handSize);
            additionalMap.set(auth.uid, { hand });
            game.players.set(userId, new Player.Player(hand));
          }
        }
      }
      return {
        lobby,
        events: [
          Event.additionally(
            UserRoleChanged.of(userId, action.role),
            additionalMap
          ),
          ...allEvents
        ],
        timeouts: allTimeouts
      };
    } else {
      return {};
    }
  };
}

export const actions = new SetUserRoleActions();
