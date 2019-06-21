import { GameStarted } from "./game-event/game-started";
import { HandRedrawn } from "./game-event/hand-redrawn";
import { PlayRevealed } from "./game-event/play-revealed";
import { PlaySubmitted } from "./game-event/play-submitted";
import { PlayTakenBack } from "./game-event/play-taken-back";
import { RoundFinished } from "./game-event/round-finished";
import { RoundStarted } from "./game-event/round-started";
import { StartRevealing } from "./game-event/start-revealing";

export type GameEvent =
  | GameStarted
  | StartRevealing
  | RoundStarted
  | RoundFinished
  | PlaySubmitted
  | PlayRevealed
  | PlayTakenBack
  | HandRedrawn;
