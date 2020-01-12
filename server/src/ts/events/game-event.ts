import { GameStarted } from "./game-event/game-started";
import { HandRedrawn } from "./game-event/hand-redrawn";
import { PauseStateChanged } from "./game-event/pause-state-changed";
import { PlayRevealed } from "./game-event/play-revealed";
import { PlaySubmitted } from "./game-event/play-submitted";
import { PlayTakenBack } from "./game-event/play-taken-back";
import { PlayerPresenceChanged } from "./game-event/player-presence-changed";
import { RoundFinished } from "./game-event/round-finished";
import { RoundStarted } from "./game-event/round-started";
import { StageTimerDone } from "./game-event/stage-timer-done";
import { StartRevealing } from "./game-event/start-revealing";

export type GameEvent =
  | GameStarted
  | StartRevealing
  | RoundStarted
  | RoundFinished
  | PlaySubmitted
  | PlayRevealed
  | PlayTakenBack
  | HandRedrawn
  | PlayerPresenceChanged
  | PauseStateChanged
  | StageTimerDone;
