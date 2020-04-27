import * as Actions from "./../actions";
import * as Like from "./player/like";
import * as Submit from "./player/submit";
import * as TakeBack from "./player/take-back";
import * as Fill from "./player/fill";

/**
 * An action only players can perform.
 */
export type Player = Submit.Submit | TakeBack.TakeBack | Like.Like | Fill.Fill;

export const actions = new Actions.PassThroughGroup(
  Submit.actions,
  TakeBack.actions,
  Like.actions,
  Fill.actions
);
