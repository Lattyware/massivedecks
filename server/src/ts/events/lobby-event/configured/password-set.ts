import * as configured from "../configured";

/**
 * The lobby password is (un)set.
 */
export interface PasswordSet extends configured.Base {
  event: "PasswordSet";
  password?: string;
}

export const of = (version: string, password?: string): PasswordSet => ({
  event: "PasswordSet",
  version: version,
  ...(password !== undefined ? { password } : {})
});
