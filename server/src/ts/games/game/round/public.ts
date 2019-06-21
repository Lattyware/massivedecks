import * as user from "../../../user";
import * as card from "../../cards/card";
import { Play } from "../../cards/play";
import * as play from "../../cards/play";

export type Public = Playing | Revealing | Judging | Complete;

interface Base {
  stage: string;
  id: string;
  czar: user.Id;
  players: user.Id[];
  call: card.Call;
}

export interface Playing extends Base {
  stage: "Playing";
  played: user.Id[];
}

export interface Revealing extends Base {
  stage: "Revealing";
  plays: play.PotentiallyRevealed[];
}

export interface Judging extends Base {
  stage: "Judging";
  plays: play.Revealed[];
}

export interface Complete extends Base {
  stage: "Complete";
  winner: user.Id;
  plays: { [player: string]: Play };
}
