import * as Actions from "./../actions";
import * as Submit from "./player/submit";
import * as TakeBack from "./player/take-back";
import * as Fill from "./player/fill";
import * as Discard from "./player/discard";
import * as Action from "../../action";
import * as Lobby from "../../lobby";
import * as Token from "../../user/token";
import * as GameAction from "../game-action";

/**
 * An action only players can perform.
 */
export type Player =
  | Submit.Submit
  | TakeBack.TakeBack
  | Fill.Fill
  | Discard.Discard;

class PlayerActions extends Actions.Group<
  Action.Action,
  Player,
  Lobby.WithActiveGame,
  Lobby.WithActiveGame
> {
  constructor() {
    super(Submit.actions, TakeBack.actions, Fill.actions, Discard.actions);
  }

  limit(
    auth: Token.Claims,
    lobby: Lobby.WithActiveGame,
    action: Player
  ): lobby is Lobby.WithActiveGame {
    GameAction.expectRole(auth, action, lobby.game, "Player");
    return true;
  }
}

export const actions = new PlayerActions();
