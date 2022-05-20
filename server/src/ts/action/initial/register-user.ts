import { InvalidActionError } from "../../errors/validation.js";
import type * as User from "../../user.js";
import * as Validation from "../validation.validator.js";

/**
 * The details to register a new user for a lobby.
 */
export interface RegisterUser {
  /**
   * The name the user wishes to use.
   * @minLength 1
   * @maxLength 100
   */
  name: User.Name;
  /**
   * The lobby password, if there is one, this must be given and correct.
   * @minLength 1
   * @maxLength 100
   */
  password?: string;
}

const _validateRegisterUser = Validation.validate("RegisterUser");
export const validate = (action: object): RegisterUser => {
  try {
    return _validateRegisterUser(action);
  } catch (e) {
    const error = e as Error;
    throw new InvalidActionError(error.message);
  }
};
