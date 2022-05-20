import type { Configured } from "./lobby-event/configured.js";
import type { ConnectionChanged } from "./lobby-event/connection-changed.js";
import type { ErrorEncountered } from "./lobby-event/error-encountered.js";
import type { PresenceChanged } from "./lobby-event/presence-changed.js";
import type { PrivilegeChanged } from "./lobby-event/privilege-changed.js";
import type { UserRoleChanged } from "./lobby-event/user-role-changed.js";

export type LobbyEvent =
  | Configured
  | ConnectionChanged
  | PresenceChanged
  | PrivilegeChanged
  | UserRoleChanged
  | ErrorEncountered;
