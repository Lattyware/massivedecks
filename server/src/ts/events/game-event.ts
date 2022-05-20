import type { CardDiscarded } from "./game-event/card-discarded.js";
import type { GameEnded } from "./game-event/game-ended.js";
import type { GameStarted } from "./game-event/game-started.js";
import type { HandRedrawn } from "./game-event/hand-redrawn.js";
import type { PauseStateChanged } from "./game-event/pause-state-changed.js";
import type { PlayLiked } from "./game-event/play-liked.js";
import type { PlayRevealed } from "./game-event/play-revealed.js";
import type { PlaySubmitted } from "./game-event/play-submitted.js";
import type { PlayTakenBack } from "./game-event/play-taken-back.js";
import type { PlayerPresenceChanged } from "./game-event/player-presence-changed.js";
import type { PlayingStarted } from "./game-event/playing-started.js";
import type { RoundFinished } from "./game-event/round-finished.js";
import type { RoundStarted } from "./game-event/round-started.js";
import type { StageTimerDone } from "./game-event/stage-timer-done.js";
import type { StartJudging } from "./game-event/start-judging.js";
import type { StartRevealing } from "./game-event/start-revealing.js";

export type GameEvent =
  | GameStarted
  | StartRevealing
  | StartJudging
  | RoundStarted
  | PlayingStarted
  | RoundFinished
  | PlaySubmitted
  | PlayRevealed
  | PlayTakenBack
  | HandRedrawn
  | CardDiscarded
  | PlayerPresenceChanged
  | PauseStateChanged
  | StageTimerDone
  | GameEnded
  | PlayLiked;
