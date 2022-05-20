import type * as User from "../../user.js";

/**
 * Indicates a user's level of privilege has changed.
 */
export interface PrivilegeChanged {
  event: "PrivilegeChanged";
  user: User.Id;
  privilege: User.Privilege;
}

export const of = (
  user: User.Id,
  privilege: User.Privilege,
): PrivilegeChanged => ({
  event: "PrivilegeChanged",
  user,
  privilege,
});
