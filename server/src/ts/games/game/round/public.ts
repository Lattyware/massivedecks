import type * as User from "../../../user.js";
import type * as Card from "../../cards/card.js";
import type * as Play from "../../cards/play.js";
import type * as Player from "../../player.js";

export type Public = Starting | Playing | Revealing | Judging | Complete;

interface Base {
  stage: string;
  id: string;
  czar: User.Id;
  players: User.Id[];
  startedAt: number;
}

interface Timed {
  timedOut?: boolean;
}

export interface Starting extends Base, Timed {
  stage: "Starting";
}

export interface Playing extends Base, Timed {
  stage: "Playing";
  call: Card.Call;
  played: User.Id[];
}

export interface LikeDetail {
  liked: Play.Id[];
  played?: Play.Id;
}

export interface Revealing extends Base, Timed {
  stage: "Revealing";
  call: Card.Call;
  plays: Play.PotentiallyRevealed[];
}

export interface Judging extends Base, Timed {
  stage: "Judging";
  call: Card.Call;
  plays: Play.Revealed[];
}

export interface PlayWithDetails {
  play: Play.Play;
  playedBy: User.Id;
  likes?: Player.Likes;
}

export interface Complete extends Base {
  stage: "Complete";
  call: Card.Call;
  winner: User.Id;
  plays: { [id: string]: PlayWithDetails };
  playOrder: Play.Id[];
}

export interface PlayDetails {
  playedBy: User.Id;
  likes?: Player.Likes;
}
