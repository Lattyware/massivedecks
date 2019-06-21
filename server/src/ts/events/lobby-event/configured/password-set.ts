import * as configured from "../configured";

/**
 * The lobby password is (un)set.
 */
export interface PasswordSet extends configured.Base {
  event: "PasswordSet";
  password?: string | boolean;
}

export const censor = (passwordSet: PasswordSet): PasswordSet => ({
  event: "PasswordSet",
  version: passwordSet.version,
  password: passwordSet.password !== undefined
});
