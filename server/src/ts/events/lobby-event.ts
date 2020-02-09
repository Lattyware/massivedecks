import { Configured } from "./lobby-event/configured";
import { ConnectionChanged } from "./lobby-event/connection-changed";
import { ErrorEncountered } from "./lobby-event/error-encountered";
import { PresenceChanged } from "./lobby-event/presence-changed";
import { PrivilegeChanged } from "./lobby-event/privilege-changed";
import { UserRoleChanged } from "./lobby-event/user-role-changed";

export type LobbyEvent =
  | Configured
  | ConnectionChanged
  | PresenceChanged
  | PrivilegeChanged
  | UserRoleChanged
  | ErrorEncountered;
