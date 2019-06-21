import { Configured } from "./lobby-event/configured";
import { ConnectionChanged } from "./lobby-event/connection-changed";
import { PresenceChanged } from "./lobby-event/presence-changed";

export type LobbyEvent = Configured | ConnectionChanged | PresenceChanged;
