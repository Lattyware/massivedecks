import * as user from "../../user";

/**
 * Promotes a user to be privileged.
 */
export interface PrivilegeChanged {
  event: "PrivilegeChanged";
  user: user.Id;
  privilege: user.Privilege;
}

export const of = (
  user: user.Id,
  privilege: user.Privilege
): PrivilegeChanged => ({
  event: "PrivilegeChanged",
  user,
  privilege
});
