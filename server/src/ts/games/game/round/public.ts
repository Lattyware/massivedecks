import * as user from "../../../user";
import * as card from "../../cards/card";
import { Play } from "../../cards/play";
import * as play from "../../cards/play";
import * as player from "../../player";

export type Public = Playing | Revealing | Judging | Complete;

interface Base {
  stage: string;
  id: string;
  czar: user.Id;
  players: user.Id[];
  call: card.Call;
  startedAt: number;
}

interface Timed {
  timedOut?: boolean;
}

export interface Playing extends Base, Timed {
  stage: "Playing";
  played: user.Id[];
}

export interface Revealing extends Base, Timed {
  stage: "Revealing";
  plays: play.PotentiallyRevealed[];
}

export interface Judging extends Base, Timed {
  stage: "Judging";
  plays: play.Revealed[];
}

export interface PlayWithLikes {
  play: Play;
  likes?: number;
}

export interface Complete extends Base {
  stage: "Complete";
  winner: user.Id;
  plays: { [player: string]: PlayWithLikes };
  playOrder: user.Id[];
}

export interface PlayDetails {
  playedBy: user.Id;
  likes?: player.Likes;
}
