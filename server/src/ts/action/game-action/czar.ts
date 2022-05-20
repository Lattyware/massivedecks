import type * as Action from "../../action.js";
import type * as Lobby from "../../lobby.js";
import type * as Token from "../../user/token.js";
import * as Actions from "../actions.js";
import * as GameAction from "../game-action.js";
import * as Judge from "./czar/judge.js";
import * as PickCall from "./czar/pick-call.js";
import * as Reveal from "./czar/reveal.js";

/**
 * An action only the czar can perform.
 */
export type Czar = Judge.Judge | PickCall.PickCall | Reveal.Reveal;

class CzarActions extends Actions.Group<
  Action.Action,
  Czar,
  Lobby.WithActiveGame,
  Lobby.WithActiveGame
> {
  constructor() {
    super(Judge.actions, PickCall.actions, Reveal.actions);
  }

  limit(
    auth: Token.Claims,
    lobby: Lobby.WithActiveGame,
    action: Czar,
  ): lobby is Lobby.WithActiveGame {
    GameAction.expectRole(auth, action, lobby.game, "Czar");
    return true;
  }
}

export const actions = new CzarActions();
