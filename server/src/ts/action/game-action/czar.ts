import * as Action from "../../action";
import * as Lobby from "../../lobby";
import * as Token from "../../user/token";
import * as GameAction from "../game-action";
import * as Actions from "../actions";
import * as Judge from "./czar/judge";
import * as Reveal from "./czar/reveal";

/**
 * An action only the czar can perform.
 */
export type Czar = Judge.Judge | Reveal.Reveal;

class CzarActions extends Actions.Group<
  Action.Action,
  Czar,
  Lobby.WithActiveGame,
  Lobby.WithActiveGame
> {
  constructor() {
    super(Judge.actions, Reveal.actions);
  }

  limit(
    auth: Token.Claims,
    lobby: Lobby.WithActiveGame,
    action: Czar
  ): lobby is Lobby.WithActiveGame {
    GameAction.expectRole(auth, action, lobby.game, "Czar");
    return true;
  }
}

export const actions = new CzarActions();
