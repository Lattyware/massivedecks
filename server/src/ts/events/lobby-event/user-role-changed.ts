import * as Card from "../../games/cards/card";
import * as User from "../../user";

/**
 * Indicates the role for a user has changed.
 */
export interface UserRoleChanged {
  event: "UserRoleChanged";
  user: User.Id;
  role: User.Role;
  hand?: Card.Response[];
}

export const of = (user: User.Id, role: User.Role): UserRoleChanged => ({
  event: "UserRoleChanged",
  user,
  role,
});
