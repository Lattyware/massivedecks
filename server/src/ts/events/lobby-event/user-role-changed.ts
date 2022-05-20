import type * as Card from "../../games/cards/card.js";
import type * as User from "../../user.js";

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
