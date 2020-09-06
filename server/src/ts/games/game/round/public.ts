import * as User from "../../../user";
import * as Card from "../../cards/card";
import * as Play from "../../cards/play";
import * as Player from "../../player";

export type Public = Playing | Revealing | Judging | Complete;

interface Base {
  stage: string;
  id: string;
  czar: User.Id;
  players: User.Id[];
  call: Card.Call;
  startedAt: number;
}

interface Timed {
  timedOut?: boolean;
}

export interface Playing extends Base, Timed {
  stage: "Playing";
  played: User.Id[];
}

export interface LikeDetail {
  liked: Play.Id[];
  played?: Play.Id;
}

export interface Revealing extends Base, Timed {
  stage: "Revealing";
  plays: Play.PotentiallyRevealed[];
}

export interface Judging extends Base, Timed {
  stage: "Judging";
  plays: Play.Revealed[];
}

export interface PlayWithDetails {
  play: Play.Play;
  playedBy: User.Id;
  likes?: Player.Likes;
}

export interface Complete extends Base {
  stage: "Complete";
  winner: User.Id;
  plays: { [id: string]: PlayWithDetails };
  playOrder: Play.Id[];
}

export interface PlayDetails {
  playedBy: User.Id;
  likes?: Player.Likes;
}
